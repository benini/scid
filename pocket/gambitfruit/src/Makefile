
# files

EXE = gambitfruit

OBJS = attack.o board.o book.o eval.o fen.o hash.o list.o main.o material.o \
       move.o move_check.o move_do.o move_evasion.o move_gen.o move_legal.o \
       option.o pawn.o piece.o posix.o protocol.o pst.o pv.o random.o \
       search.o search_full.o see.o sort.o square.o trans.o util.o value.o \
       vector.o

# rules

all: $(EXE) .depend

ipc.o: ipc.c
	$(CC) -c -o ipc.o ipc.c

clean:
	$(RM) *.o .depend gambitfruit gambitfruit.exe gmon.out

# general

CXX      = g++
CXXFLAGS = -pipe
LDFLAGS  = -lm

# C++

CXXFLAGS += -fno-exceptions -fno-rtti

# optimisation

CXXFLAGS += -O3 -fstrict-aliasing
CXXFLAGS += -fomit-frame-pointer
# CXXFLAGS += -march=athlon-xp # SELECT ME

# strip

LDFLAGS += -s

# dependencies

$(EXE): $(OBJS) ipc.o
	$(CXX) $(LDFLAGS) -o $@ $(OBJS) ipc.o

.depend:
	$(CXX) -MM $(OBJS:.o=.cpp) > $@

include .depend

