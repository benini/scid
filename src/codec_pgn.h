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
 * Implements the CodecPgn class, which manages the databases encoded in PGN
 * format.
 */

#ifndef CODEC_PGN_H
#define CODEC_PGN_H

#include "codec_proxy.h"
#include "common.h"
#include "filebuf.h"
#include "pgnparse.h"

#if !CPP11_SUPPORT
#define override
#endif

class CodecPgn : public CodecProxy<CodecPgn> {
	std::string filename_;
	std::streamsize fileSize_;
	Filebuf file_;
	PgnParser parser_;

public:
	CodecPgn() : parser_(&file_) {}

	Codec getType() override { return ICodecDatabase::PGN; }

	std::vector<std::string> getFilenames() override {
		return std::vector<std::string>(1, filename_);
	};

	errorT flush() override {
		errorT errFile = (file_.pubsync() == 0) ? OK : ERROR_FileWrite;
		errorT errProxy = CodecProxy<CodecPgn>::flush();
		return (errFile != OK) ? errFile : errProxy;
	}

	/**
	 * Opens/creates a PGN database.
	 * After successfully opening/creating the file, the PgnParser object @e
	 * parser_ is initialized to be ready for parseNext() calls.
	 * @param filename: full path of the pgn file to be opened.
	 * @param fMode:    valid file access mode.
	 * @returns OK in case of success, an @p errorT code otherwise.
	 */
	errorT open(const char* filename, fileModeT fmode) {
		filename_ = filename;
		if (filename_.empty()) return ERROR_FileOpen;

		errorT res = file_.Open(filename, fmode);
		if (res == OK) {
			fileSize_ = file_.pubseekoff(0, std::ios::end);
			res = (fileSize_ >= 0) ? OK : ERROR_FileSeek;
			file_.pubseekpos(0);
		}
		if (res == OK) {
			parser_ = PgnParser(&file_);
		}

		return res;
	}

	/**
	 * Reads the next game.
	 * @param g: valid pointer to the Game object where the data will be stored.
	 * @returns
	 * - OK on success.
	 * - ERROR_NotFound if there are no more games to be read.
	 * - ERROR code if the game cannot be read and was skipped.
	 */
	errorT parseNext(Game* g) {
		return parser_.ParseGame(g, false);
	}

	/**
	 * Returns info about the parsing progress.
	 * @returns a pair<size_t, size_t> where first element is the quantity of
	 * data parsed and second one is the total amount of data of the database.
	 */
	std::pair<size_t, size_t> parseProgress() {
		return std::make_pair(parser_.BytesUsed() / 1024, fileSize_ / 1024);
	}

	/**
	 * Returns the list of errors produced by parseNext() calls.
	 */
	const char* parseErrors() {
		return parser_.ErrorMessages();
	}

public:
	/**
	 * Add a game into the database.
	 * The @e game is encoded in pgn format and appended at the end of @e file_.
	 * @param game: valid pointer to a Game object with the new data.
	 * @returns OK in case of success, an @e errorT code otherwise.
	 */
	errorT dyn_addGame(Game* game) {
		game->SetPgnFormat(PGN_FORMAT_Plain);
		game->ResetPgnStyle(PGN_STYLE_TAGS | PGN_STYLE_VARS |
		                    PGN_STYLE_COMMENTS | PGN_STYLE_SCIDFLAGS);
		std::pair<const char*, unsigned> pgn = game->WriteToPGN(75, true);

		file_.pubseekpos(fileSize_);
		if (file_.sputn(pgn.first, pgn.second) == pgn.second) {
			fileSize_ += pgn.second;
			return OK;
		}
		return ERROR_FileWrite;
	}
};

#if !CPP11_SUPPORT
#undef override
#endif

#endif
