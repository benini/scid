#include "glaurung.h"

#define MAX_UCI_OPTIONS 128

enum {UCI_SPIN, UCI_COMBO, UCI_CHECK, UCI_STRING, UCI_BUTTON};

struct uci_option_t {
  char name[64];
  char default_value[128], value[128];
  int type;
  int min, max;
  char combo_vars[16][32];
};

uci_option_t UCIOptions[MAX_UCI_OPTIONS];
int NumberOfUCIOptions = 0;

static void define_uci_option(char *name, char *default_value, int type, 
                               int min, int max, ...) {
  uci_option_t *u = UCIOptions + NumberOfUCIOptions;
  char *str;
  int i = 0;

  if(NumberOfUCIOptions == MAX_UCI_OPTIONS) {
    send_msg("Too many UCI options\n");
    quit();
  }
  
  strcpy(u->name, name);
  strcpy(u->default_value, default_value);
  strcpy(u->value, u->default_value);
  u->type = type; u->min = min; u->max = max;
         
  if(u->type == UCI_COMBO) {
    va_list arglist;
    va_start(arglist, max);
    do {
      str = va_arg(arglist, char *);
      if(str != NULL) strcpy(u->combo_vars[i++], str);
    } while(i < max);
    u->combo_vars[i][0] = '\0';
    va_end(arglist);
  }
  NumberOfUCIOptions++;
}

void define_uci_options(void) {
//  define_uci_option("Hash", "32", UCI_SPIN, 4, 1024);
// Pocket PC : Hash in kB
  define_uci_option("Hash", "64", UCI_SPIN, 64, 512);
  define_uci_option("Aggressiveness", "130", UCI_SPIN, 0, 300);
  define_uci_option("Cowardice", "100", UCI_SPIN, 0, 300);
  define_uci_option("Passed pawns (middle game)", "100", UCI_SPIN, 0, 300);
  define_uci_option("Passed pawns (endgame)", "140", UCI_SPIN, 0, 300);
  define_uci_option("Pawn structure (middle game)", "150", UCI_SPIN, 0, 300);
  define_uci_option("Pawn structure (endgame)", "150", UCI_SPIN, 0, 300);
  define_uci_option("Mobility (middle game)", "160", UCI_SPIN, 0, 300);
  define_uci_option("Mobility (endgame)", "150", UCI_SPIN, 0, 300);
  define_uci_option("Space", "100", UCI_SPIN, 0, 300);
  define_uci_option("Development", "130", UCI_SPIN, 0, 300);
//  define_uci_option("Static evaluation cache", "true", UCI_CHECK, 0, 0);
  define_uci_option("Static evaluation cache", "false", UCI_CHECK, 0, 0);
  define_uci_option("Static evaluation cache size", "4", UCI_SPIN, 1, 128);
  define_uci_option("Static null move pruning", "true", UCI_CHECK, 0, 0);
  define_uci_option("Static pruning depth", "3", UCI_SPIN, 1, 6);
  define_uci_option("Null move reduction factor (middle game)", "3", UCI_SPIN, 
                    1, 3);
  define_uci_option("Null move reduction factor (endgame)", "2", UCI_SPIN, 
                    1, 3);
  define_uci_option("Late move reductions", "All nodes", UCI_COMBO, 0, 3,
                    "All nodes", "Non-PV nodes", "Off");
  define_uci_option("Reduce based on", "Knowledge and history", UCI_COMBO, 0, 3,
                    "Knowledge", "History", "Knowledge and history");
  define_uci_option("Futility pruning", "Non-PV nodes", UCI_COMBO, 0, 3,
                    "All nodes", "Non-PV nodes", "Off");
  define_uci_option("Futility margin 0", "100", UCI_SPIN, 0, 1000);
  define_uci_option("Futility margin 1", "150", UCI_SPIN, 0, 1000);
  define_uci_option("Futility margin 2", "300", UCI_SPIN, 0, 1000);
  define_uci_option("Check extension", "60", UCI_SPIN, 0, 60);
  define_uci_option("One reply to check extension", "45", UCI_SPIN, 0, 60);
  define_uci_option("Two replies to check extension", "20", UCI_SPIN, 0, 60);
  define_uci_option("Mate threat extension", "45", UCI_SPIN, 0, 60);
  define_uci_option("Pawn push to 7th rank extension", "45", UCI_SPIN, 0, 60);
  define_uci_option("Threat depth", "5", UCI_SPIN, 0, 20);
  define_uci_option("Checks in quiescence search", "3", UCI_SPIN, 0, 20);
  define_uci_option("Hash quiescence search", "true", UCI_CHECK, 0, 0);
  define_uci_option("Position learning", "false", UCI_CHECK, 0, 0);
  define_uci_option("Clear position learning", "false", UCI_BUTTON, 0, 0);
  if(MaxNumOfThreads > 1) {
    define_uci_option("Number of threads", "2", UCI_SPIN, 1, MaxNumOfThreads);
    define_uci_option("Minimum tree split depth", "5", UCI_SPIN, 4, 7);
  }
  define_uci_option("Clear Hash", "false", UCI_BUTTON, 0, 0);
  define_uci_option("Ponder", "false", UCI_CHECK, 0, 0);
  define_uci_option("OwnBook", "true", UCI_CHECK, 0, 0);
  define_uci_option("MultiPV", "1", UCI_SPIN, 1, MAX_ROOT_MOVES);
  define_uci_option("UCI_Chess960", "false", UCI_CHECK, 0, 0);
  define_uci_option("UCI_ShowCurrLine", "false", UCI_CHECK, 0, 0);
  define_uci_option("UCI_AnalyseMode", "false", UCI_CHECK, 0, 0);
  define_uci_option("UCI_EngineAbout", 
                    "Glaurung by Tord Romstad, see http://www.glaurungchess.com",
                    UCI_STRING, 0, 0);
}

static void print_uci_option(uci_option_t *u) {
  int i;
  char option_type_name[UCI_BUTTON+1][16] = {
    "spin", "combo", "check", "string", "button"
  };
  send_msg("option name %s ", u->name);
  send_msg("type %s ", option_type_name[u->type]);
  if(u->type != UCI_BUTTON) send_msg("default %s ", u->default_value);
  switch(u->type) {
  case UCI_SPIN: send_msg("min %d max %d", u->min, u->max); break;
  case UCI_COMBO:
    for(i = 0; strlen(u->combo_vars[i]) > 0; i++)
      send_msg("var %s ", u->combo_vars[i]);
    break;
  default: break;
  }
  send_msg("\n");
}

void print_uci_options(void) {
  for(int i = 0; i < NumberOfUCIOptions; i++) print_uci_option(UCIOptions + i);
}

static uci_option_t *option_by_name(const char *option_name) {
  for(int i = 0; i < NumberOfUCIOptions; i++) 
    if(strcmp(option_name, UCIOptions[i].name) == 0) return UCIOptions + i;
  return NULL;
}

bool get_option_value_bool(const char *option_name) {
  uci_option_t *u = option_by_name(option_name);
  return (u->value[0] == 't')? true : false;
}

int button_was_pushed(const char *button_name) {
  uci_option_t *u = option_by_name(button_name);
  if(u->value[0] == 't') {
    strcpy(u->value, "false"); return 1;
  }
  return 0;
}

int get_option_value_int(const char *option_name) {
  uci_option_t *u = option_by_name(option_name);
  return atoi(u->value);
}

char *get_option_value_string(const char *option_name, char *str) {
  uci_option_t *u = option_by_name(option_name);
  strcpy(str, u->value);
  return str;
}

void set_option_value(const char *option_name, const char *value) {
  uci_option_t *u = option_by_name(option_name);
  char *c;
  if(u != NULL) {
    strcpy(u->value, value);
    // Remove trailing newline character: 
    c = strchr(u->value, '\n');
    if(c != NULL) *c = '\0';
  }
}

void push_button(char *button_name) {
  uci_option_t *u;
  char *c;
  // Remove trailing newline character: 
  c = strchr(button_name, '\n');
  if(c != NULL) *c = '\0';
  u = option_by_name(button_name);
  if(u != NULL) strcpy(u->value, "true");
}
