#include "viper.h"

#define MAX_UCI_OPTIONS 128

enum uci_option_type_t {
  UCI_SPIN, UCI_COMBO, UCI_CHECK, UCI_STRING, UCI_BUTTON
};

struct uci_option_t {
  char name[64];
  char default_value[128];
  char value[128];
  int type;
  int min;
  int max;
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
  u->type = type;
  u->min = min;
  u->max = max;
         
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
  define_uci_option("Hash", "128", UCI_SPIN, 64, 2048); // PPC
  define_uci_option("Passed pawns (middle game)", "100", UCI_SPIN, 0, 200);
  define_uci_option("Passed pawns (endgame)", "140", UCI_SPIN, 0, 200);
  define_uci_option("Pawn structure", "150", UCI_SPIN, 0, 200);
  define_uci_option("Mobility (middle game)", "130", UCI_SPIN, 0, 200);
  define_uci_option("Mobility (endgame)", "110", UCI_SPIN, 0, 200);
  define_uci_option("Development", "130", UCI_SPIN, 0, 200);
  define_uci_option("Clear Hash", "false", UCI_BUTTON, 0, 0);
  define_uci_option("Ponder", "false", UCI_CHECK, 0, 0);
  define_uci_option("MultiPV", "1", UCI_SPIN, 1, MAX_ROOT_MOVES);
  define_uci_option("UCI_Chess960", "false", UCI_CHECK, 0, 0);
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
    if(strcmp(option_name, UCIOptions[i].name) == 0) 
      return UCIOptions + i;
  return NULL;
}

int get_option_value_bool(const char *option_name) {
  uci_option_t *u = option_by_name(option_name);
  return (u->value[0] == 't')? 1 : 0;
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
