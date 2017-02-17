/*
# Copyright (C) 2016 Fulvio Benini

* This file is part of Scid (Shane's Chess Information Database).
*
* Scid is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation.
*
* Scid is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Scid. If not, see <http://www.gnu.org/licenses/>.
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
 * class CodecScid4 - class for Scid format version 4.
 *
 * This class manages databases encoded using Scid format version 4.
 */
class CodecScid4 : public CodecMemory {
	GFile gfile_;
	std::string filename_;

public:
	virtual ~CodecScid4() { flush(); }

	virtual Codec getType() override { return ICodecDatabase::SCID4; }

	/**
	* CodecScid4::getFilenames() - returns the files used by the database
	*
	* Return the full path of the three files (index, namebase and gamefile)
	* used by the database.
	*/
	virtual std::vector<std::string> getFilenames() override {
		std::vector<std::string> res;
		res.push_back(filename_ + INDEX_SUFFIX);
		res.push_back(filename_ + NameBase::Suffix());
		res.push_back(filename_ + GFILE_SUFFIX);
		return res;
	};

	/**
	* CodecScid4::getGameData() - get a game's data from the database
	* @offset: offset of the requested game
	* @length: length in bytes of the game's data
	*
	* This function returns the data (excluding index info) of a game, encoded
	* in native format, stored inside the member GFile object gfile_.
	* Return a pointer to the requested data or 0 on error.
	*/
	virtual const byte* getGameData(uint32_t offset, uint32_t length) override {
		return gfile_.getGame(offset, length);
	}

	/**
	* CodecScid4::flush() - flush pending changes
	*
	* This function flushes all the files.
	* Return OK or an error code.
	*/
	virtual errorT flush() override {
		errorT err = CodecMemory::flush();
		if (err != OK) return err;

		err = idx_->flush();
		if (err == OK) err = nb_->flush(idx_);
		errorT errGfile = gfile_.flush();

		return (err == OK) ? errGfile : err;
	}

protected:
	/**
	* CodecScid4::dyn_open() - open/create the database
	* @fMode:    a valid file mode.
	* @filename: the full path of the database to open.
	* @progress: a Progress object used for GUI communications.
	* @idx:      valid pointer to the Index object of this database
	* @nb:       valid pointer to the NameBase object corresponding to @idx
	*
	* Open/create a database and make it ready to be used.
	* Return:
	* - OK: the object is ready to be used.
	* - ERROR_NameDataLoss: some names are corrupted and cannot be recovered,
	*                       however the object can still be used.
	* - Other error codes: the operation failed (the object should be destroyed).
	*/
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

	/**
	* CodecScid4::dyn_addGameData() - add a game's data to the database
	* @src:       valid pointer to a buffer containing the data to add
	*             (encoded in native format).
	* @length:    length in bytes of buffer @src
	* @resOffset: reference to the variable that, on success, will obtain
	*             the corresponding offset for the game.
	*
	* This function stores the game's data into the member GFile object gfile_.
	* Return OK if successful and set @resOffset to the corresponding offset,
	* or an error code.
	*/
	virtual errorT dyn_addGameData(const byte* src, size_t length,
	                               uint32_t& resOffset) override {
		return gfile_.addGame(src, length, resOffset);
	}
};

#if !CPP11_SUPPORT
#undef override
#endif

#endif
