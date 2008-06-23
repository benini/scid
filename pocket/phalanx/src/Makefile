CC = gcc

####### choose the line that makes the binary faster on your machine
# CFLAGS = -O3 -Wall -fomit-frame-pointer -funroll-loops
CFLAGS = -O0 -Wall -fomit-frame-pointer -std=c99 -D_GNU_SOURCE

#######
### DEFINES
### -DSHOW_FORCED_MOVES
### -DPBOOK_FILE=\"pbook.phalanx\"
### -DSBOOK_FILE=\"sbook.phalanx\"
### -DLEARN_FILE=\"learn.phalanx\"
### -DPBOOK_DIR=\"/usr/local/lib\"
### -DSBOOK_DIR=\"/usr/local/lib\"
### -DLEARN_DIR=\"/var/local/lib\"
### -DQCAPSONLY

DEFINES = -DGNUFUN 
LDFLAGS =

OBJ = .o/phalanx.o .o/search.o .o/io.o .o/data.o .o/evaluate.o .o/genmoves.o \
.o/moving.o .o/hash.o .o/static.o .o/levels.o .o/killers.o .o/endgame.o .o/ipc.o

phalanx: .o $(OBJ)
	$(CC) $(CFLAGS) $(DEFINES) $(LDFLAGS) $(OBJ) -o phalanx

.o/%.o: Makefile %.c
	$(CC) $(CFLAGS) $(DEFINES) -c $*.c -o .o/$*.o

.o:
	mkdir .o

clean:
	rm -rf .o phalanx phalanx.exe *.lrn
