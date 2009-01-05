
// book_merge.cpp

// includes

#include <cerrno>
#include <cstdio>
//#include <cstdlib>
#include <cstring>

#include "book_merge.h"
#include "util.h"

// types

struct book_t {
#ifdef WINCE
   Tcl_Channel file;
#else
   FILE * file;
#endif
   int size;
};

struct entry_t {
   uint64 key;
   uint16 move;
   uint16 count;
   uint16 n;
   uint16 sum;
};

// variables

static book_t In1[1];
static book_t In2[1];
static book_t Out[1];

// prototypes

static void   book_clear    (book_t * book);

static void   book_open     (book_t * book, const char file_name[], const char mode[]);
static void   book_close    (book_t * book);

static bool   read_entry    (book_t * book, entry_t * entry, int n);
static void   write_entry   (book_t * book, const entry_t * entry);
#ifdef WINCE
static uint64 read_integer  (Tcl_Channel file, int size);
static void   write_integer (Tcl_Channel file, int size, uint64 n);
#else
static uint64 read_integer  (FILE * file, int size);
static void   write_integer (FILE * file, int size, uint64 n);
#endif
// functions

// book_merge()

void book_merge(int argc, char * argv[]) {

   int i;
   const char * in_file_1;
   const char * in_file_2;
   const char * out_file;
   int i1, i2;
   bool b1, b2;
   entry_t e1[1], e2[1];
   int skip;

   in_file_1 = NULL;
   my_string_clear(&in_file_1);

   in_file_2 = NULL;
   my_string_clear(&in_file_2);

   out_file = NULL;
   my_string_set(&out_file,"out.bin");

   for (i = 1; i < argc; i++) {

      if (false) {

      } else if (my_string_equal(argv[i],"merge-book")) {

         // skip

      } else if (my_string_equal(argv[i],"-in1")) {

         i++;
         if (argv[i] == NULL) my_fatal("book_merge(): missing argument\n");

         my_string_set(&in_file_1,argv[i]);

      } else if (my_string_equal(argv[i],"-in2")) {

         i++;
         if (argv[i] == NULL) my_fatal("book_merge(): missing argument\n");

         my_string_set(&in_file_2,argv[i]);

      } else if (my_string_equal(argv[i],"-out")) {

         i++;
         if (argv[i] == NULL) my_fatal("book_merge(): missing argument\n");

         my_string_set(&out_file,argv[i]);

      } else {

         my_fatal("book_merge(): unknown option \"%s\"\n",argv[i]);
      }
   }

   book_clear(In1);
   book_clear(In2);
   book_clear(Out);

   book_open(In1,in_file_1,"rb");
   book_open(In2,in_file_2,"rb");
   book_open(Out,out_file,"wb");

   skip = 0;

   i1 = 0;
   i2 = 0;

   while (true) {

      b1 = read_entry(In1,e1,i1);
      b2 = read_entry(In2,e2,i2);

      if (false) {

      } else if (!b1 && !b2) {

         break;

      } else if (b1 && !b2) {

         write_entry(Out,e1);
         i1++;

      } else if (b2 && !b1) {

         write_entry(Out,e2);
         i2++;

      } else {

         ASSERT(b1);
         ASSERT(b2);

         if (false) {
         } else if (e1->key < e2->key) {
            write_entry(Out,e1);
            i1++;
         } else if (e1->key > e2->key) {
            write_entry(Out,e2);
            i2++;
         } else {
            ASSERT(e1->key==e2->key);
            skip++;
            i2++;
         }
      }
   }

   book_close(In1);
   book_close(In2);
   book_close(Out);

   if (skip != 0) {
      printf("skipped %d entr%s.\n",skip,(skip>1)?"ies":"y");
   }

   printf("done!\n");
}

// book_clear()

static void book_clear(book_t * book) {

   ASSERT(book!=NULL);

   book->file = NULL;
   book->size = 0;
}

// book_open()

static void book_open(book_t * book, const char file_name[], const char mode[]) {

   ASSERT(book!=NULL);
   ASSERT(file_name!=NULL);
   ASSERT(mode!=NULL);
#ifdef WINCE
   book->file = my_Tcl_OpenFileChannel(NULL, file_name, mode, 0666);
   my_Tcl_SetChannelOption(NULL, book->file, "-encoding", "binary");
   my_Tcl_SetChannelOption(NULL, book->file, "-translation", "binary");
#else
   book->file = fopen(file_name,mode);
#endif

   if (book->file == NULL) my_fatal("book_open(): can't open file \"%s\": %s\n",file_name,strerror(errno));

#ifdef WINCE
    if (my_Tcl_Seek(book->file,0,SEEK_END) == -1)
      my_fatal("book_open(): fseek(): %s\n",strerror(errno));
#else
   if (fseek(book->file,0,SEEK_END) == -1) {
      my_fatal("book_open(): fseek(): %s\n",strerror(errno));
   }
#endif

#ifdef WINCE
   book->size = my_Tcl_Tell(book->file) / 16;
#else
   book->size = ftell(book->file) / 16;
#endif

}

// book_close()

static void book_close(book_t * book) {

   ASSERT(book!=NULL);

#ifdef WINCE
    if (my_Tcl_Close(NULL, book->file) != TCL_OK) {
#else
   if (fclose(book->file) == EOF) {
#endif
      my_fatal("book_close(): fclose(): %s\n",strerror(errno));
   }

}

// read_entry()

static bool read_entry(book_t * book, entry_t * entry, int n) {

   ASSERT(book!=NULL);
   ASSERT(entry!=NULL);

   if (n < 0 || n >= book->size) return false;

   ASSERT(n>=0&&n<book->size);

#ifdef WINCE
    if (my_Tcl_Seek(book->file,n*16,SEEK_SET) == -1) {
#else
   if (fseek(book->file,n*16,SEEK_SET) == -1) {
#endif
      my_fatal("read_entry(): fseek(): %s\n",strerror(errno));
   }

   entry->key   = read_integer(book->file,8);
   entry->move  = read_integer(book->file,2);
   entry->count = read_integer(book->file,2);
   entry->n     = read_integer(book->file,2);
   entry->sum   = read_integer(book->file,2);

   return true;
}

// write_entry()

static void write_entry(book_t * book, const entry_t * entry) {

   ASSERT(book!=NULL);
   ASSERT(entry!=NULL);

   write_integer(book->file,8,entry->key);
   write_integer(book->file,2,entry->move);
   write_integer(book->file,2,entry->count);
   write_integer(book->file,2,entry->n);
   write_integer(book->file,2,entry->sum);
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

   ASSERT(file!=NULL);
   ASSERT(size>0&&size<=8);

   n = 0;

   for (i = 0; i < size; i++) {

#ifdef WINCE
      unsigned char c;
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

   ASSERT(file!=NULL);
   ASSERT(size>0&&size<=8);
   ASSERT(size==8||n>>(size*8)==0);

   for (i = size-1; i >= 0; i--) {

      b = (n >> (i*8)) & 0xFF;
      ASSERT(b>=0&&b<256);


#ifdef WINCE
      unsigned char c;
      c = b;
      if (my_Tcl_Write(file, (char*) &c, 1) != 1) {
#else
      if (fputc(b,file) == EOF) {
#endif
         my_fatal("write_integer(): fputc(): %s\n",strerror(errno));
      }
   }
}

// end of book_merge.cpp

