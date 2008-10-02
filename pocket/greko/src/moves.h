#ifndef MOVES_H
#define MOVES_H

#include <vector>
using namespace std;

#include "consts.h"
#include "position.h"

struct MoveEntry
{
	MoveEntry() {}
	MoveEntry(Move mv) : m_mv(mv) {}
	~MoveEntry() {}

	Move m_mv;
	EVAL m_value;
};

class MoveList
{
public:

	MoveList() {}
	~MoveList() {}

	Move operator[] (int n) const { return m_data[n].m_mv; }

	void Clear() { m_size = 0; }
	void AddSimpleChecks(const Position& pos);
	void GenAllMoves(const Position& pos);
	void GenAllMovesInCheck(const Position& pos);
	void GenCapturesAndPromotions(const Position& pos);
	Move GetNthBest(int n);
	int  Size() const { return m_size; }
	void UpdateScores(const Position& pos, Move hashmv, Move killermv);

private:

	inline void Add(FLD from, FLD to, PIECE piece)
	{
		m_data[m_size++].m_mv = Move(from, to, piece);
	}

	inline void Add(FLD from, FLD to, PIECE piece, PIECE captured)
	{
		m_data[m_size++].m_mv = Move(from, to, piece, captured);
	}

	inline void Add(FLD from, FLD to, PIECE piece, PIECE captured, PIECE promotion)
	{
		m_data[m_size++].m_mv = Move(from, to, piece, captured, promotion);
	}

	enum { MAX_SIZE = 256 };
	MoveEntry m_data[MAX_SIZE];
	int m_size;
};
////////////////////////////////////////////////////////////////////////////////

#endif
