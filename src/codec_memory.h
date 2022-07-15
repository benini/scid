/*
 * Copyright (C) 2016-2021  Fulvio Benini

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
 * Implements the CodecMemory class, which represent a memory database.
 */

#ifndef CODEC_MEMORY_H
#define CODEC_MEMORY_H

#include "codec.h"
#include "index.h"
#include "namebase.h"

/**
 * Manages memory databases that do not have associated files.
 * Every open database should have a native representation in memory: to satisfy
 * this requirement non-native codecs should be derived from this class.
 */
class CodecMemory : public ICodecDatabase {
	Index* idx_ = nullptr;
	NameBase* nb_ = nullptr;
	VectorChunked<byte, 24> v_;
	unsigned baseType_ = 0;

	enum : uint64_t {
		LIMIT_GAMEOFFSET = 1ULL << 46,
		LIMIT_GAMELEN = 1ULL << 18,
		LIMIT_NUMGAMES = (1ULL << 32) - 2,
		LIMIT_UNIQUENAMES = 1ULL << 28,
		LIMIT_NAMELEN = 255
	};

public: // ICodecDatabase interface
	Codec getType() const override { return ICodecDatabase::MEMORY; }

	std::vector<std::string> getFilenames() const override {
		return std::vector<std::string>();
	}

	std::vector<std::pair<const char*, std::string>>
	getExtraInfo() const override {
		std::vector<std::pair<const char*, std::string>> res;
		res.emplace_back("type", std::to_string(baseType_));
		return res;
	}

	errorT setExtraInfo(const char* tagname, const char* new_value) override {
		if (std::strcmp(tagname, "type") == 0) {
			baseType_ = strGetUnsigned(new_value);
			return OK;
		}
		return ERROR_CodecUnsupFeat;
	}

	ByteBuffer getGameData(uint64_t offset, uint32_t length) final {
		ASSERT(offset < v_.size());
		ASSERT(length <= v_.size() - offset);
		ASSERT(v_.contiguous(static_cast<size_t>(offset)) >= length);

		return {&v_[offset], length};
	}

	ByteBuffer getGameMoves(IndexEntry const& ie) final {
		auto data = getGameData(ie.GetOffset(), ie.GetLength());
		if (data && OK == data.decodeTags([](auto, auto) {}))
			return data;

		return {nullptr, 0};
	}

	errorT addGame(IndexEntry const& ie_src, TagRoster const& tags,
	               ByteBuffer const& data) override {
		IndexEntry ie = ie_src;
		if (auto err = addGameNamesAndData(ie, tags, data.data(), data.size()))
			return err;

		return dyn_addIndexEntry(ie);
	}

	errorT saveGame(IndexEntry const& ie_src, TagRoster const& tags,
	                ByteBuffer const& data, gamenumT replaced) override {
		IndexEntry ie = ie_src;
		if (auto err = addGameNamesAndData(ie, tags, data.data(), data.size()))
			return err;

		return dyn_saveIndexEntry(ie, replaced);
	}

	errorT saveIndexEntry(const IndexEntry& ie, gamenumT replaced) override {
		return dyn_saveIndexEntry(ie, replaced);
	}

	std::pair<errorT, idNumberT> addName(nameT nt, const char* name) override {
		return dyn_addName(nt, name);
	}

	errorT flush() override { return OK; }

	errorT dyn_open(fileModeT fMode, const char*, const Progress&, Index* idx,
	                NameBase* nb) override {
		if (idx == 0 || nb == 0)
			return ERROR;
		if (fMode != FMODE_Create)
			return ERROR;
		idx_ = idx;
		nb_ = nb;
		return OK;
	}

private:
	/// Stores the data of a game into memory.
	/// @param src:    valid pointer to a buffer that contains the game data
	///                (encoded in native format).
	/// @param length: the length of the buffer @p src (in bytes).
	/// @returns
	/// - on success, a @e std::pair containing OK and the offset of the stored
	/// data (usable to retrieve the data with getGameData()).
	/// - on failure, a @e std::pair containing an error code and 0.
	std::pair<errorT, uint64_t> dyn_addGameData(const byte* src,
	                                            size_t length) {
		ASSERT(src != 0);

		if (length >= LIMIT_GAMELEN)
			return std::make_pair(ERROR_GameLengthLimit, 0);

		const auto offset = v_.next_contiguous(length);
		if (offset >= LIMIT_GAMEOFFSET)
			return std::make_pair(ERROR_OffsetLimit, 0);

		v_.append(src, length, offset);
		return {OK, offset};
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
		if (nb_->namebase_size(nt) < LIMIT_UNIQUENAMES)
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
		return OK;
	}

	/**
	 * Replace an IndexEntry.
	 * @param ie:       the IndexEntry with the new data.
	 * @param replaced: valid gamenumT of the game to be replaced.
	 * @returns OK if successful or an error code.
	 */
	errorT dyn_saveIndexEntry(const IndexEntry& ie, gamenumT replaced) {
		idx_->replaceEntry(ie, replaced);
		return OK;
	}

protected:
	bool equalExceptFlags(IndexEntry const& ie, gamenumT gnum) const {
		return idx_->GetEntry(gnum)->equalExceptFlags(ie);
	}

	auto numGames() const { return idx_->GetNumGames(); }

private:
	/// Add the game's roster tags and gamedata to the database.
	/// Set the references to the new data in @e ie.
	errorT addGameNamesAndData(IndexEntry& ie, TagRoster const& tags,
	                           const byte* srcData, size_t dataLen) {
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
};

#endif
