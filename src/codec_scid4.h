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
 * Implements the CodecSCID4 class that manages databases encoded in SCID
 * format v4.
 */

#ifndef CODEC_SCID4_H
#define CODEC_SCID4_H

#include "codec.h"
#include "filebuf.h"
#include "index.h"
#include "namebase.h"
#include <limits>

/**
 * This class manages databases encoded in SCID format v4.
 */
class CodecSCID4 : public ICodecDatabase {
	Index* idx_ = nullptr;
	NameBase* nb_ = nullptr;
	std::vector<std::string> filenames_;
	Filebuf idxfile_;
	FilebufAppend gfile_;
	char gamecache_[1ULL << 17];
	gamenumT seqWrite_ = 0;

	struct {
		std::string description; // a string describing the database.
		std::string flagDesc[6]; // short description (8 chars) for CUSTOM flags
		gamenumT autoLoad = 1;   // game number to autoload:
		                         // 0=none, 1=1st, >numGames=last
		uint32_t baseType = 0;   // Type, e.g. tournament, theory, etc.
		versionT version = SCID_VERSION; // version number. 2 bytes.
		bool dirty = false;
	} header_;

	enum : uint64_t {
		LIMIT_GAMEOFFSET = 1ULL << 32,
		LIMIT_GAMELEN = 1ULL << 17,
		LIMIT_NUMGAMES = 16777214ULL, // Three bytes -1 because GetAutoLoad uses
		                              // 0 to mean "no autoload"
		LIMIT_NAMELEN = 255
	};

public: // ICodecDatabase interface
	Codec getType() const final { return ICodecDatabase::SCID4; }

	/**
	 * Returns the full path of the three files (index, namebase and gamefile)
	 * used by the database.
	 */
	std::vector<std::string> getFilenames() const final { return filenames_; };

	std::vector<std::pair<const char*, std::string>>
	getExtraInfo() const final {
		std::vector<std::pair<const char*, std::string>> res;
		res.emplace_back("type", std::to_string(header_.baseType));
		res.emplace_back("description", header_.description);
		const auto autoload = std::min(header_.autoLoad, idx_->GetNumGames());
		res.emplace_back("autoload", std::to_string(autoload));
		res.emplace_back("flag1", header_.flagDesc[0]);
		res.emplace_back("flag2", header_.flagDesc[1]);
		res.emplace_back("flag3", header_.flagDesc[2]);
		res.emplace_back("flag4", header_.flagDesc[3]);
		res.emplace_back("flag5", header_.flagDesc[4]);
		res.emplace_back("flag6", header_.flagDesc[5]);
		return res;
	}

	errorT setExtraInfo(const char* tagname, const char* new_value) override;

	ByteBuffer getGameData(uint64_t offset, uint32_t length) final {
		if (offset >= gfile_.size())
			return {nullptr, 0};
		if (length >= LIMIT_GAMELEN)
			return {nullptr, 0};

		if (gfile_.pubseekpos(offset) == -1)
			return {nullptr, 0};
		if (gfile_.sgetn(gamecache_, length) != std::streamsize(length))
			return {nullptr, 0};

		return {reinterpret_cast<const byte*>(gamecache_), length};
	}

	ByteBuffer getGameMoves(IndexEntry const& ie) final {
		auto data = getGameData(ie.GetOffset(), ie.GetLength());
		if (data && OK == data.decodeTags([](auto, auto) {}))
			return data;

		return {nullptr, 0};
	}

	errorT addGame(IndexEntry const& ie_src, TagRoster const& tags,
	               ByteBuffer const& data) final {
		IndexEntry ie = ie_src;
		if (auto err = addGameNamesAndData(ie, tags, data.data(), data.size()))
			return err;

		return dyn_addIndexEntry(ie);
	}

	errorT saveGame(IndexEntry const& ie_src, TagRoster const& tags,
	                ByteBuffer const& data, gamenumT replaced) final {
		IndexEntry ie = ie_src;
		if (auto err = addGameNamesAndData(ie, tags, data.data(), data.size()))
			return err;

		return dyn_saveIndexEntry(ie, replaced);
	}

	errorT saveIndexEntry(const IndexEntry& ie, gamenumT replaced) final {
		return dyn_saveIndexEntry(ie, replaced);
	}

	std::pair<errorT, idNumberT> addName(nameT nt, const char* name) final {
		return dyn_addName(nt, name);
	}

	errorT flush() final;

	errorT dyn_open(fileModeT, const char*, const Progress&, Index*,
	                NameBase*) final;

private:
	/**
	 * Stores the data into the .sg4 file.
	 * @param src:    valid pointer to a buffer that contains the game data
	 *                (encoded in native format).
	 * @param length: the length of the buffer @e src (in bytes).
	 * @returns
	 * - on success, a @e std::pair containing OK and the offset of the stored
	 *   data (needed for retrieving the data with getGameData()).
	 * - on failure, a @e std::pair containing an error code and 0.
	 */
	std::pair<errorT, uint64_t> dyn_addGameData(const byte* src,
	                                            size_t length) {
		ASSERT(src != 0);
		const char* data = reinterpret_cast<const char*>(src);

		if (length >= LIMIT_GAMELEN)
			return std::make_pair(ERROR_GameLengthLimit, 0);

		// The SCID4 format uses 32-bits to store games' offset.
		uint64_t offset = gfile_.size();
		if (offset >= LIMIT_GAMEOFFSET - length)
			return std::make_pair(ERROR_OffsetLimit, 0);

		// The SCID4 format stores games into blocks of 128KB.
		// If the current block does not have enough space, we fill it with
		// random data and use the next one.
		uint64_t blockSpace = LIMIT_GAMELEN - (offset % LIMIT_GAMELEN);
		if (blockSpace < length) {
			errorT err = gfile_.append(data, blockSpace);
			if (err != OK)
				return std::make_pair(err, 0);
			offset += blockSpace;
		}

		errorT err = gfile_.append(data, length);
		return std::make_pair(err, offset);
	}

	/**
	 * Given a name (string), retrieve the corresponding ID.
	 * The name is added to @e nb_ if do not already exists in the NameBase.
	 * @param nt:   nameT type of the name to retrieve.
	 * @param name: the name to retrieve.
	 * @returns
	 * - on success, a @e std::pair containing OK and the ID.
	 * - on failure, a @e std::pair containing an error code and 0.
	 */
	std::pair<errorT, idNumberT> dyn_addName(nameT nt, const char* name) {
		if (std::string_view(name).size() > LIMIT_NAMELEN)
			return {ERROR_NameTooLong, 0};

		static constexpr auto limit_unique_names = [] {
			std::array<unsigned long long, NUM_NAME_TYPES> res;
			res[NAME_PLAYER] = 1048575; // Maximum of 2^20 -1 = 1,048,575
			res[NAME_EVENT] = 524287;   // Maximum of 2^19 -1 =   524,287
			res[NAME_SITE] = 524287;    // Maximum of 2^19 -1 =   524,287
			res[NAME_ROUND] = 262143;   // Maximum of 2^18 -1 =   262,143
			return res;
		}();
		if (nb_->namebase_size(nt) < limit_unique_names[nt])
			return {OK, nb_->namebase_find_or_add(nt, name)};

		idNumberT id;
		if (nb_->FindExactName(nt, name, &id) == OK)
			return {OK, id};

		return {ERROR_NameLimit, 0};
	}

	/**
	 * Add an IndexEntry to @e idx_.
	 * @param ie: the IndexEntry object to add.
	 * @returns OK if successful or an error code.
	 */
	errorT dyn_addIndexEntry(const IndexEntry& ie) {
		const auto nGames = idx_->GetNumGames();
		if (nGames >= LIMIT_NUMGAMES)
			return ERROR_NumGamesLimit;

		idx_->addEntry(ie);
		header_.dirty = true;
		return writeEntry(ie, nGames);
	}

	/**
	 * Replace an IndexEntry.
	 * @param ie:       the IndexEntry with the new data.
	 * @param replaced: valid gamenumT of the game to be replaced.
	 * @returns OK if successful or an error code.
	 */
	errorT dyn_saveIndexEntry(const IndexEntry& ie, gamenumT replaced) {
		idx_->replaceEntry(ie, replaced);
		return writeEntry(ie, replaced);
	}

	/// Add the game's roster tags and gamedata to the database.
	/// Set the references to the new data in @e ie.
	errorT addGameNamesAndData(IndexEntry& ie, TagRoster const& tags,
	                           const byte* srcData, size_t dataLen) {
		if (!ie.isChessStd())
			return ERROR_CodecChess960;

		auto errNames = tags.map(
		    ie, [&](auto nt, auto name) { return dyn_addName(nt, name); });
		if (errNames)
			return errNames;

		auto [err, offset] = dyn_addGameData(srcData, dataLen);
		if (!err) {
			ie.SetOffset(offset);
			ie.SetLength(dataLen);
		}
		return err;
	}

	errorT readIndex(gamenumT nGames, Progress const& progress);

	errorT writeEntry(const IndexEntry& ie, gamenumT gnum);
};

#endif
