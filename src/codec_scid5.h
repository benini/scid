/*
 * Copyright (C) 2022  Fulvio Benini

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
 * Implements the CodecSCID5 class.
 */

#pragma once

#include "codec.h"
#include "index.h"
#include "namebase.h"
#include <filesystem>
#include <future>

// This class manages databases encoded in SCID format v5.
class CodecSCID5 : public ICodecDatabase {
	Index* idx_ = nullptr;
	NameBase* nb_ = nullptr;
	std::vector<std::string> filenames_;
	Filebuf idxfile_;
	FilebufAppend gfile_;
	Filebuf nbfile_;
	gamenumT seqWrite_ = 0;
	char gamecache_[1ULL << 17];

	enum : uint64_t {
		LIMIT_GAMEOFFSET = 1ULL << 47,
		LIMIT_GAMELEN = 1ULL << 17,
		LIMIT_NUMGAMES = (1ULL << 32) - 2,
		LIMIT_UNIQUENAMES = 1ULL << 28,
		LIMIT_NAMELEN = 255
	};

	enum { INDEX_ENTRY_SIZE = 56 };

public: // ICodecDatabase interface
	Codec getType() const final { return ICodecDatabase::SCID5; }

	// Returns the full path of the three files (index, namebase and gamefile)
	// used by the database.
	std::vector<std::string> getFilenames() const final { return filenames_; };

	std::vector<std::pair<const char*, std::string>>
	getExtraInfo() const final {
		std::vector<std::pair<const char*, std::string>> res;
		return res;
	}

	errorT setExtraInfo(const char*, const char*) final { return OK; };

	ByteBuffer getGameData(uint64_t offset, uint32_t length) final {
		if (offset >= gfile_.size())
			return {nullptr, 0};
		if (length >= LIMIT_GAMELEN)
			return {nullptr, 0};

		if (gfile_.pubseekpos(offset) == -1)
			return {nullptr, 0};
		if (gfile_.sgetn(gamecache_, length) != std::streamsize(length))
			return {nullptr, 0};

		return {reinterpret_cast<const byte*>(gamecache_), length};
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
		if (auto err = addGameNamesAndData(ie, tags, data, nGames))
			return err;

		idx_->addEntry(ie);
		return writeIndexEntry(ie, nGames);
	}

	errorT saveGame(IndexEntry const& ie_src, TagRoster const& tags,
	                ByteBuffer const& data, gamenumT replaced) final {
		IndexEntry ie = ie_src;
		if (auto err = addGameNamesAndData(ie, tags, data, replaced))
			return err;

		idx_->replaceEntry(ie, replaced);
		return writeIndexEntry(ie, replaced);
	}

	errorT saveIndexEntry(const IndexEntry& ie, gamenumT replaced) final {
		idx_->replaceEntry(ie, replaced);
		return writeIndexEntry(ie, replaced);
	}

	std::pair<errorT, idNumberT> addName(nameT nt, const char* name) final {
		return dyn_addName(nt, name);
	}

	errorT flush() final {
		seqWrite_ = 0;
		errorT errIndex = (idxfile_.pubsync() == 0) ? OK : ERROR_FileWrite;
		errorT errGfile = (gfile_.pubsync() == 0) ? OK : ERROR_FileWrite;
		errorT errNBfile = (gfile_.pubsync() == 0) ? OK : ERROR_FileWrite;
		return errIndex ? errIndex : errGfile ? errGfile : errNBfile;
	}

	errorT dyn_open(fileModeT fMode, const char* dbname,
	                const Progress& progress, Index* idx, NameBase* nb) final {
		if (fMode == FMODE_WriteOnly || !dbname || !idx || !nb)
			return ERROR;
		if (*dbname == '\0')
			return ERROR_FileOpen;

		idx_ = idx;
		nb_ = nb;

		filenames_.resize(3);
		auto dbpath = std::filesystem::path(dbname);
		filenames_[0] = dbpath.replace_extension("si5").string();
		filenames_[1] = dbpath.replace_extension("sg5").string();
		filenames_[2] = dbpath.replace_extension("sn5").string();

		if (fMode == FMODE_Create) {
			for (auto const& fname : filenames_) {
				std::error_code ec;
				if (std::filesystem::exists(fname, ec) || ec)
					return ERROR_Exists;
			}

			if (auto err = idxfile_.Open(filenames_[0].c_str(), fMode))
				return err;

			if (auto err = gfile_.open(filenames_[1], fMode))
				return err;

			return nbfile_.Open(filenames_[2].c_str(), fMode);
		}

		auto read_names = std::async(std::launch::async,
		                             &CodecSCID5::readNamebase, this, fMode,
		                             filenames_[2]);

		if (auto err = gfile_.open(filenames_[1], fMode))
			return err;

		auto res = readIndex(fMode, filenames_[0].c_str(), progress);
		auto err_names = read_names.get();
		progress.report(1, 1);
		return err_names ? err_names : res;
	}

private:
	// Given a name (string), retrieve the corresponding ID.
	// The name is added to @e nb_ if do not already exists in the NameBase.
	// @param nt:   nameT type of the name to retrieve.
	// @param name: the name to retrieve.
	// @returns
	// - on success, a @e std::pair containing OK and the ID.
	// - on failure, a @e std::pair containing an error code and 0.
	std::pair<errorT, idNumberT> dyn_addName(nameT nt, const char* name) {
		idNumberT id;
		if (OK == nb_->FindExactName(nt, name, &id))
			return {OK, id};

		auto res = nb_->addName(nt, name, LIMIT_NAMELEN, LIMIT_UNIQUENAMES);
		if (res.first != OK)
			return res;

		// TODO: If writing fails the name must be removed from memory
		const auto nameLen = strlen(name);
		if (nameLen != nbfile_.sputc(static_cast<unsigned char>(nameLen)))
			return {ERROR_FileWrite, id};

		if (nt != nbfile_.sputc(nt))
			return {ERROR_FileWrite, id};

		if (nameLen != nbfile_.sputn(name, nameLen))
			return {ERROR_FileWrite, id};

		return res;
	}

	/// Add the game's roster tags and gamedata to the database.
	/// Set the references to the new data in @e ie.
	errorT addGameNamesAndData(IndexEntry& ie, TagRoster const& tags,
	                           ByteBuffer const& data, gamenumT replaced) {
		const auto data_sz = data.size();
		if (data_sz >= LIMIT_GAMELEN)
			return ERROR_GameLengthLimit;

		if (auto err = tags.map(
		        ie, [&](auto nt, auto name) { return dyn_addName(nt, name); }))
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

	errorT readIndex(fileModeT fMode, const char* indexFilename,
	                 Progress const& progress) {
		if (auto err = idxfile_.Open(indexFilename, fMode))
			return err;

		auto nGames = idxfile_.pubseekoff(0, std::ios::end);
		if (nGames < 0 || (nGames % INDEX_ENTRY_SIZE) != 0 ||
		    idxfile_.pubseekoff(0, std::ios::beg)) {
			return ERROR_Corrupt;
		}
		nGames = nGames / INDEX_ENTRY_SIZE;
		idx_->entries_.resize(nGames);

		for (gamenumT gNum = 0; idxfile_.sgetc() != EOF; ++gNum) {
			if (gNum == nGames)
				return ERROR_Corrupt;

			if ((gNum % 8192) == 0) {
				if (!progress.report(gNum, nGames))
					return ERROR_UserCancel;
			}

			char buf[INDEX_ENTRY_SIZE];
			if (idxfile_.sgetn(buf, INDEX_ENTRY_SIZE) != INDEX_ENTRY_SIZE)
				return ERROR_FileRead;

			idx_->entries_[gNum] = decodeIndexEntry(buf);
		}
		return OK;
	}

	errorT writeIndexEntry(IndexEntry const& ie, gamenumT gnum) {
		if (seqWrite_ == 0 || (gnum != seqWrite_ + 1)) {
			std::streampos pos = gnum;
			pos = pos * INDEX_ENTRY_SIZE;
			if (idxfile_.pubseekpos(pos) != pos) {
				seqWrite_ = 0;
				return ERROR_FileWrite;
			}
		}
		char buf[INDEX_ENTRY_SIZE];
		encodeIndexEntry(ie, buf);
		errorT res = idxfile_.sputn(buf, INDEX_ENTRY_SIZE) == INDEX_ENTRY_SIZE
		                 ? OK
		                 : ERROR_FileWrite;

		seqWrite_ = (res == OK) ? gnum : 0;
		return res;
	}

	void encodeIndexEntry(IndexEntry const& ie, char* buf) {
		auto pack = [](uint32_t a, auto a_sz, uint32_t b) {
			assert(a < (uint32_t(1) << a_sz));
			assert(b < (uint32_t(1) << (32 - a_sz)));
			return (a << (32 - a_sz)) | b;
		};
		auto pack4 = [](uint32_t a, auto a_sz, uint32_t b, auto b_sz,
		                uint32_t c, auto c_sz, uint32_t d) {
			assert(a < (uint32_t(1) << a_sz));
			assert(b < (uint32_t(1) << b_sz));
			assert(c < (uint32_t(1) << c_sz));
			assert(d < (uint32_t(1) << (32 - a_sz - b_sz - c_sz)));
			return (a << (32 - a_sz)) | (b << (32 - a_sz - b_sz)) |
			       (c << (32 - a_sz - b_sz - c_sz)) | d;
		};

		// TODO: Remove counts and use only flags?
		const auto counts = ie.GetRaw4bitsCounts();
		const auto nVariations = counts & 0x0F;
		const auto nComments = (counts >> 4) & 0x0F;
		const auto nNags = (counts >> 8) & 0x0F;

		const auto chess960 = ie.isChessStd() ? 1 : 0;

		encode_uint32(buf + 0, pack(nComments, 4, ie.GetWhite()));
		encode_uint32(buf + 4, pack(nVariations, 4, ie.GetBlack()));
		encode_uint32(buf + 8, pack(nNags, 4, ie.GetEvent()));
		encode_uint32(buf + 12, ie.GetSite());
		encode_uint32(buf + 16, pack(chess960, 1, ie.GetRound()));
		encode_uint32(buf + 20, pack(ie.GetWhiteElo(), 12, ie.GetDate()));
		encode_uint32(buf + 24, pack(ie.GetBlackElo(), 12, ie.GetEventDate()));
		encode_uint32(buf + 28,
		              pack(ie.GetNumHalfMoves(), 10, ie.GetRawFlags()));
		encode_uint32(buf + 32,
		              pack4(ie.GetResult(), 2, ie.GetWhiteRatingType(), 3,
		                    ie.GetBlackRatingType(), 3, ie.GetFinalMatSig()));
		buf[36] = static_cast<uint8_t>(ie.GetEcoCode());
		buf[37] = static_cast<uint8_t>(ie.GetEcoCode() >> 8);
		buf[38] = ie.GetStoredLineCode();
		std::copy_n(ie.GetHomePawnData(), 9, buf + 39);

		const uint64_t offset = ie.GetOffset();
		encode_uint32(buf + 48, pack(offset >> 32, 15, ie.GetLength()));
		encode_uint32(buf + 52, static_cast<uint32_t>(offset));
	}

	IndexEntry decodeIndexEntry(const char* data) {
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

		const auto matsig = decode_uint32(data + 32);
		res.SetResult(matsig >> 30);
		res.SetWhiteRatingType((matsig >> 27) & 0b00000111);
		res.SetBlackRatingType((matsig >> 24) & 0b00000111);
		res.SetFinalMatSig(matsig & 0x00FFFFFF);

		res.SetEcoCode(static_cast<uint32_t>(data[36]) |
		               (static_cast<uint32_t>(data[37]) << 8));
		res.SetStoredLineCode(data[38]);
		res.SetHomePawnData(data[39], reinterpret_cast<const byte*>(data + 40));

		val = unpack(decode_uint32(data + 48), 15);
		res.SetLength(val.second);
		res.SetOffset((static_cast<uint64_t>(val.first) << 32) |
		              decode_uint32(data + 52));

		return res;
	}

	errorT readNamebase(fileModeT fMode, std::string const& filename) {
		if (auto err = nbfile_.Open(filename.c_str(), fMode))
			return err;

		if (nbfile_.pubseekpos(0))
			return ERROR_FileRead;

		idNumberT id[NUM_NAME_TYPES] = {};
		auto ch = Filebuf::traits_type::eof();
		while ((ch = nbfile_.sbumpc()) != Filebuf::traits_type::eof()) {
			char buf[256];
			if (nbfile_.sgetn(buf, ch + 1) != ch + 1)
				return ERROR_Corrupt;

			const nameT nt = buf[0];
			if (nt > NUM_NAME_TYPES)
				return ERROR_Corrupt;

			nb_->insert(buf + 1, ch, nt, id[nt]++);
		}
		for (nameT nt = 0; nt < NUM_NAME_TYPES; ++nt) {
			if (nb_->getNames()[nt].size() != nb_->GetNumNames(nt))
				return ERROR_Corrupt;
		}
		return OK;
	}

	inline void encode_uint32(char* dst, uint32_t value) {
		uint8_t* const buf = reinterpret_cast<uint8_t*>(dst);
		buf[0] = static_cast<uint8_t>(value);
		buf[1] = static_cast<uint8_t>(value >> 8);
		buf[2] = static_cast<uint8_t>(value >> 16);
		buf[3] = static_cast<uint8_t>(value >> 24);
	}

	inline uint32_t decode_uint32(const char* src) {
		const uint8_t* const buf = reinterpret_cast<const uint8_t*>(src);
		return (static_cast<uint32_t>(buf[0])) |
		       (static_cast<uint32_t>(buf[1]) << 8) |
		       (static_cast<uint32_t>(buf[2]) << 16) |
		       (static_cast<uint32_t>(buf[3]) << 24);
	}
};
