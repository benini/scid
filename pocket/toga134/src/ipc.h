#ifndef IPC_H
#define IPC_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

void closeMsgQueues     ();
void uiAlive            ();
void get_msg            (char string[], int size);
void send_msg           (const char format[], ...);
int init_socket         ();
void my_usleep          (int usec);
int lowPrio             (int prio);

#ifdef __cplusplus
}
#endif

#endif
