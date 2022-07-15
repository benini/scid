/*
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

#include "index.h"
#include "indexentry.h"
#include "misc.h"
#include <algorithm>
#include <array>
#include <limits>
#include <map>
#include <memory>
#include <string_view>
#include <vector>

using nameT = unsigned;
enum {
	NAME_PLAYER,
	NAME_EVENT,
	NAME_SITE,
	NAME_ROUND,
	NUM_NAME_TYPES,
	NAME_INVALID = 99
};

/**
 * This class stores the database's names (players, events, sites and rounds).
 * Assigns a idNumberT (which will be used as reference) to each name.
 */
class NameBase {
	std::vector<std::unique_ptr<const char[]>> names_[NUM_NAME_TYPES];
	struct idxCmp {
		bool operator()(const char* str1, const char* str2) const {
			// *** Compatibility ***
			// Older code used a custom StrTree class with a peculiar sorting:
			// - the first char was interpreted as an unsigned char;
			// - the remaining part was compared with the function
			// strComapare(),
			//   which converts the chars to ints, and is not consistent with
			//   the standard function strcmp().
			// The old StrTree class did also have unpredictable behaviors when
			// fed with names not sorted according to that criteria, for example
			// it could create Namebase objects with duplicate entries.
			// ***
			if (*str1 == *str2)
				return strCompare(str1, str2) < 0;

			return static_cast<uint32_t>(*str1) < static_cast<uint32_t>(*str2);
		}
	};
	std::map<const char*, idNumberT, idxCmp> idx_[NUM_NAME_TYPES];

public:
	// Add a name (string) to the NameBase.
	// @param nt:      @e nameT type of the name to add.
	// @param name:    the name to add.
	// @return the ID assigned to @e name.
	idNumberT namebase_add(
	    nameT nt, std::string_view name,
	    std::map<const char*, idNumberT, idxCmp>::iterator* hint = nullptr) {
		ASSERT(IsValidNameType(nt));
		ASSERT(names_[nt].size() <= std::numeric_limits<idNumberT>::max());

		char* alloc = new char[name.size() + 1];
		std::copy_n(name.data(), name.size(), alloc);
		alloc[name.size()] = '\0';
		idNumberT newID = static_cast<idNumberT>(names_[nt].size());
		names_[nt].emplace_back(alloc);
		if (hint) {
			idx_[nt].emplace_hint(*hint, alloc, newID);
		} else {
			idx_[nt].emplace(alloc, newID);
		}
		return newID;
	}

	// Return the ID corresponding to @e name.
	// Add the name to the NameBase if it doesn't exists.
	// @param nt:      @e nameT type of the name.
	idNumberT namebase_find_or_add(nameT nt, const char* name) {
		ASSERT(IsValidNameType(nt));

		auto& nb = idx_[nt];
		auto it = nb.lower_bound(name);
		if (it != nb.end() && !nb.key_comp()(name, it->first))
			return it->second;

		return namebase_add(nt, name, &it);
	}

	// Return the number of names stored in the NameBase.
	// @param nt: a valid @e nameT type.
	size_t namebase_size(nameT nt) const {
		ASSERT(IsValidNameType(nt));

		return names_[nt].size();
	}

	/// DEPRECATED
	/// Add a name (string) and its associated id to the NameBase.
	/// Return false if the name or the id already exists: the NameBase object
	/// is then no longer valid and should be destroyed.
	/// The caller should also ensure that before invoking any other object's
	/// function none of names_[nt] == nullptr.
	bool insert(const char* name, size_t nameLen, nameT nt, idNumberT id) {
		if (id >= names_[nt].size())
			names_[nt].resize(id + size_t{1});

		if (names_[nt][id]) // A name with the same ID already exists
			return false;

		char* buf = new char[nameLen + 1];
		std::copy_n(name, nameLen, buf);
		buf[nameLen] = '\0';
		names_[nt][id].reset(buf);
		auto it = idx_[nt].emplace_hint(idx_[nt].end(), buf, id);
		return it->second == id; // Check that the name doesn't already exists
	}

	/**
	 * Frees memory, leaving the object empty.
	 */
	void Clear() { *this = NameBase(); }

	/**
	 * Get the first few matches of a name prefix.
	 * @param nt:         @e nameT type of the name to be searched.
	 * @param str:        name prefix be searched.
	 * @param maxMatches: the max number of ID to return
	 * @returns a vector containing the ID of the matching names.
	 */
	std::vector<idNumberT> getFirstMatches(nameT nt, const char* str,
	                                       size_t maxMatches) const {
		ASSERT(IsValidNameType(nt) && str != NULL);

		std::vector<idNumberT> res;
		size_t len = strlen(str);
		for (auto it = idx_[nt].lower_bound(str);
		     it != idx_[nt].end() && res.size() < maxMatches; ++it) {
			const char* s = it->first;
			if (strlen(s) < len || !std::equal(str, str + len, s))
				break;
			res.emplace_back(it->second);
		}
		return res;
	}

	/**
	 * Retrieve a name.
	 * @param nt: the valid @e nameT type of the name to retrieve.
	 * @param id: the valid ID of the name to retrieve.
	 * @returns the name corresponding to @e id.
	 */
	const char* GetName(nameT nt, idNumberT id) const {
		ASSERT(IsValidNameType(nt) && id < GetNumNames(nt));
		return names_[nt][id].get();
	}

	/**
	 * @returns a reference to a container with all the names and IDs (given as
	 * std::pair<const char*, idNumberT>).
	 */
	const decltype(idx_)& getNames() const { return idx_; }

	/**
	 * @param nt: a valid @e nameT type.
	 * @returns the first invalid idNumberT (which is equal to the number of
	 * names stored).
	 */
	idNumberT GetNumNames(nameT nt) const {
		ASSERT(IsValidNameType(nt));
		return static_cast<idNumberT>(names_[nt].size());
	}

	/**
	 * Finds an exact full, case-sensitive name.
	 * @param nt:         @e nameT type of the name to be searched.
	 * @param str:        name to be be searched.
	 * @param[out] idPtr: pointer which will receive the ID of the name.
	 * @returns OK or ERROR_NameNotFound if the name does not exists.
	 */
	errorT FindExactName(nameT nt, const char* str, idNumberT* idPtr) const {
		ASSERT(IsValidNameType(nt) && str != NULL && idPtr != NULL);

		auto it = idx_[nt].find(str);
		if (it != idx_[nt].end()) {
			*idPtr = (*it).second;
			return OK;
		}
		return ERROR_NameNotFound;
	}

	/**
	 * For every name generates a 32bit hash with the first 4 chars.
	 * @param nt: @e nameT type of the names.
	 * @returns a vector containing the hashes.
	 */
	std::vector<uint32_t> generateHashMap(nameT nt) const {
		std::vector<uint32_t> res(names_[nt].size());
		std::transform(
		    names_[nt].begin(), names_[nt].end(), res.begin(),
		    [](auto const& name) { return strStartHash(name.get()); });
		return res;
	}

	/**
	 * Counts how many times each name is used.
	 * @returns an array of std::vectors containing the count of each name.
	 */
	std::array<std::vector<int>, NUM_NAME_TYPES>
	calcNameFreq(Index const& idx) const {
		std::array<std::vector<int>, NUM_NAME_TYPES> resVec;
		for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
			resVec[n].resize(GetNumNames(n), 0);
		}
		for (gamenumT i = 0, n = idx.GetNumGames(); i < n; i++) {
			const IndexEntry* ie = idx.GetEntry(i);
			resVec[NAME_PLAYER][ie->GetWhite()] += 1;
			resVec[NAME_PLAYER][ie->GetBlack()] += 1;
			resVec[NAME_EVENT][ie->GetEvent()] += 1;
			resVec[NAME_SITE][ie->GetSite()] += 1;
			resVec[NAME_ROUND][ie->GetRound()] += 1;
		}
		return resVec;
	}

	/**
	 * Validate a @e nameT type.
	 * @param nt: @e nameT type to be validated.
	 * @returns true if @e nt is valid.
	 */
	static bool IsValidNameType(nameT nt) { return (nt < NUM_NAME_TYPES); }

	/**
	 * Match a string to a nameT.
	 * To match, the string should be a prefix of "player", "event", "site" or
	 * "round", or be a superstring of it, e.g. "player ...."
	 * @param str: the string to be matched.
	 * @returns a valid nameT, or NAME_INVALID.
	 */
	static nameT NameTypeFromString(const char* str) {
		if (*str == '\0')
			return NAME_INVALID;
		if (strIsAlphaPrefix(str, "player"))
			return NAME_PLAYER;
		if (strIsAlphaPrefix(str, "event"))
			return NAME_EVENT;
		if (strIsAlphaPrefix(str, "site"))
			return NAME_SITE;
		if (strIsAlphaPrefix(str, "round"))
			return NAME_ROUND;
		if (strIsAlphaPrefix("player", str))
			return NAME_PLAYER;
		if (strIsAlphaPrefix("event", str))
			return NAME_EVENT;
		if (strIsAlphaPrefix("site", str))
			return NAME_SITE;
		if (strIsAlphaPrefix("round", str))
			return NAME_ROUND;
		return NAME_INVALID;
	}
};

/// The Seven Tag Roster defined in the PGN standard is stored in the
/// IndexEntry, but 5 are indexes that refer to a NameBase object.
/// This helper struct stores the referred values.
struct TagRoster {
	const char* event;
	const char* site;
	const char* round;
	const char* white;
	const char* black;

	template <typename TEntry>
	static TagRoster make(TEntry const& ie, NameBase const& nb) {
		TagRoster res;
		res.event = nb.GetName(NAME_EVENT, ie.GetEvent());
		res.site = nb.GetName(NAME_SITE, ie.GetSite());
		res.white = nb.GetName(NAME_PLAYER, ie.GetWhite());
		res.black = nb.GetName(NAME_PLAYER, ie.GetBlack());
		res.round = nb.GetName(NAME_ROUND, ie.GetRound());
		return res;
	}

	template <typename TEntry, typename Fn>
	auto map(TEntry& dest, Fn getID) const {
		{
			auto [err, id] = getID(NAME_EVENT, event);
			if (err)
				return err;
			dest.SetEvent(id);
		}
		{
			auto [err, id] = getID(NAME_SITE, site);
			if (err)
				return err;
			dest.SetSite(id);
		}
		{
			auto [err, id] = getID(NAME_ROUND, round);
			if (err)
				return err;
			dest.SetRound(id);
		}
		{
			auto [err, id] = getID(NAME_PLAYER, white);
			if (err)
				return err;
			dest.SetWhite(id);
		}
		{
			auto [err, id] = getID(NAME_PLAYER, black);
			if (!err)
				dest.SetBlack(id);

			return err;
		}
	}
};

#endif // SCID_NAMEBASE_H
