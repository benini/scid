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
#include "mfile.h"
#include "pgnparse.h"

#if !CPP11_SUPPORT
#define override
#endif

class CodecPgn : public CodecProxy<CodecPgn> {
	PgnParser parser_;
	std::string filename_;
	size_t fileSize_;
	MFile file_;

public:
	Codec getType() override { return ICodecDatabase::PGN; }

	std::vector<std::string> getFilenames() override {
		return std::vector<std::string>(1, filename_);
	};

	errorT flush() override {
		file_.Flush();
		return CodecProxy<CodecPgn>::flush();
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

		errorT res = (fmode != FMODE_Create)
		                 ? file_.Open(filename, fmode)
		                 : file_.Create(filename, FMODE_Both);

		if (res == OK) {
			if (fmode == FMODE_Create) {
				fileSize_ = 0;
			} else {
				fileSize_ = fileSize(filename, "");
				if (fileSize_ == 0 && !file_.EndOfFile())
					return ERROR_FileOpen;
			}
			parser_.Reset(&file_);
			parser_.IgnorePreGameText();
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
		return parser_.ParseGame(g);
	}

	/**
	 * Returns info about the parsing progress.
	 * @returns a pair<size_t, size_t> where first element is the quantity of
	 * data parsed and second one is the total amount of data of the database.
	 */
	std::pair<size_t, size_t> parseProgress() {
		return std::make_pair(size_t(parser_.BytesUsed()) / 1024, fileSize_ / 1024);
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

		file_.Seek(fileSize_);
		errorT err = file_.WriteNBytes(pgn.first, pgn.second);
		if (err == OK) fileSize_ += pgn.second;
		return err;
	}
};

#if !CPP11_SUPPORT
#undef override
#endif

#endif
