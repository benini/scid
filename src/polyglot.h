#ifndef POLYGLOT_H
#define POLYGLOT_H

#include <vector>

int polyglot_open			(const char * BookFile, const int BookNumber);
int polyglot_close		(const int BookNumber);

std::vector<std::tuple<int16_t, uint8_t, uint8_t>>
polyglot_moves(char* moves, const char* fen, const int BookNumber);

int polyglot_positions	(char *moves, const char *fen, const int BookNumber);
void scid_book_update	(char * probs, const int BookNumber);
int scid_book_movesupdate  (char *moves, char * probs, const int BookNumber, char *tempfile);

#endif
