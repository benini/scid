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

#include "misc.h"
#include "timer.h"
#include <gtest/gtest.h>
#include <random>

namespace v4_6_2 {
	uint strTrimRight(char * target, const char * trimChars);
}


class Test_StrTrimRight : public ::testing::Test {
	// strTrimRight testing
	virtual void SetUp() {
		char* s = buf;
		for (auto& e : data_) {
			auto sz = strlen(e.static_input) + 1;

			e.input1 = s;
			strcpy(e.input1, e.static_input);
			s += sz;

			e.input2 = s;
			strcpy(e.input2, e.static_input);
			s += sz;
		}
	}

protected:
	char buf[1024];
	struct Data {
		const char* static_input;
		char* input1;
		char* input2;
		const char* expected;
		uint nTrimmed;
	};

	std::vector<Data> data_ = {
		{ ""    , nullptr, nullptr, ""   , 0 } ,
		{ " "   , nullptr, nullptr, ""   , 1 } ,
		{ "a"   , nullptr, nullptr, "a"  , 0 } ,
		{ "a "  , nullptr, nullptr, "a"  , 1 } ,
		{ " a"  , nullptr, nullptr, " a" , 0 } ,
		{ "  "  , nullptr, nullptr, ""   , 2 } ,
		{ "a  " , nullptr, nullptr, "a"  , 2 } ,
		{ "a\t ", nullptr, nullptr, "a"  , 2 } ,
		{ " a " , nullptr, nullptr, " a" , 1 } ,
		{ "  a" , nullptr, nullptr, "  a", 0 } ,
		{ " a  ", nullptr, nullptr, " a" , 2 } ,
		{ " \rare\n\t\r  ", nullptr, nullptr, " \rare" , 5 } ,
		{ u8"utf8 κόσμε\t\r ♚♛♜ \n ", nullptr, nullptr, u8"utf8 κόσμε\t\r ♚♛♜" , 3 }
	};

	size_t createRandom(char*& buf1, char*& buf2, size_t maxLineLenght) {
		std::default_random_engine re(std::random_device{}());
		std::uniform_int_distribution<> lineLenght(1, maxLineLenght - 1);
		std::uniform_int_distribution<> randomChar(1, 227);
		size_t nLines = std::uniform_int_distribution<>{2000, 4000}(re);
		buf1 = new char[maxLineLenght * nLines];
		buf2 = new char[maxLineLenght * nLines];
		for (size_t i = 0; i < nLines; i++) {
			size_t len = lineLenght(re);
			for (size_t j = 0; j < len; j++) {
				auto ch = randomChar(re);
				if (ch > 127) ch = WHITESPACE[ch % 4];
				buf1[maxLineLenght * i + j] = ch;
				buf2[maxLineLenght * i + j] = ch;
			}
			buf1[maxLineLenght * i + len] = 0;
			buf2[maxLineLenght * i + len] = 0;
		}
		return nLines;
	}
};

TEST_F(Test_StrTrimRight, correctness) {
	for (auto& e : data_) {
		auto n = strTrimRight(e.input1);
		EXPECT_EQ(e.nTrimmed, n);
		EXPECT_STREQ(e.expected, e.input1);
	}
}

TEST_F(Test_StrTrimRight, consistency) {
	for (auto& e : data_) {
		auto n = strTrimRight(e.input1);
		auto n_old = v4_6_2::strTrimRight(e.input2, WHITESPACE);
		EXPECT_EQ(n_old, n);
		EXPECT_STREQ(e.input2, e.input1);
	}
}

TEST_F(Test_StrTrimRight, performance) {
	const size_t lineLen = 130;
	char* buf1;
	char* buf2;
	size_t nLines = createRandom(buf1, buf2, lineLen);

	Timer t1;
	for (size_t i = 0; i < nLines; i++) {
		strTrimRight(buf1 + lineLen * i);
	}
	auto tNew = t1.MilliSecs();

	Timer t2;
	for (size_t i = 0; i < nLines; i++) {
		v4_6_2::strTrimRight(buf2 + lineLen * i, WHITESPACE);
	}
	auto tOld = t2.MilliSecs();

	EXPECT_LE(tNew, tOld);
	for (size_t i = 0; i < nLines; i++) {
		ASSERT_STREQ(buf2 + lineLen * i, buf1 + lineLen * i);
	}

	delete[] buf1;
	delete[] buf2;
}

namespace v4_6_2 {
	uint strTrimRight(char * target, const char * trimChars) {
		uint trimCount = 0;
		char * s = target;
		char * lastNonTrim = NULL;
		while (*s) {
			if (strContainsChar(trimChars, *s)) {
				trimCount++;
			}
			else {
				lastNonTrim = s;
				trimCount = 0;
			}
			s++;
		}
		if (lastNonTrim != NULL) {
			// End the string after the last nontrimmable char:
			lastNonTrim++;
			*lastNonTrim = 0;
		}
		else {
			// The string only contained trimmable characters:
			*target = 0;
		}
		return trimCount;
	}
}
