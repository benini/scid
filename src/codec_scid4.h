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
#include "gfile.h"

#if !CPP11_SUPPORT
#define override
#endif

/**
 * This class manages databases encoded in Scid format v4.
 */
class CodecScid4 : public CodecMemory {
	GFile gfile_;
	std::string filename_;

public:
	virtual ~CodecScid4() { flush(); }

	virtual Codec getType() override { return ICodecDatabase::SCID4; }

	/**
	* Returns the full path of the three files (index, namebase and gamefile)
	* used by the database.
	*/
	virtual std::vector<std::string> getFilenames() override {
		std::vector<std::string> res;
		res.push_back(filename_ + INDEX_SUFFIX);
		res.push_back(filename_ + NameBase::Suffix());
		res.push_back(filename_ + GFILE_SUFFIX);
		return res;
	};

	virtual const byte* getGameData(uint32_t offset, uint32_t length) override {
		return gfile_.getGame(offset, length);
	}

	virtual errorT flush() override {
		errorT err = CodecMemory::flush();
		if (err != OK) return err;

		err = idx_->flush();
		if (err == OK) err = nb_->flush(idx_);
		errorT errGfile = gfile_.flush();

		return (err == OK) ? errGfile : err;
	}

protected:
	virtual errorT dyn_open(fileModeT fMode, const char* filename,
	                        const Progress& progress, Index* idx,
	                        NameBase* nb) override {
		if (filename == 0 || idx == 0 || nb == 0) return ERROR;

		errorT err = CodecMemory::dyn_open(FMODE_Memory, 0, progress, idx, nb);
		if (err != OK) return err;

		filename_ = filename;
		if (filename_.empty()) return ERROR_FileOpen;

		if (fMode == FMODE_Create) {
			err = idx->Create(filename);
			if (err == OK) err = nb->Create(filename);
			if (err == OK) err = gfile_.Create(filename);
		} else {
			err = idx->Open(filename, fMode);
			if (err == OK) err = gfile_.Open(filename, fMode);
			if (err == OK) err = nb->ReadEntireFile(filename);
			if (err == OK) err = idx->ReadEntireFile(nb, progress);
		}

		return err;
	}

	virtual errorT dyn_addGameData(const byte* src, size_t length,
	                               uint32_t& resOffset) override {
		return gfile_.addGame(src, length, resOffset);
	}
};

#if !CPP11_SUPPORT
#undef override
#endif

#endif
