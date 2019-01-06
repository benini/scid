/*
 * Copyright (C) 2017  Fulvio Benini

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
 * Implements @e CodecNative, which is used as base class by native codecs.
 */

#ifndef CODEC_NATIVE_H
#define CODEC_NATIVE_H

#include "bytebuf.h"
#include "codec.h"
#include "game.h"
#include "index.h"
#include "namebase.h"

/**
 * This class stores the pointers to the @e Index and @e NameBase objects used
 * by a native codec. It also implements the addGame() and saveGame() functions
 * of the ICodecDatabase interface, splitting them into 2 function calls to a
 * derived class (CRTP technique):
 * - dyn_addName() should return the ID corresponding to a name, eventually
 *   adding the name to the @e nb_ if necessary;
 * - dyn_addGameData() should stores the data of the game, encoded in native
 *   format, and returns the offset that can be used to retrieve the data.
 */
template <typename Derived> class CodecNative : public ICodecDatabase {
protected:
	Index* idx_;
	NameBase* nb_;
	ByteBuffer bbuf_;

protected:
	CodecNative() : idx_(0), nb_(0), bbuf_(BBUF_SIZE) {}

public: // ICodecDatabase interface
	errorT addGame(const IndexEntry* srcIe, const NameBase* srcNb,
	               const byte* srcData, size_t dataLen) override {
		IndexEntry ie = *srcIe;
		errorT err = addGameHelper(
		    &ie, srcData, dataLen,
		    srcNb->GetName(NAME_PLAYER, srcIe->GetWhite()),
		    srcNb->GetName(NAME_PLAYER, srcIe->GetBlack()),
		    srcNb->GetName(NAME_EVENT, srcIe->GetEvent()),
		    srcNb->GetName(NAME_SITE, srcIe->GetSite()),
		    srcNb->GetName(NAME_ROUND, srcIe->GetRound()));
		if (err != OK)
			return err;

		return derived()->dyn_addIndexEntry(ie);
	}

	errorT addGame(Game* game) override {
		std::pair<errorT, IndexEntry> ie = addGameHelper(game);
		if (ie.first != OK)
			return ie.first;

		return derived()->dyn_addIndexEntry(ie.second);
	}

	errorT saveGame(Game* game, gamenumT replaced) override {
		if (replaced >= idx_->GetNumGames())
			return ERROR_BadArg;

		std::pair<errorT, IndexEntry> ie = addGameHelper(game);
		if (ie.first != OK)
			return ie.first;

		return derived()->dyn_saveIndexEntry(ie.second, replaced);
	}

	errorT saveIndexEntry(const IndexEntry& ie, gamenumT replaced) override {
		return derived()->dyn_saveIndexEntry(ie, replaced);
	}

	std::pair<errorT, idNumberT> addName(nameT nt, const char* name) override {
		return derived()->dyn_addName(nt, name);
	}

private:
	std::pair<errorT, IndexEntry> addGameHelper(Game* game) {
		std::pair<errorT, IndexEntry> res;
		res.second.Init();
		res.first = game->Encode(&bbuf_, &res.second);
		if (res.first == OK) {
			res.first = addGameHelper(&res.second, bbuf_.getData(),
			                          bbuf_.GetByteCount(), game->GetWhiteStr(),
			                          game->GetBlackStr(), game->GetEventStr(),
			                          game->GetSiteStr(), game->GetRoundStr());
		}
		return res;
	}

	errorT addGameHelper(IndexEntry* ie, const byte* srcData, size_t dataLen,
	                     const char* white, const char* black,
	                     const char* event, const char* site,
	                     const char* round) {
		auto id = derived()->dyn_addName(NAME_PLAYER, white);
		if (id.first != OK)
			return id.first;
		ie->SetWhite(id.second);
		nb_->AddElo(id.second, ie->GetWhiteElo());

		id = derived()->dyn_addName(NAME_PLAYER, black);
		if (id.first != OK)
			return id.first;
		ie->SetBlack(id.second);
		nb_->AddElo(id.second, ie->GetBlackElo());

		id = derived()->dyn_addName(NAME_EVENT, event);
		if (id.first != OK)
			return id.first;
		ie->SetEvent(id.second);

		id = derived()->dyn_addName(NAME_SITE, site);
		if (id.first != OK)
			return id.first;
		ie->SetSite(id.second);

		id = derived()->dyn_addName(NAME_ROUND, round);
		if (id.first != OK)
			return id.first;
		ie->SetRound(id.second);

		auto offset = derived()->dyn_addGameData(srcData, dataLen);
		if (offset.first == OK) {
			ie->SetOffset(offset.second);
			ie->SetLength(dataLen);
		}
		return offset.first;
	}

	Derived* derived() { return static_cast<Derived*>(this); }
};

#endif
