#ifndef POLYGLOT_H
#define POLYGLOT_H

int polyglot_open			(const char * BookFile, const int BookNumber);
int polyglot_close		(const int BookNumber);
int polyglot_moves		(char *moves, const char *fen, const int BookNumber);
void scid_book_update	(char * probs, const int BookNumber);

#endif
