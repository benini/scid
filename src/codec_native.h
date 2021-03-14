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
#include <vector>

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
	Index* idx_ = nullptr;
	NameBase* nb_ = nullptr;
	std::vector<byte> bbuf_;

public: // ICodecDatabase interface
	errorT addGame(IndexEntry const& ie, NameBase const& nb,
	               ByteBuffer const& data) override {
		IndexEntry ie_new = ie;
		errorT err = addGameHelper(&ie_new, data.data(), data.size(),
		                           nb.GetName(NAME_PLAYER, ie.GetWhite()),
		                           nb.GetName(NAME_PLAYER, ie.GetBlack()),
		                           nb.GetName(NAME_EVENT, ie.GetEvent()),
		                           nb.GetName(NAME_SITE, ie.GetSite()),
		                           nb.GetName(NAME_ROUND, ie.GetRound()));
		if (err != OK)
			return err;

		return derived()->dyn_addIndexEntry(ie_new);
	}

	errorT addGame(Game* game) override {
		bbuf_.clear();
		IndexEntry ie;
		auto err = game->Encode(bbuf_, ie);
		if (err)
			return err;

		err = addGameHelper(&ie, bbuf_.data(), bbuf_.size(),
		                    game->GetWhiteStr(), game->GetBlackStr(),
		                    game->GetEventStr(), game->GetSiteStr(),
		                    game->GetRoundStr());
		if (err)
			return err;

		return derived()->dyn_addIndexEntry(ie);
	}

	errorT saveGame(Game* game, gamenumT replaced) override {
		if (replaced >= idx_->GetNumGames())
			return ERROR_BadArg;

		bbuf_.clear();
		IndexEntry ie;
		auto err = game->Encode(bbuf_, ie);
		if (err)
			return err;

		err = addGameHelper(&ie, bbuf_.data(), bbuf_.size(),
		                    game->GetWhiteStr(), game->GetBlackStr(),
		                    game->GetEventStr(), game->GetSiteStr(),
		                    game->GetRoundStr());
		if (err)
			return err;

		return derived()->dyn_saveIndexEntry(ie, replaced);
	}

private:
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
