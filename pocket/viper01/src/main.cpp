#include "viper.h"

int main(void) {
  // No buffering, please...
//   setbuf(stdout, NULL);
//   setbuf(stdin, NULL);
  // and I *really* mean it, too!
//   setvbuf(stdout, NULL, _IONBF, 0);
//   setvbuf(stdin, NULL, _IONBF, 0);


   // init
   if (init_socket() != 0) {
    return 1;
   }

  init();
  uci_main_loop();
  return 0;
}
