/*
 * Copyright (C) 2026  Fulvio Benini.
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

#include "filemap.h"
#include <algorithm>
#include <filesystem>
#include <gtest/gtest.h>
#include <random>
#include <vector>

class Test_FileMap : public ::testing::Test {
protected:
	std::filesystem::path tempFile_;

	void SetUp() override {
		auto* info = ::testing::UnitTest::GetInstance()->current_test_info();
		tempFile_ = std::filesystem::temp_directory_path() /
		            (std::string(info->test_suite_name()) + "_" + info->name());
		// Ensure clean state
		std::filesystem::remove(tempFile_);
	}

	void TearDown() override { std::filesystem::remove(tempFile_); }
};

// ============================================================================
// 1. Buffer management in append
// ============================================================================

TEST_F(Test_FileMap, BufferManagement_SmallDataStaysBuffered) {
	constexpr size_t kBufferSize = 64;
	const char* data = "Hello, World!";
	size_t len = strlen(data);

	{
		FileMap<kBufferSize> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append(data, len));
		EXPECT_EQ(len, file.size());
	}

	FileMap<kBufferSize> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(len, reader.size());
	EXPECT_EQ("Hello, World!", reader.view_at(0, len));
}

TEST_F(Test_FileMap, BufferManagement_ExactlyBufferSize) {
	constexpr size_t kBufferSize = 64;
	std::vector<char> data(kBufferSize, 'A');

	{
		FileMap<kBufferSize> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append(data.data(), data.size()));
		EXPECT_EQ(kBufferSize, file.size());
	}

	FileMap<kBufferSize> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(kBufferSize, reader.size());
	auto view = reader.view_at(0, kBufferSize);
	EXPECT_TRUE(std::equal(view.begin(), view.end(), data.begin()));
}

TEST_F(Test_FileMap, BufferManagement_LargerThanBufferDirectWrite) {
	constexpr size_t kBufferSize = 64;
	std::vector<char> data(kBufferSize * 3, 'B');

	{
		FileMap<kBufferSize> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append(data.data(), data.size()));
		EXPECT_EQ(data.size(), file.size());
	}

	FileMap<kBufferSize> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(data.size(), reader.size());
	auto view = reader.view_at(0, data.size());
	EXPECT_TRUE(std::equal(view.begin(), view.end(), data.begin()));
}

TEST_F(Test_FileMap, BufferManagement_SizeIncludesBufferedData) {
	constexpr size_t kBufferSize = 64;

	FileMap<kBufferSize> file;
	ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

	EXPECT_EQ(0u, file.size());

	ASSERT_EQ(OK, file.append("Hello", 5));
	EXPECT_EQ(5u, file.size());

	ASSERT_EQ(OK, file.append("World", 5));
	EXPECT_EQ(10u, file.size());

	ASSERT_EQ(OK, file.pubsync());
	EXPECT_EQ(10u, file.size());

	ASSERT_EQ(OK, file.append("!", 1));
	EXPECT_EQ(11u, file.size());
}

// ============================================================================
// 2. view_at behavior
// ============================================================================

TEST_F(Test_FileMap, ViewAt_ValidReads) {
	const char* data = "0123456789ABCDEF";
	size_t len = strlen(data);

	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append(data, len));
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));

	EXPECT_EQ("0123", reader.view_at(0, 4));
	EXPECT_EQ("4567", reader.view_at(4, 4));
	EXPECT_EQ("CDEF", reader.view_at(12, 4));
	EXPECT_EQ(data, reader.view_at(0, len));
}

TEST_F(Test_FileMap, ViewAt_OffsetAtOrBeyondSize) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append("Hello", 5));
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));

	EXPECT_TRUE(reader.view_at(5, 1).empty());
	EXPECT_TRUE(reader.view_at(100, 1).empty());
	EXPECT_TRUE(reader.view_at(std::numeric_limits<size_t>::max(), 1).empty());
}

TEST_F(Test_FileMap, ViewAt_CountExceedsAvailable) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append("Hello", 5));
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));

	auto view1 = reader.view_at(0, 100);
	EXPECT_EQ(5u, view1.size());
	EXPECT_EQ("Hello", view1);

	auto view2 = reader.view_at(3, 100);
	EXPECT_EQ(2u, view2.size());
	EXPECT_EQ("lo", view2);

	auto view3 = reader.view_at(0, std::numeric_limits<size_t>::max());
	EXPECT_EQ(5u, view3.size());
}

TEST_F(Test_FileMap, ViewAt_EmptyFileReturnsEmptyView) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));

	EXPECT_EQ(0u, reader.size());
	EXPECT_TRUE(reader.view_at(0, 0).empty());
	EXPECT_TRUE(reader.view_at(0, 10).empty());
	EXPECT_TRUE(reader.view_at(5, 10).empty());
}

TEST_F(Test_FileMap, ViewAt_ReflectsDataOnlyAfterPubsync) {
	FileMap<64> file;
	ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

	ASSERT_EQ(OK, file.append("First", 5));
	ASSERT_EQ(OK, file.pubsync());
	EXPECT_EQ("First", file.view_at(0, 5));

	ASSERT_EQ(OK, file.append("Second", 6));
	EXPECT_EQ(11u, file.size());

	ASSERT_EQ(OK, file.pubsync());
	EXPECT_EQ("FirstSecond", file.view_at(0, 11));
}

// ============================================================================
// 3. pubsync lifecycle
// ============================================================================

TEST_F(Test_FileMap, Pubsync_FlushBufferSyncRemap) {
	FileMap<64> file;
	ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

	for (int i = 0; i < 5; ++i) {
		ASSERT_EQ(OK, file.append("AAAA", 4));
	}
	EXPECT_EQ(20u, file.size());

	ASSERT_EQ(OK, file.pubsync());

	EXPECT_EQ(std::string(20, 'A'), file.view_at(0, 20));
}

TEST_F(Test_FileMap, Pubsync_ViewAtWorksAfterFileGrows) {
	FileMap<64> file;
	ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

	ASSERT_EQ(OK, file.append("Initial", 7));
	ASSERT_EQ(OK, file.pubsync());
	EXPECT_EQ("Initial", file.view_at(0, 7));

	ASSERT_EQ(OK, file.append("Appended", 8));
	ASSERT_EQ(OK, file.pubsync());

	EXPECT_EQ("InitialAppended", file.view_at(0, 15));
	EXPECT_EQ("Appended", file.view_at(7, 8));
}

TEST_F(Test_FileMap, Pubsync_MultipleSyncs) {
	std::string expected;

	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

		for (int i = 0; i < 10; ++i) {
			std::string chunk = "Chunk" + std::to_string(i);
			ASSERT_EQ(OK, file.append(chunk.data(), chunk.size()));
			expected += chunk;
			ASSERT_EQ(OK, file.pubsync());
			EXPECT_EQ(expected, file.view_at(0, expected.size()));
		}
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(expected, reader.view_at(0, expected.size()));
}

// ============================================================================
// 4. File modes
// ============================================================================

TEST_F(Test_FileMap, FileMode_ReadOnly_NoWrites) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append("Test content", 12));
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(12u, reader.size());
	EXPECT_EQ("Test content", reader.view_at(0, 12));

	EXPECT_EQ(OK, reader.append("More", 4));
	EXPECT_EQ(16u, reader.size());
	EXPECT_NE(OK, reader.pubsync());
}

TEST_F(Test_FileMap, FileMode_Both_ReadAndAppend) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append("Initial", 7));
	}

	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Both));
		EXPECT_EQ(7u, file.size());
		EXPECT_EQ("Initial", file.view_at(0, 7));

		ASSERT_EQ(OK, file.append("Appended", 8));
		ASSERT_EQ(OK, file.pubsync());
		EXPECT_EQ(15u, file.size());
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ("InitialAppended", reader.view_at(0, 15));
}

TEST_F(Test_FileMap, FileMode_Create_TruncatesExisting) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append("Original content that is long", 29));
	}

	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		EXPECT_EQ(0u, file.size());
		ASSERT_EQ(OK, file.append("New", 3));
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(3u, reader.size());
	EXPECT_EQ("New", reader.view_at(0, 3));
}

// ============================================================================
// 5. Round-trip tests
// ============================================================================

TEST_F(Test_FileMap, RoundTrip_VariousSizes) {
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<> randch(0, 255);

	std::vector<size_t> sizes = {1,   10,  63,  64,   65,   127,  128,
	                             129, 256, 512, 1024, 4096, 8192, 10000};

	for (size_t dataSize : sizes) {
		std::vector<char> original(dataSize);
		for (auto& c : original) {
			c = static_cast<char>(randch(gen));
		}

		{
			FileMap<64> file;
			ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
			ASSERT_EQ(OK, file.append(original.data(), original.size()));
		}

		FileMap<64> reader;
		ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
		auto view = reader.view_at(0, original.size());
		ASSERT_EQ(original.size(), view.size())
		    << "Size mismatch at " << dataSize;
		EXPECT_TRUE(std::equal(view.begin(), view.end(), original.begin()))
		    << "Data mismatch at size " << dataSize;
	}
}

TEST_F(Test_FileMap, RoundTrip_RandomChunks) {
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<> randch(0, 255);
	std::uniform_int_distribution<size_t> randsize(1, 150);

	std::vector<char> allData;

	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

		for (int i = 0; i < 100; ++i) {
			size_t chunkSize = randsize(gen);
			std::vector<char> chunk(chunkSize);
			for (auto& c : chunk) {
				c = static_cast<char>(randch(gen));
			}

			ASSERT_EQ(OK, file.append(chunk.data(), chunk.size()));
			allData.insert(allData.end(), chunk.begin(), chunk.end());
			EXPECT_EQ(allData.size(), file.size());
		}
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	auto view = reader.view_at(0, allData.size());
	EXPECT_EQ(allData.size(), view.size());
	EXPECT_TRUE(std::equal(view.begin(), view.end(), allData.begin()));
}

// ============================================================================
// 6. close behavior
// ============================================================================

TEST_F(Test_FileMap, Close_FlushesPendingBuffer) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append("Buffered data", 13));
		ASSERT_EQ(OK, file.close());
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(13u, reader.size());
	EXPECT_EQ("Buffered data", reader.view_at(0, 13));
}

TEST_F(Test_FileMap, Close_ResetsAllState) {
	FileMap<64> file;

	ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
	ASSERT_EQ(OK, file.append("First", 5));
	ASSERT_EQ(OK, file.close());

	EXPECT_EQ(0u, file.size());

	ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Both));
	EXPECT_EQ(5u, file.size());

	ASSERT_EQ(OK, file.append("Second", 6));
	ASSERT_EQ(OK, file.close());

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(11u, reader.size());
	EXPECT_EQ("FirstSecond", reader.view_at(0, 11));
}

TEST_F(Test_FileMap, Close_ReopeningWorks) {
	FileMap<64> writer;
	FileMap<64> reader;

	for (int i = 0; i < 5; ++i) {
		std::string data = "Iteration" + std::to_string(i);

		ASSERT_EQ(OK, writer.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, writer.append(data.data(), data.size()));
		ASSERT_EQ(OK, writer.close());

		ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
		EXPECT_EQ(data, reader.view_at(0, reader.size()));
		ASSERT_EQ(OK, reader.close());
	}
}

// ============================================================================
// 7. Edge cases
// ============================================================================

TEST_F(Test_FileMap, EdgeCase_EmptyFile) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		EXPECT_EQ(0u, file.size());
		EXPECT_TRUE(file.view_at(0, 10).empty());
		ASSERT_EQ(OK, file.pubsync());
		EXPECT_EQ(0u, file.size());
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(0u, reader.size());
	EXPECT_TRUE(reader.view_at(0, 10).empty());
}

TEST_F(Test_FileMap, EdgeCase_AppendToEmptyFile) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		EXPECT_EQ(0u, file.size());
		ASSERT_EQ(OK, file.append("First", 5));
		EXPECT_EQ(5u, file.size());
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ("First", reader.view_at(0, 5));
}

TEST_F(Test_FileMap, EdgeCase_MultipleSmallAppendsFillBuffer) {
	constexpr size_t kBufferSize = 64;
	std::string expected;

	{
		FileMap<kBufferSize> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

		for (int i = 0; i < 16; ++i) {
			ASSERT_EQ(OK, file.append("AAAA", 4));
			expected += "AAAA";
			EXPECT_EQ(expected.size(), file.size());
		}

		EXPECT_EQ(kBufferSize, file.size());

		ASSERT_EQ(OK, file.append("BBBB", 4));
		expected += "BBBB";
		EXPECT_EQ(kBufferSize + 4, file.size());
	}

	FileMap<kBufferSize> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(expected, reader.view_at(0, expected.size()));
}

TEST_F(Test_FileMap, EdgeCase_AppendExactlyBufferBytes) {
	constexpr size_t kBufferSize = 64;
	std::vector<char> data(kBufferSize, 'X');

	{
		FileMap<kBufferSize> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append(data.data(), data.size()));
		EXPECT_EQ(kBufferSize, file.size());
	}

	FileMap<kBufferSize> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	auto view = reader.view_at(0, kBufferSize);
	EXPECT_TRUE(std::equal(view.begin(), view.end(), data.begin()));
}

TEST_F(Test_FileMap, EdgeCase_AppendNullOrZero) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

		EXPECT_EQ(OK, file.append(nullptr, 10));
		EXPECT_EQ(0u, file.size());

		EXPECT_EQ(OK, file.append("test", 0));
		EXPECT_EQ(0u, file.size());

		ASSERT_EQ(OK, file.append("Valid", 5));
		EXPECT_EQ(5u, file.size());
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(5u, reader.size());
	EXPECT_EQ("Valid", reader.view_at(0, 5));
}

// ============================================================================
// 8. Small buffer size template tests
// ============================================================================

TEST_F(Test_FileMap, SmallBuffer_OverflowPaths) {
	constexpr size_t kSmallBuffer = 16;
	std::string allData;

	{
		FileMap<kSmallBuffer> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

		ASSERT_EQ(OK, file.append("Hello", 5));
		allData += "Hello";
		EXPECT_EQ(5u, file.size());

		ASSERT_EQ(OK, file.append("World12345678", 13));
		allData += "World12345678";
		EXPECT_EQ(18u, file.size());

		std::string large(kSmallBuffer * 2, 'Z');
		ASSERT_EQ(OK, file.append(large.data(), large.size()));
		allData += large;
		EXPECT_EQ(50u, file.size());
	}

	FileMap<kSmallBuffer> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(allData, reader.view_at(0, allData.size()));
}

TEST_F(Test_FileMap, SmallBuffer_StressTest) {
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<> randch(0, 255);
	std::uniform_int_distribution<size_t> randsize(1, 50);

	constexpr size_t kSmallBuffer = 32;
	std::vector<char> expected;

	{
		FileMap<kSmallBuffer> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));

		for (int i = 0; i < 500; ++i) {
			size_t chunkSize = randsize(gen);
			std::vector<char> chunk(chunkSize);
			for (auto& c : chunk) {
				c = static_cast<char>(randch(gen));
			}

			ASSERT_EQ(OK, file.append(chunk.data(), chunk.size()));
			expected.insert(expected.end(), chunk.begin(), chunk.end());
			EXPECT_EQ(expected.size(), file.size());
		}
	}

	FileMap<kSmallBuffer> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	auto view = reader.view_at(0, expected.size());
	EXPECT_EQ(expected.size(), view.size());
	EXPECT_TRUE(std::equal(view.begin(), view.end(), expected.begin()));
}

// ============================================================================
// Additional tests
// ============================================================================

TEST_F(Test_FileMap, OpenNonExistentFile) {
	auto nonExistent = std::filesystem::temp_directory_path() /
	                   "nonexistent_filemap_test";

	FileMap<64> file;
	EXPECT_EQ(ERROR_FileOpen, file.open_path(nonExistent, FMODE_ReadOnly));
	EXPECT_EQ(ERROR_FileOpen, file.open_path(nonExistent, FMODE_Both));
}

TEST_F(Test_FileMap, RandomAccessReads) {
	std::random_device rd;
	std::mt19937 gen(rd());

	std::vector<char> data(1024);
	for (size_t i = 0; i < data.size(); ++i) {
		data[i] = static_cast<char>(i & 0xFF);
	}

	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append(data.data(), data.size()));
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));

	for (int i = 0; i < 100; ++i) {
		size_t offset = std::uniform_int_distribution<size_t>(0, data.size() -
		                                                             1)(gen);
		size_t maxCount = data.size() - offset;
		size_t count = std::uniform_int_distribution<size_t>(1, maxCount)(gen);

		auto view = reader.view_at(offset, count);
		ASSERT_EQ(count, view.size());
		EXPECT_TRUE(std::equal(view.begin(), view.end(), data.begin() + offset))
		    << "Mismatch at offset " << offset << " count " << count;
	}
}

TEST_F(Test_FileMap, LargeFile) {
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<> randch(0, 255);

	constexpr size_t kLargeSize = 1024 * 1024;
	std::vector<char> data(kLargeSize);
	for (auto& c : data) {
		c = static_cast<char>(randch(gen));
	}

	{
		FileMap<8192> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append(data.data(), data.size()));
	}

	FileMap<8192> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(kLargeSize, reader.size());

	auto viewStart = reader.view_at(0, 100);
	EXPECT_TRUE(std::equal(viewStart.begin(), viewStart.end(), data.begin()));

	auto viewMid = reader.view_at(kLargeSize / 2, 100);
	EXPECT_TRUE(std::equal(viewMid.begin(), viewMid.end(),
	                       data.begin() + kLargeSize / 2));

	auto viewEnd = reader.view_at(kLargeSize - 100, 100);
	EXPECT_TRUE(std::equal(viewEnd.begin(), viewEnd.end(), data.end() - 100));
}

TEST_F(Test_FileMap, DestructorClosesFile) {
	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
		ASSERT_EQ(OK, file.append("Destructor test", 15));
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(15u, reader.size());
	EXPECT_EQ("Destructor test", reader.view_at(0, 15));
}

TEST_F(Test_FileMap, OpenClearsExistingState) {
	auto tempFile2 = tempFile_;
	tempFile2 += "_second";
	struct Cleanup {
		std::filesystem::path p;
		~Cleanup() { std::filesystem::remove(p); }
	} cleanup{tempFile2};

	FileMap<64> file;

	ASSERT_EQ(OK, file.open_path(tempFile_, FMODE_Create));
	ASSERT_EQ(OK, file.append("File1", 5));

	ASSERT_EQ(OK, file.open_path(tempFile2, FMODE_Create));
	EXPECT_EQ(0u, file.size());
	ASSERT_EQ(OK, file.append("File2", 5));
	ASSERT_EQ(OK, file.close());

	FileMap<64> reader1;
	ASSERT_EQ(OK, reader1.open_path(tempFile_, FMODE_ReadOnly));
	EXPECT_EQ(5u, reader1.size());
	EXPECT_EQ("File1", reader1.view_at(0, 5));

	FileMap<64> reader2;
	ASSERT_EQ(OK, reader2.open_path(tempFile2, FMODE_ReadOnly));
	EXPECT_EQ(5u, reader2.size());
	EXPECT_EQ("File2", reader2.view_at(0, 5));
}

TEST_F(Test_FileMap, OpenUtf8_Compatibility) {
	std::string filename = tempFile_.string();

	{
		FileMap<64> file;
		ASSERT_EQ(OK, file.open_utf8(filename, FMODE_Create));
		ASSERT_EQ(OK, file.append("UTF8 test", 9));
	}

	FileMap<64> reader;
	ASSERT_EQ(OK, reader.open_utf8(filename, FMODE_ReadOnly));
	EXPECT_EQ("UTF8 test", reader.view_at(0, 9));
}
