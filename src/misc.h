
//////////////////////////////////////////////////////////////////////
//
//  FILE:       misc.h
//              Miscellaneous routines (File I/O, etc)
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 2001-2003  Shane Hudson.  All rights reserved.
//              Copyright (C) 2015  Fulvio Benini
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_MISC_H
#define SCID_MISC_H

#include "common.h"
#include <string>
#include <string.h>
#include <stdio.h>
#include <ctype.h>   // For isspace(), etc
#include <cstdlib>
#include <vector>

/**
 * class StrRange - parse a string interpreting its content as 1 or 2 integers
 *                  separated by whitespace.
 * The integers represent the min and max value of a range.
 * If only one integer is provided it will represent both the min and max value.
 *
 * inRange()  :  Return true if @val is >= min and <= max
 */
class StrRange {
protected:
	long min_;
	long max_;

protected:
	StrRange()
	: min_(0), max_(0) {}

public:
	explicit StrRange(const char* range) {
		char* next;
		min_ = std::strtol(range, &next, 10);
		char* end;
		max_ = std::strtol(next, &end, 10);
		if (next == end) max_ = min_;
		if (min_ > max_) std::swap(min_, max_);
	}

	bool inRange(long val) const {
		if (val < min_ || val > max_) return false;
		return true;
	}
};


/**
 * class VectorBig - store data into chunks to avoid (or minimize) reallocations
 * @CHUNKSHIFT:	is the base-2 logarithm of the number of T entries per chunk.
 *              Total size of a chunk: (2^CHUNKSHIFT)*sizeof(T)
 * resize()   : Used to avoid reallocations.
 *              Very efficient because it allocates space only for chunk pointers
 *              i.e with @count==16777214 and @CHUNKSHIFT==16 will use 256 pointers
 */
template <class T, size_t CHUNKSHIFT>
class VectorBig {
	std::vector<T*> index_;
	size_t size_;

public:
	VectorBig() : size_(0) {}
	VectorBig(const VectorBig&);
	VectorBig& operator=(const VectorBig&);
	~VectorBig() { resize(0); }

	const T& operator[] (size_t idx) const {
		const size_t low_mask = ((1 << CHUNKSHIFT) - 1);
		return index_[idx >> CHUNKSHIFT][idx & low_mask];
	}
	T& operator[] (size_t idx) {
		const size_t low_mask = ((1 << CHUNKSHIFT) - 1);
		return index_[idx >> CHUNKSHIFT][idx & low_mask];
	}

	size_t size() const {
		return size_;
	}

	void reserve(size_t count) {
		index_.reserve(1 + (count >> CHUNKSHIFT));
	}

	void resize(size_t count) {
		size_ = count;
		size_t index_NewSize = (count > 0) ? 1 + (count >> CHUNKSHIFT) : 0;

		while (index_.size() > index_NewSize) {
			delete [] index_.back();
			index_.pop_back();
		}
		while (index_.size() < index_NewSize) {
			index_.push_back(new T[1 << CHUNKSHIFT]);
		}
	}
	void resize(size_t count, const T& defaulVal) {
		size_t i = size_;
		resize(count);
		while (i < count) (*this)[i++] = defaulVal;
	}

	void push_back(const T& e) {
		resize(size_ + 1, e);
	}
};



class Progress {
public:
	struct Impl {
		virtual ~Impl() {}
		virtual bool report(uint done, uint total, const char* msg) = 0;
	};

	Progress(Impl* f = NULL) : f_(f) {}
	Progress(const Progress&);
	Progress& operator=(const Progress&);
	~Progress() { delete f_; }

	bool report(uint done, uint total) const {
		return operator()(done, total);
	}
	bool operator()(uint done, uint total, const char* msg = NULL) const {
		if (f_) return f_->report(done, total, msg);
		return true;
	}

private:
	Impl* f_;
};


#if CPP11_SUPPORT
using std::to_string;
#else
#include <sstream>
inline std::string to_string(int val) {
	std::ostringstream res;
	res << std::dec << val;
	return res.str();
}
#endif


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// strGetFilterOp:
//    Converts a string value to a filter operation value.
enum filterOpT { FILTEROP_AND, FILTEROP_OR, FILTEROP_RESET };

inline filterOpT strGetFilterOp (const char * str)
{
    switch (*str) {
        // AND:
        case 'A': case 'a': case '0': return FILTEROP_AND;
        // OR:
        case 'O': case 'o': case '1': return FILTEROP_OR;
        // RESET:
        case 'R': case 'r': case '2': return FILTEROP_RESET;
    }
    // Default is RESET.
    return FILTEROP_RESET;
}

// ECO string routines
//
void eco_ToString (ecoT ecoCode, char * ecoStr, bool extensions = true);
inline void eco_ToBasicString (ecoT ecoCode, char * ecoStr) {
    eco_ToString (ecoCode, ecoStr, false);
}
inline void eco_ToExtendedString (ecoT ecoCode, char * ecoStr) {
    eco_ToString (ecoCode, ecoStr, true);
}
ecoT eco_FromString (const char * ecoStr);
ecoT eco_LastSubCode (ecoT ecoCode);
ecoT eco_BasicCode (ecoT ecoCode);
ecoT eco_Reduce(ecoT eco);

// String routines. Some are identical to ANSI standard functions, but
//      I have included them:
//      (a) to keep nice consistent naming conventions, e.g. strCopy.
//      (b) so stats can easily be kept by modifying the functions.
//      (c) so some can be made inline for speed if necessary.
//
//      Currently, strLength() and strPrefix() are inline.
//      strCompare_INLINE() is an inline equivalent of strCompare().

inline uint32_t strStartHash(const char* str) {
	typedef unsigned char U;
	uint32_t result = tolower(U(*str)) * 16777216;
	if (str[1]) {
		result += tolower(U(str[1])) * 65536;
		if (str[2]) result += tolower(U(str[2])) * 256 + tolower(U(str[3]));
	}
	return result;
}

char * strDuplicate (const char * str);
int    strCompare (const char * s1, const char * s2);
int    strCaseCompare (const char * s1, const char * s2);
int    strCompareRound (const char * sleft, const char * sright);

inline bool
strEqual (const char * s1, const char * s2) {
    return (strCompare (s1, s2) == 0);
}

void   strCopy (char * target, const char * original);
void   strCopyExclude (char * target, const char * original,
                       const char * excludeChars);
char * strAppend (char * target, const char * extra);
char * strAppend (char * target, uint u);
char * strAppend (char * target, int i);
char * strAppend (char * target, const char * s1, const char * s2);
char * strAppend (char * target, const char * s1, const char * s2);
char * strAppend (char * target, const char * s1, const char * s2,
                  const char * s3);
char * strAppend (char * target, const char * s1, const char * s2,
                  const char * s4);
uint   strPrefix (const char * s1, const char * s2);
uint   strPad (char * target, const char * orig, int length, char pad);
const char * strFirstChar (const char * target, char matchChar);
const char * strLastChar (const char * target, char matchChar);
void   strStrip (char * str, char ch);

static const char WHITESPACE[6] = " \t\r\n";
const char * strTrimLeft (const char * target, const char * trimChars);
inline const char * strTrimLeft (const char * target) {
    return strTrimLeft (target, WHITESPACE);
}
uint   strTrimRight (char * target, const char * trimChars);
inline uint strTrimRight (char * target) {
    return strTrimRight (target, WHITESPACE);
}
uint   strTrimSuffix (char * target, char suffixChar);
void   strTrimDate (char * str);
void   strTrimMarkCodes (char * str);
void   strTrimMarkup (char * str);
void   strTrimSurname (char * str, uint initials);
inline void strTrimSurname (char * str) { strTrimSurname (str, 0); }
const char * strFirstWord (const char * str);
const char * strNextWord (const char * str);

// strPlural:
//    Returns the empty string if its parameter is 1, or "s" otherwise.
inline const char *
strPlural (uint x) {
    return (x == 1 ? "" : "s");
}

bool   strIsAllWhitespace (const char * str);
bool   strIsUnknownName (const char * str);

// strIsPrefix: returns true if prefix is a prefix of longStr.
bool   strIsPrefix (const char * prefix, const char * longStr);

// strIsCasePrefix: like strIsPrefix, but case-insensitive.
bool   strIsCasePrefix (const char * prefix, const char * longStr);

// strIsAlphaPrefix: like strIsPrefix, but case-insensitive and space
//    characters are ignored.
bool   strIsAlphaPrefix (const char * prefix, const char * longStr);

// strIsSurnameOnly: returns true if a string appears to only
//    contain a surname.
bool   strIsSurnameOnly (const char * name);

// strAlphaContains: returns true if longStr contains keyStr,
//    case-insensitive and ignoring spaces. strContains is similar but
//    is case-sensitive and does not ignore spaces.
bool   strAlphaContains (const char * longStr, const char * keyStr);

bool   strContains (const char * longStr, const char * keyStr);
bool   strCaseContains (const char * longStr, const char * keyStr);
int    strContainsIndex (const char * longStr, const char * keyStr);

bool   strGetBoolean (const char * str);
int    strGetInteger (const char * str);
uint   strGetUnsigned (const char * str);
void   strGetIntegers (const char * str, int * results, uint nResults);
void   strGetUnsigneds (const char * str, uint * results, uint nResults);
void   strGetBooleans (const char * str, bool * results, uint nResults);
resultT strGetResult (const char * str);

typedef uint flagT;
const flagT FLAG_EMPTY = 0;
const flagT FLAG_YES = 1;
const flagT FLAG_NO = 2;
const flagT FLAG_BOTH = 3;
inline bool flag_Yes (flagT t) { return (t & FLAG_YES); }
inline bool flag_No (flagT t) { return (t & FLAG_NO); }
flagT  strGetFlag (const char * str);

squareT strGetSquare (const char * str);

inline uint
strTrimFileSuffix (char * target) { return strTrimSuffix (target, '.'); }

inline const char *
strFileSuffix (const char * target) { return strLastChar (target, '.'); }



int strUniqueExactMatch (const char * keyStr, const char ** strTable,
                         bool exact);

inline int strUniqueMatch (const char * keyStr, const char ** strTable) {
    return strUniqueExactMatch (keyStr, strTable, false);
}
inline int strExactMatch (const char * keyStr, const char ** strTable) {
    return strUniqueExactMatch (keyStr, strTable, true);
}

inline bool
strContainsChar (const char * str, char ch)
{
    while (*str) {
        if (*str == ch) { return true; }
        str++;
    }
    return false;
}

inline int
strCompare_INLINE (const char *s1, const char *s2)
{
    while (1) {
        if (*s1 != *s2) {
            return ((int) *s1) - ((int) *s2);
        }
        if (*s1 == 0)
            break;
        s1++; s2++;
    }
    return 0;
}

inline uint
strLength (const char * str)
{
    ASSERT(str != NULL);
    uint len = 0;
    while (*str != 0) { len++; str++; }
    return len;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// strTrimRight():
//      Trims the provided string in-place, removing the
//      end characters that match the trimChars.
//      Returns the number of characters trimmed.
//      E.g., strTrimRight("abcyzyz", "yz") would leave the string
//      as "abc" and return 4.
inline uint strTrimRight (char* target, const char* trimChars)
{
	int oldSz = strlen(target);
	int sz = oldSz;
	while (--sz >= 0) {
		if (strchr(trimChars, target[sz]) == 0) break;
	}
	if (++sz == oldSz) return 0;
	target[sz] = 0;
	return oldSz - sz;
}


//////////////////////////////////////////////////////////////////////
//   FILE I/O Routines.
// TODO: remove this functions

uint    fileSize (const char * name, const char * suffix);
uint    rawFileSize (const char * name);
uint    gzipFileSize (const char * name);

bool    fileExists (const char * fname, const char * suffix);
errorT  renameFile (const char * oldName, const char * newName,
                    const char * suffix);
errorT  removeFile (const char * fname, const char * suffix);
errorT  createFile (const char * fname, const char * suffix);

errorT  writeString (FILE * fp, const char * str, uint length);
errorT  readString  (FILE * fp, char * str, uint length);


#endif  // #ifdef SCID_MISC_H

//////////////////////////////////////////////////////////////////////
//  EOF: misc.h
//////////////////////////////////////////////////////////////////////

