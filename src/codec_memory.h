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
 * Implements the CodecMemory class, which manages the memory representation of
 * the open databases.
 */

#ifndef CODEC_MEMORY_H
#define CODEC_MEMORY_H

#include "bytebuf.h"
#include "codec.h"
#include "common.h"
#include "game.h"
#include "index.h"
#include "namebase.h"
#include <vector>
#include <limits>

#if !CPP11_SUPPORT
#define override
#endif

/**
 * Manages memory databases that do not have associated files.
 * This class stores the data of the games into a std::vector; derived classes
 * can override the virtual functions dyn_addGameData() and getGameData() in
 * order to store the data into a different container or file.
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

	Codec getType() override { return ICodecDatabase::MEMORY; }

	std::vector<std::string> getFilenames() override {
		return std::vector<std::string>();
	}

	const byte* getGameData(uint32_t offset, uint32_t length) override {
		ASSERT(offset < v_.size());
		ASSERT(length <= v_.size() - offset);
		return v_.data() + offset;
	}

	errorT addGame(IndexEntry* ie, const byte* src, size_t length) override {
		return doAddGame(ie, src, length);
	}

	errorT saveGame(IndexEntry* ie, const byte* src, size_t length,
	                gamenumT replaced) override {
		return doAddGame(ie, src, length, true, replaced);
	}

	errorT addGame(Game* game) override {
		IndexEntry ie;
		errorT err = encodeGame(game, &ie, &bbuf_);
		if (err != OK) return err;

		return doAddGame(&ie, bbuf_.getData(), bbuf_.GetByteCount());
	}

	errorT saveGame(Game* game, gamenumT replaced) override {
		IndexEntry ie;
		errorT err = encodeGame(game, &ie, &bbuf_);
		if (err != OK) return err;

		return doAddGame(&ie, bbuf_.getData(), bbuf_.GetByteCount(), true, replaced);
	}

	errorT flush() override {
		return OK;
	}

protected:
	errorT dyn_open(fileModeT fMode, const char*, const Progress&, Index* idx,
	                NameBase* nb) override {
		if (idx == 0 || nb == 0) return ERROR;
		if (fMode != FMODE_Memory) return ERROR;
		idx_ = idx;
		nb_ = nb;
		return OK;
	}

	/**
	 * Stores the data of the game into the database.
	 * A derived class can override this function to store the data into a
	 * different container or file. In that case it must also override the
	 * virtual function getGameData().
	 * @param src:    valid pointer to a buffer that contains the game data
	 *                (encoded in native format).
	 * @param length: the length of the buffer @p src (in bytes).
	 * @returns
	 * - on success, a @e std::pair containing OK and the offset of the stored
	 * data (usable to retrieve the data with getGameData()).
	 * - on failure, a @e std::pair containing an error code and 0.
	 */
	virtual std::pair<errorT, uint32_t> dyn_addGameData(const byte* src,
	                                                    size_t length) {
		ASSERT(src != 0);

		if (v_.size() >= std::numeric_limits<uint32_t>::max())
			return std::make_pair(ERROR_Full, 0);

		uint32_t offset = v_.size();
		v_.insert(v_.end(), src, src + length);
		return std::make_pair(OK, offset);
	}

private:
	CodecMemory(const CodecMemory&);
	CodecMemory& operator=(const CodecMemory&);

	/**
	 * Add/Replace a game into the database.
	 * Calls the virtual function dyn_addGameData() to store the game data and
	 * obtain the corresponding offset. The offset and the @p length are stored
	 * in @p ie; then the game will be added/replaced in the Index object idx_.
	 * @param ie:       valid pointer to the new header data of the game.
	 * @param src:      valid pointer to the new game data of the game.
	 * @param length:   length of the game data (in bytes).
	 * @param replace:  false to add a game or true to replace an existing one.
	 * @param replaced: valid gamenumT of the game to be replaced (used only
	 *                  when @p replace is true).
	 * @returns OK if successful or an error code.
	 */
	errorT doAddGame(IndexEntry* ie, const byte* src, size_t length,
	                 bool replace = false, gamenumT replaced = 0) {
		if (replace && replaced >= idx_->GetNumGames()) return ERROR_BadArg;

		std::pair<errorT, uint32_t> offset = dyn_addGameData(src, length);
		if (offset.first != OK)
			return offset.first;
		ie->SetOffset(offset.second);
		ie->SetLength(length);

		if (replace)
			return idx_->WriteEntry(ie, replaced);
		else
			return idx_->AddGame(ie);
	}

	/**
	 * Encodes a Game object to native format.
	 * The names are added to the member NameBase object @p nb_, if necessary.
	 * @param game:         valid pointer to the Game object to be encoded.
	 * @param[out] resIe:   valid pointer to the IndexEntry object that will
	 *                      receive the encoded header data.
	 * @param[out] resBBuf: valid pointer to the ByteBuffer object that will
	 *                      receive the encoded games data.
	 * @returns OK if successful or an error code.
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
