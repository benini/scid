CC = g++

CFLAGS = -O2 -funroll-loops -fomit-frame-pointer -fstrict-aliasing -Wall
#CFLAGS = -O2 -g -funroll-loops -fomit-frame-pointer -fstrict-aliasing -Wall -arch i386 -arch ppc -arch ppc64
#CFLAGS = -O2 -g -funroll-loops -Wall -pg
#CFLAGS = -O2 -funroll-loops -fomit-frame-pointer -Wall -g -mcpu=G5 -mpowerpc64

DEFINES =
LDFLAGS = 

OBJ = .o/book.o \
	.o/data.o \
	.o/endgame.o \
	.o/eval.o \
	.o/extend.o \
	.o/init.o \
	.o/io.o \
	.o/learn.o \
	.o/main.o \
	.o/mersenne.o \
	.o/move.o \
	.o/movegen.o \
	.o/order.o \
	.o/position.o \
	.o/psq.o \
	.o/pstruct.o \
	.o/root.o \
	.o/safety.o \
	.o/search.o \
	.o/see.o \
	.o/smp.o \
	.o/think.o \
	.o/tt.o \
	.o/uci.o \
	.o/ucioption.o \
	.o/zobrist.o

glaurung: .o $(OBJ) ipc.o
	$(CC) $(CFLAGS) $(DEFINES) $(LDFLAGS) $(OBJ) .o/ipc.o -o glaurung -lm

ipc.o : ipc.h ipc.c
	gcc $(CFLAGS) $(DEFINES) -c -o .o/ipc.o ipc.c

.o/%.o: Makefile %.cpp
	$(CC) $(CFLAGS) $(DEFINES) -c $*.cpp -o .o/$*.o

.o:
	mkdir .o

clean:
	rm -rf .o glaurung glaurung.exe
