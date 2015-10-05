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

#include "sortcache.h"
#include <vector>
#include <algorithm>

#if CPP11_SUPPORT
#include <thread>

bool SortCache::Sort_thread::start() {
	interrupt();
	if (!sc_->sorted_) {
		sc_->numGames = sc_->index->GetNumGames();
		sc_->GetSpace(sc_->numGames);
		for (uint i=0; i < sc_->numGames; i++) sc_->fullMap[i] = i;
		th_ = (void*) new std::thread (&SortCache::Sort_thread::sort, this, sc_->numGames);
	}
	return true;
}

void SortCache::Sort_thread::interrupt() {
	if (th_ != 0) {
		interrupt_ = true;
		join();
		interrupt_ = false;
	}
}

void SortCache::Sort_thread::join() {
	if (th_ != 0) {
		static_cast<std::thread*> (th_)->join();
		delete static_cast<std::thread*> (th_);
		th_ = 0;
	}
}

void SortCache::Sort_thread::sort(uint numGames){
	auto downheap = [this](int v, int n) {
		int w=2*v+1;
		while (w<n)
		{
			if (w+1<n)
				if (sc_->Compare(sc_->fullMap[w+1],sc_->fullMap[w]) > 0)
					w++;
			if (sc_->Compare(sc_->fullMap[v],sc_->fullMap[w]) >= 0)
				return;

			std::swap(sc_->fullMap[v], sc_->fullMap[w]);
			v=w;
			w=2*v+1;
		}
	};


	for (int v=numGames/2-1; v>=0; v--)	{
		if (interrupt_) return;
		downheap(v, numGames);
	}
	for (uint n = numGames; n > 1; )
	{
		if (interrupt_) return;
		n--;
		std::swap(sc_->fullMap[0], sc_->fullMap[n]);
		downheap(0, n);
    }
	sc_->sorted_ = true;
}

#else
bool SortCache::Sort_thread::start() { return false; }
void SortCache::Sort_thread::join() {}
void SortCache::Sort_thread::interrupt() {}
void SortCache::Sort_thread::sort(uint numGames){}
#endif

///////////////////////////////////////////////////////////////////////////////

enum {
    SORTING_date, SORTING_year, SORTING_event, SORTING_site, SORTING_round,
    SORTING_white, SORTING_black, SORTING_eco, SORTING_result, SORTING_moveCount,
    SORTING_avgElo, SORTING_country, SORTING_month,
    SORTING_deleted, SORTING_eventdate, 
	SORTING_whiteelo, SORTING_blackelo,
	SORTING_commentcount, SORTING_varcount, SORTING_nagcount,
	SORTING_resultwin, SORTING_resultdraw, SORTING_resultloss,
	SORTING_rating, SORTING_number,
//	TODO:
//	SORTING_flags, SORTING_endmaterial, SORTING_start, SORTING_nextmove,
	SORTING_sentinel
};

static const char shortCriteriaNames[][2] = 
{
	{'d', (char) SORTING_date},
	{'y', (char) SORTING_year},
	{'e', (char) SORTING_event},
	{'s', (char) SORTING_site},
	{'n', (char) SORTING_round},
	{'w', (char) SORTING_white},
	{'b', (char) SORTING_black},
	{'o', (char) SORTING_eco},
	{'r', (char) SORTING_result},
	{'m', (char) SORTING_moveCount},
	{'R', (char) SORTING_avgElo},
	{'c', (char) SORTING_country},
	{'D', (char) SORTING_deleted},
	{'E', (char) SORTING_eventdate},
	{'W', (char) SORTING_whiteelo},
	{'B', (char) SORTING_blackelo},
	{'C', (char) SORTING_commentcount},
	{'V', (char) SORTING_varcount},
	{'A', (char) SORTING_nagcount},
	{'1', (char) SORTING_resultwin},
	{'5', (char) SORTING_resultdraw},
	{'0', (char) SORTING_resultloss},
	{'i', (char) SORTING_rating},
	{'N', (char) SORTING_number},
//	TODO:
//	{'f', (char) SORTING_flags},
//	{'M', (char) SORTING_endmaterial},
//	{'S', (char) SORTING_start},
//	{'x', (char) SORTING_nextmove},
	{ 0, 0}
};

SortCache* SortCache::Create(const Index* idx, const NameBase* nb, const char* criterium, bool multithread)
{
	SortCache* s = new SortCache();
	if (OK == s->Init(idx, nb, criterium)) {
		if (multithread) s->t_.start();
		return s;
	}
	delete s;
	return 0;
}

SortCache::SortCache()
: t_(this)
{
	partialHashing = false;
	fullMap = NULL;
	mapSize = 0;
	hashValues = NULL;
	refCount = 1;
	sorted_ = false;
}

SortCache::~SortCache()
{
    t_.interrupt();

    if (fullMap != NULL)
		delete[] fullMap;

    if (hashValues != NULL)
		delete[] hashValues;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SortCache::Init():
// criterium: a list of names converted into a corresponding array of
//      integers denoting sorting criteria.
//      e.g.: "-Sdate,event,white" --> { SORTING_date, SORTING_event, SORTING_white }
//      The final element is set to SORTING_sentinel.
errorT SortCache::Init(const Index* idx, const NameBase* nb, const char* criterium)
{
	ASSERT(idx != 0 && nb != 0 && criterium != 0);
	index = idx;
	nbase = nb;
	criteria = criterium;
	numGames = index->GetNumGames();

	size_t numOFArgs = strlen( criterium) / 2;
	if (numOFArgs >= (INDEX_MaxSortingCriteria - 1))
	{
		SortCriteria[numOFArgs] = SORTING_sentinel;
		return ERROR_Full;
	}

	for(size_t i=0; i<numOFArgs; i++)
	{
		char key = criterium[2*i];
		SortCriteria[i] = SORTING_sentinel;
		for( int j=0; shortCriteriaNames[j][0] != 0; j++)
		{
			if( key == shortCriteriaNames[j][0])
			{
				SortCriteria[i] = shortCriteriaNames[j][1];
				SortReverse[i] = criterium[2*i+1] == '-';
				break;
			}
		}
		if( SortCriteria[i] == SORTING_sentinel)
		{
			return ERROR;
		}
	}
	SortCriteria[numOFArgs] = SORTING_sentinel;

	hashValues = new uint[numGames];
	for(uint i=0; i<numGames; i++)
		hashValues[i] = CalcHash(index->GetEntry(i));

	return OK;
}

errorT SortCache::GetRange( uint start, uint count, const HFilter& filter, uint *result)
{
	if (count == 0) return OK;
	if (start >= numGames) { *result = IDX_NOT_FOUND; return OK; }
	bool use_filter = (*filter && filter.count() != numGames);

	if (!sorted_) { // Not fully sorted
		std::vector<uint> v;
		if (use_filter) {
			v.resize(filter.count());
			for(uint i=0, gnum=0; gnum < numGames; gnum++) {
				if(filter.get(gnum) != 0) v[i++] = gnum;
			}
		} else {
			v.resize(numGames);
			for (uint i=0; i < numGames; ++i) v[i] = i;
		}

		if (start >= v.size()) {
			if (count > 0) *result = IDX_NOT_FOUND;
			return OK;
		}
		uint last = start + count;
		if (last > v.size()) {
			last = v.size();
			result[last - start] = IDX_NOT_FOUND;
		}
		uint skip = 0;
		if (start > 1000) {
			skip = start;
			std::nth_element(v.begin(), v.begin() + start, v.end(), Compare_std(this));
		}
		std::partial_sort(v.begin() + skip, v.begin() + last, v.end(), Compare_std(this));
		std::copy(v.begin() + start, v.begin() + last, result);

	} else { //Fully sorted cache

		if (hashValues)
		{
			delete[] hashValues;
			hashValues = NULL;
		}

		uint i = 0, j = 0;
		if (!use_filter) {
			//Speedup unfiltered search
			for (i = start; i < numGames && j < count; i++) result[j++] = fullMap[i];
		} else {
			uint filterCount = 0;

			// Pick up the specified range, ignore those not matching the filter
			for(; i < numGames && j < count; i++)
			{
				if( filter.get( fullMap[i]) == 0) continue;
				if( filterCount >= start) result[j++] = fullMap[i];
				filterCount++;
			}
		}
		if (j < count) result[j] = IDX_NOT_FOUND;
	}
	return OK;
}

/*IndexToFilteredCount
Given a game number find its position in the sorted list
gnumber: game number (first game has value 1)
filter: restrict search to filtered games
return: IDX_NOT_FOUND if gnumber is not found
        the position into the sorted list (first position has value 0)
*/
uint SortCache::IndexToFilteredCount( uint gnumber, const HFilter& filter)
{
	if (gnumber == 0 || gnumber > numGames) return IDX_NOT_FOUND;
	gnumber--;
	if (*filter && filter.get(gnumber) == 0) return IDX_NOT_FOUND;
	uint res = 0;
	if (!sorted_) {
		for (uint i=0; i < numGames; i++) {
			if (*filter && filter.get(i) == 0) continue;
			if (Compare(i, gnumber) <0) ++res;
		}
		return res;
	} else {
		for(uint i=0; i < numGames; i++) {
			if (*filter && filter.get(fullMap[i]) == 0) continue;
			if (fullMap[i] == gnumber) return res;
			res++;
		}
	}
	return IDX_NOT_FOUND;
}

errorT SortCache::CheckForChanges (uint id)
{
	if (id <= numGames)
	{
		t_.join();
		if (id == numGames) return AddEntry();

		if( hashValues)
			hashValues[id] = CalcHash( index->GetEntry( id));

		if (sorted_) {
			for(uint i=0; i<numGames; i++)
				if( fullMap[i] == id)
				{
					for(; i<numGames - 1; i++) fullMap[i] = fullMap[i + 1];
					Insert( id, numGames - 1);
					break;
				}
		}
	}
	else
	{
		t_.interrupt();
		numGames = index->GetNumGames();
		if (hashValues != NULL) delete[] hashValues;
		hashValues = new uint[numGames];
		for(uint i=0; i<numGames; i++)
			hashValues[i] = CalcHash( index->GetEntry( i));
		sorted_ = false;
		t_.start();
	}

	return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SortCache::Compare():
//      Compare two index entries according to sort criteria.
//      The parameter criteria is an array of integers denoting
//      sorting criteria (SORTING_date, SORTING_white, etc), terminated by
//      the value SORTING_sentinel.
//
inline int
SortCache::Compare (uint left, uint right)
{
	int res = 0;
	if (hashValues)
	{
		if (hashValues[left] == hashValues[right] && partialHashing) {
			res = FullCompare( left, right);
		} else {
			res = hashValues[left] - hashValues[right];
		}
	}
	else
	{
		res = FullCompare( left, right);
	}
	if (res == 0) res = left - right;
	return res;
}

inline bool
SortCache::Compare_std::operator() (uint i1, uint i2) const {
	int c = sc_->Compare(i1, i2);
	return c < 0;
}

int
SortCache::FullCompare (uint left, uint right)
{
	int res, rOne, rTwo;
	byte *fields = SortCriteria;
	bool *reverse = SortReverse;

	const IndexEntry *ie1 = index->GetEntry(left);
	const IndexEntry *ie2 = index->GetEntry(right);

	while (1) {
		switch (*fields) {
		case SORTING_sentinel:  // End of sort criteria array reached.
			return 0;
			break;

		case SORTING_date:
			res = (int)ie1->GetDate() - (int)ie2->GetDate();
			break;

		case SORTING_year:
			res = (int)ie1->GetYear() - (int)ie2->GetYear();
			break;

		case SORTING_eco:
			res = (int)ie1->GetEcoCode() - (int)ie2->GetEcoCode();
			break;

		case SORTING_moveCount:
			res = (int)ie1->GetNumHalfMoves() - (int)ie2->GetNumHalfMoves();
			break;

		case SORTING_white:
			res = strCaseCompare (ie1->GetWhiteName (nbase), ie2->GetWhiteName (nbase));
			break;

		case SORTING_black:
			res = strCaseCompare (ie1->GetBlackName (nbase), ie2->GetBlackName (nbase));
			break;

		case SORTING_event:
			res = strCaseCompare (ie1->GetEventName (nbase), ie2->GetEventName (nbase));
			break;

		case SORTING_site:
			res = strCaseCompare (ie1->GetSiteName (nbase), ie2->GetSiteName (nbase));
			break;

		case SORTING_round:
			res = strCompareRound (ie1->GetRoundName (nbase), ie2->GetRoundName (nbase));
			break;

		case SORTING_resultwin:
			res = (ie1->GetResult() == RESULT_White ? 1 : 0) - (ie2->GetResult() == RESULT_White ? 1 : 0);
			break;

		case SORTING_resultdraw:
			res = (ie1->GetResult() == RESULT_Draw ? 1 : 0) - (ie2->GetResult() == RESULT_Draw ? 1 : 0);
			break;

		case SORTING_resultloss:
			res = (ie1->GetResult() == RESULT_Black ? 1 : 0) - (ie2->GetResult() == RESULT_Black ? 1 : 0);
			break;

		case SORTING_result:
			res = RESULT_SORT[ie1->GetResult()] - RESULT_SORT[ie2->GetResult()];
			break;

		case SORTING_avgElo:  // Average Elo rating:
			rOne = ie1->GetWhiteElo(nbase) + ie1->GetBlackElo(nbase);
			rTwo = ie2->GetWhiteElo(nbase) + ie2->GetBlackElo(nbase);
			res = rOne - rTwo;
			break;

		case SORTING_country:  // Last 3 characters of site field:
			{
				const char * sOne = ie1->GetSiteName (nbase);
				const char * sTwo = ie2->GetSiteName (nbase);
				uint slenOne = strLength (sOne);
				uint slenTwo = strLength (sTwo);
				if (slenOne > 3) { sOne += slenOne - 3; }
				if (slenTwo > 3) { sTwo += slenTwo - 3; }
				res = strCaseCompare (sOne, sTwo);
			}
			break;

		case SORTING_month:
			res = (int)ie1->GetMonth() - (int)ie2->GetMonth();
			break;

		case SORTING_deleted:
			res = (int)ie1->GetDeleteFlag() - (int)ie2->GetDeleteFlag();
			break;

		case SORTING_eventdate:
			res = (int)ie1->GetEventDate() - (int)ie2->GetEventDate();
			break;

		case SORTING_whiteelo:
			res = (int) ie1->GetWhiteElo(nbase) - (int) ie2->GetWhiteElo(nbase);
			break;

		case SORTING_blackelo:
			res = (int) ie1->GetBlackElo(nbase) - (int) ie2->GetBlackElo(nbase);
			break;

		case SORTING_commentcount:
			res = (int) ie1->GetCommentCount() - (int) ie2->GetCommentCount();
			break;

		case SORTING_varcount:
			res = (int) ie1->GetVariationCount() - (int) ie2->GetVariationCount();
			break;

		case SORTING_nagcount:
			res = (int) ie1->GetNagCount() - (int) ie2->GetNagCount();
			break;

		case SORTING_rating:
			res = (int)ie1->GetRating(nbase) - (int)ie2->GetRating(nbase);
			break;

		case SORTING_number:
			res = (int) left - (int) right;
			break;

		default:    // Should never happen:
			ASSERT(0);
			return 0;
		}

		if (res != 0) return (*reverse) ? -res : res;
		fields++; 
		reverse++;
	}

	// Unreachable:
    ASSERT (0);
    return 0;
}

inline uint SortCache::GetStartHash (const char *strVal)
{
	uint result = tolower(*strVal) * 16777216;
	if( strVal[1])
	{
		result += tolower(*(strVal+1)) * 65536;
		if( strVal[2])
			result += tolower(*(strVal+2)) * 256 + tolower(*(strVal+3));
	}
	partialHashing = true;
	return result;
}

uint SortCache::CalcHash (const IndexEntry* ie)
{
	uint retValue = 0;
	int i = 0;
	byte totalBytesUsed = 0;

	while( SortCriteria[i] != SORTING_sentinel && totalBytesUsed < 4)
	{
		uint cacheValue = 0;
		byte bytesUsed = 4;
		switch( SortCriteria[i])
		{
			case SORTING_white:
				cacheValue = GetStartHash(ie->GetWhiteName(nbase));
				break;
			case SORTING_black:
				cacheValue = GetStartHash(ie->GetBlackName(nbase));
				break;
			case SORTING_site:
				cacheValue = GetStartHash(ie->GetSiteName(nbase));
				break;
			case SORTING_event:
				cacheValue = GetStartHash(ie->GetEventName(nbase));
				break;
			case SORTING_country:
			{
				const char *scountry = ie->GetSiteName (nbase);
				uint slen = strLength (scountry);
				if (slen > 3) 
					scountry += slen - 3;
				cacheValue = GetStartHash(scountry);
				break;
			}
			case SORTING_date:
				cacheValue = ie->GetDate();
				bytesUsed = 3;
				break;
			case SORTING_eventdate:
				cacheValue = ie->GetEventDate();
				break;
			case SORTING_year:
				cacheValue = ie->GetYear();
				bytesUsed = 2;
				break;
			case SORTING_month:
				cacheValue = ie->GetMonth();
				bytesUsed = 1;
				break;
			case SORTING_whiteelo:
				cacheValue = ie->GetWhiteElo(nbase);
				bytesUsed = 2;
				break;
			case SORTING_blackelo:
				cacheValue = ie->GetBlackElo(nbase);
				bytesUsed = 2;
				break;
			case SORTING_avgElo:
				cacheValue = ie->GetWhiteElo(nbase) + ie->GetBlackElo(nbase);
				bytesUsed = 2;
				break;
			case SORTING_round:
				cacheValue = ie->GetRound();
				bytesUsed = 1;
				break;
			case SORTING_result:
				cacheValue = RESULT_SORT[ie->GetResult()];
				bytesUsed = 1;
				break;
			case SORTING_resultwin:
				cacheValue = ie->GetResult() == RESULT_White ? 1 : 0;
				bytesUsed = 1;
				break;
			case SORTING_resultdraw:
				cacheValue = ie->GetResult() == RESULT_Draw ? 1 : 0;
				bytesUsed = 1;
				break;
			case SORTING_resultloss:
				cacheValue = ie->GetResult() == RESULT_Black ? 1 : 0;
				bytesUsed = 1;
				break;
			case SORTING_moveCount:
				cacheValue = ie->GetNumHalfMoves();
				bytesUsed = 2;
				break;
			case SORTING_eco:
				cacheValue = ie->GetEcoCode();
				bytesUsed = 2;
				break;
			case SORTING_commentcount:
				cacheValue = ie->GetCommentCount();
				bytesUsed = 2;
				break;
			case SORTING_varcount:
				cacheValue = ie->GetVariationCount();
				bytesUsed = 2;
				break;
			case SORTING_nagcount:
				cacheValue = ie->GetNagCount();
				bytesUsed = 2;
				break;
			case SORTING_deleted:
				cacheValue = (ie->GetDeleteFlag() ? 1 : 0);
				bytesUsed = 1;
				break;
			case SORTING_rating:
				cacheValue = ie->GetRating(nbase);
				bytesUsed = 1;
				break;
			case SORTING_number:
				//TODO: Hash the game number
				partialHashing = true;
				cacheValue = 0;
				break;
		}

		// If reverse search, just reverse the cache value
		if( SortReverse[i])
		{
			switch (bytesUsed)
			{
				case 1:
					cacheValue = 0xff - cacheValue;
					break;
				case 2:
					cacheValue = 0xffff - cacheValue;
					break;
				case 3:
					cacheValue = 0xffffff - cacheValue;
					break;
				case 4:
					cacheValue = 0xffffffff - cacheValue;
					break;
			}
		}
		// If there is not enough space in the cache, use only the highest bytes
		for( int j=0; j < bytesUsed - 4 + totalBytesUsed; j++)
			cacheValue /= 256;
		// Shift the old cache value to the left
		int used = 4 - totalBytesUsed < bytesUsed ? 4 - totalBytesUsed : bytesUsed;
		for( int j=0; j < used; j++)
			retValue *= 256;
		retValue += cacheValue;
		// Update the available cache
		totalBytesUsed += bytesUsed;
		i++;
	}
	// If not all search attributes fit, then it is a partial hash
	if( totalBytesUsed > 4 ||  SortCriteria[i] != SORTING_sentinel)
		partialHashing = true;

	return retValue;
}

// Function that change fullMap or hashValues need MT sync
// t_.join() or t_.interrupt() must be called before using one of the following functions
void SortCache::GetSpace( uint size)
{
	if(mapSize > size)
		return;

	if (fullMap != NULL) {
		uint *oldMap = fullMap;
		fullMap = new uint[size];
		memcpy( fullMap, oldMap, mapSize * 4);
		delete[] oldMap;
	}
	else
		fullMap = new uint[size];
	mapSize = size;
}

uint SortCache::Insert( uint gnum, uint done)
{
	uint insert = std::lower_bound(fullMap, fullMap + done, gnum, Compare_std(this)) - fullMap;

	for( uint tmp=done; tmp>insert; tmp--)
		fullMap[tmp] = fullMap[tmp-1];
	fullMap[insert] = gnum;
	return insert;
}

errorT SortCache::AddEntry()
{
    if (hashValues != NULL) {
		uint *oldMap = hashValues;
		hashValues = new uint[numGames + 1];
		memcpy( hashValues, oldMap, numGames * 4);
		delete[] oldMap;
		hashValues[numGames] = CalcHash( index->GetEntry( numGames));
	}
	if (sorted_)
	{
		GetSpace( numGames + 1);
		Insert( numGames, numGames);
	}
	numGames++;
	return OK;
}

