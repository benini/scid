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

#ifndef CODEC_H
#define CODEC_H

#include "common.h"
#include <string>
#include <vector>

class Game;
class Index;
class IndexEntry;
class NameBase;
class Progress;

/**
 * class ICodecDatabase - interface to database formats
 *
 * This interface separates the database's logic from data formats.
 * Ideally all the file input/output of databases should be contained in class
 * derived from this interface.
 */
class ICodecDatabase {
public:
	virtual ~ICodecDatabase() {};

	/**
	* make() - create an object
	* @codec: the type of object to create
	*
	* Creates an object of type @codec and call the virtual function dyn_open().
	* Return:
	* - on success: a valid pointer to the object and set @resError to OK.
	* - on error:   return 0 (destroy the object that was created) and
	*               set @resError to an appropriate error code.
	*/
	enum Codec { MEMORY, SCID4, PGN };
	static ICodecDatabase* make(Codec codec, errorT* resError, fileModeT fMode,
	                            const char* filename, const Progress& progress,
	                            Index* idx, NameBase* nb);

	/**
	* getType() - return the Codec type
	*
	* A derivate class must override this function and return the Codec type.
	*/
	virtual Codec getType() = 0;

	/**
	* getFilenames() - return the full path of the files used by the database
	*
	* A derivate class must override this function and return the full path
	* of the files used. The order of the filenames must be consistent for
	* objects of the same Codec type.
	*/
	virtual std::vector<std::string> getFilenames() = 0;

	/**
	* getGameData() - get a game's data from the database
	* @offset: offset of the requested game
	* @length: length in bytes of the game's data
	*
	* Overrides of this function must returns the game's data
	* (excluding index info) encoded in native format.
	* Return a pointer to the requested data or 0 on error.
	*/
	virtual const byte* getGameData(uint32_t offset, uint32_t length) = 0;

	/**
	* add/saveGame() - add/replace a game of the database
	* @game: valid pointer to a Game object with the new data.
	* @ie:  valid pointer to the IndexEntry with new header data of the game.
	* @src: valid pointer to a buffer containing the new game's data of the
	*       game (encoded in native format).
	* @length: length in bytes of buffer @src
	* @replaced: valid gamenumT of the game to be replaced
	*
	* This functions add/replace a game into the database.
	* The new game can be either encoded in native format or contained inside
	* a Game object.
	* Return OK if successful or an error code.
	*/
	virtual errorT addGame(IndexEntry* srcIe, const byte* src, size_t length)  = 0;
	virtual errorT addGame(Game* game) = 0;
	virtual errorT saveGame(IndexEntry* ie, const byte* src, size_t length,
	                        gamenumT replaced) = 0;
	virtual errorT saveGame(Game* game, gamenumT replaced) = 0;

	/**
	* flush() - flush pending changes
	*
	* A derivate class may defer file output operations in order to increase
	* performance.
	* Overrides of this function must write all pending changes to files.
	* Return OK if successful or an error code.
	*/
	virtual errorT flush() = 0;

private:
	/**
	* dyn_open() - open/create the database
	* @fMode:    a valid file mode.
	* @filename: the full path of the database to open.
	* @progress: a Progress object used for GUI communications.
	* @idx:      valid pointer to the Index object of this database
	* @nb:       valid pointer to the NameBase object corresponding to @idx
	*
	* This function is called only once immediately after the class constructor.
	* Return:
	* - OK: the object is ready to be used.
	* - ERROR_NameDataLoss: some names are corrupted and cannot be recovered,
	*                       however the object can still be used.
	* - Other error codes: the operation failed (the object will be destroyed).
	*/
	virtual errorT dyn_open(fileModeT fMode, const char* filename,
	                        const Progress& progress, Index* idx,
	                        NameBase* nb) = 0;
};

#endif
