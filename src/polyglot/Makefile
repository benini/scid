
# files

EXE = polyglot

OBJS = adapter.o attack.o board.o book.o book_make.o book_merge.o colour.o \
       engine.o epd.o fen.o game.o hash.o io.o line.o list.o main.o move.o \
       move_do.o move_gen.o move_legal.o option.o parse.o pgn.o piece.o \
       posix.o random.o san.o search.o square.o uci.o util.o

# rules

all: $(EXE) .depend

clean:
	$(RM) *.o .depend

# general

CXX       = g++
CXXFLAGS  = -pipe
LDFLAGS   = -lm

# C++

CXXFLAGS += -fno-exceptions -fno-rtti

# optimisation

CXXFLAGS += -O2
CXXFLAGS += -fomit-frame-pointer

# strip

LDFLAGS  += -s

# dependencies

$(EXE): $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $(OBJS)

%.s: %.cpp
	$(CXX) -S $(CXXFLAGS) $<

.depend:
	$(CXX) -MM $(OBJS:.o=.cpp) > $@

include .depend

