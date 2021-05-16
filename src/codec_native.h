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
	errorT addGame(Game* game) override {
		bbuf_.clear();
		auto [ie, tags] = game->Encode(bbuf_);

		if (auto err = addGameHelper(&ie, bbuf_.data(), bbuf_.size(), tags))
			return err;

		return derived()->dyn_addIndexEntry(ie);
	}

private:
	template <typename Tags>
	errorT addGameHelper(IndexEntry* ie, const byte* srcData, size_t dataLen,
	                     Tags const& tags) {
		auto err = tags.map(*ie, [&](auto nt, auto name) {
			return derived()->dyn_addName(nt, name);
		});
		if (err)
			return err;

		nb_->AddElo(ie->GetWhite(), ie->GetWhiteElo());
		nb_->AddElo(ie->GetBlack(), ie->GetBlackElo());

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
