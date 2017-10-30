/*
* Copyright (c) 2001  Shane Hudson.
* Copyright (C) 2014-2016  Fulvio Benini

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
#include "namebase.h"
#include "misc.h"
#include "filebuf.h"
#include "index.h"

// NameBase file signature, used to identify the file format
const char* NameBase::NAMEBASE_MAGIC = "Scid.sn";

/**
* NameBase::clear() - clears file associations and frees memory
*
* Clears file associations and frees memory, leaving the object empty.
*/
void NameBase::Clear()
{
    for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
        for (size_t i=0; i < names_[n].size(); i++) delete [] names_[n][i];
        names_[n].resize(0);
        idx_[n].clear();
    }
    eloV_.resize(0);
}

/**
 * NameBase::ReadNameFile() - Reads a NameBase file into memory.
 * @filename: the filename (without extension) of the file to be read
 *
 * A NameBase file starts with an header containing:
 * - header_magic (8 bytes): identify the file format
 * - unused (4 bytes):  obsolete timeStamp
 * - number of NAME_PLAYER names stored in the file (3 bytes)
 * - number of NAME_EVENT names stored in the file (3 bytes)
 * - number of NAME_SITE names stored in the file (3 bytes)
 * - number of NAME_ROUND names stored in the file (3 bytes)
 * - unused (12 bytes): obsolete max frequency
 * Names are stored using front-coding and each record is composed by:
 * - name_id (2-3 bytes): the idx (idNumberT) stored in the Index (.si4) file
 * - unused (1-3 bytes): obsolete frequency
 * - length (1 byte): the total number of bytes of the name (max 255)
 * - prefix (1 byte): the number of bytes in common with the previous name
 * - name (0-255 bytes): the part of the name that differs from the previous one.
 * Return OK if successful.
 */
errorT
NameBase::ReadEntireFile (const char* filename, fileModeT fmode)
{
    Filebuf file;
    if (file.Open(filename, fmode) != OK) return ERROR_FileOpen;

    char Header_magic[9] = {0}; // magic identifier must be "Scid.sn"
    file.sgetn(Header_magic, 8);
    if (strcmp (Header_magic, NAMEBASE_MAGIC) != 0) return ERROR_BadMagic;

    // *** Compatibility ***
    // Even if timeStamp is not used we still need to read the bytes
    file.ReadFourBytes();
    // ***

    idNumberT Header_numNames[NUM_NAME_TYPES];
    Header_numNames[NAME_PLAYER] = file.ReadThreeBytes();
    Header_numNames[NAME_EVENT] = file.ReadThreeBytes();
    Header_numNames[NAME_SITE] = file.ReadThreeBytes();
    Header_numNames[NAME_ROUND] = file.ReadThreeBytes();

    // *** Compatibility ***
    // Even if frequency is no longer used we still need to read the bytes
    uint obsolete_maxFreq[NUM_NAME_TYPES];
    obsolete_maxFreq[NAME_PLAYER] = file.ReadThreeBytes();
    obsolete_maxFreq[NAME_EVENT] = file.ReadThreeBytes();
    obsolete_maxFreq[NAME_SITE] = file.ReadThreeBytes();
    obsolete_maxFreq[NAME_ROUND] = file.ReadThreeBytes();
    // ***

    eloV_.resize(Header_numNames[NAME_PLAYER], 0);
    for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
        names_[nt].resize(Header_numNames[nt], 0);
        idNumberT id;
        std::string prevName;
        for (idNumberT i = 0; i < Header_numNames[nt]; i++) {
            if (Header_numNames[nt] >= 65536) {
                id = file.ReadThreeBytes();
            } else {
                id = file.ReadTwoBytes();
            }

            // *** Compatibility ***
            // Even if frequency is no longer used we still need to read the bytes
            // Frequencies can be stored in 1, 2 or 3 bytes:
            if (obsolete_maxFreq[nt] >= 65536) {
                file.ReadThreeBytes();
            } else if (obsolete_maxFreq[nt] >= 256) {
                file.ReadTwoBytes();
            } else {  // Frequencies all <= 255: fit in one byte
                file.ReadOneByte();
            }
            // ***

            // Read the name string.
            // All strings EXCEPT the first are front-coded.
            uint length = file.ReadOneByte();
            uint prefix = (i > 0) ? file.ReadOneByte() : 0;
            char* name = new char[length +1];
            if (prefix > length || prefix != prevName.copy(name, prefix)) {
                delete[] name;
                return ERROR_Corrupt;
            }

            std::streamsize extra_chars = length - prefix;
            if (extra_chars != file.sgetn(name + prefix, extra_chars)) {
                delete[] name;
                return ERROR_FileRead;
            }
            name[length] = 0;
            prevName = name;

            if (id < Header_numNames[nt] && names_[nt][id] == 0) {
                names_[nt][id] = name;
                idx_[nt].insert(idx_[nt].end(), std::make_pair(name, id));
            } else {
                delete[] name;
                return ERROR_Corrupt;
            }
        }

        if (idx_[nt].size() != names_[nt].size()) return ERROR_Corrupt;
    }

    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::WriteNameFile(): Write the entire in-memory index to disk.
//      For each nametype, names are written in alphabetical order and
//      the strings are front-coded to save space.
//
errorT NameBase::WriteNameFile(const char* filename, const Index* idx) {
    for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
        if (idx_[nt].size() != names_[nt].size()) return ERROR_Corrupt;
    }

    std::vector<int> freq[NUM_NAME_TYPES];
    if (idx != 0) idx->calcNameFreq(*this, freq);

    Filebuf file;
    if (file.Open(filename, FMODE_WriteOnly) != OK)
        return ERROR_FileOpen;

    file.sputn(NAMEBASE_MAGIC, 8);

    // *** Compatibility ***
    // Even if timeStamp is not used we still need to write the bytes
    file.WriteFourBytes(0);
    // ***

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
    // ***

    for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
        char prevName[1024] = {0};
        size_t numNames = idx_[nt].size();
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
            // ***

            ASSERT(strlen(name) < 256);
            byte length = strlen(name);
            file.WriteOneByte(length);
            byte prefix = 0;
            if (it != idx_[nt].begin()) {
                prefix = (byte) strPrefix (name, prevName);
                file.WriteOneByte(prefix);
            }
            file.sputn(name + prefix, (length - prefix));
            strcpy(prevName, name);
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
NameBase::FindExactName (nameT nt, const char* str, idNumberT* idPtr) const
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
                           idNumberT * array) const
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

//////////////////////////////////////////////////////////////////////
//  EOF: namebase.cpp
//////////////////////////////////////////////////////////////////////
