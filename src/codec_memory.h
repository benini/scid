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
 * Implements the CodecMemory class, which represent a memory database.
 */

#ifndef CODEC_MEMORY_H
#define CODEC_MEMORY_H

#include "codec_native.h"
#include <limits>

#if !CPP11_SUPPORT
#define override
#endif

/**
 * Manages memory databases that do not have associated files.
 * Every open database should have a native representation in memory: to satisfy
 * this requirement non-native codecs should be derived from this class.
 */
class CodecMemory : public CodecNative<CodecMemory> {
	std::vector<byte> v_;

public: // ICodecDatabase interface
	Codec getType() override { return ICodecDatabase::MEMORY; }

	std::vector<std::string> getFilenames() override {
		return std::vector<std::string>();
	}

	const byte* getGameData(uint32_t offset, uint32_t length) override {
		ASSERT(offset < v_.size());
		ASSERT(length <= v_.size() - offset);
		#if !CPP11_SUPPORT
		return &v_.front() + offset;
		#else
		return v_.data() + offset;
		#endif
	}

	errorT flush() override {
		return OK;
	}

	errorT dyn_open(fileModeT fMode, const char*, const Progress&, Index* idx,
	                NameBase* nb) override {
		if (idx == 0 || nb == 0) return ERROR;
		if (fMode != FMODE_Memory) return ERROR;
		idx_ = idx;
		nb_ = nb;
		return OK;
	}

public: // CodecNative CRTP
	/**
	 * Stores the data of a game into memory.
	 * @param src:    valid pointer to a buffer that contains the game data
	 *                (encoded in native format).
	 * @param length: the length of the buffer @p src (in bytes).
	 * @returns
	 * - on success, a @e std::pair containing OK and the offset of the stored
	 * data (usable to retrieve the data with getGameData()).
	 * - on failure, a @e std::pair containing an error code and 0.
	 */
	std::pair<errorT, uint32_t> dyn_addGameData(const byte* src,
	                                            size_t length) {
		ASSERT(src != 0);

		if (v_.size() >= std::numeric_limits<uint32_t>::max())
			return std::make_pair(ERROR_OffsetLimit, 0);

		uint32_t offset = v_.size();
		v_.insert(v_.end(), src, src + length);
		return std::make_pair(OK, offset);
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
	std::pair<errorT, idNumberT> dyn_getNameID(nameT nt, const char* name) {
		const size_t MAX_LEN = 255; // Max 255 chars;
		if (nt == NAME_PLAYER)
			return nb_->getID(nt, name, MAX_LEN, 1048575); // Maximum of 2^20 -1
		if (nt == NAME_ROUND)
			return nb_->getID(nt, name, MAX_LEN, 262143); // Maximum of 2^18 -1

		ASSERT(nt == NAME_EVENT || nt == NAME_SITE);
		return nb_->getID(nt, name, MAX_LEN, 524287); // Maximum of 2^19 -1
	}
};

#if !CPP11_SUPPORT
#undef override
#endif

#endif
