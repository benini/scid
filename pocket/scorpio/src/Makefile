CPP = g++
CC = gcc
CFLAGS = -fstrict-aliasing -fomit-frame-pointer
CPPFLAGS = -fno-exceptions -fno-rtti -fstrict-aliasing -fomit-frame-pointer
OPT = -O3
DEFINES = 
LDFLAGS = 

RM = rm -rf
OBJ = attack.o scorpio.o eval.o hash.o moves.o probe.o search.o see.o util.o

scorpio: $(OBJ) ipc.o
	$(CC) $(CFLAGS) $(OPT) $(DEFINES) $(LDFLAGS) $(OBJ) ipc.o -o scorpio -lm -lpthread -ldl -lstdc++

%.o: %.cpp scorpio.h
	$(CC) $(CFLAGS) $(DEFINES) -c $<

ipc.o: ipc.c ipc.h
	$(CC) $(OPT) $(CFLAGS) $(DEFINES) -c $<

clean:
	$(RM) $(OBJ) ipc.o scorpio scorpio.exe
