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

#ifndef SEARCHTOURNAMENTS_H
#define SEARCHTOURNAMENTS_H

#include "common.h"
#include "misc.h"
#include <vector>
#include <algorithm>


/**
 * class TourneyGame - Private class used by Tourney and SearchTournaments
 */
struct TourneyGame {
	idNumberT siteID_;
	idNumberT eventID_;
	dateT     eventDate_;
	idNumberT whiteID_;
	idNumberT blackID_;
	eloT      wElo_;
	eloT      bElo_;
	dateT     date_;
	gamenumT  gnum_;
	resultT   result_;

	TourneyGame(const IndexEntry* ie, gamenumT gnum)
	: gnum_ (gnum) {
		siteID_ = ie->GetSite();
		eventID_ = ie->GetEvent();
		eventDate_ = ie->GetEventDate();
		whiteID_ = ie->GetWhite();
		blackID_ = ie->GetBlack();
		wElo_ = ie->GetWhiteElo();
		bElo_ = ie->GetBlackElo();
		result_ = ie->GetResult();
		date_ = ie->GetDate();
	}
};


/**
 * class Tourney - Calculate information about a tournament
 *
 * This class takes a range of TourneyGame references and calculate some
 * basic information (number of Players, average elo, scores, etc.).
 * Invariants:
 *     the range of TourneyGame refs should not be empty
 */
class Tourney {
	typedef std::vector<TourneyGame>::const_iterator Iter;

public:
	Tourney(Iter begin, Iter end)
	: begin_(begin), end_(end), minDateGame_(begin) {
		ASSERT(begin_ != end_);

		for (Iter it = begin_; it != end_; it++) {
			size_t idxW = addPlayer(it->whiteID_);
			size_t idxB = addPlayer(it->blackID_);
			players_[idxW].elo = std::max(players_[idxW].elo, it->wElo_);
			players_[idxB].elo = std::max(players_[idxB].elo, it->bElo_);
			switch (it->result_) {
				case RESULT_White:
					players_[idxW].score += 2;
					break;
				case RESULT_Black:
					players_[idxB].score += 2;
					break;
				case RESULT_Draw:
					players_[idxW].score++;
					players_[idxB].score++;
					break;
			}

			if (it->date_ < minDateGame_->date_) minDateGame_ = it;
		}

		std::sort(players_.begin(), players_.end(), SortScoreDesc());

		avgElo_ = calcAvgElo();
	}

	idNumberT getEventId() const { return begin_->eventID_; }
	idNumberT getSiteId() const { return begin_->siteID_; }
	dateT     getStartDate() const { return minDateGame_->date_; }
	gamenumT  getStartGameNum() const { return minDateGame_->gnum_; }
	uint      getAvgElo() const { return avgElo_; }
	uint      nGames() const { return std::distance(begin_, end_); }
	uint      nPlayers() const { return players_.size(); }

	struct Player {
		idNumberT nameId;
		uint16_t score;
		eloT elo;

		explicit Player(idNumberT id) : nameId(id), score(0), elo(0) {}
		bool operator==(idNumberT id) {	return nameId == id; }
	};
	const Player& getPlayer(size_t position) const {
		ASSERT(position < players_.size());
		return players_[position];
	}

private:
	std::vector<TourneyGame>::const_iterator begin_;
	std::vector<TourneyGame>::const_iterator end_;
	std::vector<TourneyGame>::const_iterator minDateGame_;
	std::vector<Player> players_;
	eloT avgElo_;

	size_t addPlayer(idNumberT playerID) {
		std::vector<Player>::iterator it_begin = players_.begin();
		std::vector<Player>::iterator it_end = players_.end();
		std::vector<Player>::iterator it = std::find(it_begin, it_end, playerID);
		size_t res = std::distance(it_begin, it);
		if (it == it_end) players_.push_back(Player(playerID));
		return res;
	};

	uint calcAvgElo() const {
		uint sum = 0;
		uint n = 0;
		std::vector<Player>::const_iterator it = players_.begin();
		std::vector<Player>::const_iterator it_end = players_.end();
		for (; it != it_end; it++) {
			if (it->elo != 0) {
				sum += it->elo;
				n++;
			}
		}
		return (n != 0) ? sum / n : 0;
	}

	struct SortScoreDesc {
		bool operator()(const Tourney::Player& a, const Tourney::Player& b) {
			return a.score > b.score;
		}
	};
};


/**
 * class SearchTournamens - Search tournaments in a database
 *
 * This class group games in tournaments.
 * Games with the same EventId, SiteId and EventDate are considered
 * a tournament. A game with EventDate == 0 is also considered part of
 * a tournament if its date is greater than or equal to the EventDate
 * of the other games.
 * It's also possible to filter the results further by:
 *     - average elo
 *     - number of partecipants
 *     - number of games
 *     - name of a participant
 * Results can be sorted by
 *     - event name
 *     - event date
 *     - site name
 *     - number of partecipants
 *     - number of games
 *     - average elo
 *
 * Dependencies:
 * Indexes of NameBase are used for the names of the event, site and player
 * and they must be valid and unchanged throughout all the life of the
 * SearchTournament object.
 */
class SearchTournaments {
	const scidBaseT* dbase_;
	std::vector<TourneyGame> games_;
	std::vector<Tourney> tourney_;

public:
	SearchTournaments(const scidBaseT* dbase, const HFilter& filter);

	typedef std::vector<Tourney>::const_iterator Iter;
	Iter begin() const { return tourney_.begin(); }
	Iter end() const { return tourney_.end(); }

	void filterByAvgElo(const StrRange& range) {
		tourney_.erase(
			std::remove_if(tourney_.begin(), tourney_.end(),
				Filter<& Tourney::getAvgElo>(range)),
			tourney_.end());
	}

	void filterByNPlayers(const StrRange& range) {
		tourney_.erase(
			std::remove_if(tourney_.begin(), tourney_.end(),
				Filter<& Tourney::nPlayers>(range)),
			tourney_.end());
	}

	void filterByNGames(const StrRange& range) {
		tourney_.erase(
			std::remove_if(tourney_.begin(), tourney_.end(),
				Filter<& Tourney::nGames>(range)),
			tourney_.end());
	}

	void filterByPlayer(const char* name) {
		tourney_.erase(
			std::remove_if(tourney_.begin(), tourney_.end(),
				FilterByPlayer(name, dbase_->getNameBase())),
			tourney_.end());
	}


	bool sort(const char* criteria, size_t max);

private:
	struct GameSort {
		bool operator()(const TourneyGame& a, const TourneyGame& b) {
			if (a.eventID_ != b.eventID_) return a.eventID_ < b.eventID_;
			if (a.siteID_ != b.siteID_) return a.siteID_ < b.siteID_;
			dateT d1 = a.eventDate_ != 0 ? a.eventDate_ : a.date_;
			dateT d2 = b.eventDate_ != 0 ? b.eventDate_ : b.date_;
			return d1 < d2;
		}
	};

	class FindNewTourney {
		const TourneyGame& g_;
	public:
		FindNewTourney(const TourneyGame& start) : g_(start) {}

		bool operator()(const TourneyGame& g) {
			if (g_.eventID_ != g.eventID_ || g_.siteID_ != g.siteID_)
				return true;

			if (g_.eventDate_ != 0 && g.eventDate_ == 0)
				return g_.eventDate_ > g.date_;

			if (g_.eventDate_ == 0 && g.eventDate_ != 0)
				return g.eventDate_ > g_.date_;

			return g_.eventDate_ != g.eventDate_;
		}
	};


	template <uint (Tourney::* f)() const>
	class Filter {
		const StrRange& range_;

	public:
		Filter(const StrRange& range) : range_(range) {}

		bool operator()(const Tourney& t) {
			return ! range_.inRange((t.*f)());
		}
	};

	class FilterByPlayer {
		const char* name_;
		const NameBase* nb_;

	public:
		FilterByPlayer(const char* name, const NameBase* nb)
		: name_(name), nb_(nb) {}

		bool operator()(const Tourney& t) {
			for (size_t i = 0, n = t.nPlayers(); i < n; i++) {
				const char* name = nb_->GetName(NAME_PLAYER, t.getPlayer(i).nameId);
				if (strAlphaContains(name, name_)) return false;
			}
			return true;
		}
	};


	struct SortDate {
		bool operator()(const Tourney& a, const Tourney& b) {
			return a.getStartDate() > b.getStartDate();
		}
	};

	template <uint (Tourney::* f)() const>
	struct SortDesc {
		bool operator()(const Tourney& a, const Tourney& b) {
			return (a.*f)() > (b.*f)();
		}
	};

	template <nameT nt, idNumberT (Tourney::* f)() const>
	class SortId {
		const NameBase* nb_;
	public:
		SortId(const NameBase* nb) : nb_(nb) {}
		bool operator()(const Tourney& a, const Tourney& b) {
			const char* nameA = nb_->GetName(nt, (a.*f)());
			const char* nameB = nb_->GetName(nt, (b.*f)());
			return strCaseCompare(nameA, nameB) < 0;
		}
	};
};

inline SearchTournaments::SearchTournaments(const scidBaseT* dbase, const HFilter& filter)
: dbase_(dbase) {
	ASSERT(dbase != 0);
	ASSERT(filter != 0);
	games_.reserve(filter->size());
	for (uint i=0, n = dbase->numGames(); i < n; i++) {
		if (filter.get(i) == 0) continue;
		games_.push_back( TourneyGame(dbase->getIndexEntry(i), i) );
	}

	std::sort(games_.begin(), games_.end(), GameSort());

	typedef std::vector<TourneyGame>::const_iterator GameIt;
	GameIt it = games_.begin();
	GameIt it_end = games_.end();
	while (it !=  it_end) {
		GameIt start = it;
		it = std::find_if(it, it_end, FindNewTourney(*start));
		tourney_.push_back(Tourney(start, it));
	}
}

inline bool SearchTournaments::sort(const char* criteria, size_t nOrdered) {
	static const char* criterions [] = {
		 "Date", "Elo", "Event", "Games", "Players", "Site", NULL
	};
	enum { DATE, ELO, EVENT, GAMES, PLAYERS, SITE };

	std::vector<Tourney>::iterator begin = tourney_.begin();
	std::vector<Tourney>::iterator it = (nOrdered < tourney_.size()) ?
		tourney_.begin() + nOrdered : tourney_.end();
	std::vector<Tourney>::iterator end = tourney_.end();

	switch (strUniqueMatch(criteria, criterions)) {
	case DATE:
		std::partial_sort(begin, it, end, SortDate());
		break;
	case ELO:
		std::partial_sort(begin, it, end, SortDesc<& Tourney::getAvgElo>());
		break;
	case EVENT:
		std::partial_sort(begin, it, end,
			SortId<NAME_EVENT, & Tourney::getEventId>(dbase_->getNameBase()));
		break;
	case GAMES:
		std::partial_sort(begin, it, end, SortDesc<& Tourney::nGames>());
		break;
	case PLAYERS:
		std::partial_sort(begin, it, end, SortDesc<& Tourney::nPlayers>());
		break;
	case SITE:
		std::partial_sort(begin, it, end,
			SortId<NAME_SITE, & Tourney::getSiteId>(dbase_->getNameBase()));
		break;
	default:
		return false;
	}

	return true;
}

#endif
