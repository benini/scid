CPP = g++
CC = gcc

CPPFLAGS = -DNDEBUG -Wall -pipe -O3 -fno-exceptions -fomit-frame-pointer -fno-rtti

BIN = greko

OBJ = bitboards.o	commands.o eval.o main.o moves.o notation.o	\
      position.o search.o utils.o unix.o ipc.o

LINKOBJ = $(OBJ)

.PHONY:	all clean

all:	$(BIN)

clean:
	rm -f $(OBJ) $(BIN) greko.exe *~

$(BIN):	$(OBJ)
	$(CPP) $(LINKOBJ) -o $(BIN)
	rm -f *~

bitboards.o: bitboards.cpp 
	$(CPP) $(CPPFLAGS) -c bitboards.cpp -o bitboards.o

commands.o: commands.cpp 
	$(CPP) $(CPPFLAGS) -c commands.cpp -o commands.o

eval.o: eval.cpp eval.h
	$(CPP) $(CPPFLAGS) -c eval.cpp -o eval.o

main.o:	main.cpp 
	$(CPP) $(CPPFLAGS) -c main.cpp -o main.o

moves.o: moves.cpp 
	$(CPP) $(CPPFLAGS) -c moves.cpp -o moves.o

notation.o: notation.cpp
	$(CPP) $(CPPFLAGS) -c notation.cpp -o notation.o

position.o: position.cpp 
	$(CPP) $(CPPFLAGS) -c position.cpp -o position.o

search.o: search.cpp 
	$(CPP) $(CPPFLAGS) -c search.cpp -o search.o

utils.o: utils.cpp
	$(CPP) $(CPPFLAGS) -c utils.cpp -o utils.o

unix.o: unix.cpp
	$(CPP) $(CPPFLAGS) -c unix.cpp -o unix.o

ipc.o: ipc.c
	$(CC) $(CFLAGS) -c ipc.c -o ipc.o
