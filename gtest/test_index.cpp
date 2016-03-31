/*
* Copyright (C) 2015 Fulvio Benini

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

#include "index.h"
#include <gtest/gtest.h>

class Test_Index : public ::testing::Test {
	virtual void SetUp() {
		idNumberT idNumber;
		for (nameT nt = 0; nt < NUM_NAME_TYPES; nt++) {
			for (size_t i = 0; i < 100; i++)
				nb_dummy.AddName(nt, std::to_string(i).c_str(), &idNumber);
		}
	}


protected:
	const dateT  maxDate = DATE_MAKE(2047, 12, 31);
	const size_t max24 = (1 << 24) - 1;
	const size_t max20 = (1 << 20) - 1;
	const size_t max19 = (1 << 19) - 1;
	const size_t max18 = (1 << 18) - 1;
	const size_t max16 = (1 << 16) - 1;
	const size_t max12 = (1 << 12) - 1;
	const size_t max10 = (1 << 10) - 1;
	const size_t max8 = (1 << 8) - 1;
	const size_t max4 = (1 << 4) - 1;

	NameBase nb_dummy;

	IndexEntry createIndexEntry(uint64_t i, uint64_t i16, uint64_t i7) {
		IndexEntry ie;
		ie.Init();
		ie.SetWhite(i++);
		ie.SetBlack(i++);
		ie.SetEvent(i++);
		ie.SetSite(i++);
		ie.SetRound(i++);
		ie.SetDate(i++);
		ie.SetEventDate(i++);
		ie.SetResult(i16++);
		ie.SetWhiteElo(i++);
		ie.SetBlackElo(i++);
		ie.SetWhiteRatingType(i16++);
		ie.SetBlackRatingType(i16++);
		ie.SetEcoCode(i++);
		ie.SetNumHalfMoves(i++);
		ie.SetFlag(i++, true);
		ie.SetVariationCount(i7++);
		ie.SetCommentCount(i7++);
		ie.SetNagCount(i7++);
		ie.SetFinalMatSig(i++);
		ie.SetStoredLineCode(i++);
		return ie;
	}

	IndexEntry createIndexEntryMax() {
		IndexEntry ie;
		ie.Init();
		ie.SetWhite(~0);
		ie.SetBlack(~0);
		ie.SetEvent(~0);
		ie.SetSite(~0);
		ie.SetRound(~0);
		ie.SetDate(maxDate);
		ie.SetEventDate(maxDate);
		ie.SetResult(~0);
		ie.SetWhiteElo(~0);
		ie.SetBlackElo(~0);
		ie.SetWhiteRatingType(~0);
		ie.SetBlackRatingType(~0);
		ie.SetEcoCode(~0);
		ie.SetNumHalfMoves(~0);
		ie.SetFlag(~0, true);
		ie.SetVariationCount(~0);
		ie.SetCommentCount(~0);
		ie.SetNagCount(~0);
		ie.SetFinalMatSig(~0);
		ie.SetStoredLineCode(~0);
		return ie;
	}

	void expectIndexEntryMax(const IndexEntry* ie) {
		EXPECT_EQ(max20, ie->GetWhite());
		EXPECT_EQ(max20, ie->GetBlack());
		EXPECT_EQ(max19, ie->GetEvent());
		EXPECT_EQ(max19, ie->GetSite());
		EXPECT_EQ(max18, ie->GetRound());
		EXPECT_EQ(maxDate, ie->GetDate());
		EXPECT_EQ(maxDate, ie->GetEventDate());
		EXPECT_EQ(max4, ie->GetResult());
		EXPECT_EQ(max12, ie->GetWhiteElo());
		EXPECT_EQ(max12, ie->GetBlackElo());
		EXPECT_EQ(max4, ie->GetWhiteRatingType());
		EXPECT_EQ(max4, ie->GetBlackRatingType());
		EXPECT_EQ(max16, ie->GetEcoCode());
		EXPECT_EQ(max16, ie->GetNumHalfMoves());
		for (size_t i = 0; i < IDX_NUM_FLAGS; i++) {
			EXPECT_TRUE(ie->GetFlag(1 << i));
		}
		EXPECT_EQ(50, ie->GetVariationCount());
		EXPECT_EQ(50, ie->GetCommentCount());
		EXPECT_EQ(50, ie->GetNagCount());
		EXPECT_EQ(max24, ie->GetFinalMatSig());
		EXPECT_EQ(max8, ie->GetStoredLineCode());
	}

};

TEST_F(Test_Index, file_io) {
	{ // Create
		Index index_out;
		ASSERT_EQ(OK, index_out.Create("test_index1"));
		IndexEntry ie = createIndexEntry(1, 1, 1);
		index_out.AddGame(&ie);
	}
	{ // Add games
		Index index_out;
		ASSERT_EQ(OK, index_out.Open("test_index1", FMODE_Both));
		EXPECT_EQ(OK, index_out.ReadEntireFile(&nb_dummy, Progress()));

		IndexEntry ie = createIndexEntry(21, 4, 4);
		index_out.AddGame(&ie);
		IndexEntry* ie_fetch = index_out.FetchEntry(0);
		ie_fetch->SetEvent(19);
		index_out.WriteEntry(ie_fetch, 0);

		index_out.SetType(5);
		index_out.SetDescription("unit test");
		for (auto flag = IDX_FLAG_CUSTOM1; flag < IDX_FLAG_CUSTOM1 + CUSTOM_FLAG_MAX; flag++) {
			index_out.SetCustomFlagDesc(flag, (std::to_string(flag) + " desc").c_str());
		}
		index_out.SetAutoLoad(2);
	}
	{ // Read games and check that they have the right values
		Index index_in;
		ASSERT_EQ(OK, index_in.Open("test_index1", FMODE_ReadOnly));
		EXPECT_EQ(OK, index_in.ReadEntireFile(&nb_dummy, Progress()));
		ASSERT_EQ(2, index_in.GetNumGames());
		EXPECT_EQ(5, index_in.GetType());
		EXPECT_STREQ("unit test", index_in.GetDescription());
		for (auto flag = IDX_FLAG_CUSTOM1; flag < IDX_FLAG_CUSTOM1 + CUSTOM_FLAG_MAX; flag++) {
			EXPECT_STREQ((std::to_string(flag) + " desc").c_str(),
				index_in.GetCustomFlagDesc(flag));
		}
		EXPECT_EQ(2, index_in.GetAutoLoad());

		size_t j7 = 1;
		size_t j16 = 1;
		for (gamenumT idx = 0; idx < 2; idx++) {
			size_t j = 1 + idx * 20;
			const IndexEntry* ie = index_in.GetEntry(idx);
			EXPECT_EQ(j++, ie->GetWhite());
			EXPECT_EQ(j++, ie->GetBlack());
			if (idx == 0) {
				EXPECT_EQ(19, ie->GetEvent());
				j++;
			}
			else {
				EXPECT_EQ(j++, ie->GetEvent());
			}
			EXPECT_EQ(j++, ie->GetSite());
			EXPECT_EQ(j++, ie->GetRound());
			EXPECT_EQ(j++, ie->GetDate());
			EXPECT_EQ(j++, ie->GetEventDate());
			EXPECT_EQ(j16++, ie->GetResult());
			EXPECT_EQ(j++, ie->GetWhiteElo());
			EXPECT_EQ(j++, ie->GetBlackElo());
			EXPECT_EQ(j16++, ie->GetWhiteRatingType());
			EXPECT_EQ(j16++, ie->GetBlackRatingType());
			EXPECT_EQ(j++, ie->GetEcoCode());
			EXPECT_EQ(j++, ie->GetNumHalfMoves());
			EXPECT_TRUE(ie->GetFlag(j++));
			EXPECT_EQ(j7++, ie->GetVariationCount());
			EXPECT_EQ(j7++, ie->GetCommentCount());
			EXPECT_EQ(j7++, ie->GetNagCount());
			EXPECT_EQ(j++, ie->GetFinalMatSig());
			EXPECT_EQ(j++, ie->GetStoredLineCode());
		}
	}
	std::remove("test_index1.si4");
}

TEST_F(Test_Index, max_values) {
	{
		Index index_out;
		ASSERT_EQ(OK, index_out.Create("test_index2"));
		IndexEntry ie = createIndexEntryMax();
		expectIndexEntryMax(&ie);
		index_out.AddGame(&ie);
	}
	{
		Index index_in;
		ASSERT_EQ(OK, index_in.Open("test_index2", FMODE_Both));
		EXPECT_EQ(ERROR_NameDataLoss, index_in.ReadEntireFile(&nb_dummy, Progress()));
		ASSERT_EQ(1, index_in.GetNumGames());

		const IndexEntry* ie = index_in.GetEntry(0);
		EXPECT_EQ(nb_dummy.GetNumNames(NAME_PLAYER) - 1, ie->GetWhite());
		EXPECT_EQ(nb_dummy.GetNumNames(NAME_PLAYER) - 1, ie->GetBlack());
		EXPECT_EQ(nb_dummy.GetNumNames(NAME_EVENT) - 1, ie->GetEvent());
		EXPECT_EQ(nb_dummy.GetNumNames(NAME_SITE) - 1, ie->GetSite());
		EXPECT_EQ(nb_dummy.GetNumNames(NAME_ROUND) - 1, ie->GetRound());
		EXPECT_EQ(maxDate, ie->GetDate());
		EXPECT_EQ(maxDate, ie->GetEventDate());
		EXPECT_EQ(max4, ie->GetResult());
		EXPECT_EQ(MAX_ELO, ie->GetWhiteElo());
		EXPECT_EQ(MAX_ELO, ie->GetBlackElo());
		EXPECT_EQ(max4, ie->GetWhiteRatingType());
		EXPECT_EQ(max4, ie->GetBlackRatingType());
		EXPECT_EQ(max16, ie->GetEcoCode());
		EXPECT_EQ(max10, ie->GetNumHalfMoves());
		for (size_t i = 0; i < IDX_NUM_FLAGS; i++) {
			EXPECT_TRUE(ie->GetFlag(1 << i));
		}
		EXPECT_EQ(50, ie->GetVariationCount());
		EXPECT_EQ(50, ie->GetCommentCount());
		EXPECT_EQ(50, ie->GetNagCount());
		EXPECT_EQ(max24, ie->GetFinalMatSig());
		EXPECT_EQ(max8, ie->GetStoredLineCode());
	}
	std::remove("test_index2.si4");
}
