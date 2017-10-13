/*
 * Copyright (C) 2016-2017  Fulvio Benini

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
#include "common.h"
#include "game.h"

#ifndef MULTITHREADING_OFF
#include <atomic>
#include <thread>
#endif

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
template <typename Derived>
class CodecProxy : public CodecMemory {
protected:
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
	 * @param Game*: valid pointer to the Game object where the data will be stored.
	 * @returns
	 * - OK on success.
	 * - ERROR_NotFound if there are no more games to be read.
	 * - ERROR code if the game cannot be read and was skipped.
	 */
	errorT parseNext(Game*) {
		return ERROR_NotFound;
	}

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
	const char* parseErrors() {
		return NULL;
	}

	/**
	 * Adds a game into the database.
	 * @param Game*: valid pointer to a Game object with the new data.
	 * @returns OK in case of success, an @p errorT code otherwise.
	 */
	errorT dyn_addGame(Game*) {
		return ERROR_CodecUnsupFeat;
	}

	/**
	 * Replaces a game in the database.
	 * @param Game*:    valid pointer to a Game object with the new data.
	 * @param gamenumT: valid gamenumT of the game to be replaced.
	 * @returns OK in case of success, an @p errorT code otherwise.
	 */
	errorT dyn_saveGame(Game*, gamenumT) {
		return ERROR_CodecUnsupFeat;
	}


private:
	errorT addGame(Game* game) override {
		errorT err = getDerived()->dyn_addGame(game);
		if (err != OK) return err;

		return CodecMemory::addGame(game);
	}

	errorT saveGame(Game* game, gamenumT replaced) override {
		errorT err = getDerived()->dyn_saveGame(game, replaced);
		if (err != OK) return err;

		return CodecMemory::saveGame(game, replaced);
	}

	errorT addGame(const IndexEntry* srcIe, const NameBase* srcNb,
	               const byte* srcData, size_t dataLen) override {
		ByteBuffer buf(0);
		buf.ProvideExternal(const_cast<byte*>(srcData), dataLen);
		Game game;
		errorT err = game.Decode(&buf, GAME_DECODE_ALL);
		if (err == OK)
			err = game.LoadStandardTags(srcIe, srcNb);
		if (err != OK) return err;

		err = getDerived()->dyn_addGame(&game);
		if (err != OK) return err;

		return CodecMemory::addGame(srcIe, srcNb, srcData, dataLen);
	}

	/*
	 * Creates a memory database and invokes the function open(), which will
	 * open the non-native database @p filename. Subsequently, the function
	 * parseNext() is repeatedly called until it returns ERROR_NotFound, and
	 * the games are copied into the memory database.
	 */
	errorT dyn_open(fileModeT fMode, const char* filename,
	                const Progress& progress, Index* idx,
	                NameBase* nb) override {
		if (filename == 0) return ERROR;

		errorT err = CodecMemory::dyn_open(FMODE_Memory, filename, progress, idx, nb);
		if (err != OK) return err;

		err = getDerived()->open(filename, fMode);
		if (err != OK) return err;

#ifndef MULTITHREADING_OFF
		Game game[4];
		std::atomic<int8_t> sync[4] = {};
		enum {sy_free, sy_used, sy_stop};

		auto work = getDerived()->parseProgress();
		std::atomic<size_t> workDone(work.first);

		std::thread producer([this, &game, &sync, &workDone]() {
			uint64_t slot;
			for (uint64_t nProduced = 0; true;) {
				slot = nProduced % 4;
				int sy;
				do { // spinlock if the slot is in use
					sy = sync[slot].load(std::memory_order_acquire);
				} while (sy == sy_used);
				if (sy == sy_stop) break;

				errorT err = getDerived()->parseNext(&game[slot]);
				if (err == ERROR_NotFound) break;

				workDone.store(getDerived()->parseProgress().first,
				               std::memory_order_release);

				if (err == OK) { // Process only the games with no errors
					sync[slot].store(sy_used, std::memory_order_release);
					++nProduced;
				}
			}
			sync[slot].store(sy_stop, std::memory_order_release);
		});

		// Consumer
		uint64_t slot;
		for (uint64_t nImported = 0; true; ++nImported) {
			slot = nImported % 4;
			int sy;
			do { // spinlock if the slot is empty
				sy = sync[slot].load(std::memory_order_acquire);
			} while (sy == sy_free);
			if (sy == sy_stop) break;

			if (nImported % 1024 == 0) {
				if (!progress.report(workDone.load(std::memory_order_acquire),
				                     work.second)) {
					err = ERROR_UserCancel;
					break;
				}
			}

			err = CodecMemory::addGame(&game[slot]);
			if (err != OK) break;

			game[slot].Clear();
			sync[slot].store(sy_free, std::memory_order_release);
		}
		sync[slot].store(sy_stop, std::memory_order_release);

		producer.join();
		progress(1, 1, getDerived()->parseErrors());
		return err;

#else
		Game g;
		uint nImported = 0;
		while ((err = getDerived()->parseNext(&g)) != ERROR_NotFound) {
			if (err != OK) continue;

			err = CodecMemory::addGame(&g);
			if (err != OK) break;

			if (++nImported % 1024 == 0) {
				std::pair<size_t, size_t> count = getDerived()->parseProgress();
				if (!progress.report(count.first, count.second)) {
					err = ERROR_UserCancel;
					break;
				}
			}
		}
		progress(1, 1, getDerived()->parseErrors());

		return (err == ERROR_NotFound) ? OK : err;
#endif
	}

	/**
	 * Return a pointer to the derived class.
	 */
	Derived* getDerived() { return static_cast<Derived*>(this); }
};

#endif
