
// main.cpp

// includes

#include <cstdio>
#include <cstdlib>

#include "attack.h"
#include "book.h"
#include "hash.h"
#include "move_do.h"
#include "option.h"
#include "pawn.h"
#include "piece.h"
#include "protocol.h"
#include "random.h"
#include "square.h"
#include "trans.h"
#include "util.h"
#include "value.h"
#include "vector.h"
#include "ipc.h"

#ifdef WIN32
#include <windows.h>
#endif

// functions

// main()

int main(int argc, char * argv[]) {

   // init
   if (init_socket() != 0) {
    return 1;
   }
   util_init();
   my_random_init(); // for opening book

   send_msg("Fruit 2.1 UCI by Fabien Letouzey\n");

   // early initialisation (the rest is done after UCI options are parsed in protocol.cpp)

   option_init();

   square_init();
   piece_init();
   pawn_init_bit();
   value_init();
   vector_init();
   attack_init();
   move_do_init();

   random_init();
   hash_init();

   trans_init(Trans);
   book_init();

   // loop

   loop();

   return EXIT_SUCCESS;
}

// end of main.cpp

