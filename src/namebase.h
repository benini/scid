/*
* Copyright (c) 2001  Shane Hudson.
* Copyright (C) 2014-2017 Fulvio Benini

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

#ifndef SCID_NAMEBASE_H
#define SCID_NAMEBASE_H

#include "common.h"
#include "misc.h"
#include <algorithm>
#include <functional>
#include <map>
#include <vector>

const char NAME_TYPE_STRING [NUM_NAME_TYPES][8] = {
    "player",
    "event",
    "site",
    "round"
};


class NameBase
{
    std::vector<const char*> names_[NUM_NAME_TYPES];
    std::vector<eloT> eloV_;
    struct idxCmp {
        bool operator() (const char* str1, const char* str2) const {
            // *** Compatibility ***
            // Older code used a custom StrTree class with a peculiar sorting:
            // - the first char was interpreted as an unsigned char;
            // - the remaining part was compared with the function strComapare(),
            //   which converts the chars to ints, and is not consistent with
            //   the standard function strcmp().
            // The old StrTree class did also have unpredictable behaviors when
            // fed with names not sorted according to that criteria, for example
            // it could create Namebase objects with duplicate entries.
            // ***
            if (*str1 == *str2)
                return strCompare(str1, str2) < 0;

            return static_cast<uint>(*str1) < static_cast<uint>(*str2);
        }
    };
    std::map<const char*, idNumberT, idxCmp> idx_[NUM_NAME_TYPES];

public:
    static bool IsValidNameType (nameT nt) { return (nt < NUM_NAME_TYPES); }
    static nameT NameTypeFromString (const char * str);

    NameBase() = default;
    NameBase(const NameBase&) = delete;
    NameBase& operator=(const NameBase&) = delete;
    ~NameBase() { Clear(); }
    void Clear();

    const char* GetName (nameT nt, idNumberT id) const { return names_[nt][id]; }
    eloT GetElo (idNumberT id) const { return eloV_[id]; }

    void AddElo (idNumberT id, eloT elo) { if (elo > eloV_[id]) eloV_[id] = elo; }

    errorT    FindExactName   (nameT nt, const char * str, idNumberT * idPtr) const;
    uint      GetFirstMatches (nameT nt, const char * str, uint maxMatches,
                               idNumberT * array) const;

	idNumberT GetNumNames(nameT n) const {
		return static_cast<idNumberT>(names_[n].size());
	}

	std::vector<uint32_t> generateHashMap(nameT nt) const {
        std::vector<uint32_t> res(names_[nt].size());
        std::transform(names_[nt].begin(), names_[nt].end(), res.begin(),
                       strStartHash);
        return res;
    }

	/**
	 * Given a name (string), retrieve the corresponding ID.
	 * The name is added if do not already exists in the NameBase.
	 * @param nt:      nameT type of the name to retrieve.
	 * @param name:    the name to retrieve.
	 * @param MAX_LEN: the max length for names of type @nt
	 *                 (used only when adding a name).
	 * @param MAX_ID:  the max ID allowed for names of type @nt
	 *                 (used only when adding a name).
	 * @returns
	 * - on success, a @e std::pair containing OK and the ID.
	 * - on failure, a @e std::pair containing an error code and 0.
	 */
	std::pair<errorT, idNumberT> getID(nameT nt, const char* name,
	                                   size_t MAX_LEN, idNumberT MAX_ID) {
		ASSERT(IsValidNameType(nt) && name != NULL);

		auto exists = idx_[nt].lower_bound(name);
		if (exists != idx_[nt].end() &&
		    !idx_[nt].key_comp()(name, exists->first))
			return std::make_pair(OK, exists->second);

		const size_t nameLen = strlen(name);
		if (nameLen > MAX_LEN)
			return std::make_pair(ERROR_NameTooLong, 0);

		if (names_[nt].size() >= MAX_ID)
			return std::make_pair(ERROR_NameLimit, 0);

		char* buf = new char[nameLen + 1];
		std::copy_n(name, nameLen + 1, buf);
		idNumberT newID = static_cast<idNumberT>(names_[nt].size());
		names_[nt].push_back(buf);
		idx_[nt].insert(exists, std::make_pair(buf, newID));

		if (nt == NAME_PLAYER)
			eloV_.push_back(0);

		return std::make_pair(OK, newID);
	}

	/**
	 * Used only by codecs to read/write data from files.
	 * @returns references to the containers storing the names.
	 */
	std::tuple<decltype(idx_) &, decltype(names_) &, decltype(eloV_) &>
	getData() {
		return std::make_tuple(std::ref(idx_), std::ref(names_),
		                       std::ref(eloV_));
	}
	const decltype(idx_) & getNames() const { return std::ref(idx_); }
};

#endif  // #ifdef SCID_NAMEBASE_H

//////////////////////////////////////////////////////////////////////
//  EOF: namebase.h
//////////////////////////////////////////////////////////////////////

