#include <stdio.h>
#include <sys/types.h>

#ifndef WIN32
  #include <sys/socket.h>
  #include <netinet/in.h>
  #include <netdb.h> 
  #include <fcntl.h>
  #define PORT 12937
  #define HOST "localhost"
#endif

#include <string.h>
#include <stdarg.h>
#include <unistd.h>
#include <sys/time.h>

#include <signal.h>

#ifdef WIN32
  #include <windows.h>
#endif

int sockfd;
// ======================================================================
#ifndef WIN32
int input_available() {
  fd_set set;
  struct timeval timeout;
 
  FD_ZERO (&set);
  FD_SET (sockfd, &set);
     
  timeout.tv_sec = 0;
  timeout.tv_usec = 0;

  // select returns 0 if timeout, 1 if input available, -1 if error.
  int ret = select(1, &set, NULL, NULL, &timeout);
  return ret;
}
#endif

// ======================================================================
void my_usleep(int usec) {
  usleep(usec);
}

// ======================================================================
int lowPrio(int prio) {
#ifdef WIN32
    return (int) CeSetThreadPriority(GetCurrentThread(), prio);
#else
  return 1;
#endif
}
// ======================================================================
#ifdef WIN32
#include "../../../src/msgqueue.h"
  HANDLE hw, hr;

// ==============================================================
void AnsiToUnicode(LPCSTR pszA, LPWSTR* ppszW) {
    ULONG cCharacters;
    cCharacters =  strlen(pszA)+1;
    *ppszW = (LPWSTR) malloc(cCharacters*2);
    MultiByteToWideChar(CP_ACP, 0, pszA, cCharacters, *ppszW, cCharacters);
}

// ======================================================================
int init_socket() {
  MSGQUEUEOPTIONS opt;
  char * s1 = "toga1342scid";
  char * s2 = "scid2toga134";
  LPWSTR sunicode;

  opt.dwSize = sizeof(MSGQUEUEOPTIONS);
  opt.dwFlags = MSGQUEUE_NOPRECOMMIT | MSGQUEUE_ALLOW_BROKEN;
  opt.dwMaxMessages = 0;
  opt.cbMaxMessage = 1024;
  opt.bReadAccess = FALSE;

  AnsiToUnicode(s1, &sunicode);
  hw = CreateMsgQueue( (LPCWSTR) sunicode, &opt );
  if (hw == NULL)
    printf("error hw null\n");
  free(sunicode);

  opt.bReadAccess = TRUE;
  AnsiToUnicode(s2, &sunicode);
  hr = CreateMsgQueue( (LPCWSTR) sunicode, &opt );
  if (hr == NULL)
    printf("error hr null\n");
  free(sunicode);
  return 0;
}

// ======================================================================
void send_msg(const char format[], ...) {

   va_list arg_list;
   char string[1024];

   va_start(arg_list,format);
   vsprintf(string,format,arg_list);
   va_end(arg_list);

  if (!WriteMsgQueue( hw, (LPVOID)string, strlen(string), 0, 0 ) )
    printf("error WriteMsgQueue failed\n");
}

// ======================================================================
// get()

void get_msg(char string[], int size) {

  int read = 0;
  int dwFlags = 0;
  if ( ! ReadMsgQueue( hr,(LPVOID) string, 1024, (LPDWORD) &read, 0, (DWORD *) &dwFlags ) ) {
    string[0] = '\0';
  } else {
    string[read] = '\0';
  }
}

// ======================================================================
// checks that the user interface (Scid) is still there
// this code is designed to kill the engine if useless on PDA (not attached to an UI
// and the interface was not able to stop the engine)
void uiAlive() {
  MSGQUEUEINFO qinfor, qinfow;
  qinfor.dwSize = sizeof(MSGQUEUEINFO);
  qinfow.dwSize = sizeof(MSGQUEUEINFO);

  if (! GetMsgQueueInfo( hr,  (LPMSGQUEUEINFO) &qinfor) ) {
    exit(EXIT_SUCCESS);
  }
  if (! GetMsgQueueInfo( hw,  (LPMSGQUEUEINFO) &qinfow) ) {
    exit(EXIT_SUCCESS);
  }
  if ( qinfor.wNumReaders == 1 && qinfor.wNumWriters == 1 &&
       qinfow.wNumReaders == 1 && qinfow.wNumWriters == 1) {
    return;
  } else {
    exit(EXIT_SUCCESS);
  }
}

// not WIN32
#else

// get_msg()

void get_msg(char string[], int size) {

/*
   if (!my_file_read_line(stdin,string,size)) { // EOF
      exit(EXIT_SUCCESS);
   }*/
// Network connexions : CRLF
  string[0] = '\0';
  char *ptr = string;
  while ((int)(ptr - string) < size) {
    if (read(sockfd,ptr,1) < 0) {
      *ptr = '\0';
      //send("error get no new line");
      return;//printMsg("ERROR reading from socket");
    }
    if (ptr[0] == '\n') break;
    ptr++;
  }
  ptr = strchr(string,'\n');
  if (ptr != NULL) *ptr = '\0';
  ptr = strchr(string,'\r');
  if (ptr != NULL) *ptr = '\0';

//send("toga ---get() <%s>\n", string);
}

// send()

void send_msg(const char format[], ...) {

   va_list arg_list;
   char string[4096];

   va_start(arg_list,format);
   vsprintf(string,format,arg_list);
   va_end(arg_list);
   strcat(string, "\n");
   if (write(sockfd, string,strlen(string)) < 0 ) printf("ERROR writing to socket\n");
    //write(sockfd, "\n", 1);
    //fflush(NULL);
}

// ======================================================================
int setNonblocking(int fd) {
    int flags;
    if (-1 == (flags = fcntl(fd, F_GETFL, 0)))
        flags = 0;
    return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
}
// ======================================================================
int init_socket() {
    struct sockaddr_in serv_addr;
    struct hostent *server;

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
      printf("ERROR opening socket\n");
      return 1;
    }

    server = gethostbyname(HOST);
    if (server == NULL) {
      printf("ERROR, no such host\n");
      return 1;
    }
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr, server->h_length);
    serv_addr.sin_port = htons(PORT);
    if (connect(sockfd,(const struct sockaddr *)&serv_addr,sizeof(serv_addr)) < 0) {
      printf("ERROR connecting\n");
      return 1;
      }
    if ( setNonblocking(sockfd) == -1 )
      printf("ERROR setNonblocking\n");
   return 0;
}

#endif

// ======================================================================
void closeMsgQueues() {
#ifdef WIN32
  CloseMsgQueue(hw);
  CloseMsgQueue(hr);
#endif
}

