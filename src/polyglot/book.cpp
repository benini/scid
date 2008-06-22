
// book.cpp

// includes

#include <cerrno>
#include <cstdio>
//#include <cstdlib>
#include <cstring>

#include "board.h"
#include "book.h"
#include "move.h"
#include "move_legal.h"
#include "san.h"
#include "util.h"

// types

struct entry_t {
   uint64 key;
   uint16 move;
   uint16 count;
   uint16 n;
   uint16 sum;
};

// variables
#ifdef WINCE
static Tcl_Channel BookFile[MaxBook];
#else
static FILE * BookFile[MaxBook];
#endif

static int BookSize[MaxBook];

// prototypes

static int    find_pos      (uint64 key, const int BookNumber);

static void   read_entry    (entry_t * entry, int n, const int BookNumber);
static void   write_entry   (const entry_t * entry, int n, const int BookNumber);

#ifdef WINCE
static uint64 read_integer  (Tcl_Channel file, int size);
static void   write_integer (Tcl_Channel file, int size, uint64 n);
#else
static uint64 read_integer  (FILE * file, int size);
static void   write_integer (FILE * file, int size, uint64 n);
#endif

// functions

// =================================================================
// Pascal Georges : functions added to interface with Scid
// =================================================================
board_t scid_board[MaxBook][1]; 
void scid_book_update(char * probs, const int BookNumber) {
 
  int first_pos;
   int sum;
   int pos;
   entry_t entry[1];
	 int prob[100];
	 int prob_count = 0;
	 int prob_sum = 0;
	 int i;
	 
	 /* parse probs and fill prob array */
	 char *s;
	 
	 s = strtok( probs, " " );
	 sscanf( s, "%d", &(prob[prob_count]) );
	 prob_count++;
	 while ( (s = strtok(NULL, " ")) != NULL) {
	 	sscanf( s, "%d", &(prob[prob_count]) );
	 	prob_count++;
	 }
 	 
   first_pos = find_pos(scid_board[BookNumber]->key, BookNumber);

   // sum

   sum = 10000;

    for (i=0; i< prob_count; i++)
      prob_sum += prob[i];
    double coef = double(sum)/double(prob_sum);

	 i = 0;
   for (pos = first_pos; pos < BookSize[BookNumber] && i < prob_count; pos++) {
      read_entry(entry,pos,BookNumber);
      if (entry->key != scid_board[BookNumber]->key) break;
			// change entry weight : no entry count == 0
      if (prob[i] != 0) {
			 entry->count = int( double(prob[i]) * coef );
      } else {
        entry->count = 1;
      }
			i++;
			write_entry( entry, pos, BookNumber );
   }
}

// =================================================================
int scid_book_close(const int BookNumber) {
	if (BookFile[BookNumber] != NULL) {
#ifdef WINCE
    if (my_Tcl_Close(NULL, BookFile[BookNumber]) != TCL_OK) {
#else
    if (fclose(BookFile[BookNumber]) == EOF) {
#endif
      return -1;
   	}


	}
	return 0;
}
// =================================================================
int scid_book_open(const char file_name[], const int BookNumber) {

#ifdef WINCE
   BookFile[BookNumber] = my_Tcl_OpenFileChannel(NULL, file_name, "r+", 0666);
#else
   BookFile[BookNumber] = fopen(file_name,"rb+");
#endif

   if (BookFile[BookNumber] == NULL) return -1;

#ifdef WINCE
   my_Tcl_SetChannelOption(NULL, BookFile[BookNumber], "-encoding", "binary");
   my_Tcl_SetChannelOption(NULL, BookFile[BookNumber], "-translation", "binary");
    if (my_Tcl_Seek(BookFile[BookNumber], 0, SEEK_END) == -1) 
      return -1;
#else
   if (fseek(BookFile[BookNumber],0,SEEK_END) == -1) {
      return -1;
   }
#endif

#ifdef WINCE
    BookSize[BookNumber] = my_Tcl_Tell(BookFile[BookNumber]) / 16;
#else
    BookSize[BookNumber] = ftell(BookFile[BookNumber]) / 16;
#endif
   if (BookSize[BookNumber] == 0) return -1;
   return 0; //success
}
// =================================================================
int scid_book_disp(const board_t * board, char * s, const int BookNumber) {

   int first_pos;
   int sum;
   int pos;
   entry_t entry[1];
   int move;
   int score;
   char move_string[256];
	 char tmp[256];
	 
	 // keep board in memory to ease book update	 
	 memcpy(scid_board[BookNumber], board, sizeof(board_t));
	 	  	 
   first_pos = find_pos(board->key, BookNumber);

   // sum

   sum = 0;

   for (pos = first_pos; pos < BookSize[BookNumber]; pos++) {

      read_entry(entry,pos,BookNumber);
      if (entry->key != board->key) break;
      sum += entry->count;
   }

   // disp
	 s[0] = '\0';
   for (pos = first_pos; pos < BookSize[BookNumber]; pos++) {

      read_entry(entry,pos,BookNumber);
      if (entry->key != board->key) break;

      move = entry->move;
      score = entry->count;

      if (score > 0 && move != MoveNone && move_is_legal(move,board)) {
         move_to_san(move,board,move_string,256);
         sprintf(tmp, " %s %.0f%%",move_string,(double(score)/double(sum))*100.0);
      }
      strcat(s, tmp);
   }

	return 0;
}

// =================================================================

// book_clear()

void book_clear(const int BookNumber) {

   BookFile[BookNumber] = NULL;
   BookSize[BookNumber] = 0;
}

// book_open()

void book_open(const char file_name[], const int BookNumber) {

   ASSERT(file_name!=NULL);

#ifdef WINCE
   BookFile[BookNumber] = my_Tcl_OpenFileChannel(NULL, file_name, "r+", 0666);
   my_Tcl_SetChannelOption(NULL, BookFile[BookNumber], "-encoding", "binary");
   my_Tcl_SetChannelOption(NULL, BookFile[BookNumber], "-translation", "binary");
#else
   BookFile[BookNumber] = fopen(file_name,"rb+");
#endif

   if (BookFile[BookNumber] == NULL) my_fatal("book_open(): can't open file \"%s\": %s\n",file_name,strerror(errno));


#ifdef WINCE
    if (my_Tcl_Seek(BookFile[BookNumber], 0, SEEK_END) == -1) {
#else
   if (fseek(BookFile[BookNumber],0,SEEK_END) == -1) {
#endif
      my_fatal("book_open(): fseek(): %s\n",strerror(errno));
   }

#ifdef WINCE
    BookSize[BookNumber] = my_Tcl_Tell(BookFile[BookNumber]) / 16;
#else
    BookSize[BookNumber] = ftell(BookFile[BookNumber]) / 16;
#endif

   if (BookSize[BookNumber] == 0) my_fatal("book_open(): empty file\n");
}

// book_close()

void book_close(const int BookNumber) {
#ifdef WINCE
    if (my_Tcl_Close(NULL, BookFile[BookNumber]) != TCL_OK) {
#else
    if (fclose(BookFile[BookNumber]) == EOF) {
#endif
      my_fatal("book_close(): fclose(): %s\n",strerror(errno));
   }
}

// is_in_book()

bool is_in_book(const board_t * board, const int BookNumber) {

   int pos;
   entry_t entry[1];

   ASSERT(board!=NULL);

   for (pos = find_pos(board->key, BookNumber); pos < BookSize[BookNumber]; pos++) {
      read_entry(entry,pos,BookNumber);
      if (entry->key == board->key) return true;
   }

   return false;
}

// book_move()

int book_move(const board_t * board, bool random, const int BookNumber) {

   int best_move;
   int best_score;
   int pos;
   entry_t entry[1];
   int move;
   int score;

   ASSERT(board!=NULL);
   ASSERT(random==true||random==false);

   best_move = MoveNone;
   best_score = 0;

   for (pos = find_pos(board->key, BookNumber); pos < BookSize[BookNumber]; pos++) {

      read_entry(entry,pos, BookNumber);
      if (entry->key != board->key) break;

      move = entry->move;
      score = entry->count;

      if (move != MoveNone && move_is_legal(move,board)) {

         // pick this move?

         ASSERT(score>0);

         if (random) {
            best_score += score;
            if (my_random_int(best_score) < score) best_move = move;
         } else {
            if (score > best_score) {
               best_move = move;
               best_score = score;
            }
         }

      } else {

         ASSERT(false);
      }
   }

   return best_move;
}

// book_disp()

void book_disp(const board_t * board, const int BookNumber) {

   int first_pos;
   int sum;
   int pos;
   entry_t entry[1];
   int move;
   int score;
   char move_string[256];

   ASSERT(board!=NULL);

   first_pos = find_pos(board->key, BookNumber);

   // sum

   sum = 0;

   for (pos = first_pos; pos < BookSize[BookNumber]; pos++) {

      read_entry(entry,pos, BookNumber);
      if (entry->key != board->key) break;

      sum += entry->count;
   }

   // disp

   for (pos = first_pos; pos < BookSize[BookNumber]; pos++) {

      read_entry(entry,pos, BookNumber);
      if (entry->key != board->key) break;

      move = entry->move;
      score = entry->count;

      if (score > 0 && move != MoveNone && move_is_legal(move,board)) {
         move_to_san(move,board,move_string,256);
         printf(" %s (%.0f%%)\n",move_string,(double(score)/double(sum))*100.0);
      }
   }

   printf("\n");
}

// book_learn_move()

void book_learn_move(const board_t * board, int move, int result, const int BookNumber) {

   int pos;
   entry_t entry[1];

   ASSERT(board!=NULL);
   ASSERT(move_is_ok(move));
   ASSERT(result>=-1&&result<=+1);

   ASSERT(move_is_legal(move,board));

   for (pos = find_pos(board->key, BookNumber); pos < BookSize[BookNumber]; pos++) {

      read_entry(entry,pos,BookNumber);
      if (entry->key != board->key) break;

      if (entry->move == move) {

         entry->n++;
         entry->sum += result+1;

         write_entry(entry,pos, BookNumber);

         break;
      }
   }
}

// book_flush()

void book_flush(const int BookNumber) {
#ifdef WINCE
   if (my_Tcl_Flush(BookFile[BookNumber]) != TCL_OK) {
#else
   if (fflush(BookFile[BookNumber]) == EOF) {
#endif
      my_fatal("book_flush(): fflush(): %s\n",strerror(errno));
   }
}

// find_pos()

static int find_pos(uint64 key, const int BookNumber) {

   int left, right, mid;
   entry_t entry[1];

   // binary search (finds the leftmost entry)

   left = 0;
   right = BookSize[BookNumber]-1;

   ASSERT(left<=right);

   while (left < right) {

      mid = (left + right) / 2;
      ASSERT(mid>=left&&mid<right);

      read_entry(entry,mid,BookNumber);

      if (key <= entry->key) {
         right = mid;
      } else {
         left = mid+1;
      }
   }

   ASSERT(left==right);

   read_entry(entry,left,BookNumber);

   return (entry->key == key) ? left : BookSize[BookNumber];
}

// read_entry()

static void read_entry(entry_t * entry, int n, const int BookNumber) {
   ASSERT(entry!=NULL);
   ASSERT(n>=0&&n<BookSize[BookNumber]);
#ifdef WINCE
    if (my_Tcl_Seek(BookFile[BookNumber], n*16,SEEK_SET) == -1) {
#else
   if (fseek(BookFile[BookNumber],n*16,SEEK_SET) == -1) {
#endif
      my_fatal("read_entry(): fseek(): %s\n",strerror(errno));
   }

   entry->key   = read_integer(BookFile[BookNumber],8);
   entry->move  = read_integer(BookFile[BookNumber],2);
   entry->count = read_integer(BookFile[BookNumber],2);
   entry->n     = read_integer(BookFile[BookNumber],2);
   entry->sum   = read_integer(BookFile[BookNumber],2);
}

// write_entry()

static void write_entry(const entry_t * entry, int n, const int BookNumber) {

   ASSERT(entry!=NULL);
   ASSERT(n>=0&&n<BookSize[BookNumber]);
#ifdef WINCE
   if (my_Tcl_Seek(BookFile[BookNumber],n*16,SEEK_SET) == -1) {
#else
   if (fseek(BookFile[BookNumber],n*16,SEEK_SET) == -1) {
#endif
      my_fatal("write_entry(): fseek(): %s\n",strerror(errno));
   }

   write_integer(BookFile[BookNumber],8,entry->key);
   write_integer(BookFile[BookNumber],2,entry->move);
   write_integer(BookFile[BookNumber],2,entry->count);
   write_integer(BookFile[BookNumber],2,entry->n);
   write_integer(BookFile[BookNumber],2,entry->sum);
}

// read_integer()
#ifdef WINCE
static uint64 read_integer(Tcl_Channel file, int size) {
#else
static uint64 read_integer(FILE * file, int size) {
#endif
   uint64 n;
   int i;
   int b;
   unsigned char c;
   ASSERT(file!=NULL);
   ASSERT(size>0&&size<=8);

   n = 0;

   for (i = 0; i < size; i++) {

#ifdef WINCE
      my_Tcl_Read(file, (char *)&c , 1);
      b = c;
#else
      b = fgetc(file);
      if (b == EOF) {
         if (feof(file)) {
            my_fatal("read_integer(): fgetc(): EOF reached\n");
         } else { // error
            my_fatal("read_integer(): fgetc(): %s\n",strerror(errno));
         }
      }
#endif

      ASSERT(b>=0&&b<256);
      n = (n << 8) | b;
   }

   return n;
}

// write_integer()
#ifdef WINCE
static void write_integer(Tcl_Channel file, int size, uint64 n) {
#else
static void write_integer(FILE * file, int size, uint64 n) {
#endif
   int i;
   int b;
   unsigned char c;
   ASSERT(file!=NULL);
   ASSERT(size>0&&size<=8);
   ASSERT(size==8||n>>(size*8)==0);

   for (i = size-1; i >= 0; i--) {

      b = (n >> (i*8)) & 0xFF;
      ASSERT(b>=0&&b<256);
#ifdef WINCE
      c = b;
      if (my_Tcl_Write(file, (char*) &c, 1) != 1) {
#else
      if (fputc(b,file) == EOF) {
#endif
         my_fatal("write_integer(): fputc(): %s\n",strerror(errno));
      }
   }
}

// end of book.cpp

