/*
* Copyright (C) 2016 Fulvio Benini

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

#include "bytebuf.h"
#include "codec.h"
#include "game.h"
#include "index.h"
#include "misc.h"
#include "namebase.h"
#include <cstring>
#include <gtest/gtest.h>
#include <iterator>
#include <memory>
#include <vector>

ICodecDatabase::Codec codecs[] = {
	ICodecDatabase::MEMORY, ICodecDatabase::SCID4
};

std::vector< std::pair<ICodecDatabase::Codec, std::string> > unsupportedVec = {
	{ ICodecDatabase::MEMORY, "FMODE" + std::to_string(FMODE_None) },
	{ ICodecDatabase::MEMORY, "FMODE" + std::to_string(FMODE_Create) },
	{ ICodecDatabase::MEMORY, "FMODE" + std::to_string(FMODE_ReadOnly) },
	{ ICodecDatabase::MEMORY, "FMODE" + std::to_string(FMODE_WriteOnly) },
	{ ICodecDatabase::MEMORY, "FMODE" + std::to_string(FMODE_Both) },

	{ ICodecDatabase::SCID4, "FMODE" + std::to_string(FMODE_None) },
	{ ICodecDatabase::SCID4, "FMODE" + std::to_string(FMODE_Memory) },
	{ ICodecDatabase::SCID4, "FMODE" + std::to_string(FMODE_WriteOnly) },
	{ ICodecDatabase::SCID4, "empty_filename" },
};

class Supports {
	ICodecDatabase::Codec dbtype_;

public:
	Supports(ICodecDatabase::Codec dbtype) : dbtype_(dbtype) {}

	bool operator()(const std::string& feature) const {
		auto it = std::find(unsupportedVec.begin(), unsupportedVec.end(),
		                    std::make_pair(dbtype_, feature));
		return it == unsupportedVec.end();
	}
};

fileModeT fmodes[] = {
	FMODE_Memory, FMODE_Create, FMODE_ReadOnly, FMODE_WriteOnly, FMODE_Both
};
const char* filename = "codecbase";

class Test_Codec : public ::testing::TestWithParam<ICodecDatabase::Codec> {
protected:
	Game gameSimple_;
	IndexEntry gameSimpleIe_;
	std::vector<byte> gameSimpleData_;

	Game gameComplex_;
	IndexEntry gameComplexIe_;
	std::vector<byte> gameComplexData_;

	void SetUpGames(NameBase& nb) {
		{
			gameSimpleIe_.Init();
			gameSimpleIe_.SetWhiteName(&nb, "Simple game White");
			gameSimpleIe_.SetBlackName(&nb, "Simple game Black");
			gameSimpleIe_.SetEventName(&nb, "Simple game Event");
			gameSimpleIe_.SetSiteName(&nb, "Simple game Site");
			gameSimpleIe_.SetRoundName(&nb, "Simple game Round");
			gameSimple_.LoadStandardTags(&gameSimpleIe_, &nb);
			simpleMoveT sm;
			gameSimple_.GetCurrentPos()->ReadCoordMove(&sm, "e2e4", true);
			gameSimple_.AddMove(&sm, NULL);
			gameSimple_.GetCurrentPos()->ReadCoordMove(&sm, "e7e5", true);
			gameSimple_.AddMove(&sm, NULL);
			gameSimple_.GetCurrentPos()->ReadCoordMove(&sm, "g1f3", true);
			gameSimple_.AddMove(&sm, NULL);
			gameSimple_.GetCurrentPos()->ReadCoordMove(&sm, "b8c6", true);
			gameSimple_.AddMove(&sm, NULL);
			gameSimple_.GetCurrentPos()->ReadCoordMove(&sm, "f1b5", true);
			gameSimple_.AddMove(&sm, NULL);
			gameSimple_.GetCurrentPos()->ReadCoordMove(&sm, "g8f6", true);
			gameSimple_.AddMove(&sm, NULL);
			gameSimple_.GetCurrentPos()->ReadCoordMove(&sm, "e1g1", true);
			gameSimple_.AddMove(&sm, NULL);
			ByteBuffer bbuf(BBUF_SIZE);
			gameSimple_.Encode(&bbuf, &gameSimpleIe_);
			const byte* src = bbuf.getData();
			std::copy(src, src + bbuf.GetByteCount(),
			          std::back_inserter(gameSimpleData_));
		}

		{
			gameComplexIe_.Init();
			gameComplexIe_.SetWhiteName(&nb, "Complex game White");
			gameComplexIe_.SetBlackName(&nb, "Complex game Black");
			gameComplexIe_.SetEventName(&nb, "Complex game Event");
			gameComplexIe_.SetSiteName(&nb, "Complex game Site");
			gameComplexIe_.SetRoundName(&nb, "Complex game Round");
			gameComplex_.LoadStandardTags(&gameComplexIe_, &nb);
			gameComplex_.SetScidFlags("WBMENPTKQ!?U123456");
			simpleMoveT sm;
			gameComplex_.GetCurrentPos()->ReadCoordMove(&sm, "d2d4", true);
			gameComplex_.AddMove(&sm, NULL);
			gameComplex_.GetCurrentPos()->ReadCoordMove(&sm, "d7d5", true);
			gameComplex_.AddMove(&sm, NULL);
			gameComplex_.GetCurrentPos()->ReadCoordMove(&sm, "c2c4", true);
			gameComplex_.AddMove(&sm, NULL);
			gameComplex_.AddVariation();
			gameComplex_.GetCurrentPos()->ReadCoordMove(&sm, "g1f3", true);
			gameComplex_.AddMove(&sm, NULL);
			gameComplex_.SetMoveComment("Test comment");
			gameComplex_.GetCurrentPos()->ReadCoordMove(&sm, "g8f6", true);
			gameComplex_.AddMove(&sm, NULL);
			gameComplex_.GetCurrentPos()->ReadCoordMove(&sm, "c2c4", true);
			gameComplex_.AddMove(&sm, NULL);
			gameComplex_.MoveExitVariation();
			gameComplex_.MoveForward();
			gameComplex_.GetCurrentPos()->ReadCoordMove(&sm, "e7e6", true);
			gameComplex_.AddMove(&sm, NULL);
			ByteBuffer bbuf(BBUF_SIZE);
			gameComplex_.Encode(&bbuf, &gameComplexIe_);
			const byte* src = bbuf.getData();
			std::copy(src, src + bbuf.GetByteCount(),
			          std::back_inserter(gameComplexData_));
		}
	}
};

TEST_P(Test_Codec, fileModeT) {
	ICodecDatabase::Codec dbtype = GetParam();
	Supports supports(dbtype);

	std::unique_ptr<ICodecDatabase> valid;
	// Try to obtain a ICodecDatabase pointer for each file mode
	for (auto& fmode : fmodes) {
		Index idx;
		NameBase nb;
		errorT err;
		ICodecDatabase* codec = ICodecDatabase::make(
		    dbtype, &err, fmode, filename, Progress(), &idx, &nb);

		// Check if the codec should support the current file mode
		if (supports("FMODE" + std::to_string(fmode))) {
			ASSERT_NE(nullptr, codec);
			EXPECT_EQ(dbtype, codec->getType());
		} else {
			EXPECT_EQ(nullptr, codec);
		}

		if (codec != nullptr) valid = std::unique_ptr<ICodecDatabase>(codec);
	}

	// Remove the files created
	ASSERT_NE(nullptr, valid);
	auto filenames = valid->getFilenames();
	valid = nullptr; // Close the base
	for (const auto& filename : filenames) {
		EXPECT_EQ(0, std::remove(filename.c_str()));
	}
}

TEST_P(Test_Codec, create_emptyfilename) {
	ICodecDatabase::Codec dbtype = GetParam();
	Supports supports(dbtype);

	if (!supports("FMODE" + std::to_string(FMODE_Create))) {
		return;
	}

	Index idx;
	NameBase nb;
	errorT err;
	ICodecDatabase* codec = ICodecDatabase::make(dbtype, &err, FMODE_Create, "",
	                                             Progress(), &idx, &nb);

	if (!supports("empty_filename")) {
		EXPECT_EQ(nullptr, codec);
	} else {
		EXPECT_NE(nullptr, codec);
		auto filenames = codec->getFilenames();
		delete codec;
		for (const auto& filename : filenames) {
			EXPECT_EQ(0, std::remove(filename.c_str()));
		}
	}
}

TEST_P(Test_Codec, rename) {
	ICodecDatabase::Codec dbtype = GetParam();
	Supports supports(dbtype);

	if (!supports("FMODE" + std::to_string(FMODE_Create))) {
		return;
	}

	Index idx1, idx2;
	NameBase nb1, nb2;
	errorT err;
	ICodecDatabase* codec1 = ICodecDatabase::make(
	    dbtype, &err, FMODE_Create, filename, Progress(), &idx1, &nb1);
	ASSERT_NE(nullptr, codec1);

	std::string renamed_name = std::string(filename) + "__renamed__";
	ICodecDatabase* codec2 = ICodecDatabase::make(
	    dbtype, &err, FMODE_Create, renamed_name.c_str(), Progress(), &idx2, &nb2);
	ASSERT_NE(nullptr, codec2);

	auto filenames1 = codec1->getFilenames();
	auto filenames2 = codec2->getFilenames();
	EXPECT_EQ(filenames1.size(), filenames2.size());

	delete codec1;
	delete codec2;
	for (const auto& filename : filenames1) {
		EXPECT_EQ(0, std::remove(filename.c_str()));
	}
	for (size_t i = 0, n = filenames2.size(); i < n; i++) {
		const char* s1 = filenames1[i].c_str();
		const char* s2 = filenames2[i].c_str();
		EXPECT_EQ(0, std::rename(s2, s1));
	}

	if (!supports("FMODE" + std::to_string(FMODE_ReadOnly))) {
		return;
	}
	Index idx_reopen;
	NameBase nb_reopen;
	ICodecDatabase* codec3 = ICodecDatabase::make(
	    dbtype, &err, FMODE_ReadOnly, filename, Progress(), &idx_reopen, &nb_reopen);
	ASSERT_NE(nullptr, codec3);

	// Remove the files created
	auto filenames3 = codec3->getFilenames();
	delete codec3;
	for (const auto& filename : filenames3) {
		EXPECT_EQ(0, std::remove(filename.c_str()));
	}
}

TEST_P(Test_Codec, addsave) {
	ICodecDatabase::Codec dbtype = GetParam();
	Supports supports(dbtype);

	fileModeT fMode = FMODE_Create;
	if (!supports("FMODE" + std::to_string(fMode))) {
		fMode = FMODE_Memory;
	}

	Index idx;
	NameBase nb;
	errorT err;
	ICodecDatabase* codec = ICodecDatabase::make(dbtype, &err, fMode, filename,
	                                             Progress(), &idx, &nb);
	ASSERT_NE(nullptr, codec);

	const byte* gameData = codec->getGameData(0, gameSimpleData_.size());
	EXPECT_EQ(nullptr, gameData);

	auto addNative = [&](auto&& ie, auto&& src, auto&& size) {
		if (supports("addGame_native")) {
			errorT err = codec->addGame(&ie, src, size);
			EXPECT_EQ(OK, err);
			size_t nGames = idx.GetNumGames();
			EXPECT_TRUE(nGames > 0);
			EXPECT_EQ(0, std::memcmp(&ie, idx.GetEntry(--nGames), sizeof(IndexEntry)));
			EXPECT_EQ(size, ie.GetLength());
			const byte* gameData =
			    codec->getGameData(ie.GetOffset(), ie.GetLength());
			ASSERT_NE(nullptr, codec);
			EXPECT_TRUE(std::equal(src, src + size, gameData));
		}
	};
	auto saveNative = [&](auto&& ie, auto&& src, auto&& size, auto&& replace) {
		if (supports("saveGame_native")) {
			errorT err = codec->saveGame(&ie, src, size, replace);
			EXPECT_EQ(OK, err);
			EXPECT_EQ(0, std::memcmp(&ie, idx.GetEntry(replace), sizeof(IndexEntry)));
			EXPECT_EQ(size, ie.GetLength());
			const byte* gameData =
			    codec->getGameData(ie.GetOffset(), ie.GetLength());
			ASSERT_NE(nullptr, codec);
			EXPECT_TRUE(std::equal(src, src + size, gameData));
		}
	};
	auto addGame = [&](auto&& game, auto&& src, auto&& size) {
		if (supports("addGame_game")) {
			errorT err = codec->addGame(&game);
			EXPECT_EQ(OK, err);
			size_t nGames = idx.GetNumGames();
			EXPECT_TRUE(nGames > 0);
			const IndexEntry* ie = idx.GetEntry(--nGames);
			EXPECT_EQ(size, ie->GetLength());
			const byte* gameData =
			    codec->getGameData(ie->GetOffset(), ie->GetLength());
			ASSERT_NE(nullptr, codec);
			EXPECT_TRUE(std::equal(src, src + size, gameData));
		}
	};
	auto saveGame = [&](auto&& game, auto&& src, auto&& size, auto&& replace) {
		if (supports("saveGame_game")) {
			errorT err = codec->saveGame(&game, replace);
			EXPECT_EQ(OK, err);
			const IndexEntry* ie = idx.GetEntry(replace);
			EXPECT_EQ(size, ie->GetLength());
			const byte* gameData =
			    codec->getGameData(ie->GetOffset(), ie->GetLength());
			ASSERT_NE(nullptr, codec);
			EXPECT_TRUE(std::equal(src, src + size, gameData));
		}
	};

	SetUpGames(nb);
	addNative (gameSimpleIe_,  gameSimpleData_.data(),  gameSimpleData_.size());
	saveNative(gameComplexIe_, gameComplexData_.data(), gameComplexData_.size(), 0);
	saveGame  (gameSimple_,    gameSimpleData_.data(),  gameSimpleData_.size(),  0);
	saveGame  (gameComplex_,   gameComplexData_.data(), gameComplexData_.size(), 0);
	saveNative(gameSimpleIe_,  gameSimpleData_.data(),  gameSimpleData_.size(),  0);
	addGame   (gameComplex_,   gameComplexData_.data(), gameComplexData_.size());
	saveGame  (gameSimple_,    gameSimpleData_.data(),  gameSimpleData_.size(),  1);
	saveNative(gameComplexIe_, gameComplexData_.data(), gameComplexData_.size(), 1);
	saveNative(gameSimpleIe_,  gameSimpleData_.data(),  gameSimpleData_.size(),  1);
	addGame   (gameSimple_,    gameSimpleData_.data(),  gameSimpleData_.size());
	addNative (gameComplexIe_, gameComplexData_.data(), gameComplexData_.size());
	saveGame  (gameComplex_,   gameComplexData_.data(), gameComplexData_.size(), 1);


	codec->flush();

	if (supports("FMODE" + std::to_string(FMODE_ReadOnly))) {
		Index idxReopen;
		NameBase nbReopen;
		auto codec2 = std::unique_ptr<ICodecDatabase>(
		    ICodecDatabase::make(dbtype, &err, FMODE_ReadOnly, filename,
		                         Progress(), &idxReopen, &nbReopen));
		ASSERT_NE(nullptr, codec2);

		auto cmpGame = [&](auto gnum, auto& origIe, auto& origGData) {
			const IndexEntry* ie = idxReopen.GetEntry(gnum);
			IndexEntry tmpIe = origIe;
			EXPECT_STREQ(tmpIe.GetWhiteName(&nb), ie->GetWhiteName(&nbReopen));
			tmpIe.SetWhite(ie->GetWhite());
			EXPECT_STREQ(tmpIe.GetBlackName(&nb), ie->GetBlackName(&nbReopen));
			tmpIe.SetBlack(ie->GetBlack());
			EXPECT_STREQ(tmpIe.GetEventName(&nb), ie->GetEventName(&nbReopen));
			tmpIe.SetEvent(ie->GetEvent());
			EXPECT_STREQ(tmpIe.GetSiteName(&nb), ie->GetSiteName(&nbReopen));
			tmpIe.SetSite(ie->GetSite());
			EXPECT_STREQ(tmpIe.GetRoundName(&nb), ie->GetRoundName(&nbReopen));
			tmpIe.SetRound(ie->GetRound());
			tmpIe.SetOffset(ie->GetOffset());
			tmpIe.SetLength(ie->GetLength());
			EXPECT_EQ(0, std::memcmp(ie, &tmpIe, sizeof(tmpIe)));

			const byte* gameData =
			    codec2->getGameData(ie->GetOffset(), ie->GetLength());
			EXPECT_TRUE(
			    std::equal(origGData.begin(), origGData.end(), gameData));
		};

		cmpGame(0, gameSimpleIe_, gameSimpleData_);
		cmpGame(1, gameComplexIe_, gameComplexData_);
		cmpGame(2, gameSimpleIe_, gameSimpleData_);
		cmpGame(3, gameComplexIe_, gameComplexData_);
	}

	// Remove the files created
	auto filenames = codec->getFilenames();
	delete codec;
	for (const auto& filename : filenames) {
		EXPECT_EQ(0, std::remove(filename.c_str()));
	}
}

INSTANTIATE_TEST_CASE_P(CodecDatabase, Test_Codec, ::testing::ValuesIn(codecs));
