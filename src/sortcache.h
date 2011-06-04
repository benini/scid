#ifndef SORTINGCACHE_DEFINED
#define SORTINGCACHE_DEFINED

#include "filter.h"
#include "index.h"

class Index;
class IndexEntry;

static const uint INDEX_MaxSortingCriteria = 16;
static const uint IDX_NOT_FOUND = 0xffffffff;

class SortCache
{
  private:

	Index *index;
	bool doPresorting;
	bool doHashing;
	bool partialHashing;
	bool keep;
	uint numSorted;
	uint numGames;
    uint *fullMap;
	uint mapSize;
    uint *hashValues;
	NameBase *nbase;
    byte SortCriteria [INDEX_MaxSortingCriteria];
    bool SortReverse [INDEX_MaxSortingCriteria];
    char *ErrorMsg;
	uint lastStart;
	uint lastIndex;
	uint lastCount;
	Filter *lastFilter;
	int refCount;

	inline int Compare (uint left, uint right);
	int FullCompare (uint left, uint right);
	void sortUpto( uint idx, Filter *filter);
    errorT ParseSortCriteria (const char *inputStr);
	void GetSpace( uint size);
	uint CalcHash (IndexEntry *ie);
	void HeapSort(int reportFrequency,
                  void (*progressFn)(void * data, uint progress, uint total),
                  void * progressData);
	void Downheap( int v, int n);
	inline uint GetStartHash (const char *strVal);
	errorT Recalc( uint sortedField);
	uint Insert( uint gnum, uint done);

  public:

	SortCache( Index *idx, NameBase * nb, const char *criterium, bool preSort, bool hash);
	~SortCache();
	void Clear( const char *criterium, bool doPreSort);
    char *ErrorMessage() { return ErrorMsg; }

	errorT GetSortingCrit( char *crit);
    void DoFullSort(int reportFrequency,
                    void (*progressFn)(void * data, uint progress, uint total),
                    void * progressData);

	errorT GetIndex( uint idx, Filter *filter, uint *result);
    errorT GetRange( uint start, uint count, Filter *filter, uint *result);

	errorT CheckForChanges ( int *criteria);
	errorT CheckForChanges ( int *criteria, uint id);
	errorT AddEntry();
	uint IndexToFilteredCount( uint gnumber, Filter *filter);
	void FilterChanged();
	errorT WriteToFile ();
	errorT ReadFromFile ();
	void ReleaseCount();
	void AddCount();
	int GetReferenceCount();
	bool GetDoPresorting();
	uint GetNumSorted();
	bool MatchCriteria( const char *crit);
	static bool CanLoad( char *fName, uint numGames);
};

#endif