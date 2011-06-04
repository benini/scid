#include "sortcache.h"

enum {
    SORTING_date, SORTING_year, SORTING_event, SORTING_site, SORTING_round,
    SORTING_white, SORTING_black, SORTING_eco, SORTING_result, SORTING_moveCount,
    SORTING_avgElo, SORTING_country, SORTING_month,
    SORTING_deleted, SORTING_eventdate, 
	SORTING_gamenumber, SORTING_whiteelo, SORTING_blackelo, 
	SORTING_commentcount, SORTING_varcount, SORTING_nagcount,
	SORTING_resultwin, SORTING_resultdraw, SORTING_resultloss,
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
	{ 0, 0}
};

SortCache::SortCache( Index *idx, NameBase * nb, const char *criterium, bool preSort, bool hash)
{
	index = idx;
	doPresorting = preSort;
	doHashing = hash;
	partialHashing = false;
	fullMap = NULL;
	mapSize = 0;
	nbase = nb;
	numSorted = 0;
	hashValues = NULL;
	refCount = 1;
	numGames = index->GetNumGames();
	lastStart = IDX_NOT_FOUND;
	ParseSortCriteria(criterium);
}

SortCache::~SortCache()
{
    if (fullMap != NULL)
		delete[] fullMap;
	fullMap = NULL;

    if (hashValues != NULL)
		delete[] hashValues;
	hashValues = NULL;
}


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


void SortCache::Clear( const char *criterium, bool doPresort)
{
	numSorted = 0;
	partialHashing = false;
	lastStart = IDX_NOT_FOUND;
	doPresorting = doPresort;
	refCount = 1;
	if(criterium)
		ParseSortCriteria(criterium);
}


errorT SortCache::GetIndex( uint idx, Filter *filter, uint *result)
{
	*result = IDX_NOT_FOUND;
	if( doPresorting)
	{
		// Do sorting if not already done
		if( fullMap == NULL)
			DoFullSort(0,NULL,NULL);
	}
	else
	{
		// Ensure that the necessary number of entries are sorted
		sortUpto( idx, filter);
	}

	// Pick up the entry with number idx, ignore those not matching the filter
	uint numFound = 0;
	for( int i=0; i<numSorted; i++)
	{
		if( filter->Get( fullMap[i]) == 0)
			continue;
		if( numFound == idx)
		{
			*result = fullMap[i];
			break;
		}
		numFound++;
	}
	return OK;
}

errorT SortCache::GetRange( uint start, uint count, Filter *filter, uint *result)
{
	if( doPresorting)
	{
		// Do sorting if not already done
		if( fullMap == NULL)
			DoFullSort( 0,NULL,NULL);
	}
	else
	{
		// Ensure that the necessary number of entries are sorted
		sortUpto( start + count, filter);
	}

	uint searchStart = 0;
	uint filterCount = 0;
	if( start >= lastStart && filter == lastFilter)
	{
		searchStart = lastIndex;
		filterCount = lastCount;
	}

	// Pick up the specified range, ignore those not matching the filter
	for( uint i=searchStart; i<numSorted && filterCount<start+count; i++)
	{
		if( filter && filter->Get( fullMap[i]) == 0)
			continue;
		if( filterCount == start)
		{
			lastIndex = i;
			lastCount = filterCount;
		}
		if( filterCount >= start)
			result[filterCount-start] = fullMap[i];
		if( filterCount == start)
		{
			lastIndex = i;
			lastCount = filterCount;
			lastStart = start;
			lastFilter = filter;
		}
		filterCount++;
	}
	if( filterCount < count + start)
		result[filterCount-start >= 0 ? filterCount-start : 0] = IDX_NOT_FOUND;

	return OK;
}


void SortCache::sortUpto( uint idx, Filter *filter)
{
	uint *doneMap = NULL;
	uint done = 0;

	if( filter)
	{
		for( int i=0; i<numSorted; i++)
			if( filter->Get(fullMap[i]) > 0)
				done++;
	}

	GetSpace(numSorted + idx - done + 100);

	if(numSorted)
	{
		// Initialize doneMap
		doneMap = new uint[(numGames + 31) / 32];
		memset( doneMap, 0, (numGames + 31) / 32 * 4);
		for( uint i=0; i<numSorted; i++)
			doneMap[ fullMap[i] / 32] = doneMap[ fullMap[i] / 32] | (1 << (fullMap[i] % 32));
	}

	uint todo = idx - done;
    for( uint gnum=0; gnum < numGames; gnum++) 
	{
		// check whether done
		if(( doneMap != NULL) && (doneMap[gnum/32] & (1 << (gnum%32))))
			continue;

		// Ignore games not matching the actual filter
		if( filter && filter->Get(gnum) == 0)
			continue;

		if( todo)
		{
			if( numSorted == 0 || Compare( fullMap[numSorted-1], gnum) <= 0)
			{
				// Value too low, but there are still free places at the end
				fullMap[numSorted] = gnum;
			}
			else
			{
				fullMap[numSorted] = fullMap[numSorted - 1];
				Insert( gnum, numSorted);
			}
			todo--;
			numSorted++;
			continue;
		}
		
		if( Compare( fullMap[numSorted-1], gnum) <= 0)
			// Value too high, result already full - so ignore
			continue;

		// Candidate found. so insert it into cache.
//		fullMap[numSorted] = fullMap[numSorted - 1];
		Insert( gnum, numSorted);
//		numSorted++;
    }

	if(doneMap)
		delete[] doneMap;
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

errorT SortCache::GetSortingCrit( char *crit)
{
	for (int i=0; i<INDEX_MaxSortingCriteria, SortCriteria[i] != SORTING_sentinel; i++)
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

void SortCache::DoFullSort(int reportFrequency,
                           void (*progressFn)(void * data, uint progress, uint total),
                           void * progressData)
{
	numGames = index->GetNumGames();
	GetSpace(numGames);
	for (uint i=0; i<numGames; i++)
		fullMap[i] = i;
	HeapSort( reportFrequency, progressFn, progressData);
	numSorted = numGames;
	if (hashValues)
	{
		delete[] hashValues;
		hashValues = NULL;
	}
}

void SortCache::HeapSort(int reportFrequency,
                         void (*progressFn)(void * data, uint progress, uint total),
                         void * progressData)
{
	int tmp;
	for (int v=numGames/2-1; v>=0; v--)
		Downheap(v, numGames);

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
                (*progressFn) (progressData, progressCounter, n);
            }
            reportAfter = reportFrequency;
        }
    }
    if (progressFn != NULL) {
        (*progressFn) (progressData, 1, 1);
    }
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


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::Compare():
//      Compare two index entries according to sort criteria.
//      The parameter criteria is an array of integers denoting
//      sorting criteria (SORTING_date, SORTING_white, etc), terminated by
//      the value SORTING_sentinel.
//
inline int
SortCache::Compare (uint left, uint right)
{
	if( doHashing && hashValues)
	{
		if(partialHashing && hashValues[left] == hashValues[right])
			return FullCompare( left, right);
		return hashValues[left] - hashValues[right];
	}
	else
		return FullCompare( left, right);
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
			res = strCompare (ie1->GetWhiteName (nbase), ie2->GetWhiteName (nbase));
			break;

		case SORTING_black:
			res = strCompare (ie1->GetBlackName (nbase), ie2->GetBlackName (nbase));
			break;

		case SORTING_event:
			res = strCompare (ie1->GetEventName (nbase), ie2->GetEventName (nbase));
			break;

		case SORTING_site:
			res = strCompare (ie1->GetSiteName (nbase), ie2->GetSiteName (nbase));
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
				res = strCompare (sOne, sTwo);
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
	uint result = *strVal * 16777216;
	if( strVal[1])
	{
		result += *(strVal+1) * 65536;
		if( strVal[2])
			result += *(strVal+2) * 256 + *(strVal+3);
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


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::ParseSortCriteria():
//      Parses a list of names into a corresponding array of
//      integers denoting sorting criteria.
//      Used for parsing sort criteria, e.g.:
//      "-Sdate,event,white" --> { SORTING_date, SORTING_event, SORTING_white }
//      The final element is set to SORTING_sentinel.
//
//      If an error occurs, ERROR is returned and ErrorMsg is set to
//      an appropriate error message.
//
errorT
SortCache::ParseSortCriteria (const char * inputStr)
{
	int numOFArgs = strlen( inputStr) / 2;
    if (numOFArgs >= (INDEX_MaxSortCriteria - 1)) 
	{
	    SortCriteria[numOFArgs] = SORTING_sentinel;
        ErrorMsg = strDuplicate ( "Error: Too many fields in sort criteria!");
        return ERROR_Full;
	}

	for( int i=0; i<numOFArgs; i++)
	{
		char key = inputStr[2*i];
		SortCriteria[i] = SORTING_sentinel;
		for( int j=0; shortCriteriaNames[j][0] != 0; j++)
		{
			if( key == shortCriteriaNames[j][0])
			{
				SortCriteria[i] = shortCriteriaNames[j][1];
				SortReverse[i] = inputStr[2*i+1] == '-';
				break;
			}
		}
		if( SortCriteria[i] == SORTING_sentinel)
		{
            sprintf (ErrorMsg, "Error: invalid character in sort field list: \"%c\"", key);
	        return ERROR_Full;
		}
	}
    SortCriteria[numOFArgs] = SORTING_sentinel;

	if(doHashing)
	{
		if(hashValues)
			delete[] hashValues;
		hashValues = new uint[numGames];
		for( int i=0; i<numGames; i++)
			hashValues[i] = CalcHash(index->FetchEntry(i));
	}

	lastStart = IDX_NOT_FOUND;
	return OK;
}


errorT
SortCache::CheckForChanges ( int *criteria)
{
	return CheckForChanges ( criteria, IDX_NOT_FOUND);
}

errorT
SortCache::CheckForChanges ( int *criteria, uint id)
{
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

		int sortedField = -1;
		for( int i=0; i<numSorted; i++)
			if( fullMap[i] == id)
			{
				sortedField = i;
				break;
			}
		if( sortedField == -1)
			return OK;
		bool hasProblem = false;
		Recalc( sortedField);
	}
	else
	{
		if( hashValues)
			for( int i=0; i<numGames; i++)
				hashValues[i] = CalcHash( index->FetchEntry( i));
		numSorted = 0;
		if( doPresorting)
		{
			delete[] fullMap;
			DoFullSort( 9, NULL, NULL);
		}
	}

	return OK;
}

errorT SortCache::Recalc( uint sortedField)
{
	uint id = fullMap[ sortedField];
	for( uint i=sortedField; i<numSorted - 1; i++)
		fullMap[i] = fullMap[i + 1];
	if( doPresorting)
	{
		Insert( id, numGames - 1);
	}
	else
	{
		numSorted--;
	}
	return OK;
}

errorT SortCache::AddEntry()
{
    if (hashValues != NULL) {
		uint *oldMap = hashValues;
		fullMap = new uint[numGames + 1];
		memcpy( hashValues, oldMap, numGames * 4);
		delete[] oldMap;
		hashValues[numGames] = CalcHash( index->FetchEntry( numGames));
	}
	if( doPresorting)
	{
		GetSpace( numGames + 1);
		Insert( numGames, numGames);
		numSorted++;
	}
	else
	{
		if( Compare( numGames, numSorted-1) > 0)
			Insert( numGames, numSorted-1);
	}
	numGames++;
	return OK;
}

void SortCache::FilterChanged()
{
	lastStart = IDX_NOT_FOUND;
}

uint SortCache::IndexToFilteredCount( uint gnumber, Filter *filter)
{
	if( !doPresorting)
		return 0;
	uint filterCount = 0;
	for( uint i=0; i<numSorted; i++)
		if( filter->Get( fullMap[i]))
		{
			if( fullMap[i] == gnumber)
				return filterCount;
			filterCount++;
		}
	return 0; 
}

errorT SortCache::WriteToFile ()
{
	FILE *fp;
	char fileName[256];

	if( numSorted < numGames)
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

	for( int i=0; i<INDEX_MaxSortingCriteria; i++)
	{
		writeOneByte( fp, SortCriteria[i]);
		writeOneByte( fp, SortReverse[i]);
	}
	fwrite( fullMap, 4, numSorted, fp);
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

errorT SortCache::ReadFromFile ()
{
	FILE *fp;
	char fileName[256];

	strcpy( fileName, index->GetFileName());
	strcpy( fileName + strlen(fileName), ".ssc");
	fp = fopen( fileName, "rb");
	if(fp == NULL)
	{
		return OK;
	}

	fseek( fp, 0, SEEK_END); 
	long size = ftell( fp);
	fseek( fp, 0, SEEK_SET);
	if( size != 2*INDEX_MaxSortingCriteria + numGames * 4)
	{
		return OK;
	}

	doPresorting = true;
	partialHashing = false;
	if(hashValues)
	{
		delete[] hashValues;
		hashValues = NULL;
	}
	GetSpace(numGames);
	numGames = index->GetNumGames();
	numSorted = numGames;
	lastStart = IDX_NOT_FOUND;
	for( int i=0; i<INDEX_MaxSortingCriteria; i++)
	{
		SortCriteria[i] = readOneByte( fp);
		SortReverse[i] = readOneByte( fp);
	}
	fread( fullMap, 4, numSorted, fp);

	fclose(fp);
    return OK;
}

void SortCache::ReleaseCount()
{
	refCount--;
}

void SortCache::AddCount()
{
	refCount++;
}

int SortCache::GetReferenceCount()
{
	return refCount;
}

bool SortCache::GetDoPresorting()
{
	return doPresorting;
}

uint SortCache::GetNumSorted()
{
	return numSorted;
}

bool SortCache::MatchCriteria( const char *crit)
{

	int numOFArgs = strlen( crit) / 2;
    if (numOFArgs >= (INDEX_MaxSortCriteria - 1)) 
		return false;

	int i;
	for( i=0; i<numOFArgs; i++)
	{
		char key = crit[2*i];
		byte v = SORTING_sentinel;
		bool r;

		if( SortCriteria[i] == SORTING_sentinel)
			return false;
		for( int j=0; shortCriteriaNames[j][0] != 0; j++)
		{
			if( key == shortCriteriaNames[j][0])
			{
				v = shortCriteriaNames[j][1];
				r = crit[2*i+1] == '-';
				break;
			}
		}
		if(v == SORTING_sentinel || SortCriteria[i] != v || SortReverse[i] != r)
			return false;
	}
	return true;
}
