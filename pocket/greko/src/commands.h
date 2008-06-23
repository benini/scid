#ifndef COMMANDS_H
#define COMMANDS_H

int  is_command(const char *s, const char *pattern, size_t min_length);
void run_command_loop();

#endif

