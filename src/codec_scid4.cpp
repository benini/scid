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
 * Implements the CodecSCID4 class, which manages the databases encoded
 * in Scid format version 4.
 */

#include "codec_scid4.h"
#include <algorithm>

namespace {

/**
 * A NameBase file starts with an header containing:
 * - header_magic (8 bytes): identify the file format
 * - unused (4 bytes):  obsolete timeStamp
 * - number of NAME_PLAYER names stored in the file (3 bytes)
 * - number of NAME_EVENT names stored in the file (3 bytes)
 * - number of NAME_SITE names stored in the file (3 bytes)
 * - number of NAME_ROUND names stored in the file (3 bytes)
 * - unused (12 bytes): obsolete max frequency
 * Names are stored in alphabetical order using front-coding and each record is
 * composed by:
 * - name_id (2-3 bytes): the idx (idNumberT) stored in the Index (.si4) file
 * - unused (1-3 bytes): obsolete frequency
 * - length (1 byte): the total number of bytes of the name (max 255)
 * - prefix (1 byte): the number of bytes in common with the previous name
 * - name (0-255 bytes): the part of the name that differs from the previous
 *   one.
 */
const char* NAMEBASE_MAGIC = "Scid.sn";

/// Read a SCIDv4 NameBase file into memory.
/// @param filename: the full path of the file to open.
/// @param fMode:    a valid file mode.
/// @param nb:       reference to the object where the names will be stored.
/// @returns OK if successful or an error code.
errorT namefileRead(const char* filename, fileModeT fmode, NameBase& nb) {
	Filebuf file;
	if (file.Open(filename, fmode) != OK)
		return ERROR_FileOpen;

	char Header_magic[9] = {0}; // magic identifier must be "Scid.sn"
	file.sgetn(Header_magic, 8);
	if (strcmp(Header_magic, NAMEBASE_MAGIC) != 0)
		return ERROR_BadMagic;

	// *** Compatibility ***
	// Even if timeStamp is not used we still need to read the bytes
	file.ReadFourBytes();
	// ***

	idNumberT Header_numNames[NUM_NAME_TYPES];
	Header_numNames[NAME_PLAYER] = file.ReadThreeBytes();
	Header_numNames[NAME_EVENT] = file.ReadThreeBytes();
	Header_numNames[NAME_SITE] = file.ReadThreeBytes();
	Header_numNames[NAME_ROUND] = file.ReadThreeBytes();

	// *** Compatibility ***
	// Even if frequency is no longer used we still need to read the bytes
	uint obsolete_maxFreq[NUM_NAME_TYPES];
	obsolete_maxFreq[NAME_PLAYER] = file.ReadThreeBytes();
	obsolete_maxFreq[NAME_EVENT] = file.ReadThreeBytes();
	obsolete_maxFreq[NAME_SITE] = file.ReadThreeBytes();
	obsolete_maxFreq[NAME_ROUND] = file.ReadThreeBytes();
	// ***

	for (nameT nt : {NAME_PLAYER, NAME_EVENT, NAME_SITE, NAME_ROUND}) {
		idNumberT id;
		std::string prevName;
		for (idNumberT i = 0; i < Header_numNames[nt]; i++) {
			if (Header_numNames[nt] >= 65536) {
				id = file.ReadThreeBytes();
			} else {
				id = file.ReadTwoBytes();
			}

			// *** Compatibility ***
			// Even if frequency is no longer used we still need to read the
			// bytes Frequencies can be stored in 1, 2 or 3 bytes:
			if (obsolete_maxFreq[nt] >= 65536) {
				file.ReadThreeBytes();
			} else if (obsolete_maxFreq[nt] >= 256) {
				file.ReadTwoBytes();
			} else { // Frequencies all <= 255: fit in one byte
				file.ReadOneByte();
			}
			// ***

			// Read the name string.
			// All strings EXCEPT the first are front-coded.
			int length = file.ReadOneByte();
			int prefix = (i > 0) ? file.ReadOneByte() : 0;
			if (prefix > length)
				return ERROR_Corrupt;

			prevName.resize(length);
			const auto new_chars = length - prefix;
			if (new_chars != file.sgetn(prevName.data() + prefix, new_chars))
				return ERROR_FileRead;

			if (id >= Header_numNames[nt] ||
			    !nb.insert(prevName.c_str(), length, nt, id))
				return ERROR_Corrupt;
		}
	}

	return OK;
}

/// Write a SCIDv4 NameBase file.
/// @param filename: the full path of the file to open.
/// @param nb:       reference to the object where the names will be stored.
/// @returns OK if successful or an error code.
template <typename TCont, typename TFreq>
errorT namefileWrite(const char* filename, const TCont& names_ids,
                     const TFreq& freq) {
	Filebuf file;
	if (file.Open(filename, FMODE_WriteOnly) != OK)
		return ERROR_FileOpen;

	file.sputn(NAMEBASE_MAGIC, 8);

	// *** Compatibility ***
	// Even if timeStamp is not used we still need to write these bytes
	file.WriteFourBytes(0);
	// ***

	ASSERT(1ULL << 24 > names_ids[NAME_PLAYER].size());
	ASSERT(1ULL << 24 > names_ids[NAME_EVENT].size());
	ASSERT(1ULL << 24 > names_ids[NAME_SITE].size());
	ASSERT(1ULL << 24 > names_ids[NAME_ROUND].size());
	file.WriteThreeBytes((uint32_t)names_ids[NAME_PLAYER].size());
	file.WriteThreeBytes((uint32_t)names_ids[NAME_EVENT].size());
	file.WriteThreeBytes((uint32_t)names_ids[NAME_SITE].size());
	file.WriteThreeBytes((uint32_t)names_ids[NAME_ROUND].size());

	// *** Compatibility ***
	// even if maxFrequency is no longer used we still need to write these bytes
	unsigned maxFreq[NUM_NAME_TYPES] = {0};
	for (nameT nt : {NAME_PLAYER, NAME_EVENT, NAME_SITE, NAME_ROUND}) {
		auto it = std::max_element(freq[nt].begin(), freq[nt].end());
		maxFreq[nt] = (it == freq[nt].end()) ? 0 : *it;
		file.WriteThreeBytes(maxFreq[nt]);
	}
	// ***

	for (nameT nt : {NAME_PLAYER, NAME_EVENT, NAME_SITE, NAME_ROUND}) {
		const char* prevName = nullptr;
		size_t numNames = names_ids[nt].size();
		for (const auto& it : names_ids[nt]) {
			const char* name = it.first;
			idNumberT id = it.second;

			// *** Compatibility ***
			// Older code used a custom StrTree class with a peculiar sorting:
			// - the first char was interpreted as an unsigned char;
			// - the remaining part was compared with strComapare(),
			//   which converts the chars to ints, and is not consistent with
			//   the standard function strcmp().
			// The old StrTree class did also have unpredictable behaviors when
			// fed with names not sorted according to that criteria, for example
			// it could create Namebase objects with duplicate entries.
			// ***
			ASSERT(prevName == nullptr ||
			       static_cast<uint>(*prevName) < static_cast<uint>(*name) ||
			       (static_cast<uint>(*prevName) == static_cast<uint>(*name) &&
			        strCompare(prevName, name) < 0));

			// write idNumber in 2 bytes if possible, otherwise 3.
			if (numNames >= 65536) {
				file.WriteThreeBytes(id);
			} else {
				file.WriteTwoBytes(id);
			}

			// *** Compatibility ***
			// write these bytes even if they are not used anymore
			if (maxFreq[nt] >= 65536) {
				file.WriteThreeBytes(freq[nt][id]);
			} else if (maxFreq[nt] >= 256) {
				file.WriteTwoBytes(freq[nt][id]);
			} else {
				file.WriteOneByte(static_cast<byte>(freq[nt][id]));
			}
			// ***

			ASSERT(strlen(name) < 256);
			byte length = static_cast<byte>(strlen(name));
			file.WriteOneByte(length);
			byte prefix = 0;
			if (prevName) {
				prefix = (byte)strPrefix(name, prevName);
				file.WriteOneByte(prefix);
			}
			file.sputn(name + prefix, (length - prefix));
			prevName = name;
		}
	}
	return OK;
}

/**
 * An Index file starts with an header of 182 bytes containing:
 * - index_magic (8 bytes): identifies the file format.
 * - version (2 bytes): 300 or 400
 * - baseType (4 bytes): e.g. tournament, theory, etc.
 * - numGames (3 bytes): total number of games contained into the index.
 * - autoLoad (3 bytes): number of the game to load at start
 *                       (0=none, 1=1st, >numGames=last).
 * - description (108 bytes): a null-terminated string describing the database.
 * - flag1 description (9 bytes): a null-terminated string describing flag1.
 * - flag2 description (9 bytes): a null-terminated string describing flag2.
 * - flag3 description (9 bytes): a null-terminated string describing flag3.
 * - flag4 description (9 bytes): a null-terminated string describing flag4.
 * - flag5 description (9 bytes): a null-terminated string describing flag5.
 * - flag6 description (9 bytes): a null-terminated string describing flag6.
 */
constexpr char INDEX_MAGIC[8] = "Scid.si";
constexpr size_t SCID_DESC_LENGTH = 107;
constexpr size_t CUSTOM_FLAG_MAX = 6;
constexpr size_t CUSTOM_FLAG_DESC_LENGTH = 8;
constexpr int INDEX_ENTRY_SIZE = 47;
constexpr int OLD_INDEX_ENTRY_SIZE = 46;
// Header on-disk size: magic=8, version=2, numGames=3, baseType=4, autoLoad=3
// Description length = 111 bytes including trailing '\0'.
// Custom flag desc length = 9 bytes including trailing '\0'.
// So total is 128 bytes + 9*6 = 182 bytes for the whole header.
constexpr size_t INDEX_HEADER_SIZE = 8 + 2 + 3 + 4 + 3 + SCID_DESC_LENGTH + 1 +
                                     (CUSTOM_FLAG_DESC_LENGTH + 1) *
                                         CUSTOM_FLAG_MAX;

/// Read the header section of a SCIDv4 Index file into memory.
/// @param indexFile: file handle positioned at the start of the Index file.
/// @param fMode:     a valid file mode.
/// @param header:    reference to the object where the data will be stored.
/// @returns OK if successful or an error code.
template <typename FileT, typename HeaderT>
std::pair<errorT, gamenumT> readIndexHeader(FileT& indexFile, HeaderT& header) {
	char magic[8];
	indexFile.sgetn(magic, 8);
	if (!std::equal(std::begin(magic), std::end(magic), std::begin(INDEX_MAGIC),
	                std::end(INDEX_MAGIC))) {
		return {ERROR_BadMagic, {}};
	}

	header.version = indexFile.ReadTwoBytes();
	header.baseType = indexFile.ReadFourBytes();
	auto numGames = indexFile.ReadThreeBytes();
	header.autoLoad = indexFile.ReadThreeBytes();
	char desc[SCID_DESC_LENGTH + 1];
	indexFile.sgetn(desc, SCID_DESC_LENGTH + 1);
	header.description.assign(desc,
	                          std::find(desc, desc + SCID_DESC_LENGTH, '\0'));
	if (header.version >= 400) {
		for (size_t i = 0; i < CUSTOM_FLAG_MAX; i++) {
			char buf[CUSTOM_FLAG_DESC_LENGTH + 1];
			indexFile.sgetn(buf, CUSTOM_FLAG_DESC_LENGTH + 1);
			header.flagDesc[i].assign(
			    buf, std::find(buf, buf + CUSTOM_FLAG_DESC_LENGTH, '\0'));
		}
	}
	return {OK, numGames};
}

/// Write the header section of a SCIDv4 Index file.
/// @param indexFile: file handle of the Index file.
/// @param header:    reference to the object containing the header data.
/// @returns OK if successful or an error code.
template <typename FileT, typename HeaderT>
errorT writeIndexHeader(FileT& indexFile, HeaderT const& Header,
                        gamenumT nGames) {
	if (indexFile.pubseekpos(0) != std::streampos(0))
		return ERROR_FileWrite;

	std::streamsize n = 0;
	n += indexFile.sputn(INDEX_MAGIC, 8);
	n += indexFile.WriteTwoBytes(Header.version);
	n += indexFile.WriteFourBytes(Header.baseType);
	n += indexFile.WriteThreeBytes(nGames);
	n += indexFile.WriteThreeBytes(Header.autoLoad);
	char desc[SCID_DESC_LENGTH + 1] = {};
	std::copy_n(Header.description.data(),
	            std::min(Header.description.size(), SCID_DESC_LENGTH), desc);
	n += indexFile.sputn(desc, SCID_DESC_LENGTH + 1);
	for (auto const& flagDesc : Header.flagDesc) {
		char buf[CUSTOM_FLAG_DESC_LENGTH + 1] = {};
		std::copy_n(flagDesc.data(),
		            std::min(flagDesc.size(), CUSTOM_FLAG_DESC_LENGTH), buf);

		n += indexFile.sputn(buf, CUSTOM_FLAG_DESC_LENGTH + 1);
	}
	if (n != INDEX_HEADER_SIZE || indexFile.pubsync() == -1)
		return ERROR_FileWrite;

	return OK;
}

} // namespace

/// Decode SCID4 (or SCID3) data into an IndexEntry object.
/// @param buf_it:  pointer to the buffer containing the data
///                 (should contain INDEX_ENTRY_SIZE chars)
/// @param version: 400 for SCID4 or 300 for SCID3.
/// @param ie:      pointer to the IndexEntry object where the data will be
///                 stored.
void decodeIndexEntry(const char* buf_it, versionT version, IndexEntry* ie) {
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
	ie->SetHomePawnData(pawnData0 & 0x3F,
	                    reinterpret_cast<const unsigned char*>(buf_it));
}

/// Enccode an IndexEntry to SCID4 format.
/// @param buf_it:  pointer to the buffer where the data would be stored
///                 (should be able to contain at least INDEX_ENTRY_SIZE chars)
void encodeIndexEntry(const IndexEntry* ie, char* buf_it) {
	auto WriteOneByte = [&buf_it](uint8_t v) { *buf_it++ = v; };
	auto WriteTwoBytes = [&WriteOneByte](uint16_t v) {
		WriteOneByte(static_cast<uint8_t>(v >> 8));
		WriteOneByte(static_cast<uint8_t>(v));
	};
	auto WriteFourBytes = [&WriteTwoBytes](uint32_t v) {
		WriteTwoBytes(static_cast<uint16_t>(v >> 16));
		WriteTwoBytes(static_cast<uint16_t>(v));
	};

	ASSERT(ie->GetOffset() < (1ULL << 32));
	WriteFourBytes(static_cast<uint32_t>(ie->GetOffset()));

	ASSERT(ie->GetLength() < (1ULL << 17));
	WriteTwoBytes(static_cast<uint16_t>(ie->GetLength()));
	uint8_t len_flags = static_cast<uint8_t>(ie->GetLength() >> 9) & 0x80;
	len_flags |= static_cast<uint8_t>(ie->flags_ >> 16) & 0x3F;
	WriteOneByte(len_flags);
	WriteTwoBytes(static_cast<uint16_t>(ie->flags_));

	// WhiteID and BlackID are 20-bit values, EventID and SiteID are
	// 19-bit values, and RoundID is an 18-bit value.
	// WhiteID high 4 bits = bits 4-7 of WhiteBlack_High.
	// BlackID high 4 bits = bits 0-3 of WhiteBlack_High.
	// EventID high 3 bits = bits 5-7 of EventSiteRnd_high.
	// SiteID  high 3 bits = bits 2-4 of EventSiteRnd_high.
	// RoundID high 2 bits = bits 0-1 of EventSiteRnd_high.
	ASSERT(std::max(ie->GetWhite(), ie->GetBlack()) < (1ULL << 20));
	uint32_t WhiteID_Low = ie->GetWhite();
	uint32_t BlackID_Low = ie->GetBlack();
	uint32_t WhiteBlack_High = (WhiteID_Low & 0x0F0000) >> 12;
	WhiteBlack_High |= (BlackID_Low & 0x0F0000) >> 16;
	WriteOneByte(static_cast<uint8_t>(WhiteBlack_High));
	WriteTwoBytes(static_cast<uint16_t>(WhiteID_Low));
	WriteTwoBytes(static_cast<uint16_t>(BlackID_Low));

	ASSERT(std::max(ie->GetEvent(), ie->GetSite()) < (1ULL << 19));
	ASSERT(ie->GetRound() < (1ULL << 18));
	uint32_t EventID_Low = ie->GetEvent();
	uint32_t SiteID_Low = ie->GetSite();
	uint32_t RoundID_Low = ie->GetRound();
	uint32_t EventSiteRnd_High = (EventID_Low & 0x070000) >> 11;
	EventSiteRnd_High |= (SiteID_Low & 0x070000) >> 14;
	EventSiteRnd_High |= (RoundID_Low & 0x030000) >> 16;
	WriteOneByte(static_cast<uint8_t>(EventSiteRnd_High));
	WriteTwoBytes(static_cast<uint16_t>(EventID_Low));
	WriteTwoBytes(static_cast<uint16_t>(SiteID_Low));
	WriteTwoBytes(static_cast<uint16_t>(RoundID_Low));

	uint16_t varCounts = ie->nVariations_ & 0x0F;
	varCounts |= static_cast<uint16_t>(ie->nComments_ & 0x0F) << 4;
	varCounts |= static_cast<uint16_t>(ie->nNags_ & 0x0F) << 8;
	varCounts |= static_cast<uint16_t>(ie->GetResult() & 0x0F) << 12;
	WriteTwoBytes(varCounts);

	WriteTwoBytes(ie->GetEcoCode());

	// Due to a compact encoding format, the EventDate
	// must be within a few years of the Date.
	uint32_t date = ie->GetDate() & 0xFFFFF;
	uint32_t edate = ie->GetEventDate();
	uint32_t eyear = date_GetYear(edate);
	uint32_t dyear = date_GetYear(date);
	if ((eyear + 3) < dyear || eyear > (dyear + 3)) {
		edate = ZERO_DATE;
	} else {
		eyear = (eyear + 4 - dyear) & 7;
		edate = (eyear << 9) | (date_GetMonth(edate) << 5) | date_GetDay(edate);
	}
	WriteFourBytes((edate << 20) | date);

	// Elo ratings and rating types: 2 bytes each.
	uint16_t wElo = std::min(MAX_ELO, ie->GetWhiteElo());
	wElo |= static_cast<uint16_t>(ie->GetWhiteRatingType()) << 12;
	uint16_t bElo = std::min(MAX_ELO, ie->GetBlackElo());
	bElo |= static_cast<uint16_t>(ie->GetBlackRatingType()) << 12;
	WriteTwoBytes(wElo);
	WriteTwoBytes(bElo);

	ASSERT(ie->GetFinalMatSig() < (1ULL << 24));
	ASSERT(ie->GetStoredLineCode() < (1ULL << 8));
	uint32_t FinalMatSig = ie->GetFinalMatSig();
	FinalMatSig |= static_cast<uint32_t>(ie->GetStoredLineCode()) << 24;
	WriteFourBytes(FinalMatSig);

	// The first byte of HomePawnData has high bits of the NumHalfMoves
	// counter in its top two bits:
	uint16_t nMoves = ie->GetNumHalfMoves();
	ASSERT(nMoves < (1ULL << 10));
	WriteOneByte(static_cast<uint8_t>(nMoves));
	uint8_t pawnData0 = static_cast<uint8_t>(nMoves >> 8) << 6;

	// Write the 9-byte homePawnData array:
	const byte* pb = ie->GetHomePawnData();
	pawnData0 |= *pb & 0x3F;
	WriteOneByte(pawnData0);
	std::copy(pb + 1, pb + HPSIG_SIZE, buf_it);
}

errorT CodecSCID4::dyn_open(fileModeT fMode, const char* filename,
                            const Progress& progress, Index* idx,
                            NameBase* nb) {
	if (fMode == FMODE_WriteOnly || !filename || !idx || !nb)
		return ERROR;
	if (*filename == '\0')
		return ERROR_FileOpen;

	idx_ = idx;
	idx_->Init();
	nb_ = nb;
	filenames_.resize(3);
	filenames_[0] = std::string(filename) + ".si4";
	filenames_[1] = std::string(filename) + ".sn4";
	filenames_[2] = std::string(filename) + ".sg4";

	errorT err = gfile_.open(filenames_[2], fMode);
	if (err != OK)
		return err;

	const char* indexFilename = filenames_[0].c_str();
	if (fMode == FMODE_Create) {
		// Check that the file does not exists
		if (idxfile_.Open(indexFilename, FMODE_ReadOnly) == OK)
			err = ERROR_FileOpen;

		if (err == OK)
			err = idxfile_.Open(indexFilename, FMODE_Create);

		if (err == OK)
			err = writeIndexHeader(idxfile_, header_, idx_->GetNumGames());

		if (err == OK) {
			err = namefileWrite(filenames_[1].c_str(), nb_->getNames(),
			                    nb->calcNameFreq(*idx_));
		}
	} else {
		if (auto err = namefileRead(filenames_[1].c_str(), fMode, *nb_))
			return err;

		if (auto err = idxfile_.Open(indexFilename, fMode))
			return err;

		auto [errHeader, nGames] = readIndexHeader(idxfile_, header_);
		if (errHeader)
			return errHeader;

		constexpr versionT SCID_OLDEST_VERSION = 300; // Oldest readable version
		if (header_.version < SCID_OLDEST_VERSION ||
		    header_.version > SCID_VERSION)
			return ERROR_FileVersion;

		if (header_.version != SCID_VERSION && fMode != FMODE_ReadOnly)
			return ERROR_FileMode; // Old versions must be opened readonly

		err = readIndex(nGames, progress);
	}

	return err;
}

errorT CodecSCID4::flush() {
	seqWrite_ = 0;
	errorT errHeader = OK;
	if (header_.dirty) {
		errHeader = writeIndexHeader(idxfile_, header_, idx_->GetNumGames());
		if (errHeader == OK)
			header_.dirty = false;
	}
	errorT errSync = (idxfile_.pubsync() != 0) ? ERROR_FileWrite : OK;
	errorT err = (errHeader == OK) ? errSync : errHeader;

	if (err == OK) {
		// *** Compatibility ***
		// Even if name's frequency is no longer used, it's necessary to
		// keep the compatibility with older Scid versions, forcing a
		// recalculation.
		err = namefileWrite(filenames_[1].c_str(), nb_->getNames(),
		                    nb_->calcNameFreq(*idx_));
	}
	errorT errGfile = (gfile_.pubsync() == 0) ? OK : ERROR_FileWrite;

	return (err == OK) ? errGfile : err;
}

/**
 * Reads the entire index file into memory.
 * Invalid name IDs are replaced with "?" if possible.
 * @param progress: a Progress object used for GUI communications.
 * @returns OK if successful or an error code.
 */
errorT CodecSCID4::readIndex(gamenumT nGames, Progress const& progress) {
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

	idx_->entries_.resize(nGames);
	const auto nBytes = (header_.version < 400) ? OLD_INDEX_ENTRY_SIZE
	                                            : INDEX_ENTRY_SIZE;
	for (gamenumT gNum = 0; idxfile_.sgetc() != EOF; ++gNum) {
		if (gNum == nGames)
			return ERROR_CorruptData;

		if ((gNum % 8192) == 0) {
			if (!progress.report(gNum, nGames))
				return ERROR_UserCancel;
		}

		char buf[INDEX_ENTRY_SIZE];
		if (idxfile_.sgetn(buf, nBytes) != nBytes)
			return ERROR_FileRead;

		IndexEntry& ie = idx_->entries_[gNum];
		decodeIndexEntry(buf, header_.version, &ie);

		if (!validateNameIDs(&ie))
			return ERROR_CorruptData;
	}
	progress.report(1, 1);

	idx_->nInvalidNameId_ = nUnknowIDs;
	return (nUnknowIDs == 0) ? OK : ERROR_NameDataLoss;
}

errorT CodecSCID4::writeEntry(const IndexEntry& ie, gamenumT gnum) {
	if (seqWrite_ == 0 || (gnum != seqWrite_ + 1)) {
		std::streampos pos = gnum;
		pos = pos * INDEX_ENTRY_SIZE + INDEX_HEADER_SIZE;
		if (idxfile_.pubseekpos(pos) != pos) {
			seqWrite_ = 0;
			return ERROR_FileWrite;
		}
	}
	char buf[INDEX_ENTRY_SIZE];
	encodeIndexEntry(&ie, buf);
	errorT res = idxfile_.sputn(buf, INDEX_ENTRY_SIZE) == INDEX_ENTRY_SIZE
	                 ? OK
	                 : ERROR_FileWrite;

	seqWrite_ = (res == OK) ? gnum : 0;
	return res;
}

errorT CodecSCID4::setExtraInfo(const char* tagname, const char* new_value) {
	if (std::strcmp(tagname, "type") == 0) {
		header_.baseType = strGetUnsigned(new_value);

	} else if (std::strcmp(tagname, "description") == 0) {
		header_.description = new_value;
		if (header_.description.size() > SCID_DESC_LENGTH)
			header_.description.resize(SCID_DESC_LENGTH);

	} else if (std::strcmp(tagname, "autoload") == 0) {
		header_.autoLoad = strGetUnsigned(new_value);

	} else {
		auto len = std::strlen(tagname);
		if (len != 5 || !std::equal(tagname, tagname + 4, "flag"))
			return ERROR_CodecUnsupFeat;

		uint flag = IndexEntry::CharToFlag(tagname[4]);
		if (flag < IndexEntry::IDX_FLAG_CUSTOM1 ||
		    flag > IndexEntry::IDX_FLAG_CUSTOM6)
			return ERROR_CodecUnsupFeat;

		const auto idx = flag - IndexEntry::IDX_FLAG_CUSTOM1;
		header_.flagDesc[idx] = new_value;
		if (header_.flagDesc[idx].size() > CUSTOM_FLAG_DESC_LENGTH)
			header_.flagDesc[idx].resize(CUSTOM_FLAG_DESC_LENGTH);
	}

	header_.dirty = true;
	return OK;
}
