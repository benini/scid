/*
* Copyright (C) 2011  Gerd Lorscheid, Fulvio Benini

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

#if defined(__GXX_EXPERIMENTAL_CXX0X__) || __cplusplus >= 201103L
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
// printf("Debug: background thread started\n");
	for (int v=numGames/2-1; v>=0; v--)	sc_->Downheap(v, numGames);
	for (uint n = numGames; n > 1; )
	{
		if (interrupt_) {
// printf("Debug: background sorting interrupted\n");
			return;
		}
		n--;
		int tmp=sc_->fullMap[0]; sc_->fullMap[0]=sc_->fullMap[n]; sc_->fullMap[n]=tmp;
		sc_->Downheap(0, n);
    }
	sc_->sorted_ = true;
// printf("Debug: background sorting finished\n");
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
	SORTING_gamenumber, SORTING_whiteelo, SORTING_blackelo, 
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

SortCache* SortCache::Create(Index* idx, NameBase* nb, const char* criterium, bool multithread)
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
	ErrorMsg = 0;
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
//
//      If an error occurs, ERROR is returned and ErrorMsg is set to
//      an appropriate error message.
//
errorT SortCache::Init(Index* idx, NameBase* nb, const char* criterium)
{
	ASSERT(idx != 0 && nb != 0 && criterium != 0);
	index = idx;
	nbase = nb;
	criteria = criterium;
	numGames = index->GetNumGames();

	uint numOFArgs = strlen( criterium) / 2;
	if (numOFArgs >= (INDEX_MaxSortCriteria - 1))
	{
		SortCriteria[numOFArgs] = SORTING_sentinel;
		ErrorMsg = strDuplicate ( "Error: Too many fields in sort criteria!");
		return ERROR_Full;
	}

	for(uint i=0; i<numOFArgs; i++)
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
			sprintf (ErrorMsg, "Error: invalid character in sort field list: \"%c\"", key);
			return ERROR;
		}
	}
	SortCriteria[numOFArgs] = SORTING_sentinel;

	hashValues = new uint[numGames];
	for(uint i=0; i<numGames; i++)
		hashValues[i] = CalcHash(index->FetchEntry(i));

	return OK;
}

errorT SortCache::GetRange( uint start, uint count, Filter *filter, uint *result)
{
	if (count == 0) return OK;
	if (start >= numGames) { *result = IDX_NOT_FOUND; return OK; }
	bool full_filter = (filter == 0 || filter->Count() == numGames);

	if (!sorted_) { // Not fully sorted
		std::vector<uint> v;
		if (!full_filter) {
			v.resize(filter->Count());
			for(uint i=0, gnum=0; gnum < numGames; gnum++) {
				if(filter->Get(gnum) != 0) v[i++] = gnum;
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
		for (uint j=0, i=start; i < last; ++i) result[j++] = v[i];

	} else { //Fully sorted cache

		if (hashValues)
		{
			delete[] hashValues;
			hashValues = NULL;
		}

		uint i = 0, j = 0;
		if (full_filter) {
			//Speedup unfiltered search
			for (i = start; i < numGames && j < count; i++) result[j++] = fullMap[i];
		} else {
			uint filterCount = 0;

			// Pick up the specified range, ignore those not matching the filter
			for(; i < numGames && j < count; i++)
			{
				if( filter->Get( fullMap[i]) == 0) continue;
				if( filterCount >= start) result[j++] = fullMap[i];
				filterCount++;
			}
		}
		if (j < count) result[j] = IDX_NOT_FOUND;
	}
	return OK;
}

void SortCache::DoFullSort(int reportFrequency,
                           void (*progressFn)(void * data, uint progress, uint total),
                           void * progressData)
{
	if (t_.start()) return;
	if (!sorted_) {
		GetSpace(numGames);
		for (uint i=0; i<numGames; i++) fullMap[i] = i;

//		Was function void HeapSort(reportFrequency, progressFn, progressData);
		int tmp;
		for (int v=numGames/2-1; v>=0; v--)	Downheap(v, numGames);

	    int reportAfter = reportFrequency;
	    uint progressCounter = 0;

		uint n = numGames;
		while (n>1)
		{
			n--;
			tmp=fullMap[0]; fullMap[0]=fullMap[n]; fullMap[n]=tmp;
			Downheap(0, n);

	        progressCounter++;
	        reportAfter--;
	        if (reportAfter == 0) {
	            if (progressFn != NULL) {
	                (*progressFn) (progressData, progressCounter, numGames);
	            }
	            reportAfter = reportFrequency;
	        }
	    }
	    if (progressFn != NULL) {
	        (*progressFn) (progressData, 1, 1);
	    }
////////////////////////////////////////////////
		sorted_ = true;
	}
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

	IndexEntry *ie1 = index->FetchEntry(left); 
	IndexEntry *ie2 = index->FetchEntry(right); 

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
			res = (int)ie1->GetResult() - (int)ie2->GetResult();
			break;

		case SORTING_avgElo:  // Average Elo rating:
			rOne = ie1->GetWhiteElo() + ie1->GetBlackElo();
			rTwo = ie2->GetWhiteElo() + ie2->GetBlackElo();
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
			{
				dateT d = ie1->GetEventDate();
				dateT d2 = ie2->GetEventDate();
				if (d == ZERO_DATE) { d = ie1->GetDate(); }
				if (d2 == ZERO_DATE) { d2 = ie2->GetDate(); }
				res = (int)d - (int)d2;
			}
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

		if (res != 0) 
			return *reverse ? -res : res;
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

uint SortCache::CalcHash (IndexEntry * ie)
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
				if (cacheValue == ZERO_DATE) 
					cacheValue = ie->GetDate();
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
				cacheValue = ie->GetWhiteElo();
				bytesUsed = 2;
				break;
			case SORTING_blackelo:
				cacheValue = ie->GetBlackElo();
				bytesUsed = 2;
				break;
			case SORTING_avgElo:
				cacheValue = ie->GetWhiteElo() + ie->GetBlackElo();
				bytesUsed = 2;
				break;
			case SORTING_round:
				cacheValue = ie->GetRound();
				bytesUsed = 1;
				break;
			case SORTING_result:
				cacheValue = ie->GetResult();
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
		// Update the availabe cache
		totalBytesUsed += bytesUsed;
		i++;
	}
	// If not all search attributes fit, then it is a partial hash
	if( totalBytesUsed > 4 ||  SortCriteria[i] != SORTING_sentinel)
		partialHashing = true;

	return retValue;
}

errorT
SortCache::CheckForChanges ( int *criteria, uint id)
{
	// TODO: Maybe it's better t_.interrupt() and after changes "if (!sorted_) t_.start()"?
	t_.join();
	bool matchFound = false;
	if( id >= numGames)
		return AddEntry();

	while( criteria && *criteria != SORTING_sentinel)
	{
		byte *sc = SortCriteria;
		while( *sc != SORTING_sentinel)
			if( *sc == *criteria)
			{
				matchFound = true;
				break;
			}
		if( matchFound == true)
			break;
	}

	if( criteria && !matchFound)
		return OK;

	if(id != IDX_NOT_FOUND)
	{
		if( hashValues)
			hashValues[id] = CalcHash( index->FetchEntry( id));

		if (sorted_) {
			for(uint i=0; i<numGames; i++)
				if( fullMap[i] == id)
				{
					uint id = fullMap[i];
					for(; i<numGames - 1; i++) fullMap[i] = fullMap[i + 1];
					Insert( id, numGames - 1);
					break;
				}
		}
	}
	else
	{
		if (hashValues == 0) hashValues = new uint[numGames];
		for(uint i=0; i<numGames; i++)
			hashValues[i] = CalcHash( index->FetchEntry( i));
		if (sorted_) {
			sorted_ = false;
			if (! t_.start()) DoFullSort(0,0,0);
		}
	}

	return OK;
}

/*IndexToFilteredCount
Given a game number find it's position into the sorted list
gnumber: game number (first game has value 1)
filter: restrict search to filtered games
return: 0 if gnumber is not found
        the position into the sorted list (first position has value 1)
*/
uint SortCache::IndexToFilteredCount( uint gnumber, Filter *filter)
{
	if (gnumber == 0) return 0;
	if (gnumber > numGames) return 0;
	gnumber--;
	if (filter && filter->Get(gnumber) == 0) return 0;
	uint filterCount = 1;
	if (!sorted_) {
		for (uint gnum=0; gnum < numGames; gnum++) {
			if (filter && filter->Get(gnum) == 0) continue;
			if (Compare(gnum, gnumber) <0) ++filterCount;
		}
	} else {
		for( uint i=0; i<numGames; i++)
			if( filter && filter->Get( fullMap[i]))
			{
				if( fullMap[i] == gnumber) break;
				filterCount++;
			}
	}
	return filterCount;
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
	uint insert = done;
	if( done < 20)
	{
		// Only few entries, so do a sequential insert
		while( insert > 0)
		{
			if( Compare( fullMap[insert-1], gnum) > 0)
				insert--;
			else
				break;
		}
	}
	else
	{
		// More entries, so do a binary insert
		uint up = done - 1;
		uint low = 0;
		insert = (up + low) / 2;
		while( low < up)
		{
			int res = Compare( fullMap[insert], gnum);
			if( res == 0)
				break;
			if( res < 0)
				low = insert + 1;
			else
				up = insert;
			insert = (up + low) / 2;
		}
	}

	for( uint tmp=done; tmp>insert; tmp--)
		fullMap[tmp] = fullMap[tmp-1];
	fullMap[insert] = gnum;
	return insert;
}

void SortCache::Downheap( int v, int n)
{
	int tmp;
	int w=2*v+1;
	while (w<n)
	{
		if (w+1<n)
			if (Compare(fullMap[w+1],fullMap[w]) > 0)
				w++;
		if (Compare(fullMap[v],fullMap[w]) >= 0)
			return;
		tmp=fullMap[v]; fullMap[v]=fullMap[w]; fullMap[w]=tmp;
		v=w;
		w=2*v+1;
	}
}

errorT SortCache::AddEntry()
{
    if (hashValues != NULL) {
		uint *oldMap = hashValues;
		hashValues = new uint[numGames + 1];
		memcpy( hashValues, oldMap, numGames * 4);
		delete[] oldMap;
		hashValues[numGames] = CalcHash( index->FetchEntry( numGames));
	}
	if (sorted_)
	{
		GetSpace( numGames + 1);
		Insert( numGames, numGames);
	}
	numGames++;
	return OK;
}

//To be improved: Store/Load functions
SortCache* SortCache::CreateFromFile(Index* idx, NameBase* nb)
{
	FILE *fp;
	char fileName[256];

	strcpy( fileName, idx->GetFileName());
	strcpy( fileName + strlen(fileName), ".ssc");
	fp = fopen( fileName, "rb");
	if(fp == NULL) return 0;

	fseek( fp, 0, SEEK_END);
	long size = ftell( fp);
	fseek( fp, 0, SEEK_SET);
	if( size != 2*INDEX_MaxSortingCriteria + idx->GetNumGames() * 4) return 0;

	SortCache* s = new SortCache();
	s->index = idx;
	s->nbase = nb;
	s->numGames = idx->GetNumGames();
	s->GetSpace(s->numGames);
	for(uint i=0; i<INDEX_MaxSortingCriteria; i++)
	{
		s->SortCriteria[i] = readOneByte( fp);
		s->SortReverse[i] = readOneByte( fp);
	}
	size_t ferr = fread( s->fullMap, 4, s->numGames, fp);
	if (ferr > 0) { //(ferr != (4 * s->numGames))
		s->sorted_ = true;
		char buf[100];
		s->GetSortingCrit(buf);
		s->criteria = buf;
	}

	fclose(fp);
    return s;
}

errorT SortCache::WriteToFile ()
{
	t_.join();
	FILE *fp;
	char fileName[256];

	if( !sorted_)
	{
		return OK;
	}

	strcpy( fileName, index->GetFileName());
	strcpy( fileName + strlen(fileName), ".ssc");
	fp = fopen( fileName, "wb");
	if(fp == NULL)
	{
		return OK;
	}

	for(uint i=0; i<INDEX_MaxSortingCriteria; i++)
	{
		writeOneByte( fp, SortCriteria[i]);
		writeOneByte( fp, SortReverse[i]);
	}
	fwrite( fullMap, 4, numGames, fp);
	fclose(fp);
    return OK;
}

bool SortCache::CanLoad( char *fName, uint numGames)
{
	FILE *fp;
	char fileName[256];

	strcpy( fileName, fName);
	strcpy( fileName + strlen(fileName), ".ssc");
	fp = fopen( fileName, "rb");
	if(fp == NULL)
		return false;
	fseek( fp, 0, SEEK_END); 
	long size = ftell( fp);
	fseek( fp, 0, SEEK_SET);
	fclose( fp);
	return( size == 2*INDEX_MaxSortingCriteria + numGames * 4);
}

errorT SortCache::GetSortingCrit( char *crit)
{
	for (uint i=0; i<INDEX_MaxSortingCriteria && SortCriteria[i] != SORTING_sentinel; i++)
		for (int j=0; shortCriteriaNames[j][0] != 0; j++)
			if ( shortCriteriaNames[j][1] == SortCriteria[i])
			{
				*crit = shortCriteriaNames[j][0];
				crit++;
				*crit = SortReverse[i] ? '-' : '+';
				crit++;
			}
	*crit = 0;
	return OK;
}
