
// book.h

#ifndef BOOK_H
#define BOOK_H

// includes

#include "board.h"
#include "util.h"

#ifdef WINCE
#include <tcl.h>
#endif

// constants
const int MaxBook = 4;

// functions

extern void book_clear      (const int BookNumber);

extern void book_open       (const char file_name[], const int BookNumber);
extern void book_close      (const int BookNumber);
extern int scid_book_open       (const char file_name[], const int BookNumber);
extern int scid_book_close      (const int BookNumber);
extern int scid_book_disp      (const board_t * board, char * s, const int BookNumber);

extern bool is_in_book      (const board_t * board, const int BookNumber);
extern int  book_move       (const board_t * board, bool random, const int BookNumber);
extern void book_disp       (const board_t * board, const int BookNumber);

extern void book_learn_move (const board_t * board, int move, int result, const int BookNumber);
extern void book_flush      (const int BookNumber);
extern void scid_book_update			(char * probs, const int BookNumber);

#endif // !defined BOOK_H

// end of book.h

