##### Makefile for Scid for Unix operating systems.

### Compiler: Most Unix systems use g++ for compiling and linking.
#
COMPILE = g++
CC = gcc
LINK = g++
DESTDIR =

# BINDIR: where the Scid programs are copied for "make install".
#
BINDIR = /usr/local/bin

# SHAREDIR: where scid.eco and spelling.ssp are copied for "make install".
#
SHAREDIR = /usr/local/share/scid

### TCL_VERSION: Set this according to the version of Tcl/Tk you have
#   installed that you want Scid to use: 8.0, 8.1, 8.2, 8.3, etc.
#
TCL_VERSION = 8.3

# TCL_INCLUDE, TCL_LIBRARY, TK_LIBRARY: these are the compiler options
#    needed for linking Scid with Tcl/Tk.  The program "./configure"
#    will try to determine them automatically, but if it cannot, you
#    can use the examples below for help in setting these variables.
#
# The settings determined by "./configure" are:
#
TCL_INCLUDE = -I/usr/include
TCL_LIBRARY = -L/usr/lib -ltcl$(TCL_VERSION) -ldl
TK_LIBRARY  = $(TCL_LIBRARY) -ltk$(TCL_VERSION) -L/usr/X11R6/lib -lX11

### Here are other commonly used settings for the Tcl/Tk compiler options:

### Linux (Red Hat and other distributions):
# TCL_INCLUDE = -I /usr/include
# TCL_LIBRARY = -L /usr/lib -ltcl$(TCL_VERSION) -ldl
# TK_LIBRARY  = $(TCL_LIBRARY) -ltk$(TCL_VERSION) -L /usr/X11R6/lib -lX11

### Solaris:
# TCL_INCLUDE = -I /usr/local/tcl/include
# TCL_LIBRARY = -L /usr/local/tcl/lib -ltcl$(TCL_VERSION) -ldl
# TK_LIBRARY  = $(TCL_LIBRARY) -ltk$(TCL_VERSION)

# Someone sent me these settings for SuSE Linux 6.1:
### Linux (SuSE distribution):
# TCL_INCLUDE = -I /usr/X11R6/include
# TCL_LIBRARY = -L /usr/lib -ltcl$(TCL_VERSION) -ldl
# TK_LIBRARY  = $(TCL_LIBRARY) -L /usr/X11R6/lib -ltk$(TCL_VERSION) -lX11

# Someone sent me these settings for FreeBSD with Tcl/Tk 8.0:
### FreeBSD:
# TCL_INCLUDE = -I /usr/local/include/tcl8.0 -I /usr/local/include/tk8.0
# TCL_LIBRARY = -L /usr/local/lib -ltcl80 -ldl
# TK_LIBRARY  = $(TCL_LIBRARY) -ltk80 -L /usr/X11/lib -lX11


########################################
### Compiler options:

### TB: Using Nalimov tablebases with Scid. Use "TB = -DSCID_USE_TB" for 
#      tablebase support, or just "TB = " for no tablebase capability.
#      Use "TB = -DSCID_USE_TB -DT41_INCLUDE" to include use of 4-1
#      (King + 3 pieces vs lone king) tablebases.
#
TB = -DSCID_USE_TB -DT41_INCLUDE

### SCIDFLAGS: Scid customization flags.
#      Use -DZLIB if your system does not have zlib and you need
#      to include the code in the src/zlib directory.
#      The default is to use the system zlib library.
#
SCIDFLAGS = 

### OPTIMIZE: Optimization options for C++ compiler.
#      -O4 is the most optimization for g++. I have found -O2 to do
#      just as well, but someone reported a noticable difference in speed
#      between -O4 and -O2 so the default here is -O4.
#      On some systems, adding "-fno-rtti" and "-fno-exceptions" produces
#      smaller, faster programs since Scid does not use those C++ features.
#
OPTIMIZE = -O4 -fno-rtti -fno-exceptions

### DEBUG: Defining the macro ASSERTIONS will turn on assertions, which
#       helps to track bugs after modifications, but the programs will run 
#       a little faster with assertions turned off.
#
DEBUG = #-DASSERTIONS

### WARNINGS: I always compile with all warnings on (-Wall), and all the
#       files should compile warning-free using g++.
#
WARNINGS = -Wall

### PROFILE: Set this to "-pg" for profiling in g++ and gcc.
#
PROFILE = 

### CPP_FLAGS: Flags for C++ compilation.
#
CPP_FLAGS = $(PROFILE) $(OPTIMIZE) $(WARNINGS) $(DEBUG) $(SCIDFLAGS)

### CFLAGS: Flags for C compilation (only used for compiling zlib).
#
CFLAGS = -O2 -Wall $(PROFILE)

### LANGUAGES: List of additional Tcl files to include in Scid for
#       multi-language menu support.
#       By default, it is all the contributed languages, but you
#       can reduce the size of the Scid program by only specifying
#       the languages you want supported.
#
LANGUAGES = tcl/deutsch.tcl tcl/francais.tcl tcl/italian.tcl tcl/nederlan.tcl tcl/spanish.tcl tcl/portbr.tcl tcl/swedish.tcl tcl/norsk.tcl tcl/polish.tcl tcl/czech.tcl tcl/hungary.tcl tcl/serbian.tcl tcl/russian.tcl


############################################################
#
# You should not need to edit anything below this line.
#
############################################################

### EXECS: executable programs compiled from C++ files.
#     Note: scidt and eco2epd are obsolete and not compiled by default.
#
EXECS= pgnscid tkscid tcscid scmerge scidlet

### SCIDOBJS: not all the .o files that make up Scid, just the standard ones 
#     that most of the programs include.
#
SCIDOBJS= src/misc.o src/index.o src/date.o src/namebase.o src/position.o \
      src/game.o src/gfile.o src/matsig.o src/bytebuf.o src/textbuf.o \
      src/myassert.o src/stralloc.o src/mfile.o src/dstring.o src/pgnparse.o \
      src/stored.o src/movelist.o

### ZLIBOBJS: object files in the zlib compression library.
#
ZLIBOBJS= src/zlib/adler32.o src/zlib/compress.o src/zlib/crc32.o \
      src/zlib/gzio.o src/zlib/uncompr.o src/zlib/deflate.o src/zlib/trees.o \
      src/zlib/zutil.o src/zlib/inflate.o src/zlib/infblock.o \
      src/zlib/inftrees.o src/zlib/infcodes.o src/zlib/infutil.o \
      src/zlib/inffast.o

### ZLIB: Should be "-lz" if your system has zlib, "" otherwise.
#
ZLIB = -lz

### OBJS: Will be "$(SCIDOBJS)", and also "$(ZLIBOBJS)" if they are
#      needed on your system.
OBJS= $(SCIDOBJS)

### TCLS: all the .tcl files that make up "scid".
#
TCLS= tcl/start.tcl tcl/bitmaps.tcl tcl/menus.tcl tcl/windows.tcl \
      tcl/htext.tcl tcl/help.tcl tcl/tips.tcl tcl/misc.tcl tcl/search.tcl \
      tcl/ezsmtp/ezsmtp.tcl \
      tcl/email.tcl tcl/epd.tcl tcl/fontsel.tcl tcl/basewind.tcl \
      tcl/import.tcl tcl/spellchk.tcl tcl/graph.tcl tcl/maint.tcl \
      tcl/optable.tcl tcl/analysis.tcl tcl/wbdetect.tcl tcl/reper.tcl \
      tcl/lang.tcl tcl/english.tcl $(LANGUAGES) \
      tcl/bookmark.tcl tcl/board.tcl tcl/tb.tcl tcl/end.tcl

### SCRIPTS:
# Small extra programs. Most are written in Tcl using tcscid, but
# a few contributed ones may be in Python or other languages.
#
SCRIPTS= sc_addmove sc_epgn sc_spell sc_eco sc_import sc_remote sc_tree scidpgn pgnfix spliteco

####################

### Type "make" or "make all" to make all programs:
#
all: scid $(SCRIPTS) $(EXECS)

### To copy all executables to $BINDIR, with read and execute permission 
#   for all users, and put extra files in $SHAREDIR, type "make install".
#
install: all
	install -m 755 -d $(DESTDIR)$(BINDIR)
	install -m 755 scid $(SCRIPTS) $(EXECS) $(DESTDIR)$(BINDIR)
	-install -m 755 -d $(DESTDIR)$(SHAREDIR)
	-install -m 644 -p scid.eco spelling.ssp $(DESTDIR)$(SHAREDIR)

old-install: all
	chmod 755 scid $(SCRIPTS) $(EXECS)
	cp scid $(SCRIPTS) $(EXECS) $(BINDIR)
	-mkdir -p $(SHAREDIR)
	-chmod a+rx $(SHAREDIR)
	-cp ./scid.eco $(SHAREDIR)/scid.eco
	-cp ./spelling.ssp $(SHAREDIR)/spelling.ssp
	-chmod a+r $(SHAREDIR)/scid.eco $(SHAREDIR)/spelling.ssp

### To remove Scid files placed in the BINDIR and SHAREDIR directories,
#   type "make distclean".
#
distclean:
	cd $(BINDIR) && rm -f $(EXECS) $(SCRIPTS)
	-rm -f $(SHAREDIR)/scid.eco
	-rm -f $(SHAREDIR)/spelling.ssp

### To remove object and executable files: type "make clean".
#
clean:
	rm -f src/*.o src/zlib/*.o $(EXECS) scid $(SCRIPTS)

### To make the executable files smaller: type "make strip".
#
strip:
	strip $(EXECS)

### To compress scid and executables with gzexe: type "make gzexe".
#
gzexe:
	gzexe $(EXECS) scid


scid: $(TCLS)
	rm -f ./scid
	cat $(TCLS) > ./scid
	chmod +x scid

sc_addmove: scripts/sc_addmove.tcl
	cp scripts/sc_addmove.tcl ./sc_addmove
	chmod +x sc_addmove

sc_epgn: scripts/sc_epgn.tcl
	cp scripts/sc_epgn.tcl ./sc_epgn
	chmod +x sc_epgn

sc_spell: scripts/sc_spell.tcl
	cp scripts/sc_spell.tcl ./sc_spell
	chmod +x sc_spell

sc_eco: scripts/sc_eco.tcl
	cp scripts/sc_eco.tcl ./sc_eco
	chmod +x sc_eco

sc_import: scripts/sc_import.tcl
	cp scripts/sc_import.tcl ./sc_import
	chmod +x sc_import

sc_remote: scripts/sc_remote.tk
	cp scripts/sc_remote.tk ./sc_remote
	chmod +x sc_remote

sc_tree: scripts/sc_tree.tcl
	cp scripts/sc_tree.tcl ./sc_tree
	chmod +x sc_tree

sc_maketree: scripts/sc_maketree.tcl
	cp scripts/sc_maketree.tcl ./sc_maketree
	chmod +x sc_maketree

scidpgn: scripts/scidpgn.tcl
	cp scripts/scidpgn.tcl ./scidpgn
	chmod +x scidpgn

spliteco: scripts/spliteco.tcl
	cp scripts/spliteco.tcl ./spliteco
	chmod +x spliteco

tbstats: scripts/tbstats.tcl
	cp scripts/tbstats.tcl ./tbstats
	chmod +x tbstats

wmtest: scripts/wmtest.tk
	cp scripts/wmtest.tk ./wmtest
	chmod +x wmtest

pgnfix: scripts/pgnfix.py
	cp scripts/pgnfix.py ./pgnfix
	chmod +x pgnfix

eco2pgn: scripts/eco2pgn.py
	cp scripts/eco2pgn.py ./eco2pgn
	chmod +x eco2pgn

twic2pgn: scripts/twic2pgn.py
	cp scripts/twic2pgn.py ./twic2pgn
	chmod +x twic2pgn

scmerge: src/scmerge.o src/misc.o src/index.o src/date.o src/namebase.o \
          src/gfile.o src/bytebuf.o src/textbuf.o src/myassert.o \
          src/stralloc.o
	$(LINK) -o scmerge src/scmerge.o $(OBJS) $(ZLIB)

pgnscid: src/pgnscid.o $(OBJS)
	$(LINK) $(PROFILE) -o pgnscid src/pgnscid.o $(OBJS) $(ZLIB)

scidlet: src/scidlet.o src/engine.o src/recog.o src/misc.o src/position.o \
          src/dstring.o src/movelist.o
	$(LINK) -o scidlet src/scidlet.o src/engine.o src/recog.o src/misc.o src/position.o src/movelist.o src/dstring.o

scidt: src/scidt.o $(OBJS)
	$(LINK) -o scidt src/scidt.o $(OBJS) $(ZLIB)

tkscid: src/tkscid.o $(OBJS) src/tree.o src/filter.o src/pbook.o src/crosstab.o \
          src/spellchk.o src/probe.o src/optable.o src/engine.o src/recog.o
	$(LINK) -o tkscid src/tkscid.o $(OBJS) src/tree.o src/filter.o src/pbook.o src/crosstab.o src/spellchk.o src/probe.o src/optable.o src/engine.o src/recog.o $(ZLIB) $(TK_LIBRARY)

tcscid: src/tcscid.o $(OBJS) src/tree.o src/filter.o src/pbook.o src/crosstab.o \
          src/spellchk.o src/probe.o src/optable.o src/engine.o src/recog.o
	$(LINK) -o tcscid src/tcscid.o $(OBJS) src/tree.o src/filter.o src/pbook.o src/crosstab.o src/spellchk.o src/probe.o src/optable.o src/engine.o src/recog.o $(ZLIB) $(TCL_LIBRARY)

# eco2epd is now optional extra program NOT compiled by default, since
# scid now reads the .eco file format directly.
eco2epd: src/eco2epd.o $(OBJS) src/pbook.o
	$(LINK) -o eco2epd src/eco2epd.o $(OBJS) src/pbook.o $(ZLIB)

### Rules to create .o files from .cpp files:
#
src/tcscid.o: src/tkscid.cpp
	$(COMPILE) $(CPP_FLAGS) $(TCL_INCLUDE) -DTCL_ONLY -o src/tcscid.o -c src/tkscid.cpp

src/tkscid.o: src/tkscid.cpp
	$(COMPILE) $(CPP_FLAGS) $(TCL_INCLUDE) -o src/tkscid.o -c src/tkscid.cpp

### The endgame tablebase code in the egtb/ subdirectory (not written by me)
#   gives many warnings, so compile probe.cpp with warnings turned off:
#
src/probe.o: src/probe.cpp src/egtb/tbindex.cpp src/egtb/tbdecode.c
	$(COMPILE) $(PROFILE) $(OPTIMIZE) $(DEBUG) $(SCIDFLAGS) $(TB) -o src/probe.o -c src/probe.cpp

### Generic rule for all other .cpp files:
#
%.o: %.cpp
	$(COMPILE) $(CPP_FLAGS) -o $@ -c $<

### Rule for compiling zlib source files:
#
src/zlib/%.o: src/zlib/%.c
	$(CC) $(CFLAGS) -o $@ -c $<

### End of Makefile
