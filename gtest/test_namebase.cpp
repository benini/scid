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

#include "namebase.h"
#include <string>
#include <vector>
#include <map>
#include <gtest/gtest.h>

class Test_Namebase : public ::testing::Test {
};

TEST_F(Test_Namebase, id_limits) {
	NameBase nb;
	long nLimit[NUM_NAME_TYPES] = { 0 };
	bool finished = false;
	for (unsigned long count = 0; !finished; count++) {
		finished = true;
		std::string name = std::to_string(count);
		for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
			idNumberT id = 0;
			if (OK == nb.AddName(nt, name.c_str(), &id)) {
				EXPECT_EQ(id, nLimit[nt]++);
				finished = false;
			}
		}
	}

	EXPECT_EQ(nLimit[NAME_PLAYER], (1 << 20) - 1);
	EXPECT_EQ(nLimit[NAME_EVENT], (1 << 19) - 1);
	EXPECT_EQ(nLimit[NAME_SITE], (1 << 19) - 1);
	EXPECT_EQ(nLimit[NAME_ROUND], (1 << 18) - 1);
}

TEST_F(Test_Namebase, max_chars) {
	// .pgn and .sn4 files cannot store names longer than 255 bytes
	NameBase nb;
	long maxCh[NUM_NAME_TYPES] = { 0 };
	long maxChUtf8[NUM_NAME_TYPES] = { 0 };
	long maxChMixed1[NUM_NAME_TYPES] = { 0 };
	long maxChMixed2[NUM_NAME_TYPES] = { 0 };
	std::string ch, chUtf8, chMixed1;
	std::string chMixed2 = " ";
	bool mixed = true;
	bool finished = false;
	while (!finished) {
		ch += "A";
		chUtf8 += "Ü";
		chMixed1 += (mixed) ? "A" : "Ü";
		chMixed2 += (mixed) ? "A" : "Ü";
		mixed = !mixed;
		finished = true;
		for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
			idNumberT id;
			if (OK == nb.AddName(nt, ch.c_str(), &id)) {
				maxCh[nt]++;
				finished = false;
			}
			if (OK == nb.AddName(nt, chUtf8.c_str(), &id)) {
				maxChUtf8[nt]++;
				finished = false;
			}
			if (OK == nb.AddName(nt, chMixed1.c_str(), &id)) {
				maxChMixed1[nt]++;
				finished = false;
			}
			if (OK == nb.AddName(nt, chMixed2.c_str(), &id)) {
				maxChMixed2[nt]++;
				finished = false;
			}
		}
	}

	for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
		EXPECT_EQ(maxCh[nt], 255);
		EXPECT_EQ(maxChUtf8[nt], 127);
		EXPECT_EQ(maxChMixed1[nt], 170);
		EXPECT_EQ(maxChMixed2[nt], 169);
	}
}

TEST_F(Test_Namebase, FindExactName) {
	std::vector<const char*> test_names = {
		"Empty", "",
		"Spaces", " ", " Spaces", "Spaces ", " Spaces ",
		"German:", "Ä" "ä" "Ü" "ü" "ß",
		"Russian:", "Я", "Б", "Г", "Д", "Ж", "Й"
		"Polish:", "Ł", "Ą", "Ż", "Ę", "Ć", "Ń", "Ś", "Ź"
		"Kanji:", "てすと", "(te-su-to)",
		"Hankaku:", "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃ"
	};
	NameBase nb;
	std::map<idNumberT, const char*> ids[NUM_NAME_TYPES];
	for (const char* name : test_names) {
		for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
			idNumberT id = 0;
			EXPECT_EQ(OK, nb.AddName(nt, name, &id));
			EXPECT_TRUE(ids[nt].emplace(id, name).second);
		}
	}

	for (const char* name : test_names) {
		for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
			idNumberT id = 0;
			EXPECT_EQ(OK, nb.FindExactName(nt, name, &id));
			EXPECT_STREQ(ids[nt][id], name);
		}
	}
}

TEST_F(Test_Namebase, sort_order) {
	// Older Scid versions (< 4.6) used a class StrTree that
	// implemented an hybrid hash map/sorted binary tree.
	// The code was written in 1999 and have at least 2 known issues
	// with strings starting with a unicode char:
	// - a unicode char use multiple bytes, usually 2.
	//   The StrTree class will treat the first byte as unsigned (-1 > 127)
	//   and the other bytes as signed (-1 < 127).
	//   This leads to strings that are not consistently sorted.
	// - If strings are inserted using a different order the StrTree class have
	//   side-effects, including the possibility to create duplicate entries.
	// To minimize issues with older versions it is necessary to
	// keep using that sorting criteria.
	NameBase nb;
	nameT nt = NAME_PLAYER;
	idNumberT id;
	EXPECT_EQ(OK, nb.AddName(nt, "AA", &id));
	EXPECT_EQ(OK, nb.AddName(nt, "AÜ", &id));
	EXPECT_EQ(OK, nb.AddName(nt, "ÜA", &id));
	EXPECT_EQ(OK, nb.AddName(nt, "ÜÜ", &id));
	idNumberT names[4] = { 0 };
	nb.GetFirstMatches(nt, "", 4, names);
	EXPECT_STREQ(nb.GetName(nt, names[0]), "AÜ");
	EXPECT_STREQ(nb.GetName(nt, names[1]), "AA");
	EXPECT_STREQ(nb.GetName(nt, names[2]), "ÜÜ");
	EXPECT_STREQ(nb.GetName(nt, names[3]), "ÜA");
}
