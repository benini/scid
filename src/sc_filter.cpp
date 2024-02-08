/*
# Copyright (C) 2016 Fulvio Benini

* This file is part of Scid (Shane's Chess Information Database).
*
* Scid is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation.
*
* Scid is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Scid. If not, see <http://www.gnu.org/licenses/>.
*/

#include "dbasepool.h"
#include "scidbase.h"
#include "ui.h"
#include <algorithm>

namespace {
/*
* Filters are used to select games, usually when performing searches.
* To encapsulate database internal complexity this functions should only
* parse arguments and call other functions/objects.
*
* Command names are case sensitive
* Optional parameter are indicated using [value_opt]
* Alternative values are indicated using <value_a|value_b|value_c>
* BaseId is the handle used to select the database to work on
* filterId is the unique ID of the filter to work on
* Games are numbered starting from "1"
*
* Every database has a default filter with id "dbfilter".
*/

/// @baseId: valid database identifier
/// @filterId: valid identifier of a filter.
/// @return the ids of the "main" and "mask" filters of the composed filter
///         @e filterId (if it is not composed returns @filterId and empty).
UI_res_t sc_filter_components(UI_handle_t ti, const scidBaseT& dbase, int argc,
                              const char** argv) {
	const char* usage = "Usage: sc_filter components baseId filterId";
	if (argc != 4)
		return UI_Result(ti, ERROR_BadArg, usage);

	auto filters = dbase.getFilterComponents(argv[3]);
	UI_List res(2);
	res.push_back(filters.first);
	res.push_back(filters.second);
	return UI_Result(ti, OK, res);
}

/**
 * sc_filter_compose() - compose a new filter
 * @baseId: valid database identifier
 * @filterId: valid identifier of the "main" filter. If it is already a composed
 *            one, only the "main" part will be used.
 * @maskfilterId: identifier of the "mask" Filter, can be an empty "" string.
 *
 * A composed filter include only the games contained in both @filterId and
 * @maskfilterId. This function allows to compose a new filter, if @filterId and
 * @maskfilterId are two valid filter identifiers, or to obtain the "main"
 * filter of a composed one, if @maskfilterId is an empty "" string.
 * A composed filter should not be released.
 * Return:
 * - the identifier of the composed filter, which can be used as a "normal"
 *   filter (modifying functions will affect only the "main" @filterId)
 * - on error, an empty string.
 */
UI_res_t sc_filter_compose(UI_handle_t ti, const scidBaseT& dbase, int argc,
                           const char** argv) {
	const char* usage = "Usage: sc_filter compose baseId filterId maskfilterId";
	if (argc != 5) return UI_Result(ti, ERROR_BadArg, usage);

	std::string res = dbase.composeFilter(argv[3], argv[4]);
	if (res.empty())
		return UI_Result(ti, ERROR_BadArg, "sc_filter: invalid filterId");

	return UI_Result(ti, OK, res);
}

/**
 * sc_filter_remove() - remove games from the filter
 * @gnumber: the id of the game to be removed
 * @+: also remove games after @gnumber
 * @-: also remove games before @gnumber
 * @sortCrit: criteria used to determine before/after
 */
UI_res_t sc_filter_remove(UI_handle_t ti, scidBaseT& dbase, HFilter& filter,
                          int argc, const char** argv) {
	const char* usage = "Usage: sc_filter remove baseId filterId gnumber [<+|-> sortCrit]";
	if (argc != 5 && argc != 7) return UI_Result(ti, ERROR_BadArg, usage);

	uint gNum = strGetUnsigned(argv[4]);
	if (gNum == 0 || gNum > dbase.numGames())
		return UI_Result(ti, ERROR_BadArg);

	if (argc == 5) {
		filter.erase(gNum - 1);
	} else {
		const char* crit = argv[6];
		size_t start = dbase.sortedPosition(crit, filter, gNum - 1);
		if (start == INVALID_GAMEID)
			return UI_Result(ti, ERROR_BadArg, usage);

		size_t count;
		switch (argv[5][0]) {
		case '+':
			count = filter->size() - start;
			break;
		case '-':
			count = start + 1;
			start = 0;
			break;
		default:
			return UI_Result(ti, ERROR_BadArg, usage);
		}

		gamenumT* idxList = new gamenumT[count];
		count = dbase.listGames(crit, start, count, filter, idxList);
		for (size_t i = 0; i < count; ++i) {
			filter.erase(idxList[i]);
		}
		delete[] idxList;
	}
	return UI_Result(ti, OK);
}

/**
 * sc_filter_reset() - reset a filter to be empty or include all the games
 * @full: reset the filter to include all the games
 * @empty: reset the filter to exclude all the games
 */
UI_res_t sc_filter_reset(UI_handle_t ti, HFilter& filter, int argc,
                         const char** argv) {
	const char* usage = "Usage: sc_filter reset baseId filterId <full|empty>";
	if (argc != 5) return UI_Result(ti, ERROR_BadArg, usage);

	if (strcmp("full", argv[4]) == 0) {
		filter->includeAll();
	} else if (strcmp("empty", argv[4]) == 0) {
		filter->clear();
	} else {
		return UI_Result(ti, ERROR_BadArg, usage);
	}
	return UI_Result(ti, OK);
}

/**
 * Checks if a needle is found within a haystack, supporting wildcards.
 * Wildcards at the start (*) or end (*) of the needle adjust the match criteria:
 * - A leading '*' allows the match to occur at any position towards the end.
 * - A trailing '*' allows the match to start anywhere from the beginning.
 * The search is case-insensitive.
 * Return True if the needle (considering wildcards) is found.
 */
bool strMatch(std::string_view haystack, std::string_view needle) {
	bool flex_end = !needle.empty() && needle.back() == '*';
	if (flex_end)
		needle.remove_suffix(1);

	bool flex_start = !needle.empty() && needle.front() == '*';
	if (flex_start)
		needle.remove_prefix(1);

	if (needle.size() == haystack.size())
		return std::equal(
		    haystack.begin(), haystack.end(), needle.begin(),
		    [](char a, char b) { return std::tolower(a) == std::tolower(b); });

	if (!flex_start && !flex_end)
		return false;

	auto it = std::search(
	    haystack.begin(), haystack.end(), needle.begin(), needle.end(),
	    [](char a, char b) { return std::tolower(a) == std::tolower(b); });

	return it != haystack.end() &&
	       (flex_start || std::distance(haystack.begin(), it) == 0) &&
	       (flex_end || std::distance(it + needle.size(), haystack.end()) == 0);
}

/**
 * Restricts @e filter to include only the games with a tag-value pair matching
 * the specified criteria.
 * Wildcard characters (*) at the beginning or at the end are permitted:
 * - *tagValue matches all values that end with tagValue.
 * - tagValue* matches all values that start with tagValue.
 * - *tagValue* matches all values that include tagValue.
 */
UI_res_t sc_filter_search_tags(UI_handle_t ti, const scidBaseT& dbase,
                               HFilter& filter, int argc, const char** argv,
                               Progress const& progress = {}) {
	const char* usage =
	    "Usage: sc_filter search baseId filterId tags tagName tagValue";
	if (argc != 7)
		return UI_Result(ti, ERROR_BadArg, usage);

	std::string_view tagName = argv[5];
	std::string_view tagValue = argv[6];
	auto iProgress = 0;
	auto filterSz = filter.size();
	for (auto gnum : filter) {
		if (++iProgress % 8192 == 0 && !progress.report(iProgress, filterSz))
			return UI_Result(ti, ERROR_UserCancel);

		bool remove = true;
		auto ie = dbase.getIndexEntry(gnum);
		dbase.getGame(*ie).decodeTags([&](auto const& tag, auto const& value) {
			if (strMatch(tag, tagName) && strMatch(value, tagValue))
				remove = false;
		});
		if (remove)
			filter.erase(gnum);
	}
	return UI_Result(ti, OK);
}

/**
 * sc_filter_sizes() - get the sizes of a filter
 *
 * Return a list containing:
 * - the number of games included in the filter @filterId
 * - the total number of games contained in the database @baseId
 * - the number of games included in the "main" filter composing @filterId
 *   (if @filterId is not a combined filter, this value is equal to the first).
 */
UI_res_t sc_filter_sizes(UI_handle_t ti, const scidBaseT& dbase,
                         HFilter& filter) {
	// "Usage: sc_filter sizes baseId filterId";
	UI_List res(3);
	res.push_back(filter.size());
	res.push_back(dbase.numGames());
	res.push_back(filter.mainSize());
	return UI_Result(ti, OK, res);
}

} // End of anonymous namespace

int sc_filter_old(ClientData cd, Tcl_Interp* ti, int argc, const char** argv);

UI_res_t sc_filter(UI_extra_t cd, UI_handle_t ti, int argc, const char** argv) {
	const char* usage = "Usage: sc_filter <cmd> baseId filterId [args]";
	if (argc < 2)
		return UI_Result(ti, ERROR_BadArg, usage);

	if (argc > 3) {
		auto dbase = DBasePool::getBase(strGetUnsigned(argv[2]));
		if (!dbase)
			return UI_Result(ti, ERROR_BadArg, usage);

		HFilter filter = dbase->getFilter(argv[3]);
		if (filter == nullptr)
			return UI_Result(ti, ERROR_BadArg, usage);

		const std::string_view cmd = argv[1];
		if (cmd == "components")
			return sc_filter_components(ti, *dbase, argc, argv);
		if (cmd == "compose")
			return sc_filter_compose(ti, *dbase, argc, argv);
		if (cmd == "remove")
			return sc_filter_remove(ti, *dbase, filter, argc, argv);
		if (cmd == "reset")
			return sc_filter_reset(ti, filter, argc, argv);
		if (cmd == "search" && argc > 4) {
			const std::string_view subcmd = argv[4];
			if (subcmd == "tags")
				return sc_filter_search_tags(ti, *dbase, filter, argc, argv,
				                             UI_CreateProgress(ti));
		}
		if (cmd == "sizes")
			return sc_filter_sizes(ti, *dbase, filter);
	}
	return sc_filter_old(cd, ti, argc, argv);
}
