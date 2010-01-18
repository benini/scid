EXE = stockfish
CXX = g++
CC = gcc
CCFLAGS = 
CXXFLAGS = -O3 -msse -DNDEBUG
#GCCFLAGS += -DBIGENDIAN
CXXFLAGS += -Wall -fno-exceptions -fno-rtti
DEFINES = 
LDFLAGS  = -lpthread

OBJS = application.o bitboard.o pawns.o material.o endgame.o evaluate.o main.o \
	misc.o move.o movegen.o history.o movepick.o search.o piece.o \
	position.o direction.o tt.o value.o uci.o ucioption.o \
	mersenne.o book.o bitbase.o san.o benchmark.o

all: $(EXE) .depend

$(EXE): .o $(OBJS) ipc.o
	$(CXX) $(GCCFLAGS) $(DEFINES) $(LDFLAGS) $(OBJS) .o/ipc.o -o $@

ipc.o : ipc.h ipc.c
	$(CC) $(CFLAGS) $(DEFINES) -c -o .o/ipc.o ipc.c

.o/%.o: Makefile %.cpp
	$(CXX) $(CXXFLAGS) $(DEFINES) -c $*.cpp -o .o/$*.o

.o:
	mkdir .o

strip:
	strip $(EXE)

clean:
	$(RM) *.o .o/* .depend *~ $(EXE) *.exe

### Dependencies. Do not change
.depend:
	$(CXX) -msse -MM $(OBJS:.o=.cpp) > $@

include .depend
