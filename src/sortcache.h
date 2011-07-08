#ifndef SORTINGCACHE_DEFINED
#define SORTINGCACHE_DEFINED

#include "filter.h"
#include "index.h"
#include <string>

class Index;
class IndexEntry;

static const uint INDEX_MaxSortingCriteria = 16;
static const uint IDX_NOT_FOUND = 0xffffffff;

class SortCache
{
  public:
	static SortCache* Create(Index* idx, NameBase* nb, const char* criterium, bool multithread =true);
	~SortCache();
	char *ErrorMessage() { return ErrorMsg; }
	errorT GetRange( uint start, uint count, Filter *filter, uint *result);
	uint IndexToFilteredCount( uint gnumber, Filter *filter);
	errorT CheckForChanges ( int *criteria, uint id);
	void FilterChanged();
	bool MatchCriteria( const std::string& crit) { return crit == criteria; }
	void DoFullSort(int reportFrequency,
                    void (*progressFn)(void * data, uint progress, uint total),
                    void * progressData);
	int ReleaseCount() { return --refCount; }
	int AddCount() { return ++refCount; }

	static bool CanLoad( char *fName, uint numGames);
	errorT WriteToFile ();
	static SortCache* CreateFromFile(Index* idx, NameBase* nb);
	errorT GetSortingCrit( char *crit);

  private:
	Index *index;
	bool partialHashing;
	bool sorted_;
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
	Filter *lastFilter;
	int refCount;
	std::string criteria;

	SortCache();
	errorT Init (Index *idx, NameBase * nb, const char *criterium);
	inline int Compare (uint left, uint right);
	int FullCompare (uint left, uint right);
	void GetSpace( uint size);
	uint CalcHash (IndexEntry *ie);
	void Downheap( int v, int n);
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
		bool interrupt_;
		void sort(uint numGames);
	};
	Sort_thread t_;
};

#endif
