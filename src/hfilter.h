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

#ifndef SCID_HFILTER_H
#define SCID_HFILTER_H

#include "filter.h"

/*
 * A database can be searched according to different criteria and the list of
 * matching games is stored into a Filter object.
 * This class abstracts its internal representation providing an interface
 * equivalent to a pointer to a std::map<gamenumT, uint8_t> object, where the
 * keys are the gamenumT of matching games and the mapped_types are the number
 * of half-moves necessary to reach the matching position.
 * Searches that use only header informations (player names, dates, ...) match
 * at the starting position (0 half-moves).
 *
 * It is also possible to combine two filters in an efficient and transparent
 * way. If a secondary "mask" filter is supplied, the functions get(), size()
 * and the const_iterator consider only the games included in both filters.
 * Their behavior is equal to:
 * using Filter = std::map<gamenumT, uint8_t>;
 * Filter tmp_combined;
 * std::set_intersection(mask->begin(), mask->end(), main->begin(), main->end(),
 *     std::inserter(tmp_combined, tmp_combined.end()),
 *     [](auto& a, auto& b) { return a.first < b.first; });
 * return HFilter(&tmp_combined).begin/get/size();
*/
class HFilter {
	Filter* main_;
	const Filter* mask_;

public:
	/**
	 * class const_iterator - iterator for HFilter objects
	 *
	 * This class and the relative functions begin() and end() allow to use
	 * HFilter objects with STL algorithms and c++11 for-ranged loops.
	 * For example:
	 * for (auto& gnum : *hfilter_obj) {}
	 * is equal to:
	 * for (gamenumT gnum = 0, gnum < scidBaseT::numGames(); gnum++) {
	 *     if (hfilter_obj->get(gnum) == 0) continue;
	 * }
	 */
	class const_iterator {
		gamenumT gnum_;
		gamenumT end_;
		const HFilter* hfilter_;
		bool inFilter_;

	public:
		typedef std::forward_iterator_tag iterator_category;
		typedef std::ptrdiff_t difference_type;
		typedef gamenumT value_type;
		typedef const gamenumT* pointer;
		typedef const gamenumT& reference;

		const_iterator(gamenumT gnum, gamenumT end, const HFilter* hfilter,
		               bool inFilter = true)
		    : gnum_(gnum), end_(end), hfilter_(hfilter), inFilter_(inFilter) {
			ASSERT(hfilter != 0);
			if (gnum_ != end_) {
				bool included = (hfilter_->get(gnum_) != 0);
				if (included != inFilter_) operator++();
			}
		}

		reference operator*() const { return gnum_; }

		const_iterator& operator++() {
			while (++gnum_ != end_) {
				bool included = (hfilter_->get(gnum_) != 0);
				if (included == inFilter_) break;
			}
			return *this;
		}

		bool operator!=(const const_iterator& b) const {
			return gnum_ != b.gnum_ || hfilter_ != b.hfilter_;
		}
		bool operator==(const const_iterator& b) const {
			return ! operator!=(b);
		}
	};

	const_iterator begin() const {
		return const_iterator(0, main_->Size(), this);
	}
	const_iterator end() const {
		return const_iterator(main_->Size(), main_->Size(), this);
	}
	const_iterator beginInverted() const {
		return const_iterator(0, main_->Size(), this, false);
	}
	const_iterator endInverted() const {
		return const_iterator(main_->Size(), main_->Size(), this, false);
	}
	size_t sizeInverted() const {
		return main_->Size() - size();
	}

public: // Pointer interface
	bool operator==(const Filter* b) const { return main_ == b; }
	bool operator!=(const Filter* b) const { return main_ != b; }
	HFilter* operator->() { return this; }
	const HFilter* operator->() const { return this; }
	HFilter& operator*() { return *this; }
	const HFilter& operator*() const { return *this; }

public:
	explicit HFilter(Filter* main = 0, const Filter* mask = 0)
	    : main_(main), mask_(mask) {}

	void clear() { return main_->Fill(0); }
	void erase(gamenumT gnum) { return main_->Set(gnum, 0); }
	void insert_or_assign(gamenumT gnum, uint8_t ply) {
		return main_->Set(gnum, ply + 1);
	}
	size_t size() const;

	/* Convenience function, behave like:
	 * for (gamenumT gnum = 0; gnum < scidBaseT::numGames(); gnum++)
	 *		std:map::insert_or_assign(gnum, 0);
	 */
	void includeAll() { return main_->Fill(1); }

	/* Convenience function, behave like:
	 * return main_->size() == scidBaseT::numGames();
	 */
	bool isPrimaryWhole() const { return main_->isWhole(); }

	/* Convenience function, behave like:
	 * auto it = std::map::find(gnum);
	 * if (it == std::map::end()) return 0;
	 * return 1 + it->second;
	*/
	byte get(gamenumT gnum) const;

	/* Convenience function, behave like:
	 * if (value == 0)
	 *     erase(gnum);
	 * else
	 *     insert_or_assign(gnum, value - 1);
	 */
	void set(gamenumT gnum, byte value) { return main_->Set(gnum, value); }
};

inline size_t HFilter::size() const {
	if (mask_ == 0) return main_->Count();
	if (main_->isWhole()) return mask_->Count();
	const_iterator::difference_type res = std::distance(begin(), end());
	return static_cast<size_t>(res);
}

inline byte HFilter::get(gamenumT gnum) const {
	byte res = main_->Get(gnum);
	if (res != 0 && mask_ != 0)
		res = mask_->Get(gnum);

	return res;
}

/**
 * class HFilterInverted - iterate through games excluded from a filter
 *
 * This class allow to iterate through games not included in HFilter objects
 * using STL algorithms and c++11 for-ranged loops.
 * For example:
 * for (auto& gnum : HFilterInverted(hfilter_obj)) {}
 * is equal to:
 * for (gamenumT gnum = 0, gnum < scidBaseT::numGames(); gnum++) {
 *     if (hfilter_obj->get(gnum) != 0) continue;
 * }
 */
class HFilterInverted {
	const HFilter& hfilter_;

public:
	explicit HFilterInverted(const HFilter& hfilter) : hfilter_(hfilter) {
		ASSERT(hfilter != 0);
	}
	HFilter::const_iterator begin() const { return hfilter_.beginInverted(); }
	HFilter::const_iterator end() const { return hfilter_.endInverted(); }
	size_t size() const { return hfilter_.sizeInverted(); }
};

#endif
