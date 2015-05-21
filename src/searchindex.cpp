/*
# Copyright (C) 2015 Fulvio Benini

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

#include "common.h"
#include "misc.h"
#include "scidbase.h"
#include <string>
#include <vector>
#include <algorithm>


class SearchIndexName {
	const scidBaseT* base_;
	idNumberT (IndexEntry::* f1_) () const;
	idNumberT (IndexEntry::* f2_) () const;
	std::vector<bool> mask_;

public:
	SearchIndexName(const scidBaseT* base,
	                std::string pattern,
	                nameT name_type,
	                idNumberT (IndexEntry::* f1) () const,
	                idNumberT (IndexEntry::* f2) () const = 0)
	: base_(base), f1_(f1), f2_(f2) {
		idNumberT n = base->getNameBase()->GetNumNames(name_type);
		mask_.resize(n);

		size_t l = pattern.length();
		bool exact = (l > 2 && pattern[l -1] == '"' && pattern[0] == '"');
		if (exact) {
			Init_exact(n, name_type, pattern.substr(1, l -2));
		} else {
			Init_icase_ignoreSpaces(n, name_type, pattern.c_str());
		}
	}

	void Init_exact (idNumberT n, nameT name_type, std::string pattern) {
		const NameBase* nb = base_->getNameBase();
		for (idNumberT i=0; i < n; i++) {
			const char* name = nb->GetName (name_type, i);
			mask_[i] = (name == pattern);
		}
	}

	void Init_icase_ignoreSpaces(idNumberT n, nameT name_type, const char* pattern) {
		const NameBase* nb = base_->getNameBase();
		for (idNumberT i=0; i < n; i++) {
			const char* name = nb->GetName (name_type, i);
			mask_[i] = strAlphaContains(name, pattern);
		}
	}

	bool operator() (gamenumT gnum) {
		bool res = mask_[(base_->getIndexEntry(gnum)->*f1_)()];
		if (!res && f2_ != 0) {
			return mask_[(base_->getIndexEntry(gnum)->*f2_)()];
		}
		return res;
	}
};

class SearchIndexFlag {
	const scidBaseT* base_;
	uint flagMask_;

public:
	SearchIndexFlag(const scidBaseT* base, char flag)
	: base_(base) {
		uint flagType = IndexEntry::CharToFlag(flag);
		ASSERT(flagType != 0 || flag == 'S');
		flagMask_ = (1 << flagType);
	}

	bool operator() (gamenumT gnum) {
		return base_->getIndexEntry(gnum)->GetFlag(flagMask_);
	}
};

template <typename T>
class SearchIndexRange {
protected:
	const scidBaseT* base_;
	T (IndexEntry::* f_) () const;
	long min_;
	long max_;

	SearchIndexRange(const scidBaseT* base, T (IndexEntry::* f) () const)
	: base_(base), f_(f), min_(0), max_(0) {}

public:
	SearchIndexRange(const scidBaseT* base,
	                 const char* range,
	                 T (IndexEntry::* f) () const)
	: base_(base), f_(f) {
		char* next;
		min_ = std::strtol(range, &next, 10);
		char* end;
		max_ = std::strtol(next, &end, 10);
		if (next == end) max_ = min_;
		if (min_ > max_) std::swap(min_, max_);
	}

	bool operator() (gamenumT gnum) {
		long v = (base_->getIndexEntry(gnum)->*f_)();
		if (v < min_ || v > max_) return false;
		return true;
	}
};

class SearchIndexRangeDate : public SearchIndexRange<dateT> {
public:
	SearchIndexRangeDate(const scidBaseT* base,
	                     const char* range,
	                     dateT (IndexEntry::* f) () const)
	: SearchIndexRange<dateT>(base, f) {
		// Extract two whitespace-separated dates:
		const char* v = strFirstWord(range);
		min_ = date_EncodeFromString (v);
		const char* next = strNextWord(v);
		max_ = (*next == 0) ? min_ : date_EncodeFromString (next);
		if (min_ > max_) std::swap(min_, max_);
	}
};

class SearchIndexRangeEco : public SearchIndexRange<ecoT> {
public:
	SearchIndexRangeEco(const scidBaseT* base,
	                    const char* range,
	                    ecoT (IndexEntry::* f) () const)
	: SearchIndexRange<ecoT>(base, f) {
		// Extract two whitespace-separated ECO codes:
		const char* v = strFirstWord(range);
		min_ = eco_FromString(v);
		const char* next = strNextWord(v);
		max_ = (*next == 0) ? min_ : eco_FromString(next);
		if (min_ > max_) std::swap(min_, max_);
		// Set eco maximum to be the largest subcode, for example,
		// "B07" -> "B07z4" to make sure subcodes are included in the range:
		max_ = eco_LastSubCode(max_);
	}
};

class SearchIndexRangeGamenum : public SearchIndexRange<void> {
public:
	SearchIndexRangeGamenum(const scidBaseT* base, const char* range)
	: SearchIndexRange<void>(base, range, 0) {
		// Set up game number range:
		// Note that a negative number means a count from the end,
		// so -1 = last game, -2 = second to last, etc.
		if (min_ < 0) min_ += base->numGames();
		else min_ -=1;
		if (max_ < 0) min_ += base->numGames();
		else max_ -=1;
		if (min_ > max_) std::swap(min_, max_);
	}

	bool operator() (gamenumT gnum) {
		if (static_cast<long>(gnum) < min_ ||
			static_cast<long>(gnum) > max_) return false;
		return true;
	}
};

class SearchIndexRangeElo : public SearchIndexRange<eloT> {
protected:
	eloT (IndexEntry::* fElo1_) (const NameBase*) const;
	eloT (IndexEntry::* fElo2_) (const NameBase*) const;
	const NameBase* nb_;

public:
	SearchIndexRangeElo(const scidBaseT* base,
	                    const char* range,
	                    eloT (IndexEntry::* f1) (const NameBase*) const,
	                    eloT (IndexEntry::* f2) (const NameBase*) const = 0)
	: SearchIndexRange<eloT>(base, range, 0), fElo1_(f1), fElo2_(f2) {
		nb_ = base_->getNameBase();
	}

	bool operator() (gamenumT gnum) {
		long v1 = (base_->getIndexEntry(gnum)->*fElo1_)(nb_);
		long v2 = min_;
		if (fElo2_ != 0) v2 = (base_->getIndexEntry(gnum)->*fElo2_)(nb_);
		if (v1 < min_ || v1 > max_ || v2 < min_ || v2 > max_) return false;
		return true;
	}
};

class SearchIndexRangeEloDiff : public SearchIndexRangeElo {
public:
	SearchIndexRangeEloDiff(const scidBaseT* base,
	                        const char* range,
	                        eloT (IndexEntry::* f1) (const NameBase*) const,
	                        eloT (IndexEntry::* f2) (const NameBase*) const)
	: SearchIndexRangeElo(base, range, f1, f2) {}

	bool operator() (gamenumT gnum) {
		long v1 = (base_->getIndexEntry(gnum)->*fElo1_)(nb_);
		long v2 = (base_->getIndexEntry(gnum)->*fElo2_)(nb_);
		long v = v1 - v2;
		if (v < min_ || v > max_) return false;
		return true;
	}
};



typedef uint filterOpT;
const filterOpT FILTEROP_AND = 0;
const filterOpT FILTEROP_RESET = 2;
extern filterOpT strGetFilterOp (const char * str);

// Examples:
// -player carlsen -player kramnik
// means (white == carlsen || black == carlsen) && (white == kramnik || black == kramnik)
// and will find the games played between carlsen and kramnik
//
// -white carlsen -black anand -black| kramnik -black| aronian
// means (white == carlsen) && (black == anand || black == kramnik || black == aronian)
// and will find the games played by carlsen as white against anand, or kramnik, or aronian
//
// -elo "2700 4000" -event! blitz
// means elo > 2700 && elo < 4000 && event != blitz
// and will find the games played by players with elo greater or equal than 2700, excluding the blitz events
//
// -welo "2700 4000" -belo| "2700 4000" -delo "-200 200"
// means (white elo > 2700 && white elo < 4000) || (belo > 2700 && belo < 4000) && ((welo - belo) > -200 && (welo - belo) < 200)
// and will find the games where one player is at least 2700 and the opponent at least 2500
errorT search_index(scidBaseT* base, HFilter& filter, int argc, const char ** argv, const Progress& progress)
{
	ASSERT(*filter);

	const char * options[] = {
		"white", "black", "player", "event", "site", "round", "annotator", "annotated",
		"date", "results", "elo", "welo", "belo", "delo",
		"wtitles", "btitles", "toMove", "flag",
		"eco", "length", "gnum", "filter",
		"fStdStart", "fPromotions", "fComments", "fVariations",
		"fAnnotations", "fDelete", "fWhiteOpening", "fBlackOpening",
		"fMiddlegame", "fEndgame", "fNovelty", "fPawnStructure",
		"fTactics", "fKingside", "fQueenside", "fBrilliancy", "fBlunder",
		"fUser", "fCustom1" , "fCustom2" , "fCustom3" ,
		"fCustom4" , "fCustom5" , "fCustom6" , "pgn", NULL
	};
	enum {
		OPT_WHITE, OPT_BLACK, OPT_PLAYER, OPT_EVENT, OPT_SITE, OPT_ROUND, OPT_ANNOTATOR, OPT_ANNOTATED,
		OPT_DATE, OPT_RESULTS, OPT_ELO, OPT_WELO, OPT_BELO, OPT_DELO,
		OPT_WTITLES, OPT_BTITLES, OPT_TOMOVE, OPT_FLAG,
		OPT_ECO, OPT_LENGTH, OPT_GAMENUMBER, OPT_FILTER,
		OPT_FSTDSTART, OPT_FPROMOTIONS, OPT_FCOMMENTS, OPT_FVARIATIONS,
		OPT_FANNOTATIONS, OPT_FDELETE, OPT_FWHITEOP, OPT_FBLACKOP,
		OPT_FMIDDLEGAME, OPT_FENDGAME, OPT_FNOVELTY, OPT_FPAWNSTRUCT,
		OPT_FTACTICS, OPT_FKSIDE, OPT_FQSIDE, OPT_FBRILLIANCY, OPT_FBLUNDER,
		OPT_FUSER, OPT_FCUSTOM1, OPT_FCUSTOM2, OPT_FCUSTOM3,
		OPT_FCUSTOM4,  OPT_FCUSTOM5, OPT_FCUSTOM6, OPT_PGN
	};

	struct Param {
		int index;
		bool opNot;
		bool opOr;
		Param(std::string s, const char** options)
		: index(-1), opNot(false), opOr(false)
		{
			if (s.length() > 2 && s[0] == '-') {
				if (s.substr(s.length() -2) == "!|") {
					opNot = true;
					opOr = true;
					s.erase(s.length() -2);
				} else {
					if (s[s.length() -1] == '!') {
						opNot = true;
						s.erase(s.length() -1);
					}
					if (s[s.length() -1] == '|') {
						opOr = true;
						s.erase(s.length() -1);
					}
				}
				if (s.length() > 1) {
					s.erase(0, 1);
					index = strUniqueMatch (s.c_str(), options);
				}
			}
		}
	};

	// 1) Parse filterOp
	filterOpT filterOp = FILTEROP_RESET;
	for (int i=0; (i+1) < argc; i += 2) {
		Param p(argv[i], options);
		const char* value = argv[i+1];
		if (value[0] == 0) continue;

		if (p.index == OPT_FILTER) {
			filterOp = strGetFilterOp (value);
			if (filterOp == FILTEROP_RESET) {
				filter.fill(1);
				filterOp = FILTEROP_AND;
			}
			break;
		}
	}

	// 2) Create the list of games
	typedef std::vector<gamenumT>::iterator iter;
	std::vector<gamenumT> glist;
	glist.reserve(base->numGames());
	for (gamenumT i = 0, n=base->numGames(); i < n; i++) {
		byte v = filter.get(i);
		if (filterOp == FILTEROP_AND) {
			if (v != 0) glist.push_back(i);
		} else {
			//filterOp == FILTEROP_OR
			if (v == 0) glist.push_back(i);
		}
	}

	uint report_i = 0;
	uint report_tot = 2 + (argc / 2);
	if (!progress.report(++report_i, report_tot)) return ERROR_UserCancel;

	// 3) Search
	iter it_begin = glist.begin();
	iter it_end = glist.end();
	iter it_res = glist.end();
	for (int i=0; (i+1) < argc; i += 2) {
		Param p(argv[i], options);
		const char* value = argv[i+1];
		if (value[0] == 0) continue;

		if (p.opOr) {
			it_begin = it_res;
		} else {
			it_end = it_res;
			it_begin = glist.begin();
		}

		switch (p.index) {
		case OPT_PLAYER:
			it_res = std::partition(it_begin, it_end,
				SearchIndexName(base, value, NAME_PLAYER, &IndexEntry::GetWhite, &IndexEntry::GetBlack));
			break;
		case OPT_WHITE:
			it_res = std::partition(it_begin, it_end,
				SearchIndexName(base, value, NAME_PLAYER, &IndexEntry::GetWhite));
			break;
		case OPT_BLACK:
			it_res = std::partition(it_begin, it_end,
				SearchIndexName(base, value, NAME_PLAYER, &IndexEntry::GetBlack));
			break;
		case OPT_EVENT:
			it_res = std::partition(it_begin, it_end,
				SearchIndexName(base, value, NAME_EVENT, &IndexEntry::GetEvent));
			break;
		case OPT_SITE:
			it_res = std::partition(it_begin, it_end,
				SearchIndexName(base, value, NAME_SITE, &IndexEntry::GetSite));
			break;
		case OPT_ROUND:
			it_res = std::partition(it_begin, it_end,
				SearchIndexName(base, value, NAME_ROUND, &IndexEntry::GetRound));
			break;
		case OPT_DATE:
			it_res = std::partition(it_begin, it_end,
				SearchIndexRangeDate(base, value, &IndexEntry::GetDate));
			break;
		case OPT_ELO:
			it_res = std::partition(it_begin, it_end,
				SearchIndexRangeElo(base, value, &IndexEntry::GetWhiteElo, &IndexEntry::GetBlackElo));
			break;
		case OPT_WELO:
			it_res = std::partition(it_begin, it_end,
				SearchIndexRangeElo(base, value, &IndexEntry::GetWhiteElo));
			break;
		case OPT_BELO:
			it_res = std::partition(it_begin, it_end,
				SearchIndexRangeElo(base, value, &IndexEntry::GetBlackElo));
			break;
		case OPT_DELO:
			it_res = std::partition(it_begin, it_end,
				SearchIndexRangeEloDiff(base, value, &IndexEntry::GetWhiteElo, &IndexEntry::GetBlackElo));
			break;
		case OPT_ECO:
			it_res = std::partition(it_begin, it_end,
				SearchIndexRangeEco(base, value, &IndexEntry::GetEcoCode));
			break;
		case OPT_GAMENUMBER:
			it_res = std::partition(it_begin, it_end,
				SearchIndexRangeGamenum(base, value));
			break;
		case OPT_LENGTH:
			it_res = std::partition(it_begin, it_end,
				SearchIndexRange<ushort>(base, value, &IndexEntry::GetNumHalfMoves));
			break;
		case OPT_FLAG:
			it_res = std::partition(it_begin, it_end, SearchIndexFlag(base, value[0]));
			break;

		default:
			report_i++;
			continue;
		} // End switch

		if (p.opNot) {
			std::rotate(it_begin, it_res, it_end);
			it_res = it_begin + (it_end - it_res);
		}

		if (!progress.report(++report_i, report_tot)) return ERROR_UserCancel;

	} // End for

	// 4) Set the filter
	if (filterOp == FILTEROP_AND) {
		for (iter it = it_res; it != glist.end(); it++) filter.set(*it, 0);
	} else {
		//filterOp == FILTEROP_OR
		for (iter it = glist.begin(); it != it_res; it++) filter.set(*it, 1);
	}
	progress.report(1,1);

	return OK;
}

