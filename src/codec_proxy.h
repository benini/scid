/*
 * Copyright (C) 2016-2018  Fulvio Benini

 * This file is part of Scid (Shane's Chess Information Database).
 *
 * Scid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
 *
 * Scid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Scid.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/** @file
 * Implements the CodecProxy class, which serves as base class for non-native
 * databases.
 */

#ifndef CODEC_PROXY_H
#define CODEC_PROXY_H

#include "codec.h"
#include "codec_memory.h"
#include "game.h"

#include <atomic>
#include <thread>

/**
 * Base class for non-native databases.
 * Every class derived from ICodecDatabase must keep an @e Index object and the
 * corresponding @e NameBase object fully updated in memory.
 * This implies that the virtual function dyn_open() must load in memory the
 * header's data of all the games; however a dependency between the codecs and
 * the @e Index class is not desirable.
 * This class provides an interface that encapsulates the codecs, requiring only
 * the ability to exchange @e Game objects.
 */
template <typename Derived> class CodecProxy : public CodecMemory {
	Derived* getDerived() { return static_cast<Derived*>(this); }

	static constexpr const char* special_replace_tag = "__replace_game__";

public:
	/**
	 * Opens/creates a database encoded in a non-native format.
	 * @param filename: full path of the database to be opened.
	 * @param fMode:    valid file access mode.
	 * @returns OK in case of success, an @p errorT code otherwise.
	 */
	errorT open(const char* filename, fileModeT fMode);

	/**
	 * Reads the next game.
	 * A derived class implements this function to sequentially read the games
	 * contained into the database.
	 * @param Game&: the Game object where the data will be stored.
	 * @returns
	 * - ERROR_NotFound if there are no more games to be read.
	 * - OK otherwise.
	 */
	errorT parseNext(Game&) { return ERROR_NotFound; }

	/**
	 * Returns info about the parsing progress.
	 * @returns a pair<size_t, size_t> where first element is the quantity of
	 * data parsed and second one is the total amount of data of the database.
	 */
	std::pair<size_t, size_t> parseProgress() {
		return std::pair<size_t, size_t>(1, 1);
	}

	/**
	 * Returns the list of errors produced by parseNext() calls.
	 */
	const char* parseErrors() { return NULL; }

	/**
	 * Adds a game into the database.
	 * @param Game*: valid pointer to a Game object with the new data.
	 * @returns OK in case of success, an @p errorT code otherwise.
	 */
	errorT gameAdd(Game*) { return ERROR_CodecUnsupFeat; }

	/**
	 * Replaces a game in the database.
	 * @param Game*:    valid pointer to a Game object with the new data.
	 * @param gamenumT: valid gamenumT of the game to be replaced.
	 * @returns OK in case of success, an @p errorT code otherwise.
	 * If not overridden, adds a special tag and invoke gameAdd().
	 */
	errorT gameSave(Game* game, gamenumT replaced) {
		game->assignTagValue(special_replace_tag,
		                     std::strlen(special_replace_tag),
		                     std::to_string(replaced));
		return getDerived()->gameAdd(game);
	}

private:
	errorT saveGame(IndexEntry const& ie, TagRoster const& tags,
	                ByteBuffer const& data, gamenumT replaced) final {
		Game game;
		if (errorT err = game.Decode(ie, tags, data))
			return err;

		if (errorT err = getDerived()->gameSave(&game, replaced))
			return err;

		return CodecMemory::saveGame(ie, tags, data, replaced);
	}

	errorT addGame(IndexEntry const& ie, TagRoster const& tags,
	               ByteBuffer const& data) final {
		Game game;
		if (errorT err = game.Decode(ie, tags, data))
			return err;

		if (errorT err = getDerived()->gameAdd(&game))
			return err;

		return CodecMemory::addGame(ie, tags, data);
	}

	errorT saveIndexEntry(const IndexEntry& ie, gamenumT replaced) final {
		if (CodecMemory::equalExceptFlags(ie, replaced))
			return CodecMemory::saveIndexEntry(ie, replaced);

		return ERROR_CodecUnsupFeat;
	}

	std::pair<errorT, idNumberT> addName(nameT, const char*) final {
		return std::pair<errorT, idNumberT>(ERROR_CodecUnsupFeat, 0);
	}

	/*
	 * Create a memory database, open the non-native database @p filename and
	 * copy all the games into the memory database.
	 */
	errorT dyn_open(fileModeT fMode, const char* filename,
	                const Progress& progress, Index* idx, NameBase* nb) final {
		if (filename == 0)
			return ERROR;

		errorT err = CodecMemory::dyn_open(FMODE_Create, filename, progress,
		                                   idx, nb);
		if (err != OK)
			return err;

		err = getDerived()->open(filename, fMode);
		if (err != OK)
			return err;

		std::vector<byte> buf;
		return parseGames(progress, *getDerived(), [&](Game& game) {
			buf.clear();

			if (auto replace_game = game.FindExtraTag(special_replace_tag)) {
				auto gnum = std::strtoul(replace_game, NULL, 10);
				if (gnum < CodecMemory::numGames()) {
					game.RemoveExtraTag(special_replace_tag);
					auto [ie, tags] = game.Encode(buf);
					return CodecMemory::saveGame(
					    ie, tags, {buf.data(), buf.size()}, gnum);
				}
			}

			auto [ie, tags] = game.Encode(buf);
			return CodecMemory::addGame(ie, tags, {buf.data(), buf.size()});
		});
	}

public:
	/*
	 * Given a source database of type CodecProxy<T>, for each game a
	 * corresponding Game object is created and dispatched to @e destFn.
	 */
	template <typename TProgress, typename TSource, typename TDestFn>
	static errorT parseGames(const TProgress& progress, TSource& src,
	                         TDestFn destFn) {
		auto workTotal = src.parseProgress().second;

		Game game[4];
		std::atomic<size_t> workDone{};
		std::atomic<int8_t> sync[4] = {};
		enum { sy_free, sy_used, sy_stop };

		std::thread producer([&]() {
			uint64_t slot;
			uint64_t nProduced = 0;
			while (true) {
				slot = nProduced % 4;
				int sy;
				while (true) { // spinlock if the slot is in use
					sy = sync[slot].load(std::memory_order_acquire);
					if (sy == sy_used)
						std::this_thread::yield();
					else
						break;
				};
				if (sy == sy_stop)
					break;

				if (src.parseNext(game[slot]) == ERROR_NotFound)
					break;

				if (++nProduced % 1024 == 0) {
					workDone.store(src.parseProgress().first,
					               std::memory_order_release);
				}

				sync[slot].store(sy_used, std::memory_order_release);
			}
			sync[slot].store(sy_stop, std::memory_order_release);
		});

		// Consumer
		errorT err = OK;
		uint64_t slot;
		uint64_t nImported = 0;
		while (true) {
			slot = nImported % 4;
			int sy;
			while (true) { // spinlock if the slot is empty
				sy = sync[slot].load(std::memory_order_acquire);
				if (sy == sy_free)
					std::this_thread::yield();
				else
					break;
			};
			if (sy == sy_stop)
				break;

			if (++nImported % 1024 == 0) {
				if (!progress.report(workDone.load(std::memory_order_acquire),
				                     workTotal)) {
					err = ERROR_UserCancel;
					break;
				}
			}

			err = destFn(game[slot]);
			if (err != OK)
				break;

			sync[slot].store(sy_free, std::memory_order_release);
		}
		sync[slot].store(sy_stop, std::memory_order_release);

		producer.join();
		progress(1, 1, src.parseErrors());
		return err;
	}
};

#endif
