#include "glaurung.h"
#ifdef WIN32
#include <windows.h>
#endif

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

  // No buffering, please...
//   setbuf(stdout, NULL);
//   setbuf(stdin, NULL);
  // and I *really* mean it, too!
//   setvbuf(stdout, NULL, _IONBF, 0);
//   setvbuf(stdin, NULL, _IONBF, 0);

  init();
  uci_main_loop();
  return 0;
}
