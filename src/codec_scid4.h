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
 * Implements the CodecSCID4 class, which manages the databases encoded
 * in Scid format version 4.
 */

#ifndef CODEC_SCID4_H
#define CODEC_SCID4_H

#include "codec_native.h"
#include "filebuf.h"
#include <limits>

/**
 * This class manages databases encoded in SCID format v4.
 */
class CodecSCID4 : public CodecNative<CodecSCID4>  {
	std::vector<std::string> filenames_;
	FilebufAppend gfile_;
	char gamecache_[1ULL << 17];

	enum : uint64_t {
		LIMIT_GAMEOFFSET = 1ULL << 32,
		LIMIT_GAMELEN = 1ULL << 17,
		LIMIT_NUMGAMES = 16777214ULL, // Three bytes -1 because GetAutoLoad uses
		                              // 0 to mean "no autoload"
		LIMIT_NAMELEN = 255
	};

public: // ICodecDatabase interface
	Codec getType() override { return ICodecDatabase::SCID4; }

	/**
	 * Returns the full path of the three files (index, namebase and gamefile)
	 * used by the database.
	 */
	std::vector<std::string> getFilenames() override {
		return filenames_;
	};

	const byte* getGameData(uint64_t offset, uint32_t length) override {
		if (offset >= gfile_.size())
			return NULL;
		if (length >= LIMIT_GAMELEN)
			return NULL;

		if (gfile_.pubseekpos(offset) == -1)
			return NULL;
		if (gfile_.sgetn(gamecache_, length) != std::streamsize(length))
			return NULL;

		return reinterpret_cast<const byte*>(gamecache_);
	}

	errorT flush() override {
		errorT err = idx_->flush();
		if (err == OK) {
			// *** Compatibility ***
			// Even if name's frequency is no longer used, it's necessary to
			// keep the compatibility with older Scid versions, forcing a
			// recalculation.
			err = nb_->WriteNameFile(filenames_[1].c_str(), idx_);
		}
		errorT errGfile = (gfile_.pubsync() == 0) ? OK : ERROR_FileWrite;

		return (err == OK) ? errGfile : err;
	}

	errorT dyn_open(fileModeT fMode, const char* filename,
	                const Progress& progress, Index* idx,
	                NameBase* nb) override {
		if (filename == 0 || idx == 0 || nb == 0) return ERROR;
		if (*filename == '\0') return ERROR_FileOpen;

		idx_ = idx;
		nb_ = nb;
		filenames_.resize(3);
		filenames_[0] = std::string(filename) + ".si4";
		filenames_[1] = std::string(filename) + ".sn4";
		filenames_[2] = std::string(filename) + ".sg4";

		errorT err = gfile_.open(filenames_[2], fMode);
		if (err != OK) return err;

		if (fMode == FMODE_Create) {
			err = idx->Create(filename);
			if (err == OK) err = nb->WriteNameFile(filenames_[1].c_str(), nullptr);
		} else {
			err = idx->Open(filename, fMode);
			if (err == OK) err = nb->ReadEntireFile(filenames_[1].c_str(), fMode);
			if (err == OK) err = readIndex(progress);
		}

		return err;
	}

public: // CodecNative interface
	/**
	 * Stores the data into the .sg4 file.
	 * @param src:    valid pointer to a buffer that contains the game data
	 *                (encoded in native format).
	 * @param length: the length of the buffer @p src (in bytes).
	 * @returns
	 * - on success, a @e std::pair containing OK and the offset of the stored
	 * data (usable to retrieve the data with getGameData()).
	 * - on failure, a @e std::pair containing an error code and 0.
	 */
	std::pair<errorT, uint64_t> dyn_addGameData(const byte* src,
	                                            size_t length) {
		ASSERT(src != 0);
		const char* data = reinterpret_cast<const char*>(src);

		if (length >= LIMIT_GAMELEN)
			return std::make_pair(ERROR_GameLengthLimit, 0);

		// The Scid4 format uses 32-bits to store games' offset.
		uint64_t offset = gfile_.size();
		if (offset >= LIMIT_GAMEOFFSET - length)
			return std::make_pair(ERROR_OffsetLimit, 0);

		// The Scid4 format stores games into blocks of 128KB.
		// If the current block does not have enough space, we fill it with
		// random data and use the next one.
		uint64_t blockSpace = LIMIT_GAMELEN - (offset % LIMIT_GAMELEN);
		if (blockSpace < length) {
			errorT err = gfile_.append(data, blockSpace);
			if (err != OK)
				return std::make_pair(err, 0);
			offset += blockSpace;
		}

		errorT err = gfile_.append(data, length);
		return std::make_pair(err, offset);
	}

	/**
	 * Add an IndexEntry to @e idx_.
	 * @param ie: the IndexEntry object to add.
	 * @returns OK if successful or an error code.
	 */
	errorT dyn_addIndexEntry(const IndexEntry& ie) {
		auto nGames = idx_->GetNumGames();
		if (nGames >= LIMIT_NUMGAMES)
			return ERROR_NumGamesLimit;

		return idx_->WriteEntry(&ie, nGames, false);
	}

	/**
	 * Given a name (string), retrieve the corresponding ID.
	 * The name is added to @e nb_ if do not already exists in the NameBase.
	 * @param nt:   nameT type of the name to retrieve.
	 * @param name: the name to retrieve.
	 * @returns
	 * - on success, a @e std::pair containing OK and the ID.
	 * - on failure, a @e std::pair containing an error code and 0.
	 */
	std::pair<errorT, idNumberT> dyn_addName(nameT nt, const char* name) {
		const idNumberT MAX_ID[] = {
		    1048575, /* Player names: Maximum of 2^20 -1 = 1,048,575 */
		    524287,  /* Event names:  Maximum of 2^19 -1 =   524,287 */
		    524287,  /* Site names:   Maximum of 2^19 -1 =   524,287 */
		    262143   /* Round names:  Maximum of 2^18 -1 =   262,143 */
		};
		return nb_->getID(nt, name, LIMIT_NAMELEN, MAX_ID[nt]);
	}

	/**
	 * Decode SCID4 (or SCID3) data into an IndexEntry object.
	 * @param buf_it:  pointer to the buffer containing the data
	 *                 (should contain INDEX_ENTRY_SIZE chars)
	 * @param version: 400 for SCID4 or 300 for SCID3.
	 * @param ie:      pointer to the IndexEntry object where the data will be
	 *                 stored.
	 */
	static void decodeIndexEntry(const char* buf_it, versionT version,
	                             IndexEntry* ie);

private:
	errorT readIndex(const Progress& progress);
};

/**
 * Reads the entire index file into memory.
 * Invalid name IDs are replaced with "?" if possible.
 * @param progress: a Progress object used for GUI communications.
 * @returns OK if successful or an error code.
 */
inline errorT CodecSCID4::readIndex(const Progress& progress) {
	gamenumT nUnknowIDs = 0;
	idNumberT maxID[NUM_NAME_TYPES];
	for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
		maxID[nt] = nb_->GetNumNames(nt);
	}
	auto validateNameIDs = [&](IndexEntry* ie) {
		if (ie->GetWhite() >= maxID[NAME_PLAYER]) {
			auto unknown = dyn_addName(NAME_PLAYER, "?");
			if (unknown.first != OK)
				return false;
			ie->SetWhite(unknown.second);
			++nUnknowIDs;
		}
		if (ie->GetBlack() >= maxID[NAME_PLAYER]) {
			auto unknown = dyn_addName(NAME_PLAYER, "?");
			if (unknown.first != OK)
				return false;
			ie->SetBlack(unknown.second);
			++nUnknowIDs;
		}
		if (ie->GetEvent() >= maxID[NAME_EVENT]) {
			auto unknown = dyn_addName(NAME_EVENT, "?");
			if (unknown.first != OK)
				return false;
			ie->SetEvent(unknown.second);
			++nUnknowIDs;
		}
		if (ie->GetSite() >= maxID[NAME_SITE]) {
			auto unknown = dyn_addName(NAME_SITE, "?");
			if (unknown.first != OK)
				return false;
			ie->SetSite(unknown.second);
			++nUnknowIDs;
		}
		if (ie->GetRound() >= maxID[NAME_ROUND]) {
			auto unknown = dyn_addName(NAME_ROUND, "?");
			if (unknown.first != OK)
				return false;
			ie->SetRound(unknown.second);
			++nUnknowIDs;
		}
		return true;
	};

	auto idxFile = idx_->FilePtr;
	auto version = idx_->Header.version;
	auto nGames = idx_->GetNumGames();
	idx_->entries_.resize(nGames);

	auto nBytes = (version < 400) ? OLD_INDEX_ENTRY_SIZE : INDEX_ENTRY_SIZE;
	for (gamenumT gNum = 0; idxFile->sgetc() != EOF; ++gNum) {
		if (gNum == nGames)
			return ERROR_CorruptData;

		if ((gNum % 8192) == 0) {
			if (!progress.report(gNum, nGames))
				return ERROR_UserCancel;
		}

		char buf[INDEX_ENTRY_SIZE];
		if (idxFile->sgetn(buf, nBytes) != nBytes)
			return ERROR_FileRead;

		IndexEntry* ie = idx_->FetchEntry(gNum);
		decodeIndexEntry(buf, version, ie);

		if (!validateNameIDs(ie))
			return ERROR_CorruptData;

		nb_->AddElo(ie->GetWhite(), ie->GetWhiteElo());
		nb_->AddElo(ie->GetBlack(), ie->GetBlackElo());
	}
	progress.report(1, 1);

	if (nGames != idx_->GetNumGames())
		return ERROR_FileRead;

	idx_->nInvalidNameId_ = nUnknowIDs;
	return (nUnknowIDs == 0) ? OK : ERROR_NameDataLoss;
}

inline void CodecSCID4::decodeIndexEntry(const char* buf_it, versionT version,
                                         IndexEntry* ie) {
	auto ReadOneByte = [&buf_it]() {
		uint8_t res = *buf_it++;
		return res;
	};
	auto ReadTwoBytes = [&ReadOneByte]() {
		uint16_t high = ReadOneByte();
		uint16_t res = (high << 8) | ReadOneByte();
		return res;
	};
	auto ReadFourBytes = [&ReadTwoBytes]() {
		uint32_t high = ReadTwoBytes();
		uint32_t res = (high << 16) | ReadTwoBytes();
		return res;
	};

	// Offset of the gamefile record (32 bits).
	ie->SetOffset(ReadFourBytes());

	// Length of gamefile record for this game: 17 bits are used so the max
	// length is 128 ko (131071).
	// Lower bits of the extra byte are used for custom flags: LxFFFFFF ( L =
	// length for long games, x = spare, F = custom flags)
	uint32_t len_Low = ReadTwoBytes();
	uint32_t len_flags = (version < 400) ? 0 : ReadOneByte();
	ie->SetLength(((len_flags & 0x80) << 9) | len_Low);
	uint32_t Flags = ReadTwoBytes();
	ie->clearFlags();
	ie->SetFlag(((len_flags & 0x3F) << 16) | Flags, true);

	// WhiteID and BlackID are 20-bit values, EventID and SiteID are
	// 19-bit values, and RoundID is an 18-bit value.
	// WhiteID high 4 bits = bits 4-7 of WhiteBlack_High.
	// BlackID high 4 bits = bits 0-3 of WhiteBlack_High.
	// EventID high 3 bits = bits 5-7 of EventSiteRnd_high.
	// SiteID  high 3 bits = bits 2-4 of EventSiteRnd_high.
	// RoundID high 2 bits = bits 0-1 of EventSiteRnd_high.
	uint32_t WhiteBlack_High = ReadOneByte();
	uint32_t WhiteID_Low = ReadTwoBytes();
	ie->SetWhite(((WhiteBlack_High & 0xF0) << 12) | WhiteID_Low);
	uint32_t BlackID_Low = ReadTwoBytes();
	ie->SetBlack(((WhiteBlack_High & 0x0F) << 16) | BlackID_Low);
	uint32_t EventSiteRnd_High = ReadOneByte();
	uint32_t EventID_Low = ReadTwoBytes();
	ie->SetEvent(((EventSiteRnd_High & 0xE0) << 11) | EventID_Low);
	uint32_t SiteID_Low = ReadTwoBytes();
	ie->SetSite(((EventSiteRnd_High & 0x1C) << 14) | SiteID_Low);
	uint32_t RoundID_Low = ReadTwoBytes();
	ie->SetRound(((EventSiteRnd_High & 0x03) << 16) | RoundID_Low);

	// Counters for comments, variations, etc. (4 bits each)
	// VarCounts also stores the result (4 bits).
	uint32_t varCounts = ReadTwoBytes();
	ie->SetRawVariationCount(varCounts & 0x0F);
	ie->SetRawCommentCount((varCounts >> 4) & 0x0F);
	ie->SetRawNagCount((varCounts >> 8) & 0x0F);
	ie->SetResult((varCounts >> 12) & 0x0F);

	// ECO code (16 bits)
	ie->SetEcoCode(ReadTwoBytes());

	// Date and EventDate are stored in four bytes.
	// Due to a compact encoding format, the EventDate
	// must be within a few years of the Date.
	uint32_t date_edate = ReadFourBytes();
	uint32_t date = date_edate & 0xFFFFF;
	ie->SetDate(date);
	uint32_t edate = date_edate >> 20;
	uint32_t eyear = date_GetYear(edate) & 0x07;
	if (eyear == 0) {
		edate = ZERO_DATE;
	} else {
		eyear += date_GetYear(date);
		eyear = (eyear < 4) ? 0 : eyear - 4;
		edate = DATE_MAKE(eyear, date_GetMonth(edate), date_GetDay(edate));
	}
	ie->SetEventDate(edate);

	// The two ELO ratings and rating types take 2 bytes each.
	uint16_t whiteElo = ReadTwoBytes();
	ie->SetWhiteElo(whiteElo & 0xFFF);
	ie->SetWhiteRatingType(whiteElo >> 12);
	uint16_t blackElo = ReadTwoBytes();
	ie->SetBlackElo(blackElo & 0xFFF);
	ie->SetBlackRatingType(blackElo >> 12);

	// material of the final position in the game,
	// and the StoredLineCode in the top 8 bits.
	uint32_t finalMatSig = ReadFourBytes();
	ie->SetFinalMatSig(finalMatSig & 0xFFFFFF);
	ie->SetStoredLineCode(finalMatSig >> 24);

	// Read the 9-byte homePawnData array:
	// The first byte of HomePawnData has high bits of the NumHalfMoves
	// counter in its top two bits:
	uint16_t NumHalfMoves = ReadOneByte();
	uint16_t pawnData0 = ReadOneByte();
	ie->SetNumHalfMoves(((pawnData0 & 0xC0) << 2) | NumHalfMoves);
	byte* pb = ie->GetHomePawnData();
	*pb++ = pawnData0 & 0x3F;
	std::copy_n(buf_it, HPSIG_SIZE - 1, pb);
}

#endif
