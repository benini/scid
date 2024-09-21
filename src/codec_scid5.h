/*
 * Copyright (C) 2022  Fulvio Benini.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/** @file
 * Implements the CodecSCID5 class.
 */

#pragma once

#include "codec.h"
#include "filebuf.h"
#include "index.h"
#include "namebase.h"
#include <algorithm>
#include <array>
#include <cstdint>
#include <filesystem>
#include <future>
#include <string>
#include <string_view>
#include <vector>

// -----------------------------------------------------------------------------
// SCID database version 5.
// -----------------------------------------------------------------------------
//
// The database is composed of 3 files:
// database_name.si5 -> Index
// database_name.sn5 -> Namebase
// database_name.sg5 -> Games
// The Index file contains a fixed size record for each game (see below for
// details). Using a fixed size have some advantages, mainly the ability to
// overwrite a record in the middle of the file, but creates a few limit:
// - Maximum number of games: 4 billion
// - Maximum size of the games' data file (.sg5): 128TB
// - Maximum size of each game's data (extra tags, moves, comments): 128KB
// - Maximum number of unique player names: 268 million (2^28 = 268435456)
// - Maximum number of unique values for the tag "Event": 268 million (2^28).
// - Maximum number of unique values for the tag "Round": 2 billion (2^31).
//
// Index
// The index file (extension .si5) contains a record of 56 byte for each game.
// A record consists of 12 uint32_t (12 * 4 = 48 bytes) encoded as little-endian
// and 8 bytes at the end for the "home pawn" data.
// The fields are:
// -  4 bits - rating* based on the number of comment
// - 28 bits - while player ID (reference to the Namebase)
// -  4 bits - rating* based on the number of RAV (alternative move sequence)
// - 28 bits - black player ID (reference to the Namebase)
// -  4 bits - rating* based on the number of NAGs (Numeric Annotation Glyphs)
// - 28 bits - event ID (reference to the Namebase)
// - 32 bits - site ID (reference to the Namebase)
// -  1 bit  - 0 = standard chess; 1 = chess960
// - 31 bits - round ID (reference to the Namebase)
// - 12 bits - white elo (max 4000)
// - 20 bits - game's date (max 2047-12-31)
// - 12 bits - black's elo (max 4000)
// - 20 bits - events's date (max 2047-12-31)
// - 10 bits - half moves (ply) count (max 1023)
// - 22 bits - flags*
// - 17 bits - game's data size
// - 15 bits - higher bits of the game's data offset
// - 32 bits - lower bits of the game's data offset
// -  8 bits - stored line code
// - 24 bits - final material
// -  8 bits - home pawn count
// -  3 bits - white elo type
// -  3 bits - black elo type
// -  2 bits - result
// - 16 bits - ECO code
// - 64 bits - home pawn data
// *Ratings
// Three ratings are assigned to each game based on the number of comments, the
// number of variations and the number of tags. This are usually used to find
// the most annotated games. A rating range from 0 to 15 and it is calculated
// rounding the real count to the one closest to:
// 0,1,2,3,4,5,6,7,8,9,10,15,20,30,40,50.
//    For example:
//    16 is rounded to 15
//    12 is rounded to 10
//    26 to 30
// *Flags
// Used to mark games. For example duplicate games can be marked for deletion.
// The operation can be reversed removing the flag for one or more games.
// Only compacting the database irreversibly deletes the games.
//
// Namebase
// The NameBase file (extension .sn5) is a sequence of strings with an
// associated type (PLAYER, EVENT, SITE, ROUND, DB_INFO).
// The string are encoded as a varint (length * 8 + type) followed by the data.
// The last 3 bits of the varint store the name type.
// The file is append only. When a game is modified with a new name, it is added
// to the NameBase and the new ID is written in the game's IndexEntry.
//
// 1) number of characters for tags.
//    The tag name must consist of at least one character and at most 240 (range
//    [1: 240] ). The tag value must have a maximum of 255 characters (range [0:
//    255] ).
// The IDs are sequentially increasing values ​​starting with value 0
// The tag values ​​cannot contain the null char ('\0').
// 10) The most important limitation in my opinion is that neither the tags nor
//     the comments are compressed in any way. It is now common to have games
//     where the clock and the eventual evaluation of each position are stored
//     as comments, and it would be possible to save a lot of space.
//
// Games
// The Games file (extension .sg5) contains blobs of data; for each game:
// - the extra (not stored in the Index) tag pairs
// - the optional FEN of the initial position
// - the moves of the game
// - the comments
// The moves are encoded in one byte and the most significant 4-bits are the
// index of the moving piece. The king always has index 0. This implies that all
// the moves of the other pieces always have a value >15. A king have only 8
// possible moves, leaving room for encoding special values:
// 0 -> null move
// 9 -> castle queenside
// 10 -> castle kingside
// 11 -> NAG
// 12 -> comment placeholder
// 13 -> start variation
// 14 -> end variation
// 15 -> end game
// Placeholders for the last comments may be omitted if they are not necessary:
//   d4 {first comment] d5 c4 {2nd} c6 {3rd} Nc3 {4th} Nf6 Nf3
// is encoded as
//   d4 {} d5 c4 {} c6 Nc3 Nf6 Nf3
// The extra tag pairs are encoded as a fixed 1 byte length followed by the
// data. An empty tag name is not allowed.
// The tag name can have at most 240 characters (range [1:240] ).
// The tag value can have at most 255 characters (range [0:255] ).

// This class manages databases encoded in SCID format v5.
class CodecSCID5 final : public ICodecDatabase {
	Index* idx_ = nullptr;
	NameBase* nb_ = nullptr;
	std::vector<std::string> filenames_;
	std::vector<std::pair<const char*, std::string>> db_info_ = {
	    {"type", {}},  {"description", {}}, {"autoload", {}},
	    {"flag1", {}}, {"flag2", {}},       {"flag3", {}},
	    {"flag4", {}}, {"flag5", {}},       {"flag6", {}},
	};
	FilebufAppend gfile_;
	FilebufAppend nbfile_;
	Filebuf idxfile_;
	gamenumT idx_seqwrite_ = 0;
	char gcache_[1ULL << 17];

	enum : unsigned long long {
		LIMIT_GAMEOFFSET = 1ULL << 47,
		LIMIT_GAMELEN = 1ULL << 17,
		LIMIT_NUMGAMES = (1ULL << 32) - 2,
		LIMIT_UNIQUENAMES_PLAYER_EVENT = 1ULL << 28,
		LIMIT_UNIQUENAMES_ROUND = 1ULL << 31,
		LIMIT_UNIQUENAMES_SITE = 1ULL << 32
	};

	static constexpr auto INDEX_ENTRY_SIZE = 56;
	static constexpr unsigned NAME_INFO = 4;

public: // ICodecDatabase interface
	Codec getType() const final { return ICodecDatabase::SCID5; }

	// Returns the full path of the three files (index, namebase and gamefile)
	// used by the database.
	std::vector<std::string> getFilenames() const final { return filenames_; };

	std::vector<std::pair<const char*, std::string>>
	getExtraInfo() const final {
		return db_info_;
	}

	errorT setExtraInfo(const char* name, const char* new_value) final {
		return set_db_info(std::string(name).append(new_value));
	};

	ByteBuffer getGameData(uint64_t offset, uint32_t length) final {
		if (offset >= gfile_.size())
			return {nullptr, 0};
		if (length >= LIMIT_GAMELEN)
			return {nullptr, 0};

		if (gfile_.pubseekpos(offset) < 0)
			return {nullptr, 0};
		if (gfile_.sgetn(gcache_, length) != length)
			return {nullptr, 0};

		return {reinterpret_cast<const byte*>(gcache_), length};
	}

	ByteBuffer getGameMoves(IndexEntry const& ie) final {
		auto data = getGameData(ie.GetOffset(), ie.GetLength());
		if (data && OK == data.decodeTags([](auto, auto) {}))
			return data;

		return {nullptr, 0};
	}

	errorT addGame(IndexEntry const& ie_src, TagRoster const& tags,
	               ByteBuffer const& data) final {
		const auto nGames = idx_->GetNumGames();
		if (nGames >= LIMIT_NUMGAMES)
			return ERROR_NumGamesLimit;

		IndexEntry ie = ie_src;
		if (auto err = add_names_and_data(ie, tags, data))
			return err;

		if (auto err = write_IndexEntry(ie, nGames))
			return err;

		idx_->addEntry(ie);
		return OK;
	}

	errorT saveGame(IndexEntry const& ie_src, TagRoster const& tags,
	                ByteBuffer const& data, gamenumT replaced) final {
		IndexEntry ie = ie_src;
		if (auto err = add_names_and_data(ie, tags, data))
			return err;

		return saveIndexEntry(ie, replaced);
	}

	errorT saveIndexEntry(const IndexEntry& ie, gamenumT replaced) final {
		if (auto err = write_IndexEntry(ie, replaced))
			return err;

		idx_->replaceEntry(ie, replaced);
		return OK;
	}

	std::pair<errorT, idNumberT> addName(nameT nt, const char* name) final {
		idNumberT id;
		if (OK == nb_->FindExactName(nt, name, &id))
			return {OK, id};

		static constexpr auto limit_unique_names = [] {
			std::array<unsigned long long, NUM_NAME_TYPES> res;
			res[NAME_PLAYER] = LIMIT_UNIQUENAMES_PLAYER_EVENT;
			res[NAME_EVENT] = LIMIT_UNIQUENAMES_PLAYER_EVENT;
			res[NAME_SITE] = LIMIT_UNIQUENAMES_SITE;
			res[NAME_ROUND] = LIMIT_UNIQUENAMES_ROUND;
			return res;
		}();
		if (nb_->namebase_size(nt) >= limit_unique_names[nt])
			return {ERROR_NameLimit, 0};

		if (auto err = append_nbfile(nt, name))
			return {err, 0};

		return {OK, nb_->namebase_add(nt, name)};
	}

	errorT flush() final {
		idx_seqwrite_ = 0;
		errorT errGfile = (gfile_.pubsync() == 0) ? OK : ERROR_FileWrite;
		errorT errNBfile = (nbfile_.pubsync() == 0) ? OK : ERROR_FileWrite;
		errorT errIndex = (idxfile_.pubsync() == 0) ? OK : ERROR_FileWrite;
		return errIndex ? errIndex : errGfile ? errGfile : errNBfile;
	}

	errorT dyn_open(fileModeT fmode, const char* dbname,
	                const Progress& progress, Index* idx, NameBase* nb) final {
		if (fmode == FMODE_WriteOnly || !dbname || !idx || !nb)
			return ERROR;

		idx_ = idx;
		nb_ = nb;

		auto dbpath = std::filesystem::path(dbname);
		if (dbpath.stem().empty())
			return ERROR_FileOpen;

		filenames_.resize(3);
		filenames_[0] = dbpath.extension().empty()
		                    ? dbpath.replace_extension("si5").string()
		                    : dbpath.string();
		filenames_[1] = dbpath.replace_extension("sg5").string();
		filenames_[2] = dbpath.replace_extension("sn5").string();

		if (fmode == FMODE_Create) {
			for (auto const& fname : filenames_) {
				std::error_code ec;
				if (std::filesystem::exists(fname, ec) || ec)
					return ERROR_Exists;
			}

			if (auto err = idxfile_.Open(filenames_[0].c_str(), fmode))
				return err;

			if (auto err = gfile_.open(filenames_[1], fmode))
				return err;

			return nbfile_.open(filenames_[2], fmode);
		}

		auto read_names = std::async(std::launch::async,
		                             &CodecSCID5::read_nbfile, this, fmode,
		                             filenames_[2]);

		auto err_idx = read_index(fmode, filenames_[0].c_str(), progress);
		auto err_games = gfile_.open(filenames_[1], fmode);
		auto err_names = read_names.get();
		progress.report(1, 1);

		if (!err_names && nb_->count_invalid_ids(*idx_) > 0) {
			err_names = ERROR_CorruptData;
			// TODO: err_names = ERROR_NameDataLoss;
		}
		return err_idx ? err_idx : err_games ? err_games : err_names;
	}

private:
	/// Add the game's roster tags and gamedata to the database.
	/// Set the references to the new data in @e ie.
	errorT add_names_and_data(IndexEntry& ie, TagRoster const& tags,
	                          ByteBuffer const& data) {
		const auto data_sz = data.size();
		if (data_sz >= LIMIT_GAMELEN)
			return ERROR_GameLengthLimit;

		if (auto err = tags.map(
		        ie, [&](auto nt, auto name) { return addName(nt, name); }))
			return err;

		// The SCID5 format stores games into blocks of 128KB.
		// If the current block does not have enough space, we fill it with
		// random data and use the next one.
		const char* gdata = reinterpret_cast<const char*>(data.data());
		uint64_t blockSpace = LIMIT_GAMELEN - (gfile_.size() % LIMIT_GAMELEN);
		if (blockSpace < data_sz) {
			if (auto err = gfile_.append(gdata, blockSpace))
				return err;
		}

		uint64_t offset = gfile_.size();
		if (offset >= LIMIT_GAMEOFFSET)
			return ERROR_OffsetLimit;

		ie.SetOffset(offset);
		ie.SetLength(data_sz);
		return gfile_.append(gdata, data_sz);
	}

	// Read all the IndexEntry contained in the Index file.
	errorT read_index(fileModeT fmode, const char* fname,
	                  Progress const& progress) {
		if (auto err = idxfile_.Open(fname, fmode))
			return err;

		const auto file_size = idxfile_.pubseekoff(0, std::ios::end);
		if (file_size < 0 || (file_size % INDEX_ENTRY_SIZE) != 0 ||
		    idxfile_.pubseekoff(0, std::ios::beg) != 0) {
			return ERROR_Corrupt;
		}

		const size_t n_games = file_size / INDEX_ENTRY_SIZE;
		idx_->entries_.resize(n_games);
		constexpr auto eof = Filebuf::traits_type::eof();
		for (size_t gnum = 0; idxfile_.sgetc() != eof; ++gnum) {
			if ((gnum % 8192) == 0) {
				if (!progress.report(gnum, n_games))
					return ERROR_UserCancel;
			}

			char buf[INDEX_ENTRY_SIZE];
			if (idxfile_.sgetn(buf, INDEX_ENTRY_SIZE) != INDEX_ENTRY_SIZE)
				return ERROR_FileRead;

			idx_->entries_[gnum] = decode_IndexEntry(buf);
		}
		return OK;
	}

	// Write an IndexEntry into the Index file.
	// Stores gnum (gamenumT of the last written IndexEntry) into idx_seqwrite_
	// and avoid invoking pubseekpos() if it is not necessary.
	errorT write_IndexEntry(IndexEntry const& ie, gamenumT gnum) {
		if (idx_seqwrite_ == 0 || (gnum != idx_seqwrite_ + 1)) {
			std::streampos pos = gnum;
			pos = pos * INDEX_ENTRY_SIZE;
			if (idxfile_.pubseekpos(pos) != pos) {
				idx_seqwrite_ = 0;
				return ERROR_FileWrite;
			}
		}
		char buf[INDEX_ENTRY_SIZE];
		encode_IndexEntry(ie, buf);
		auto res = idxfile_.sputn(buf, INDEX_ENTRY_SIZE) == INDEX_ENTRY_SIZE
		               ? OK
		               : ERROR_FileWrite;

		idx_seqwrite_ = (res == OK) ? gnum : 0;
		return res;
	}

	void encode_IndexEntry(IndexEntry const& ie, char* buf) {
		auto pack = [](uint32_t a, auto a_sz, uint32_t b) {
			assert(a < (uint32_t(1) << a_sz));
			assert(b < (uint32_t(1) << (32 - a_sz)));
			return (a << (32 - a_sz)) | b;
		};

		const auto counts = ie.GetRaw4bitsCounts();
		const auto nVariations = counts & 0x0F;
		const auto nComments = (counts >> 4) & 0x0F;
		const auto nNags = (counts >> 8) & 0x0F;

		const auto chess960 = ie.isChessStd() ? 0 : 1;
		const auto rtypes_result = (ie.GetWhiteRatingType() << 5) |
		                           (ie.GetBlackRatingType() << 2) |
		                           ie.GetResult();
		auto home_pawn = ie.GetHomePawnData();
		const uint32_t home_pawn_count = *home_pawn++;
		encode_uint32(buf + 0, pack(nComments, 4, ie.GetWhite()));
		encode_uint32(buf + 4, pack(nVariations, 4, ie.GetBlack()));
		encode_uint32(buf + 8, pack(nNags, 4, ie.GetEvent()));
		encode_uint32(buf + 12, ie.GetSite());
		encode_uint32(buf + 16, pack(chess960, 1, ie.GetRound()));
		encode_uint32(buf + 20, pack(ie.GetWhiteElo(), 12, ie.GetDate()));
		encode_uint32(buf + 24, pack(ie.GetBlackElo(), 12, ie.GetEventDate()));
		encode_uint32(buf + 28,
		              pack(ie.GetNumHalfMoves(), 10, ie.GetRawFlags()));
		encode_uint32(buf + 32, pack(ie.GetLength(), 17, ie.GetOffset() >> 32));
		encode_uint32(buf + 36, static_cast<uint32_t>(ie.GetOffset()));
		encode_uint32(buf + 40,
		              pack(ie.GetStoredLineCode(), 8, ie.GetFinalMatSig()));
		encode_uint32(buf + 44, pack((home_pawn_count << 8) | rtypes_result, 16,
		                             ie.GetEcoCode()));
		std::copy_n(home_pawn, 8, buf + 48);
	}

	IndexEntry decode_IndexEntry(const char* data) {
		auto unpack = [](uint32_t val, auto sz) {
			const auto clear_high = val << sz;
			return std::pair(val >> (32 - sz), clear_high >> sz);
		};
		auto res = IndexEntry();

		auto val = unpack(decode_uint32(data + 0), 4);
		res.SetRawCommentCount(val.first);
		res.SetWhite(val.second);

		val = unpack(decode_uint32(data + 4), 4);
		res.SetRawVariationCount(val.first);
		res.SetBlack(val.second);

		val = unpack(decode_uint32(data + 8), 4);
		res.SetRawNagCount(val.first);
		res.SetEvent(val.second);

		res.SetSite(decode_uint32(data + 12));

		val = unpack(decode_uint32(data + 16), 1);
		if (val.first)
			res.setChess960();
		res.SetRound(val.second);

		val = unpack(decode_uint32(data + 20), 12);
		res.SetWhiteElo(val.first);
		res.SetDate(val.second);

		val = unpack(decode_uint32(data + 24), 12);
		res.SetBlackElo(val.first);
		res.SetEventDate(val.second);

		val = unpack(decode_uint32(data + 28), 10);
		res.SetNumHalfMoves(val.first);
		res.SetFlag(val.second, true);

		val = unpack(decode_uint32(data + 32), 17);
		res.SetLength(val.first);
		res.SetOffset((static_cast<uint64_t>(val.second) << 32) |
		              decode_uint32(data + 36));

		val = unpack(decode_uint32(data + 40), 8);
		res.SetStoredLineCode(val.first);
		res.SetFinalMatSig(val.second);

		val = unpack(decode_uint32(data + 44), 16);
		const auto home_pawn_count = val.first >> 8;
		res.SetWhiteRatingType((val.first >> 5) & 0b00000111);
		res.SetBlackRatingType((val.first >> 2) & 0b00000111);
		res.SetResult(val.first & 0b00000011);
		res.SetEcoCode(val.second);

		res.SetHomePawnData(home_pawn_count,
		                    reinterpret_cast<const byte*>(data + 48));
		return res;
	}

	// Read all the strings contained in the NameBase file.
	// The string are encoded as a varint (length+type) followed by the data.
	// The last 3 bits of the varint store the name type.
	errorT read_nbfile(fileModeT fMode, std::string const& filename) {
		if (auto err = nbfile_.open(filename, fMode))
			return err;

		if (nbfile_.pubseekpos(0))
			return ERROR_FileRead;

		auto buf = std::vector<char>(1024);
		auto ch = Filebuf::traits_type::eof();
		while ((ch = nbfile_.sbumpc()) != Filebuf::traits_type::eof()) {
			auto [nt, len] = read_nbvarint(ch);
			if (nt > NAME_INFO || len > nbfile_.size())
				return ERROR_Corrupt;

			if (len > buf.size()) {
				buf.resize(len);
			}
			if (uint64_t nread = nbfile_.sgetn(buf.data(), len); nread != len)
				return ERROR_Corrupt;

			if (nt < NUM_NAME_TYPES) {
				nb_->namebase_add(nt, {buf.data(), len});
			} else {
				// Ignore unknown extra info. This way, new fields can be added
				// without breaking compatibility with old versions.
				set_db_info({buf.data(), len}, false);
			}
		}
		return OK;
	}

	// Read a varint from the NameBase file and split the type from the length.
	std::pair<uint8_t, uint64_t>
	read_nbvarint(Filebuf::traits_type::int_type ch) {
		ASSERT(ch >= 0);

		uint64_t res = 0;
		for (int shift = 0; shift < 64; shift += 7) {
			uint8_t val = Filebuf::traits_type::to_char_type(ch);
			res |= (static_cast<uint64_t>(val & 127) << shift);
			if (val < 128) {
				return {static_cast<uint8_t>(res & 0b111), res >> 3};
			}

			ch = nbfile_.sbumpc();
			if (ch == Filebuf::traits_type::eof())
				break;
		}
		return {0b1000, 0};
	}

	// Add a new name to the NameBase file. The string is encoded as a varint
	// (length + type in the least significant 3 bits) followed by the data.
	errorT append_nbfile(unsigned nt, std::string_view name) {
		ASSERT(nt <= NAME_INFO);

		uint64_t val = name.size();
		val = (val << 3) | (nt & 0b111);
		uint8_t buf[10];
		auto n = encode_varint(buf, val);

		if (auto err = nbfile_.append(reinterpret_cast<char const*>(buf), n))
			return err;

		if (auto err = nbfile_.append(name.data(), name.size()))
			return err;

		return OK;
	}

	errorT set_db_info(std::string_view new_value, bool write = true) {
		auto it = std::find_if(db_info_.begin(), db_info_.end(),
		                       [&](auto const& elem) {
			                       return new_value.starts_with(elem.first);
		                       });
		if (it == db_info_.end())
			return ERROR_CodecUnsupFeat;

		if (write) {
			if (auto err = append_nbfile(NAME_INFO, new_value))
				return err;
		}
		it->second = new_value.substr(std::string_view(it->first).size());
		return OK;
	};

	static inline void encode_uint32(char* dst, uint32_t value) {
		uint8_t* const buf = reinterpret_cast<uint8_t*>(dst);
		buf[0] = static_cast<uint8_t>(value);
		buf[1] = static_cast<uint8_t>(value >> 8);
		buf[2] = static_cast<uint8_t>(value >> 16);
		buf[3] = static_cast<uint8_t>(value >> 24);
	}

	static inline uint32_t decode_uint32(const char* src) {
		const uint8_t* const buf = reinterpret_cast<const uint8_t*>(src);
		return (static_cast<uint32_t>(buf[0])) |
		       (static_cast<uint32_t>(buf[1]) << 8) |
		       (static_cast<uint32_t>(buf[2]) << 16) |
		       (static_cast<uint32_t>(buf[3]) << 24);
	}

	static inline int encode_varint(uint8_t* dst, uint64_t val) {
		int n = 0;
		while (val >= 128) {
			dst[n++] = static_cast<uint8_t>(val | 128);
			val >>= 7;
		}
		dst[n++] = static_cast<uint8_t>(val);
		return n;
	}
};
