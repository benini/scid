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

#include "filebuf.h"
#include <gtest/gtest.h>

using lines = std::vector< std::pair<std::streamsize, std::string> >;

class Test_FilebufSTLRef {
protected:
	const char* filename = "test_filebuf.txt";

	lines getlineSTL(size_t bufSize) {
		lines vStl;
		char* buf = new char[bufSize];
		std::ifstream stl(filename);
		size_t i = 0;
		for (; !stl.eof(); i++) {
			if (stl.fail()) {
				// Failed because the buffer is too small
				stl.clear();
				vStl.emplace_back(stl.gcount(), buf);
			}
			while (stl.getline(buf, bufSize)) {
				vStl.emplace_back(stl.gcount(), buf);
			}
		}
		vStl.emplace_back(i, "loops");
		delete[] buf;
		return vStl;
	}
};

class Test_Filebuf :
	public Test_FilebufSTLRef,
	public ::testing::Test {
};

class Test_FilebufGetline :
	public Test_FilebufSTLRef,
	public ::testing::TestWithParam<size_t> {
	// Test that Filebuf::getline works like std::fstream::getline

protected:
	lines getlineScid(Filebuf& file, size_t bufSize) {
		lines vScid;
		char* buf = new char[bufSize];
		*buf = 0;
		size_t i = 0;
		for (; file.sgetc() != EOF; i++) {
			size_t n;
			while ((n = file.getline(buf, bufSize)) != 0) {
				vScid.emplace_back(n, buf);
			}
			if (*buf != 0) {
				// Failed because the buffer is too small
				vScid.emplace_back(0, buf);
				vScid.back().first = vScid.back().second.size();
			}
		}
		vScid.emplace_back(i, "loops");
		delete[] buf;
		return vScid;
	}
};

TEST_F(Test_Filebuf, readAll) {
	std::streamsize fileSize = -1;
	Filebuf file;
	if (file.open(filename, std::ios::in | std::ios::binary | std::ios::ate) != 0) {
		fileSize = file.pubseekoff(0, std::ios::cur, std::ios::in);
		file.pubseekoff(0, std::ios::beg, std::ios::in);
	}
	EXPECT_NE(-1, fileSize);

	char* buf = (char*) malloc(fileSize + 1);
	char* bEnd = buf + fileSize + 1;
	char* line = buf;
	std::streamsize nTot = 0;
	size_t nRead;
	while ((nRead = file.getline(line, std::distance(line, bEnd))) != 0) {
		nTot += nRead;
		line += nRead;
	}
	EXPECT_EQ(EOF, file.sgetc());
	EXPECT_EQ(fileSize, nTot);
	EXPECT_EQ(bEnd, line + 1);

	lines vStl = getlineSTL(1000);
	vStl.pop_back();
	char* s = buf;
	for (auto& e : vStl) {
		EXPECT_EQ(e.second, s);
		s += 1 + e.second.size();
	}
	delete[] buf;
}

TEST_P(Test_FilebufGetline, read) {
	const size_t bufSize = GetParam();
	lines vStl = getlineSTL(bufSize);

	Filebuf file;
	file.open(filename, std::ios::in);
	lines vScid = getlineScid(file, bufSize);
	EXPECT_EQ(EOF, file.sgetc());

	ASSERT_EQ(vStl.size(), vScid.size());
	for (size_t i = 0, n = vStl.size(); i < n; i++) {
		EXPECT_EQ(vStl[i], vScid[i]);
	}
}

TEST_P(Test_FilebufGetline, filesize) {
	const size_t bufSize = GetParam();

	std::streamsize fileSize = -1;
	Filebuf file;
	if (file.open(filename, std::ios::in | std::ios::binary | std::ios::ate) != 0) {
		fileSize = file.pubseekoff(0, std::ios::cur, std::ios::in);
		file.pubseekoff(0, std::ios::beg, std::ios::in);
	}
	EXPECT_NE(-1, fileSize);

	lines vScid = getlineScid(file, bufSize);
	EXPECT_EQ(EOF, file.sgetc());

	vScid.pop_back();
	std::streamsize nTot = 0;
	for (auto& e : vScid) nTot += e.first;
	EXPECT_EQ(fileSize, nTot);
}

INSTANTIATE_TEST_CASE_P(smallbuf, Test_FilebufGetline, ::testing::Values(1000, 100, 10));
