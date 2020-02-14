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
#include <cassert>
#include <string_view>

/**
 * The Tag section is a list of <tag,value> variable length records:
 * tag_length: 1-byte
 * tag name: [0:240] bytes
 * value_length: 1-byte
 * value: [0:255] bytes
 * The section is terminated with 1-byte with value 0, meaning that un empty
 * tag name cannot be stored.
 * Some common tags are encoded in one byte, using a tag_length value over 240
 * and a tag name of 0 bytes.
 */
constexpr size_t MAX_TAG_LEN = 240;
constexpr std::string_view commonTags[] = {
    // 241, 242: Country
    "WhiteCountry", "BlackCountry",
    // 243: Annotator
    "Annotator",
    // 244: PlyCount
    "PlyCount",
    // 245: EventDate (plain text encoding)
    "EventDate",
    // 246, 247: Opening, Variation
    "Opening", "Variation",
    // 248-250: Setup and Source
    "Setup", "Source", "SetUp"
    // 252-254: spare for future use
    // 255: Reserved for compact EventDate encoding
};

template <typename SourceT, typename DestT>
void encodeTags(const SourceT& tagList, DestT& dest) {
	for (auto& tag : tagList) {
		if (tag.first.length() == 0)
			continue; // Cannot store empty tag names

		const auto it = std::find(commonTags, std::end(commonTags), tag.first);
		if (it != std::end(commonTags)) {
			// Common tags are stored with just their 1-byte value [241:250]
			const auto tagnum = std::distance(commonTags, it) + MAX_TAG_LEN + 1;
			dest.emplace_back(static_cast<unsigned char>(tagnum));
		} else {
			// Other tags are stored as 1-byte length [1:240] + the tag name.
			const auto tag_name = tag.first.data();
			const auto length = std::min(tag.first.length(), MAX_TAG_LEN);
			dest.emplace_back(static_cast<unsigned char>(length));
			dest.insert(dest.end(), tag_name, tag_name + length);
		}

		// The value is stored as 1-byte length [0:255] + the data.
		const auto value = tag.second.data();
		const auto valueLen = std::min<size_t>(tag.second.length(), 255);
		dest.emplace_back(static_cast<unsigned char>(valueLen));
		dest.insert(dest.end(), value, value + valueLen);
	}
	dest.emplace_back(0);
}

class ByteBuffer {
	const unsigned char* data_;
	const unsigned char* const end_;

public:
	ByteBuffer(const unsigned char* data, size_t length)
	    : data_(data), end_(data + length) {
		assert(data_ || data_ == end_);
	}

	operator bool() const { return data_ != end_; }

	/// Reads one byte from the buffer
	unsigned char GetByte(errorT& err) {
		if (data_ == end_) {
			err = ERROR_BufferRead;
			return 0;
		}

		err = OK;
		return *data_++;
	}

	/// Reads one byte from the buffer; returns 0 on error
	unsigned char GetByteZeroOnError() {
		if (data_ == end_)
			return 0;

		return *data_++;
	}

	/// Decodes the tag pairs not stored into the index.
	/// @param fn: a function that should accept 2 parameters
	///            (string_view tag_name, string_view tag_value)
	///            and that will be called for each tag pair.
	template <typename FuncT> errorT decodeTags(FuncT fn) {
		if (data_ == end_)
			return ERROR_BufferRead;

		auto it = data_;
		for (;;) {
			const auto tagLen = *it++;
			if (tagLen == 0) {
				data_ = it;
				return OK; // Reached the end of the tags section
			}

			const char* tag = nullptr;
			size_t tagID = 0;
			if (tagLen > MAX_TAG_LEN) {
				// A common tag name, not explicitly stored
				tagID = tagLen - MAX_TAG_LEN - 1;
			} else {
				tag = reinterpret_cast<const char*>(it);
				it += tagLen;
			}

			if (it >= end_)
				return ERROR_Decode;

			// 255 was a special 3-bytes encoding of EventDate used in SCID2
			const auto valueLen = (tagLen != 255) ? *it++ : 3;
			const char* value = reinterpret_cast<const char*>(it);
			it += valueLen;
			if (it >= end_)
				return ERROR_Decode;

			if (tag) {
				fn(std::string_view(tag, tagLen),
				   std::string_view(value, valueLen));
			} else if (tagID < 10) {
				fn(commonTags[tagID], std::string_view(value, valueLen));
			}
		}
	}

	/// Reads a null-terminated string from the buffer.
	const char* GetTerminatedString() {
		const char* res = reinterpret_cast<const char*>(data_);
		data_ = std::find(data_, end_, 0);
		if (data_ == end_)
			return nullptr;

		++data_; // skip the null char
		return res;
	}
};
