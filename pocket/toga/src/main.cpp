
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
#include "posix.h"
#include "protocol.h"
#include "random.h"
#include "square.h"
#include "trans.h"
#include "util.h"
#include "value.h"
#include "vector.h"

#ifdef WIN32
#include <windows.h>
#endif

// functions

// main()
#ifdef WIN32
int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow) {
#else
int main(int argc, char * argv[]) {
#endif

   // init
	 if (init_socket() != 0) {
	 	return 1;
	 }
   util_init();
   my_random_init(); // for opening book

   send_msg("%s\n", "Toga II 1.2.1a UCI based on Fruit 2.1 by Thomas Gaksch and Fabien Letouzey. Settings by Dieter Eberle\n");

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

  loop();
  return EXIT_SUCCESS;
}

// end of main.cpp

