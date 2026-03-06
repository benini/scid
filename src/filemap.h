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

#pragma once

#include "common.h"
#include <algorithm>
#include <cassert>
#include <filesystem>
#include <limits>
#include <string_view>

#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>

#else // POSIX (Linux, macOS)
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

/**
 * Memory-mapped file for random-access reading and append-only writing.
 *
 * This class provides efficient file I/O by combining memory mapping for reads
 * with buffered writes for appends. The memory mapping is read-only and is
 * automatically remapped when the file grows.
 *
 * @tparam kWriteBuffer Size of the internal write buffer in bytes.
 */
template <size_t kWriteBuffer = 8192> class FileMap {
	char* mappedData_ = nullptr;
	size_t mappedSize_ = 0;
	size_t fileSize_ = 0;
	char writeBuffer_[kWriteBuffer];
	size_t bufferPos_ = 0;

public:
	FileMap() = default;
	~FileMap() { close(); }
	FileMap(const FileMap&) = delete;
	FileMap& operator=(const FileMap&) = delete;

	/// Compatibility wrapper for Tcl UTF-8 strings
	errorT open_utf8(std::string_view filename, fileModeT fmode) {
		auto fname = reinterpret_cast<const char8_t*>(filename.data());
		return open_path({fname, fname + filename.size()}, fmode);
	}

	/**
	 * Opens a file for memory-mapped reading and/or buffered writing.
	 * @param path: path to the file to be opened.
	 * @param fmode: determines access mode and creation disposition:
	 *   - @c FMODE_Create: creates a new file (or overwrites an existing one)
	 *   - @c FMODE_ReadOnly: opens an existing file for reading only.
	 * @returns OK on success, an @e errorT code on failure.
	 */
	errorT open_path(std::filesystem::path const& path, fileModeT fmode) {
		close();

		if (auto err = openFile(path, fmode)) {
			close();
			return err;
		}

		if (!createMapping()) {
			close();
			return ERROR_FileOpen;
		}

		return OK;
	}

	/**
	 * Closes the file and releases all resources.
	 *
	 * Flushes any buffered data before closing. If the flush fails,
	 * the file is still closed but the error is returned.
	 *
	 * @returns OK on success, or an error code if flushing failed.
	 */
	errorT close() {
		auto err = flushBuffer();
		unmapFile();
		closeFile();
		fileSize_ = 0;
		mappedSize_ = 0;
		bufferPos_ = 0;
		return err;
	}

	/**
	 * Returns the size of the file (including buffered data not yet flushed).
	 */
	size_t size() const { return fileSize_ + bufferPos_; }

	/**
	 * Returns a zero-copy view of data at the specified position.
	 * The view is valid until the file is closed or remapped due to append.
	 * @param offset: byte offset from the beginning of the file.
	 * @param count: number of bytes to view.
	 * @returns a string_view of the data, or empty view if out of bounds.
	 * @note Multiple threads can call this concurrently.
	 *       If modified, pubsync() must be called before view_at().
	 */
	std::string_view view_at(size_t offset, size_t count) const {
		assert(bufferPos_ == 0 && "Must call pubsync() before view_at()");

		if (!mappedData_ || offset >= mappedSize_)
			return {};

		size_t available = mappedSize_ - offset;
		size_t actualCount = std::min(count, available);
		return {mappedData_ + offset, actualCount};
	}

	/**
	 * Appends data to the end of the file.
	 * @param s Pointer to the data to append.
	 * @param count Number of bytes to append.
	 * @returns OK on success, an error code otherwise.
	 * @note Data is buffered internally and written to disk when the buffer is
	 * full, when pubsync() is called, or when the file is closed.
	 */
	errorT append(const char* s, size_t count) {
		if (!s || count == 0)
			return OK;

		if (count <= kWriteBuffer - bufferPos_) {
			std::copy(s, s + count, writeBuffer_ + bufferPos_);
			bufferPos_ += count;
			return OK;
		}

		if (auto err = flushBuffer())
			return err;

		if (count >= kWriteBuffer)
			return appendDirect(s, count);

		std::copy(s, s + count, writeBuffer_);
		bufferPos_ = count;
		return OK;
	}

	/**
	 * Flushes buffered data, synchronizes to disk, and remaps the file.
	 * After this call succeeds, view_at() can be used again to read the data.
	 * @returns OK on success, an error code on failure.
	 */
	errorT pubsync() {
		if (auto err = flushBuffer())
			return err;

		if (auto err = syncFile())
			return err;

		if (mappedSize_ == fileSize_)
			return OK;

		return createMapping() ? OK : ERROR_FileOpen;
	}

private:
	errorT flushBuffer() {
		if (bufferPos_ == 0)
			return OK;

		if (auto err = appendDirect(writeBuffer_, bufferPos_))
			return err;

		bufferPos_ = 0;
		return OK;
	}

#ifdef _WIN32

	HANDLE fileHandle_ = INVALID_HANDLE_VALUE;
	HANDLE mappingHandle_ = nullptr;

	errorT openFile(std::filesystem::path const& path, fileModeT fmode) {
		DWORD access = GENERIC_READ;
		DWORD share = FILE_SHARE_READ;
		DWORD creation = OPEN_EXISTING;

		if (fmode != FMODE_ReadOnly)
			access |= GENERIC_WRITE;

		if (fmode == FMODE_Create)
			creation = CREATE_ALWAYS;

		fileHandle_ = CreateFileW(path.c_str(), access, share, nullptr,
		                          creation, FILE_ATTRIBUTE_NORMAL, nullptr);

		if (fileHandle_ == INVALID_HANDLE_VALUE)
			return ERROR_FileOpen;

		LARGE_INTEGER size;
		if (!GetFileSizeEx(fileHandle_, &size))
			return ERROR_FileOpen;

		fileSize_ = size.QuadPart;
		return OK;
	}

	void closeFile() {
		if (fileHandle_ != INVALID_HANDLE_VALUE) {
			CloseHandle(fileHandle_);
			fileHandle_ = INVALID_HANDLE_VALUE;
		}
	}

	errorT syncFile() {
		if (fileHandle_ != INVALID_HANDLE_VALUE) {
			if (!FlushFileBuffers(fileHandle_))
				return ERROR_FileWrite;
		}
		return OK;
	}

	errorT appendDirect(const char* s, size_t count) {
		if (fileHandle_ == INVALID_HANDLE_VALUE)
			return ERROR_FileWrite;

		// Windows cannot extend a file while a mapping is active.
		// The mapping will be recreated on the next pubsync() call.
		unmapFile();

		LARGE_INTEGER pos;
		pos.QuadPart = static_cast<LONGLONG>(fileSize_);
		if (!SetFilePointerEx(fileHandle_, pos, nullptr, FILE_BEGIN))
			return ERROR_FileWrite;

		size_t totalWritten = 0;
		while (totalWritten < count) {
			// Handle writes larger than DWORD max in chunks
			DWORD toWrite = static_cast<DWORD>(
			    std::min(static_cast<size_t>(std::numeric_limits<DWORD>::max()),
			             count - totalWritten));
			DWORD written = 0;
			if (!WriteFile(fileHandle_, s + totalWritten, toWrite, &written,
			               nullptr))
				return ERROR_FileWrite;

			if (written == 0)
				return ERROR_FileWrite;

			totalWritten += written;
		}

		fileSize_ += count;
		return OK;
	}

	bool createMapping() {
		if (fileSize_ == 0)
			return true;

		unmapFile();

		mappingHandle_ = CreateFileMappingW(
		    fileHandle_, nullptr, PAGE_READONLY,
		    static_cast<DWORD>(fileSize_ >> 32),
		    static_cast<DWORD>(fileSize_ & 0xFFFFFFFF), nullptr);

		if (!mappingHandle_)
			return false;

		mappedData_ = static_cast<char*>(
		    MapViewOfFile(mappingHandle_, FILE_MAP_READ, 0, 0, 0));

		if (!mappedData_) {
			CloseHandle(mappingHandle_);
			mappingHandle_ = nullptr;
			return false;
		}

		mappedSize_ = fileSize_;
		return true;
	}

	void unmapFile() {
		if (mappedData_) {
			UnmapViewOfFile(mappedData_);
			mappedData_ = nullptr;
		}
		if (mappingHandle_) {
			CloseHandle(mappingHandle_);
			mappingHandle_ = nullptr;
		}
		mappedSize_ = 0;
	}

#else // POSIX (Linux, macOS)

	int fd_ = -1;

	errorT openFile(std::filesystem::path const& path, fileModeT fmode) {
		int flags = O_RDONLY;
		if (fmode == FMODE_Create) {
			flags = O_RDWR | O_CREAT | O_TRUNC;
		} else if (fmode != FMODE_ReadOnly) {
			flags = O_RDWR;
		}

		mode_t mode = 0644; // rw-r--r-- for new files
		fd_ = ::open(path.c_str(), flags, mode);
		if (fd_ < 0)
			return ERROR_FileOpen;

		struct stat st;
		if (fstat(fd_, &st) < 0)
			return ERROR_FileOpen;

		fileSize_ = static_cast<size_t>(st.st_size);
		return OK;
	}

	void closeFile() {
		if (fd_ >= 0) {
			::close(fd_);
			fd_ = -1;
		}
	}

	errorT syncFile() {
		if (fd_ >= 0) {
			if (fsync(fd_) < 0)
				return ERROR_FileWrite;
		}
		return OK;
	}

	errorT appendDirect(const char* s, size_t count) {
		if (fd_ < 0)
			return ERROR_FileWrite;

		size_t totalWritten = 0;
		while (totalWritten < count) {
			ssize_t written = pwrite(
			    fd_, s + totalWritten, count - totalWritten,
			    static_cast<off_t>(fileSize_ + totalWritten));

			if (written < 0) {
				if (errno == EINTR)
					continue;
				return ERROR_FileWrite;
			}
			if (written == 0) // Unexpected EOF or disk full
				return ERROR_FileWrite;

			totalWritten += static_cast<size_t>(written);
		}

		fileSize_ += count;
		return OK;
	}

	bool createMapping() {
		if (fileSize_ == 0)
			return true;

		unmapFile();

		void* addr = mmap(nullptr, fileSize_, PROT_READ, MAP_SHARED, fd_, 0);
		if (addr == MAP_FAILED)
			return false;

		mappedData_ = static_cast<char*>(addr);
		madvise(mappedData_, fileSize_, MADV_RANDOM);

		mappedSize_ = fileSize_;
		return true;
	}

	void unmapFile() {
		if (mappedData_) {
			munmap(mappedData_, mappedSize_);
			mappedData_ = nullptr;
		}
		mappedSize_ = 0;
	}

#endif // _WIN32
};
