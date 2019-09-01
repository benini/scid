/*
 * Copyright (C) 2019  Fulvio Benini.
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

/** @file
 * Defines a ByteBuffer class which will act like a std::string_view.
 * The caller must ensure that a ByteBuffer object does not outlive the
 * pointed-to data.
 */

#pragma once

#include "error.h"
#include <algorithm>
#include <string_view>

class ByteBuffer {
	const unsigned char* data_;
	size_t size_;

public:
	ByteBuffer(const unsigned char* data, size_t length)
	    : data_(data), size_(length) {}

	errorT Status() { return data_ ? OK : ERROR_BufferRead; }

	operator bool() const { return data_; }

	/// Reads one byte from the buffer
	unsigned char GetByte() {
		if (size_ == 0) {
			data_ = nullptr;
			return 0;
		}
		--size_;
		return *data_++;
	}

	/// Reads a fixed-length string from the buffer.
	/// @param length: the number of requested bytes. It is adjusted if it
	///                exceeds the available bytes in the buffer.
	std::string_view GetFixedString(size_t length) {
		auto begin = reinterpret_cast<const char*>(data_);
		if (length <= size_) {
			data_ += length;
			size_ -= length;
		} else {
			length = size_;
			data_ = nullptr;
			size_ = 0;
		}
		return {begin, length};
	}

	/// Reads a null-terminated string from the buffer.
	const char* GetTerminatedString() {
		const auto begin = data_;
		const auto end = data_ + size_;
		auto it = std::find(begin, end, 0);
		if (it == end) {
			data_ = nullptr;
			size_ = 0;
			return nullptr;
		}
		data_ = ++it;
		size_ = std::distance(data_, end);
		return reinterpret_cast<const char*>(begin);
	}
};
