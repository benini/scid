/*
* Copyright (C) 2011  Gerd Lorscheid
* Copyright (C) 2011-2015  Fulvio Benini

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

#ifndef SORTINGCACHE_DEFINED
#define SORTINGCACHE_DEFINED

#include "filter.h"
#include "index.h"
#include <string>

#if CPP11_SUPPORT
#include <atomic>
typedef std::atomic<bool> atomic_bool;
#else
typedef bool atomic_bool;
#endif

class Index;
class IndexEntry;

class SortCache
{
	std::string criteria;
	uint numGames;
	atomic_bool sorted_;
	bool partialHashing;
	uint* hashValues;
	uint* fullMap;
	const Index* index;
	const NameBase* nbase;
	uint mapSize;
	byte SortCriteria [INDEX_MaxSortingCriteria];
	bool SortReverse [INDEX_MaxSortingCriteria];
	int refCount;

public:
	static SortCache* Create(const Index* idx, const NameBase* nb, const char* criterium, bool multithread =true);
	~SortCache();
	errorT GetRange( uint start, uint count, const HFilter& filter, uint *result);
	uint IndexToFilteredCount( uint gnumber, const HFilter& filter);
	void PrepareForChanges(uint id);
	errorT CheckForChanges ( uint id);
	bool MatchCriteria( const std::string& crit) { return crit == criteria; }
	int ReleaseCount() { return --refCount; }
	int AddCount() { return ++refCount; }

private:
	SortCache();
	SortCache(const SortCache&);
	SortCache& operator=(const SortCache&);
	errorT Init (const Index *idx, const NameBase * nb, const char *criterium);
	inline int Compare (uint left, uint right);
	int FullCompare (uint left, uint right);
	void GetSpace( uint size);
	uint CalcHash (const IndexEntry *ie);
	inline uint GetStartHash (const char *strVal);
	errorT AddEntry();
	uint Insert( uint gnum, uint done);

	class Compare_std {
	public:
		Compare_std (SortCache* sc) : sc_(sc) {}
		inline bool operator() (uint i1, uint i2) const;
	private:
		SortCache* sc_;
	};

	class Sort_thread {
	public:
		Sort_thread (SortCache* sc) : sc_(sc), th_(0), interrupt_(false) {}
		bool start();
		void join();
		void interrupt();
	private:
		SortCache* sc_;
		void* th_;
		atomic_bool interrupt_;
		void sort(uint numGames);
	};
	Sort_thread t_;
};

inline void SortCache::PrepareForChanges(uint id) {
	if (!sorted_) {
		if (id < numGames) t_.join();
		else t_.interrupt();
	}
}


#endif
