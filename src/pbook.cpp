/*
 * Copyright (C) 1999-2000  Shane Hudson
 * Copyright (C) 2017  Fulvio Benini

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
 *
 */

#include "pbook.h"
#include "common.h"
#include "misc.h"
#include "position.h"
#include <fstream>

namespace {

inline const char *
epd_findOpcode (const char * epdStr, const char * opcode)
{
    const char * s = epdStr;
    while (*s != 0) {
        while (*s == ' '  ||  *s == '\n') { s++; }
        if (strIsPrefix (opcode, s)) {
            const char *codeEnd = s + strLength(opcode);
            if (*codeEnd == ' ') {
                return codeEnd + 1;
            }
        }
        while (*s != '\n'  &&  *s != 0) { s++; }
    }
    return NULL;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ReadLine():
//      Parse a sequence of moves separated by whitespace and
//      move numbers, e.g. "1.e4 e5 2.Nf3" or "e4 e5 Nf3".
//
errorT ReadLine(Position& pos, const char* s) {
	while (true) {
		while (!isalpha(static_cast<unsigned char>(*s)) && *s != 0) {
			s++;
		}
		if (*s == '\0')
			return OK;

		const char* begin = s;
		while (!isspace(static_cast<unsigned char>(*s)) && *s != '\0') {
			s++;
		}

		simpleMoveT sm;
		errorT err = pos.ParseMove(&sm, begin, s);
		if (err != OK)
			return err;

		pos.DoSimpleMove(&sm);
	}
}



} // namespace

std::pair<const char*, const char*> PBook::findECOstr(Position* pos) const {
	auto range = pos_.equal_range(pos->HashValue());
	if (range.first == pos_.end())
		return std::make_pair(nullptr, nullptr);

	char cboard[36];
	pos->PrintCompactStr(cboard);
	auto it = std::find_if(range.first, range.second,
	                 [&](const std::pair<const unsigned, bookDataT>& data) {
		                 return std::equal(cboard, cboard + 36,
		                                   data.second.compactStr.get());
	                 });
	if (it == range.second)
		return std::make_pair(nullptr, nullptr);

	const char* end = NULL;
	const char* begin = epd_findOpcode(it->second.comment.get(), "eco");
	if (begin != NULL) {
		end = begin;
		while (*end != '\0' && *end != '\n') {
			++end;
		}
	}
	return std::make_pair(begin, end);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::EcoSummary():
//    Produce a summary from the PBook for the specified ECO code prefix.
std::string PBook::EcoSummary(const char* ecoPrefix) const {
    std::string dstr;
    uint depth = strLength (ecoPrefix);
    const char * prevEcoStr = "";
    for (const char* comment : comments_) {
        const char * ecoStr = epd_findOpcode (comment, "eco");
        if (ecoStr != NULL  &&  strIsPrefix (ecoPrefix, ecoStr)) {
            if (depth < 3  &&  strPrefix (ecoStr, prevEcoStr) >= depth+1) {
                continue;
            }
            prevEcoStr = ecoStr;
            while (*ecoStr != '\n'  &&  *ecoStr != 0) {
                dstr.push_back(*ecoStr);
                ecoStr++;
            }
            dstr.append("  ");
            const char* movesStr = epd_findOpcode(comment, "moves");
            while (*movesStr != '\n'  &&  *movesStr != 0) {
                dstr.push_back(*movesStr);
                movesStr++;
            }
            dstr.push_back('\n');
        }
    }
    return dstr;
}

std::pair<errorT, std::unique_ptr<PBook> >
PBook::ReadEcoFile(const char* FileName) {
    std::filebuf fp;
    if (!fp.open(FileName, std::ios::in | std::ios::binary))
        return std::make_pair(ERROR_FileOpen, nullptr);

    std::unique_ptr<PBook> pb(new PBook);
    pb->LineCount = 1;
    Position std_start;
    std_start.StdStart();
    std::string text;
    std::string moves;
    ecoStringT ecoStr;
    ecoT ecoCode;
    int ch;
    errorT err = OK;
    bool done = false;

    // Loop to read in and add all positions:

    while (!done) {
        // Find the next ECO code:
        while (true) {
            ch = fp.sbumpc();
            if (ch == EOF) { done = true; break; }
            if (ch == '\n') { pb->LineCount++; }
            if (ch >= 'A'  &&  ch <= 'E') { break; }
            if (ch == '#') {
                while (ch != '\n'  &&  ch != EOF) {
                    ch = fp.sbumpc();
                }
                if (ch == EOF) { done = true; }
                pb->LineCount++;
            }
        }
        if (done) { break; }

        // Read in the rest of the ECO code:
        ecoStr[0] = ch;
        ch = fp.sbumpc();
        if (ch < '0'  ||  ch > '9') { goto corrupt; }
        ecoStr[1] = ch;
        ch = fp.sbumpc();
        if (ch < '0'  ||  ch > '9') { goto corrupt; }
        ecoStr[2] = ch;
        ecoStr[3] = 0;

        // Now check for optional extra part of code, e.g. "A00a1":
        ch = fp.sbumpc();
        if (ch >= 'a'  &&  ch <= 'z') {
            ecoStr[3] = ch; ecoStr[4] = 0;
            ch = fp.sbumpc();
            if (ch >= '1'  &&  ch <= '4') {
                ecoStr[4] = ch; ecoStr[5] = 0;
            }
        }

        // Now put ecoCode in the text string and read the text in quotes:
        ecoCode = eco_FromString (ecoStr);
        eco_ToExtendedString (ecoCode, ecoStr);
        text.clear();
        text.append("eco ");
        text.append(ecoStr);
        text.append(" [");

        // Find the start of the text:
        while ((ch = fp.sbumpc()) != '"') {
            if (ch == EOF) { goto corrupt; }
        }
        while ((ch = fp.sbumpc()) != '"') {
            if (ch == EOF) { goto corrupt; }
            text.push_back((char) ch);
        }
        text.append("]\n");

        // Now read the position:
        moves.clear();
        char prev = 0;
        while ((ch = fp.sbumpc()) != '*') {
            if (ch == EOF) { goto corrupt; }
            if (ch == '\n') {
                ch = ' ';
                pb->LineCount++;
            }
            if (ch != ' '  ||  prev != ' ') {
                moves.push_back((char) ch);
            }
            prev = ch;
        }
        Position pos (std_start);
        err = ReadLine(pos, moves.c_str());
        if (err != OK) { goto corrupt; }
        text.append("moves ");
        text.append(strTrimLeft(moves.c_str()));
        text.push_back('\n');

        char* cboard = new char[36];
        pos.PrintCompactStr(cboard);
        auto it = pb->pos_.emplace(
            pos.HashValue(), bookDataT{cboard, strDuplicate(text.c_str())});
        pb->comments_.push_back(it->second.comment.get());
        pb->LeastMaterial = std::min(pb->LeastMaterial, pos.TotalMaterial());
    }
    return std::pair<errorT, std::unique_ptr<PBook> >(OK, std::move(pb));

corrupt:
    return std::make_pair(ERROR_Corrupt, nullptr);
}

//////////////////////////////////////////////////////////////////////
//  EOF: pbook.cpp
//////////////////////////////////////////////////////////////////////
