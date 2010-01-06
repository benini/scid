
# files

EXE = scidlet

SRC = ../src/

OBJS = scidlet.o engine.o recog.o misc.o position.o movelist.o

# rules

#all: $(EXE) .depend
all: $(EXE)

ipc.o: ipc.c
	$(CC) -c -o ipc.o ipc.c

clean:
	$(RM) *.o *.armo scidlet.exe .depend gmon.out $(EXE) $(OBJS)

CXX      = g++ -DPOCKETENGINE
CXXFLAGS = -pipe
LDFLAGS  = -lm

# C++

CXXFLAGS += -fno-exceptions -fno-rtti -I$(SRC) -I$(SRC)/zlib/ -I.
CXXFLAGS += -O3 -fstrict-aliasing -fomit-frame-pointer
LDFLAGS += -s

$(EXE): $(OBJS) ipc.o
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(OBJS) ipc.o
	
# dependencies

scidlet.o: scidlet.cpp $(SRC)engine.h $(SRC)position.h $(SRC)common.h $(SRC)error.h $(SRC)sqmove.h \
  $(SRC)misc.h $(SRC)movelist.h $(SRC)sqlist.h $(SRC)sqset.h $(SRC)tokens.h $(SRC)timer.h ipc.h
	$(CXX) $(CXXFLAGS) -c scidlet.cpp -o scidlet.o
	
engine.o: $(SRC)engine.cpp $(SRC)attacks.h $(SRC)common.h $(SRC)error.h $(SRC)sqmove.h $(SRC)engine.h \
  $(SRC)position.h $(SRC)misc.h $(SRC)movelist.h $(SRC)sqlist.h $(SRC)sqset.h $(SRC)tokens.h $(SRC)timer.h $(SRC)recog.h ipc.h
		$(CXX) $(CXXFLAGS) -c $(SRC)engine.cpp -o engine.o
		
recog.o: $(SRC)recog.cpp $(SRC)engine.h $(SRC)position.h $(SRC)common.h $(SRC)error.h $(SRC)sqmove.h $(SRC)misc.h \
  $(SRC)movelist.h $(SRC)sqlist.h $(SRC)sqset.h $(SRC)tokens.h $(SRC)timer.h $(SRC)recog.h
	$(CXX) $(CXXFLAGS) -c $(SRC)recog.cpp -o recog.o

misc.o: $(SRC)misc.cpp $(SRC)common.h $(SRC)error.h $(SRC)sqmove.h $(SRC)misc.h
	$(CXX) $(CXXFLAGS) -c $(SRC)misc.cpp -o misc.o

position.o: $(SRC)position.cpp $(SRC)common.h $(SRC)error.h $(SRC)sqmove.h $(SRC)position.h $(SRC)misc.h \
  $(SRC)movelist.h $(SRC)sqlist.h $(SRC)sqset.h $(SRC)tokens.h $(SRC)attacks.h $(SRC)hash.h
	$(CXX) $(CXXFLAGS) -c $(SRC)position.cpp -o position.o

movelist.o: $(SRC)movelist.cpp $(SRC)movelist.h $(SRC)common.h $(SRC)error.h $(SRC)sqmove.h $(SRC)misc.h
	$(CXX) $(CXXFLAGS) -c $(SRC)movelist.cpp -o movelist.o
