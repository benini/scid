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
 * Implements the CodecScid4 class, which manages the databases encoded
 * in Scid format version 4.
 */

#ifndef CODEC_SCID4_H
#define CODEC_SCID4_H

#include "codec_memory.h"
#include "common.h"
#include "filebuf.h"

#if !CPP11_SUPPORT
#define override
#endif

/**
 * This class manages databases encoded in Scid format v4.
 */
class CodecScid4 : public CodecMemory {
	std::string filename_;
	FilebufAppend gfile_;
	char gamecache_[128*1024];

public:
	Codec getType() override { return ICodecDatabase::SCID4; }

	/**
	 * Returns the full path of the three files (index, namebase and gamefile)
	 * used by the database.
	 */
	std::vector<std::string> getFilenames() override {
		std::vector<std::string> res;
		res.push_back(filename_ + INDEX_SUFFIX);
		res.push_back(filename_ + NameBase::Suffix());
		res.push_back(filename_ + ".sg4");
		return res;
	};

	const byte* getGameData(uint32_t offset, uint32_t length) override {
		if (offset >= gfile_.size())
			return NULL;
		if (length > sizeof(gamecache_))
			return NULL;

		if (gfile_.pubseekpos(offset) == -1)
			return NULL;
		if (gfile_.sgetn(gamecache_, length) != std::streamsize(length))
			return NULL;

		return reinterpret_cast<const byte*>(gamecache_);
	}

	errorT flush() override {
		errorT err = CodecMemory::flush();
		if (err != OK) return err;

		err = idx_->flush();
		if (err == OK) {
			// *** Compatibility ***
			// Even if name's frequency is no longer used, it's necessary to
			// keep the compatibility with older Scid versions, forcing a
			// recalculation.
			nb_->hackedNameFreq();
			err = nb_->flush(idx_);
		}
		errorT errGfile = (gfile_.pubsync() == 0) ? OK : ERROR_FileWrite;

		return (err == OK) ? errGfile : err;
	}

protected:
	errorT dyn_open(fileModeT fMode, const char* filename,
	                const Progress& progress, Index* idx,
	                NameBase* nb) override {
		if (filename == 0 || idx == 0 || nb == 0) return ERROR;

		errorT err = CodecMemory::dyn_open(FMODE_Memory, 0, progress, idx, nb);
		if (err != OK) return err;

		filename_ = filename;
		if (filename_.empty()) return ERROR_FileOpen;

		err = gfile_.open(filename_ + ".sg4", fMode);
		if (err != OK) return err;

		if (fMode == FMODE_Create) {
			err = idx->Create(filename);
			if (err == OK) err = nb->Create(filename);
		} else {
			err = idx->Open(filename, fMode);
			if (err == OK) err = nb->ReadEntireFile(filename);
			if (err == OK) err = idx->ReadEntireFile(nb, progress);
		}

		return err;
	}

	std::pair<errorT, uint32_t> dyn_addGameData(const byte* src,
	                                            size_t length) override {
		ASSERT(src != 0);
		const char* data = reinterpret_cast<const char*>(src);

		// The Scid4 format uses 32-bits to store games' offset.
		size_t offset = gfile_.size();
		static const uint32_t MAXSZ = std::numeric_limits<uint32_t>::max();
		if (offset >= MAXSZ || length >= MAXSZ - offset)
			return std::make_pair(ERROR_Full, 0);

		// The Scid4 format stores games into blocks of 128KB.
		// If the current block does not have enough space, we fill it with
		// random data and use the next one.
		static const size_t GF_BLOCK = 128 * 1024;
		if (length > GF_BLOCK)
			return std::make_pair(ERROR_Full, 0);
		size_t blockSpace = GF_BLOCK - (offset % GF_BLOCK);
		if (blockSpace < length) {
			errorT err = gfile_.append(data, blockSpace);
			if (err != OK)
				return std::make_pair(err, 0);
			offset += blockSpace;
		}

		errorT err = gfile_.append(data, length);
		return std::make_pair(err, uint32_t(offset));
	}
};

#if !CPP11_SUPPORT
#undef override
#endif

#endif
