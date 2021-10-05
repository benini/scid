/*
 * Copyright (C) 2017 Fulvio Benini
 *
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

#include "codec_scid4.h"
#include "date.h"
#include "indexentry.h"
#include <algorithm>
#include <gtest/gtest.h>
#include <random>
#include <stdint.h>
#include <vector>

namespace v4_6 {
#include "test_indexentry_v4_6.h"
}

namespace {

class Buffer {
	char buf_[1024];
	char* it_ = buf_;

public:
	void ToStart() { it_ = buf_; }

	bool equal(const Buffer& b, size_t count) {
		return std::equal(buf_, buf_ + count, b.buf_);
	}

	char* getBuffer() {
		return buf_;
	}

	size_t sputn(const char* s, size_t count) {
		it_ = std::copy_n(s, count, it_);
		return count;
	}

	byte ReadOneByte() { return *it_++; }
	uint16_t ReadTwoBytes() { return static_cast<uint16_t>(read<2>()); }
	uint32_t ReadThreeBytes() { return read<3>(); }
	uint32_t ReadFourBytes() { return read<4>(); }

	int WriteOneByte(byte value) {
		*it_ = static_cast<char>(value);
		++it_;
		return 1;
	}

	int WriteTwoBytes(uint32_t value) {
		return WriteOneByte(static_cast<byte>(value >> 8)) +
		       WriteOneByte(static_cast<byte>(value));
	}
	int WriteThreeBytes(uint32_t value) {
		return WriteOneByte(static_cast<byte>(value >> 16)) +
		       WriteOneByte(static_cast<byte>(value >> 8)) +
		       WriteOneByte(static_cast<byte>(value));
	}
	int WriteFourBytes(uint32_t value) {
		return WriteOneByte(static_cast<byte>(value >> 24)) +
		       WriteOneByte(static_cast<byte>(value >> 16)) +
		       WriteOneByte(static_cast<byte>(value >> 8)) +
		       WriteOneByte(static_cast<byte>(value));
	}

private:
	template <int nBytes> uint32_t read() {
		uint32_t res = 0;
		if (nBytes > 3)
			res += ReadOneByte() << 24;
		if (nBytes > 2)
			res += ReadOneByte() << 16;
		if (nBytes > 1)
			res += ReadOneByte() << 8;
		return res + ReadOneByte();
	}
};

} // namespace

TEST(Test_IndexEntry, Flags_dedicatedGetSet) {
	IndexEntry ie;
	std::mt19937 re(std::random_device{}());
	std::uniform_int_distribution<> rnd{0, 1};
	for (int i = 0; i < 100000; ++i) {
		bool v[7];
		std::generate(std::begin(v), std::end(v), [&]() { return rnd(re); });

		ie.clearFlags();
		ie.SetStartFlag(v[0]);
		ie.SetPromotionsFlag(v[1]);
		ie.SetUnderPromoFlag(v[2]);
		ie.SetDeleteFlag(v[3]);
		ie.SetCommentCount(v[4]);
		ie.SetVariationCount(v[5]);
		ie.SetNagCount(v[6]);
		EXPECT_EQ(v[0], ie.GetStartFlag());
		EXPECT_EQ(v[1], ie.GetPromotionsFlag());
		EXPECT_EQ(v[2], ie.GetUnderPromoFlag());
		EXPECT_EQ(v[3], ie.GetDeleteFlag());
		EXPECT_EQ(v[4], ie.GetCommentsFlag());
		EXPECT_EQ(v[5], ie.GetVariationsFlag());
		EXPECT_EQ(v[6], ie.GetNagsFlag());
	}
}

TEST(Test_IndexEntry, Flags) {
	IndexEntry ie;
	ie.clearFlags();

	uint32_t flags = 0;
	std::mt19937 re(std::random_device{}());
	for (int i = 0; i < 100000; ++i) {
		auto rnd = std::uniform_int_distribution<uint32_t>{
		    0, (1UL << IndexEntry::IDX_NUM_FLAGS) - 1}(re);
		if (i & 0x01) {
			ie.clearFlags();
			flags = rnd; // Reset flags
		} else {
			flags |= rnd; // Add to previous flags
		}
		ie.SetFlag(rnd, true);

		for (int32_t j = 0; j <= IndexEntry::IDX_NUM_FLAGS; j++) {
			EXPECT_EQ((flags & (1 << j)) != 0, ie.GetFlag(1 << j));
		}

		EXPECT_TRUE(ie.GetFlag(flags));
	}
}
