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

#ifndef CODEC_PROXY_H
#define CODEC_PROXY_H

#include "codec.h"
#include "codec_memory.h"
#include "common.h"
#include "game.h"

#if !CPP11_SUPPORT
#define override
#endif

/**
 * class CodecProxy - base class for non-native databases
 *
 * Every class derived from ICodecDatabase must keep an Index object and the
 * corresponding NameBase object fully updated in memory.
 * This implies that the virtual function dyn_open() must load in memory the
 * header's data of all the games; however is not desirable to have codecs
 * depending on the Index class or on native encoded formats.
 * This class provides an interface that encapsulate codecs from internal
 * representations, requiring only the ability to exchange Game objects.
 */
class CodecProxy : public CodecMemory {
	/**
	* open() - open/create a database
	* @filename: full path of the database to be opened.
	* @fMode:    valid file access mode.
	*
	* This function must be must be overridden to open/create the database
	* @filename and be ready for parseNext() calls.
	* Return OK if successful or an error code.
	*/
	virtual errorT open(const char* filename, fileModeT fMode) = 0;

	/**
	* parseNext() - load the next game
	* @g: valid pointer to the Game object where the data will be stored.
	*
	* The derivate class must override this function to sequentially
	* read the games contained into the database.
	* Return:
	* - OK: if the game is successfully read.
	* - ERROR_NotFound: if there are no more games to be read.
	* - ERROR code: the game should be skipped and an appropriate error code
	*               should be returned.
	*/
	virtual errorT parseNext(Game* g) = 0;

	/**
	* parseProgress() - get info about parsing progress
	*
	* This functions must be must be overridden to report info to the GUI.
	* Returns a pair<size_t, size_t> where first is the quantity of data parsed
	* and second the total amount of data.
	*/
	virtual std::pair<size_t, size_t> parseProgress() = 0;

	/**
	* parseErrors() - get the list of errors produced by parseNext() calls.
	*/
	virtual const char* parseErrors() = 0;

	/**
	* dyn_add/saveGame() - add/replace a game into the database
	* @game: valid pointer to a Game object with the new data.
	* @replaced: valid gamenumT of the game to be replaced
	*
	* The derivate class must override this functions to add/replace games
	* into the database.
	* Return OK if successful or an error code.
	*/
	virtual errorT dyn_addGame(Game* game) = 0;
	virtual errorT dyn_saveGame(Game* game, gamenumT replaced) = 0;

public:
	/**
	* CodecProxy::add/saveGame() - add/replace a game into the database
	* @game: valid pointer to a Game object with the new data.
	* @ie:  valid pointer to the IndexEntry with new header data of the game.
	* @src: valid pointer to a buffer containing the new game's data of the
	*       game (encoded in native format).
	* @length: length in bytes of buffer @src
	* @replaced: valid gamenumT of the game to be replaced
	*
	* This functions add/replace a game into the database.
	* If the data is provided in native format it is decoded into a Game object.
	* The virtual function dyn_add/saveGame() is invoked to store the data
	* using codec format, and the memory database is keep updated calling
	* the corresponding function add/saveGame() of the base class CodecMemory.
	* Return OK if successful or an error code.
	*/
	virtual errorT addGame(Game* game) override {
		errorT err = this->dyn_addGame(game);
		if (err != OK) return err;

		return CodecMemory::addGame(game);
	}
	virtual errorT saveGame(Game* game, gamenumT replaced) override {
		errorT err = this->dyn_saveGame(game, replaced);
		if (err != OK) return err;

		return CodecMemory::saveGame(game, replaced);
	}
	virtual errorT addGame(IndexEntry* ie, const byte* src, size_t length) override {
		Game game;
		errorT err = decodeGame(ie, src, length, game);
		if (err != OK) return err;

		err = this->dyn_addGame(&game);
		if (err != OK) return err;

		return CodecMemory::addGame(ie, src, length);
	}
	virtual errorT saveGame(IndexEntry* ie, const byte* src, size_t length,
	                        gamenumT replaced) override {
		Game game;
		errorT err = decodeGame(ie, src, length, game);
		if (err != OK) return err;

		err = this->dyn_saveGame(&game, replaced);
		if (err != OK) return err;

		return CodecMemory::saveGame(ie, src, length, replaced);
	}

	/**
	* CodecProxy::flush() - flush pending changes
	*/
	virtual errorT flush() override {
		return CodecMemory::flush();
	}

private:
	/**
	* CodecProxy::dyn_open() - open/create a database
	* @fMode:    valid file access mode.
	* @filename: full path of the database to be opened.
	* @progress: object to report opening progress.
	* @idx:      valid pointer to the Index object of this database
	* @nb:       valid pointer to the NameBase object corresponding to @idx
	*
	* Open the in-memory database and ask the derivate class to open
	* the database @filename encoded in a different codec.
	* If the file is successfully opened the virtual function parseNext() is
	* repeatedly called until it returns ERROR_NotFound and the Game objects are
	* loaded into the memory database.
	* The virtual function parseProgress is called to report about the loading
	* progress.
	* Return OK if successful or an error code.
	*/
	virtual errorT dyn_open(fileModeT fMode, const char* filename,
	                        const Progress& progress, Index* idx,
	                        NameBase* nb) override {
		if (filename == 0) return ERROR;

		errorT err = CodecMemory::dyn_open(FMODE_Memory, filename, progress, idx, nb);
		if (err != OK) return err;

		err = open(filename, fMode);
		if (err != OK) return err;

		Game g;
		uint nImported = 0;
		while ((err = parseNext(&g)) != ERROR_NotFound) {
			if (err != OK) continue;

			err = CodecMemory::addGame(&g);
			if (err != OK) break;

			if ((++nImported % 200) == 0) {
				std::pair<size_t, size_t> count = parseProgress();
				if (!progress.report(count.first, count.second)) {
					err = ERROR_UserCancel;
					break;
				}
			}
		}
		progress.report(1, 1);

		return (err == ERROR_NotFound) ? OK : err;
	}

private:
	/**
	* decodeGame() - decode a Game object from native format
	*
	* Both the game's data, provided by @src, and the header's data, provided
	* by @ie, are stored into @resGame.
	* Return OK if successful or an error code.
	*/
	errorT decodeGame(const IndexEntry* ie, const byte* src, size_t length,
	                  Game& resGame) {
		ByteBuffer buf(0);
		buf.ProvideExternal(const_cast<byte*>(src), length);
		errorT err = resGame.Decode(&buf, GAME_DECODE_ALL);
		if (err == OK) err = resGame.LoadStandardTags(ie, nb_);
		return err;
	}
};

#if !CPP11_SUPPORT
#undef override
#endif

#endif
