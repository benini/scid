/*
* Copyright (C) 2014-2015  Fulvio Benini

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
*/


#ifndef FILEBUF_H
#define FILEBUF_H

#include "common.h"
#include <fstream>

class Filebuf : public std::filebuf
{
public:
	errorT Open (const char* filename, fileModeT fmode) {
		std::ios::openmode mode = std::ios::binary;
		switch (fmode) {
			case FMODE_ReadOnly:   mode |= std::ios::in;  break;
			case FMODE_WriteOnly:  mode |= std::ios::out;  break;
			case FMODE_Both:       mode |= std::ios::in | std::ios::out; break;
			case FMODE_Create:     mode |= std::ios::in | std::ios::out | std::ios::trunc; break;
			default:			   return ERROR_FileMode;
		}

		return (open(filename, mode) != 0) ? OK : ERROR_FileOpen;
	}

	errorT Seek (uint position) { return (position != seekpos(position)) ? ERROR_FileSeek : OK; }

	uint ReadOneByte () { return sbumpc() & 255; }
	uint ReadTwoBytes () { return read<2>(); }
	uint ReadThreeBytes () { return read<3>(); }
	uint ReadFourBytes () { return read<4>(); }
	uint ReadNBytes (char* str, uint count) { return (uint) sgetn(str, count); }
	/**
	 * getline() - Extracts characters until end of file or end of line ('\n')
	 * @str:    pointer to the character string to store the characters to
	 * @count: 	size of character string pointed to by @str
	 *
	 * This function is similar to std::fstream::getline, but without the Sentry.
	 * The characters are copied to @str, excluding the '\n' char, and before
	 * returning, even in case of errors, a null character will be added.
	 * Return:
	 * - the number of characters read, including the '\n' char
	 * - 0 if the buffer is too small
	 */
	size_t getline(char* str, size_t count) {
		ASSERT(str != 0);
		ASSERT(count != 0);

		size_t n = 0;
		for (int ch = sgetc(); ch != EOF; ch = snextc()) {
			++n;
			if (ch == '\n') {
				sbumpc();
				break;
			}
			if (n >= count) {
				n = 0; //Fail if buffer is full
				break;
			}
			*str++ = static_cast<char>(ch);
		}
		*str = 0;
		return n;
	}

	//Returns the number of characters successfully written
	uint WriteOneByte (byte value) { return (sputc(value) == value) ? 1 : 0; }
	uint WriteTwoBytes (uint value) { return write<2>(value); }
	uint WriteThreeBytes (uint value) { return write<3>(value); }
	uint WriteFourBytes (uint value) { return write<4>(value); }
	uint WriteNBytes (const char* str, uint count) { return (uint) sputn(str, count); }

private:
	template <uint nBytes> uint read() {
		uint res = 0;
		if (nBytes > 3) res += ReadOneByte() << 24;
		if (nBytes > 2) res += ReadOneByte() << 16;
		if (nBytes > 1) res += ReadOneByte() << 8;
		return res + ReadOneByte();
	}

	template <uint nBytes> uint write(uint v) {
		uint res = 0;
		if (nBytes > 3) res += WriteOneByte((v >> 24) & 255);
		if (nBytes > 2) res += WriteOneByte((v >> 16) & 255);
		if (nBytes > 1) res += WriteOneByte((v >> 8) & 255);
		return res + WriteOneByte(v & 255);
	}
};

#endif  // FILEBUF_H

