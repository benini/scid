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

#ifndef CODEC_MEMORY_H
#define CODEC_MEMORY_H

#include "bytebuf.h"
#include "codec.h"
#include "common.h"
#include "index.h"
#include "namebase.h"
#include <algorithm>
#include <iterator>
#include <vector>

#if !CPP11_SUPPORT
#define override
#endif

/**
 * class CodecMemory - class for in-memory databases
 *
 * This class manages in-memory databases that do not have associated files.
 * By default this class stores game's data into a std::vector; a derived
 * class may store the data into a different container overriding the
 * virtual functions dyn_addGameData() and getGameData().
 */
class CodecMemory : public ICodecDatabase {
protected:
	Index* idx_;
	NameBase* nb_;

private:
	std::vector<byte> v_;
	ByteBuffer bbuf_;

public:
	CodecMemory() : idx_(0), nb_(0), bbuf_(BBUF_SIZE) {}

	virtual Codec getType() override { return ICodecDatabase::MEMORY; }

	/**
	* CodecMemory::getFilenames() - return the files used by the database
	*
	* Return an empty vector (memory databases do not use files)
	*/
	virtual std::vector<std::string> getFilenames() override {
		return std::vector<std::string>();
	}

	/**
	* CodecMemory::getGameData() - get a game's data from the database
	* @offset: offset of the requested game
	* @length: length in bytes of the game's data
	*
	* This function returns the data (excluding index info) of a game, encoded
	* in native format, stored inside the member vector v_.
	* Return a pointer to the requested data or 0 on error.
	*/
	virtual const byte* getGameData(uint offset, uint length) override {
		const byte* res = 0;
		if (offset + length <= v_.size()) {
			res = v_.data() + offset;
		}
		return res;
	}

	/**
	* CodecMemory::add/saveGame() - add/replace a game into the database
	* @ie:  valid pointer to the IndexEntry with new header data of the game.
	* @src: valid pointer to a buffer containing the new game's data of the
	*       game (encoded in native format).
	* @length: length in bytes of buffer @src
	* @replaced: valid gamenumT of the game to be replaced
	*
	* This functions add/replace a game into the database.
	* Return OK if successful or an error code.
	*/
	virtual errorT addGame(IndexEntry* ie, const byte* src, size_t length) override {
		return doAddGame(ie, src, length);
	}
	virtual errorT saveGame(IndexEntry* ie, const byte* src, size_t length,
	                        gamenumT replaced) override {
		return doAddGame(ie, src, length, true, replaced);
	}

	/**
	* CodecMemory::add/saveGame() - add/replace a game into the database
	* @game: valid pointer to a Game object with the new data.
	* @replaced: valid gamenumT of the game to be replaced
	*
	* This functions encode the data into native format and then add/replace
	* a game into the database.
	* Return OK if successful or an error code.
	*/
	virtual errorT addGame(Game* game) override {
		IndexEntry ie;
		errorT err = encodeGame(game, &ie, &bbuf_);
		if (err != OK) return err;

		return doAddGame(&ie, bbuf_.getData(), bbuf_.GetByteCount());
	}
	virtual errorT saveGame(Game* game, gamenumT replaced) override {
		IndexEntry ie;
		errorT err = encodeGame(game, &ie, &bbuf_);
		if (err != OK) return err;

		return doAddGame(&ie, bbuf_.getData(), bbuf_.GetByteCount(), true, replaced);
	}

	/**
	* CodecMemory::flush() - flush pending changes
	*
	* This function do nothing (memory databases do not have unwritten data).
	* Return OK.
	*/
	virtual errorT flush() override {
		return OK;
	}

protected:
	/**
	* CodecMemory::dyn_open() - open/create the database
	* @fMode: must be FMODE_Memory
	* @idx:   valid pointer to the Index object of this database
	* @nb:    valid pointer to the NameBase object corresponding to @idx
	*
	* This function stores the pointers to Index's objects into member variables
	* idx_ and nb_ and makes the database ready for use.
	* Return OK if successful or an error code.
	*/
	virtual errorT dyn_open(fileModeT fMode, const char*, const Progress&,
	                        Index* idx, NameBase* nb) override {
		if (idx == 0 || nb == 0) return ERROR;
		if (fMode != FMODE_Memory) return ERROR;
		idx_ = idx;
		nb_ = nb;
		return OK;
	}

	/**
	* CodecMemory::dyn_addGameData() - add a game's data to the database
	* @src:       valid pointer to a buffer containing the data to add
	*             (encoded in native format).
	* @length:    length in bytes of buffer @src
	* @resOffset: reference to the variable that, on success, will obtain
	*             the corresponding offset for the game.
	*
	* This function stores the game's data into member std::vector v_.
	* A derivate class can override this function to store the game's data
	* into a different container (in that case must override the virtual
	* function getGameData() too).
	* Return OK if successful and set @resOffset to the corresponding offset,
	* or an error code.
	*/
	virtual errorT dyn_addGameData(const byte* src, size_t length,
	                               uint& resOffset) {
		ASSERT(src != 0);

		size_t maxmem = v_.size() + length;
		if (maxmem != static_cast<uint32_t>(maxmem)) return ERROR_BufferFull;

		resOffset = v_.size();
		std::copy(src, src + length, std::back_inserter(v_));
		return OK;
	}

private:
	/**
	* CodecMemory::doAddGame() - add/replace a game into the database
	* @ie:  valid pointer to the IndexEntry with new header data of the game.
	* @src: valid pointer to a buffer containing the new game's data of the
	*       game (encoded in native format).
	* @length: length in bytes of buffer @src
	* @replace: false to add a game or true to replace an existing one.
	* @replaced: valid gamenumT of the game to be replaced (used only when
	*            @replace is true).
	*
	* This function add/replace a game into the database.
	* Stores the new game's data and obtain the corresponding offset with a
	* call to the virtual function dyn_addGameData().
	* The offset obtained and the length of the game's data are stored in @ie,
	* and the game will be added/replaced in the Index object idx_.
	* Return OK if successful or an error code.
	*/
	errorT doAddGame(IndexEntry* ie, const byte* src, size_t length,
	                 bool replace = false, gamenumT replaced = 0) {
		if (replace && replaced >= idx_->GetNumGames()) return ERROR_BadArg;

		uint offset;
		errorT err = dyn_addGameData(src, length, offset);
		if (err != OK) return err;

		ie->SetOffset(offset);
		ie->SetLength(length);

		if (replace)
			return idx_->WriteEntry(ie, replaced);
		else
			return idx_->AddGame(ie);
	}

	/**
	* CodecMemory::encodeGame() - encode a Game object into native format
	* @game:    valid pointer to the Game object to encode
	* @resIe:   valid pointer to the IndexEntry object that will receive
	*           the encoded header's data.
	* @resBBuf: valid pointer to the ByteBuffer object that will receive
	*           the encoded game's data.
	*
	* This function encodes a Game object into native format.
	* If necessary names are added to the NameBase object pointed by nb_.
	* Return OK if successful or an error code.
	*/
	errorT encodeGame(Game* game, IndexEntry* resIe, ByteBuffer* resBbuf) {
		resIe->Init();
		errorT err = game->Encode(resBbuf, resIe);
		if (err != OK) return err;

		err = resIe->SetWhiteName(nb_, game->GetWhiteStr());
		if (err != OK) return err;
		err = resIe->SetBlackName(nb_, game->GetBlackStr());
		if (err != OK) return err;
		err = resIe->SetEventName(nb_, game->GetEventStr());
		if (err != OK) return err;
		err = resIe->SetSiteName(nb_, game->GetSiteStr());
		if (err != OK) return err;
		err = resIe->SetRoundName(nb_, game->GetRoundStr());
		if (err != OK) return err;

		nb_->AddElo(resIe->GetWhite(), resIe->GetWhiteElo());
		nb_->AddElo(resIe->GetBlack(), resIe->GetBlackElo());

		return err;
	}
};

#if !CPP11_SUPPORT
#undef override
#endif

#endif
