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

#ifndef CODEC_PGN_H
#define CODEC_PGN_H

#include "codec_proxy.h"
#include "common.h"
#include "mfile.h"
#include "pgnparse.h"

#if !CPP11_SUPPORT
#define override
#endif

class CodecPgn : public CodecProxy {
	PgnParser parser_;
	std::string filename_;
	size_t fileSize_;
	MFile file_;

public:
	virtual Codec getType() override { return ICodecDatabase::PGN; }

	virtual std::vector<std::string> getFilenames() override {
		return std::vector<std::string>(1, filename_);
	};

	virtual errorT flush() override {
		file_.Flush();
		return CodecProxy::flush();
	}

	/**
	* CodecPgn::open() - open/create a database
	* @filename: full path of the database to be opened.
	* @fMode:    valid file access mode.
	*
	* This function open/create a database in pgn format.
	* After successfully opening/creating the file, the PgnParser object parser_
	* is initialized to be ready for parseNext() calls.
	* Return OK if successful or an error code.
	*/
	virtual errorT open(const char* filename, fileModeT fmode) override {
		filename_ = filename;
		if (filename_.empty()) return ERROR_FileOpen;

		errorT res = (fmode != FMODE_Create)
		                 ? file_.Open(filename, fmode)
		                 : file_.Create(filename, FMODE_Both);

		if (res == OK) {
			parser_.Reset(&file_);
			fileSize_ = fileSize(filename, "");
			parser_.IgnorePreGameText();
		}

		return res;
	}
	virtual errorT parseNext(Game* g) override {
		return parser_.ParseGame(g);
	}

	virtual std::pair<size_t, size_t> parseProgress() override {
		return std::make_pair((size_t)parser_.BytesUsed(), fileSize_);
	}

	virtual const char* parseErrors() override {
		return parser_.ErrorMessages();
	}

protected:
	/**
	* dyn_addGame() - add a game to the database
	* @game: valid pointer to a Game object with the new data.
	*
	* @game is encoded in pgn format and appended at the end of file_.
	* Return OK if successful or an error code.
	*/
	virtual errorT dyn_addGame(Game* game) override {
		game->SetPgnFormat(PGN_FORMAT_Plain);
		game->ResetPgnStyle(PGN_STYLE_TAGS | PGN_STYLE_VARS |
		                    PGN_STYLE_COMMENTS | PGN_STYLE_SCIDFLAGS);
		std::pair<const char*, unsigned> pgn = game->WriteToPGN(75, true);

		file_.Seek(fileSize_);
		errorT err = file_.WriteNBytes(pgn.first, pgn.second);
		if (err == OK) fileSize_ += pgn.second;
		return err;
	}

	virtual errorT dyn_saveGame(Game* game, gamenumT replaced) override {
		return ERROR_CodecUnsupFeat;
	}
};

#if !CPP11_SUPPORT
#undef override
#endif

#endif
