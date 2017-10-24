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
#include <vector>

TEST(Test_Index, Index_calcNameFreq) {
	Index idx;
	NameBase nb;

	const char* names[] = {"test", "tèst", "test ", "test1", "test2", "test3"};
	nameT types[] = {NAME_PLAYER, NAME_EVENT, NAME_SITE, NAME_ROUND};
	std::vector<int> nameFreq[NUM_NAME_TYPES];
	std::vector<int> expected[NUM_NAME_TYPES];

	// Add names with index 0
	IndexEntry ie;
	ie.Init();
	idNumberT id;
	for (auto& nt : types) {
		EXPECT_EQ(OK, nb.AddName(nt, "?", &id));
		EXPECT_EQ(id, 0U);
		expected[nt].push_back(1);
	}
	expected[NAME_PLAYER][0] += 1;
	idx.AddGame(&ie);

	for (auto& name : names) {
		for (auto& nt : types) {
			EXPECT_EQ(OK, nb.AddName(nt, name, &id));
			EXPECT_EQ(id, expected[nt].size());
			expected[nt].push_back(0);

			auto id = nb.getID(nt, name, 255, 1000);
			ASSERT_EQ(OK, id.first);

			switch (nt) {
			case NAME_PLAYER:
				ie.SetWhite(id.second);
				ie.SetBlack(id.second);
				break;
			case NAME_EVENT:
				ie.SetEvent(id.second);
				break;
			case NAME_SITE:
				ie.SetSite(id.second);
				break;
			case NAME_ROUND:
				ie.SetRound(id.second);
				break;
			}
			idx.AddGame(&ie);
			idx.calcNameFreq(nb, nameFreq);
			expected[NAME_PLAYER][ie.GetWhite()] += 1;
			expected[NAME_PLAYER][ie.GetBlack()] += 1;
			expected[NAME_EVENT][ie.GetEvent()] += 1;
			expected[NAME_SITE][ie.GetSite()] += 1;
			expected[NAME_ROUND][ie.GetRound()] += 1;
			for (auto& t : types) {
				EXPECT_TRUE(expected[t] == nameFreq[t]);
			}
		}
	}
}
