/*
* Copyright (c) 2001  Shane Hudson.
* Copyright (C) 2014  Fulvio Benini

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

#include "common.h"
#include "error.h"
#include "namebase.h"
#include "misc.h"
#include "filebuf.h"
#include "spellchk.h"

const char NAMEBASE_MAGIC[8] = "Scid.sn";

NameBase::~NameBase() {
    for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
        for (size_t i=0; i < names_[n].size(); i++) delete [] names_[n][i];
    }
}

void NameBase::Init ()
{
    Fname_[0] = 0;
    for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
        for (size_t i=0; i < names_[n].size(); i++) delete [] names_[n][i];
        names_[n].resize(0);
        idx_[n].clear();
    }
    eloV_.resize(0);
    firstDateV_.resize(0);
    lastDateV_.resize(0);
}

errorT NameBase::Create(const char* filename)
{
    SetFileName(filename);
    std::vector<int> v[NUM_NAME_TYPES];
    return WriteNameFile(v);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::ReadNameFile():
//      Reads the entire name file into memory.
//
errorT
NameBase::ReadEntireFile (const char* filename)
{
    SetFileName(filename);
    Filebuf file;
    if (file.Open(Fname_, FMODE_ReadOnly) != OK) return ERROR_FileOpen;

    char Header_magic[8]; // magic identifier must be "Scid.sn"
    file.ReadNBytes(Header_magic, 8);
    if (strcmp (Header_magic, NAMEBASE_MAGIC) != 0) return ERROR_BadMagic;

    // *** Compatibility ***
    // Even if timeStamp is not used we still need to read the bytes
    file.ReadFourBytes();
    // *** Compatibility ***
    idNumberT Header_numNames[NUM_NAME_TYPES];
    Header_numNames[NAME_PLAYER] = file.ReadThreeBytes();
    Header_numNames[NAME_EVENT] = file.ReadThreeBytes();
    Header_numNames[NAME_SITE] = file.ReadThreeBytes();
    Header_numNames[NAME_ROUND] = file.ReadThreeBytes();
    uint Header_maxFrequency[NUM_NAME_TYPES];
    Header_maxFrequency[NAME_PLAYER] = file.ReadThreeBytes();
    Header_maxFrequency[NAME_EVENT] = file.ReadThreeBytes();
    Header_maxFrequency[NAME_SITE] = file.ReadThreeBytes();
    Header_maxFrequency[NAME_ROUND] = file.ReadThreeBytes();

    eloV_.resize(Header_numNames[NAME_PLAYER], 0);
    firstDateV_.resize(Header_numNames[NAME_PLAYER], ZERO_DATE);
    lastDateV_.resize(Header_numNames[NAME_PLAYER], ZERO_DATE);
    for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
        names_[nt].resize(Header_numNames[nt]);
        idNumberT id;
        char prevName[1024] = {0};
        for (idNumberT i = 0; i < Header_numNames[nt]; i++) {
            if (Header_numNames[nt] >= 65536) {
                id = file.ReadThreeBytes();
            } else {
                id = file.ReadTwoBytes();
            }
            if (id >= Header_numNames[nt]) return ERROR_Corrupt;

            // *** Compatibility ***
            // Even if frequency is no longer used we still need to read the bytes
            // Frequencies can be stored in 1, 2 or 3 bytes:
            if (Header_maxFrequency[nt] >= 65536) {
                file.ReadThreeBytes();
            } else if (Header_maxFrequency[nt] >= 256) {
                file.ReadTwoBytes();
            } else {  // Frequencies all <= 255: fit in one byte
                file.ReadOneByte();
            }
            // *** Compatibility ***

            // Read the name string.
            // All strings EXCEPT the first are front-coded.
            uint length = file.ReadOneByte();
            uint prefix = (i > 0) ? file.ReadOneByte() : 0;
            if (prefix > length) return ERROR_Corrupt;
            char* name = new char[length +1];
            memcpy(name, prevName, prefix);
            uint nr = file.ReadNBytes(name + prefix, (length - prefix));
            if (nr != (length - prefix)) return ERROR_FileRead;
            name[length] = 0;
            strcpy(prevName, name);

            names_[nt][id] = name;
            idx_[nt].insert(idx_[nt].end(), std::make_pair(name, id));
        }
    }

    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::WriteNameFile(): Write the entire in-memory index to disk.
//      For each nametype, names are written in alphabetical order and
//      the strings are front-coded to save space.
//
errorT
NameBase::WriteNameFile (const std::vector<int>* freq)
{
    Filebuf file;
    if (file.Open(Fname_, FMODE_WriteOnly) != OK) return ERROR_FileOpen;

    file.WriteNBytes(NAMEBASE_MAGIC, 8);

    // *** Compatibility ***
    // Even if timeStamp is not used we still need to write the bytes
    file.WriteFourBytes(0);
    // *** Compatibility ***

    file.WriteThreeBytes(names_[NAME_PLAYER].size());
    file.WriteThreeBytes(names_[NAME_EVENT].size());
    file.WriteThreeBytes(names_[NAME_SITE].size());
    file.WriteThreeBytes(names_[NAME_ROUND].size());

    // *** Compatibility ***
    // even if maxFrequency is no longer used we still need to write these bytes
    int maxFreq[NUM_NAME_TYPES] = {0};
    for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
        for (size_t i=0; i < freq[n].size(); i++) {
            if (freq[n][i] > maxFreq[n]) maxFreq[n] = freq[n][i];
        }
        file.WriteThreeBytes(maxFreq[n]);
    }
    // *** Compatibility ***

    for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
        char prevName[1024] = {0};
        size_t numNames = names_[nt].size();
        for (iterator it = idx_[nt].begin(); it != idx_[nt].end(); it++) {
            const char* name = (*it).first;
            idNumberT id = (*it).second;

            // write idNumber in 2 bytes if possible, otherwise 3.
            if (numNames >= 65536) {
                file.WriteThreeBytes(id);
            } else {
                file.WriteTwoBytes(id);
            }

            // *** Compatibility ***
            // even if frequency is no longer used we still need to write these bytes
            if (maxFreq[nt] >= 65536) {
                file.WriteThreeBytes(freq[nt][id]);
            } else if (maxFreq[nt] >= 256) {
                file.WriteTwoBytes(freq[nt][id]);
            } else {
                file.WriteOneByte(freq[nt][id]);
            }
            // *** Compatibility ***

            byte length = strlen(name);
            file.WriteOneByte(length);
            byte prefix = 0;
            if (it != idx_[nt].begin()) {
                prefix = (byte) strPrefix (name, prevName);
                file.WriteOneByte(prefix);
            }
            file.WriteNBytes(name + prefix, (length - prefix));
            strcpy(prevName, name);
        }
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::AddName(): Add a name to a namebase.
// If it already exists, OK is returned.
//
errorT
NameBase::AddName (nameT nt, const char* str, idNumberT* idPtr)
{
    ASSERT (IsValidNameType(nt)  &&  str != NULL  &&  idPtr != NULL);

    iterator it = idx_[nt].find(str);
    if (it != idx_[nt].end()) {
        *idPtr = (*it).second;
    } else {
        if (names_[nt].size() >= NAME_MAX_ID[nt]) {
            return ERROR_NameBaseFull;   // Too many names already.
        }

        char* name = new char[strlen(str) +1];
        strcpy(name, str);
        *idPtr = names_[nt].size();
        names_[nt].push_back(name);
        idx_[nt][name] = *idPtr;
        if (nt == NAME_PLAYER) {
            eloV_.push_back(0);
            firstDateV_.push_back(ZERO_DATE);
            lastDateV_.push_back(ZERO_DATE);
        }
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::FindExactName():
//      Finds an exact full, case-sensitive name.
//      Returns OK or ERROR_NotFound.
//
errorT
NameBase::FindExactName (nameT nt, const char* str, idNumberT* idPtr)
{
    ASSERT (IsValidNameType(nt)  &&  str != NULL  &&  idPtr != NULL);

    iterator it = idx_[nt].find(str);
    if (it != idx_[nt].end()) {
        *idPtr = (*it).second;
        return OK;
    }
    return ERROR_NameNotFound;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::GetMatches(): Get the first few matches of a name prefix.
//      The parameter maxMatches indicates the size of the idNumber array.
//      The first maxMatches matching IDs are placed in the array.
//      Returns: the number found, up which will be <= maxMatches.
//
uint
NameBase::GetFirstMatches (nameT nt, const char * str, uint maxMatches,
                           idNumberT * array)
{
    ASSERT (IsValidNameType(nt)  &&  str != NULL);

    size_t len = strlen(str);
    uint matches = 0;
    iterator it = idx_[nt].lower_bound(str);
    for (; matches < maxMatches && it != idx_[nt].end(); matches++) {
        const char* s = (*it).first;
        if (strlen(s) < len || strncmp(s, str, len) != 0) break;
        array[matches] = (*it++).second;
    }

    return matches;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::NameTypeFromString
//    Returns a valid nameT given a string, or NAME_INVALID.
//    To match, the string should be a prefix of "player", "event",
//    "site" or "round", or be a superstring of it, e.g. "player ...."
nameT
NameBase::NameTypeFromString (const char * str)
{
    if (*str == '\0') { return NAME_INVALID; }
    if (strIsAlphaPrefix (str, "player")) { return NAME_PLAYER; }
    if (strIsAlphaPrefix (str, "event"))  { return NAME_EVENT;  }
    if (strIsAlphaPrefix (str, "site"))   { return NAME_SITE;   }
    if (strIsAlphaPrefix (str, "round"))  { return NAME_ROUND;  }
    if (strIsAlphaPrefix ("player", str)) { return NAME_PLAYER; }
    if (strIsAlphaPrefix ("event", str))  { return NAME_EVENT;  }
    if (strIsAlphaPrefix ("site", str))   { return NAME_SITE;   }
    if (strIsAlphaPrefix ("round", str))  { return NAME_ROUND;  }
    return NAME_INVALID;
}

// Update estimated ratings from spellcheck file if available:
void NameBase::recalcEstimatedRatings (SpellChecker* spellChecker)
{
    if (spellChecker == 0) { return; }
    for (idNumberT id=0; id < GetNumNames(NAME_PLAYER); id++) {
        if (GetElo(id) == 0) {
            const char * name = GetName (NAME_PLAYER, id);
            if (! strIsSurnameOnly (name)) {
                const char * text = spellChecker->GetCommentExact (name);
                if (text != NULL) {
                    AddElo (id, SpellChecker::GetPeakRating (text));
                }
            }
        }
    }
}


//////////////////////////////////////////////////////////////////////
//  EOF: namebase.cpp
//////////////////////////////////////////////////////////////////////
