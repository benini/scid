/*
 * Copyright (C) 2022-2023  Fulvio Benini

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
 * Implements the CodecRocksDB class.
 */

#pragma once

#include "codec.h"
#include "index.h"
#include "namebase.h"
#include <filesystem>
#include <future>
#include <rocksdb/db.h>
#include <rocksdb/filter_policy.h>
#include <rocksdb/options.h>
#include <rocksdb/slice.h>
#include <rocksdb/slice_transform.h>
#include <rocksdb/utilities/options_util.h>

// This class stores games into a RocksDB database.
class CodecRocksDB final : public ICodecDatabase {
	Index* idx_ = nullptr;
	NameBase* nb_ = nullptr;
	std::string buf_;
	Filebuf idxfile_;
	rocksdb::DB* db_ = nullptr;
	std::vector<rocksdb::ColumnFamilyHandle*> handles;
	rocksdb::PinnableSlice slice_;
	rocksdb::WriteOptions writeopt_;
	gamenumT seqWrite_ = 0;

	enum : uint64_t {
		LIMIT_NUMGAMES = (1ULL << 32) - 2,
		LIMIT_UNIQUENAMES = 1ULL << 28,
		LIMIT_NAMELEN = 255
	};

	enum { INDEX_ENTRY_SIZE = 48 };

public:
	~CodecRocksDB() {
		for (auto handle : handles) {
			delete handle;
		}
		delete db_;
	}

public: // ICodecDatabase interface
	Codec getType() const override { return ICodecDatabase::ROCKSDB; }

	std::vector<std::string> getFilenames() const override {
		return std::vector<std::string>();
	}

	std::vector<std::pair<const char*, std::string>>
	getExtraInfo() const override {
		std::vector<std::pair<const char*, std::string>> res;
		auto it = db_->NewIterator({}, handles[0]);
		for (it->SeekToFirst(); it->Valid(); it->Next()) {
			// TODO: change to std::vector<string, string>
			// res.emplace_back(it->key(), it->value());
		}
		delete it;
		return res;
	}

	errorT setExtraInfo(const char* tagname, const char* new_value) override {
		if (!db_->Put(writeopt_, handles[0], tagname, new_value).ok())
			return ERROR_FileWrite;

		return OK;
	}

	ByteBuffer getGameData(uint64_t offset, uint32_t length) final {
		char key[4];
		encode_uint32_bigendian(key, offset);

		if (!db_->Get({}, handles[3], {key, 4}, &buf_).ok())
			return {nullptr, 0};

		if (!db_->Get({}, handles[2], {key, 4}, &slice_).ok())
			return {nullptr, 0};

		auto tags = ByteBuffer((unsigned char*)buf_.data(), buf_.size());
		if (OK != tags.decodeTags([](auto, auto) {}))
			return {nullptr, 0};

		buf_.insert(buf_.size() - tags.size(), slice_.data(), slice_.size());
		return {(unsigned char*)buf_.data(), buf_.size()};
	}

	ByteBuffer getGameMoves(IndexEntry const& ie) final {
		char key[4];
		encode_uint32_bigendian(key, ie.GetOffset());
		if (!db_->Get({}, handles[2], {key, 4}, &slice_).ok())
			return {nullptr, 0};

		return {(unsigned char*)slice_.data(), slice_.size()};
	}

	errorT addGame(IndexEntry const& ie_src, TagRoster const& tags,
	               ByteBuffer const& data) override {
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
	                ByteBuffer const& data, gamenumT replaced) override {
		IndexEntry ie = ie_src;
		if (auto err = addGameNamesAndData(ie, tags, data, replaced))
			return err;

		idx_->replaceEntry(ie, replaced);
		return writeIndexEntry(ie, replaced);
	}

	errorT saveIndexEntry(const IndexEntry& ie, gamenumT replaced) override {
		idx_->replaceEntry(ie, replaced);
		return writeIndexEntry(ie, replaced);
	}

	std::pair<errorT, idNumberT> addName(nameT nt, const char* name) override {
		return dyn_addName(nt, name);
	}

	errorT flush() override {
		db_->Flush({}, handles);
		return OK;
	}

	errorT dyn_open(fileModeT fMode, const char* dbname,
	                const Progress& progress, Index* idx,
	                NameBase* nb) override {
		if (fMode == FMODE_WriteOnly || !dbname || !idx || !nb)
			return ERROR;
		if (*dbname == '\0')
			return ERROR_FileOpen;

		idx_ = idx;
		nb_ = nb;
		writeopt_.disableWAL = true;

		auto dbpath = std::filesystem::path(dbname);
		const auto index = dbpath.replace_extension("si5").string();
		const auto dbname_rocks = dbpath.replace_extension("rocksdb").string();

		if (fMode == FMODE_Create) {
			std::error_code ec;
			if (std::filesystem::exists(index, ec) || ec)
				return ERROR_Exists;

			if (auto err = idxfile_.Open(index.c_str(), fMode))
				return err;

			return create_db(dbname_rocks);
		}

		auto read_names = std::async(
		    std::launch::async, &CodecRocksDB::readNamebase, this, dbname_rocks);

		auto res = readIndex(fMode, index.c_str(), progress);
		auto err_names = read_names.get();
		progress.report(1, 1);
		return err_names ? err_names : res;
	}

private:
	errorT create_db(std::string const& dbname) {
		rocksdb::Options options;
		options.IncreaseParallelism();
		options.error_if_exists = true;
		options.create_if_missing = true;
		options.create_missing_column_families = true;

		// Columns
		// header:   read_seq, write_rnd, compress_none
		// index:    read_seq, write_rnd, compress_lz4
		// names:    read_seq, write_rnd, compress_lz4
		// moves:    read_rnd, write_rnd, compress_lz4
		// tags:     read_rnd, write_rnd, compress_zstd_dict
		// comments: read_rnd, write_rnd, compress_zstd_dict
		rocksdb::ColumnFamilyOptions read_seq;
		read_seq.compression = rocksdb::kLZ4Compression;

		rocksdb::ColumnFamilyOptions read_seq_nocache;
		rocksdb::BlockBasedTableOptions opt_nocache;
		opt_nocache.no_block_cache = true;
		opt_nocache.block_size = 46 * 4 * 1024;
		read_seq_nocache.compression = rocksdb::kLZ4Compression;
		read_seq_nocache.table_factory.reset(
		    rocksdb::NewBlockBasedTableFactory(opt_nocache));

		rocksdb::ColumnFamilyOptions read_rnd;
		read_rnd.OptimizeForPointLookup(128);
		read_rnd.compression = rocksdb::kLZ4Compression;

		rocksdb::ColumnFamilyOptions read_rnd_zstd;
		read_rnd_zstd.compression = rocksdb::kZSTD;
		read_rnd_zstd.compression_opts.max_dict_bytes = 16 * 1024;
		read_rnd_zstd.compression_opts.zstd_max_train_bytes = 100 * 16 * 1024;

		std::vector<rocksdb::ColumnFamilyDescriptor> cols;
		cols.emplace_back();
		cols.emplace_back("idx", read_seq_nocache);
		cols.emplace_back("moves", read_rnd);
		cols.emplace_back("tags_comments", read_rnd_zstd);
		cols.emplace_back("player", read_seq);
		cols.emplace_back("event", read_seq);
		cols.emplace_back("site", read_seq);
		cols.emplace_back("round", read_seq);
		if (!rocksdb::DB::Open(options, dbname, cols, &handles, &db_).ok())
			return ERROR_FileOpen;

		if (auto err = setExtraInfo("type", "0"))
			return err;
		if (auto err = setExtraInfo("autoload", "1"))
			return err;
		if (auto err = setExtraInfo("description", ""))
			return err;
		if (auto err = setExtraInfo("flag1", ""))
			return err;
		if (auto err = setExtraInfo("flag2", ""))
			return err;
		if (auto err = setExtraInfo("flag3", ""))
			return err;
		if (auto err = setExtraInfo("flag4", ""))
			return err;
		if (auto err = setExtraInfo("flag5", ""))
			return err;
		if (auto err = setExtraInfo("flag6", ""))
			return err;

		return OK;
	}

	errorT readNamebase(std::string const& dbname) {
		rocksdb::Options options;
		std::vector<rocksdb::ColumnFamilyDescriptor> cols;
		if (!rocksdb::LoadLatestOptions({}, dbname, &options, &cols).ok())
			return ERROR_FileOpen;

		options.error_if_exists = false;
		options.create_if_missing = false;
		options.create_missing_column_families = false;
		if (!rocksdb::DB::Open(options, dbname, cols, &handles, &db_).ok())
			return ERROR_FileOpen;

		std::future<errorT> async[3];
		async[0] = std::async(std::launch::async, &CodecRocksDB::readTable, this,
		                      NAME_PLAYER);
		async[1] = std::async(std::launch::async, &CodecRocksDB::readTable, this,
		                      NAME_EVENT);
		async[2] = std::async(std::launch::async, &CodecRocksDB::readTable, this,
		                      NAME_SITE);
		auto res = readTable(NAME_ROUND);
		for (auto& e : async) {
			if (auto err = e.get())
				res = err;
		}
		return res;
	}

	errorT readTable(char nt) {
		auto it = std::unique_ptr<rocksdb::Iterator>(
		    db_->NewIterator({}, handles[nt + 4]));
		if (!it)
			return ERROR_FileRead;

		for (it->SeekToFirst(); it->Valid(); it->Next()) {
			auto key = it->key();
			auto value = it->value();
			if (value.size() != 4)
				return ERROR_Decode;

			const auto id = decode_uint32(value.data());
			if (!nb_->insert(key.data(), key.size(), nt, id))
				return ERROR_Decode;
		}
		if (nb_->getNames()[nt].size() != nb_->GetNumNames(nt))
			return ERROR_Decode;

		return OK;
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
		idNumberT id;
		if (OK == nb_->FindExactName(nt, name, &id))
			return {OK, id};

		auto res = nb_->addName(nt, name, LIMIT_NAMELEN, LIMIT_UNIQUENAMES);
		if (res.first != OK)
			return res;

		char value[4];
		encode_uint32(value, res.second);
		if (!db_->Put(writeopt_, handles[nt + 4], name, {value, 4}).ok())
			res.first = ERROR_FileWrite;

		return res;
	}

	errorT addGameNamesAndData(IndexEntry& ie, TagRoster const& tags,
	                           ByteBuffer const& data, gamenumT replaced) {
		ie.SetOffset(replaced);

		if (auto err = tags.map(
		        ie, [&](auto nt, auto name) { return dyn_addName(nt, name); }))
			return err;

		auto split = data;
		if (auto err = split.decodeTags([](auto, auto) {}))
			return err;

		const auto tag_sz = data.size() - split.size();

		if (auto err = split.decodeStartBoard().first)
			return err;

		auto it = split.data();
		auto end = it + split.size();
		while (it != end) {
			it = std::find(it, end, 15);
			// Check it is really the end of the game and not a NAG
			if (*(it - 1) != 11)
				break;
		}
		const size_t moves_sz = std::distance(split.data(), it);
		const auto cmnt_sz = data.size() - tag_sz - moves_sz;

		char key[4];
		encode_uint32_bigendian(key, replaced);
		auto moves = reinterpret_cast<const char*>(data.data());
		if (!db_->Put(writeopt_, handles[2], {key, 4},
		              {moves + tag_sz, moves_sz})
		         .ok())
			return ERROR_FileWrite;

		auto buf = std::string(moves, tag_sz);
		buf.append(moves + tag_sz + moves_sz, cmnt_sz);
		if (!db_->Put(writeopt_, handles[3], {key, 4}, buf).ok())
			return ERROR_FileWrite;

		return OK;
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
				return ERROR_CorruptData;

			if ((gNum % 8192) == 0) {
				if (!progress.report(gNum, nGames))
					return ERROR_UserCancel;
			}

			char buf[INDEX_ENTRY_SIZE];
			if (idxfile_.sgetn(buf, INDEX_ENTRY_SIZE) != INDEX_ENTRY_SIZE)
				return ERROR_FileRead;

			idx_->entries_[gNum] = decodeIndexEntry(buf);
			idx_->entries_[gNum].SetOffset(gNum);
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
		return res;
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

	// Siccome il database è ordinato, e la ricerca posizionale è in ordine
	// memorizzare la chiave in formato big endian, che rispetta l'ordine
	// è più veloce
	inline void encode_uint32_bigendian(char* dst, uint32_t value) {
		uint8_t* const buf = reinterpret_cast<uint8_t*>(dst);
		buf[0] = static_cast<uint8_t>(value >> 24);
		buf[1] = static_cast<uint8_t>(value >> 16);
		buf[2] = static_cast<uint8_t>(value >> 8);
		buf[3] = static_cast<uint8_t>(value);
	}
};
