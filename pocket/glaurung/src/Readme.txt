1. Introduction
---------------

Glaurung is a simple and minimalistic UCI chess engine.  Compared to
other chess programs, it is neither very fast nor particularly
intelligent, but on fast modern computers it is nevertheless strong
enough to give most human players a good challenge.  The source code
is delivered under the GNU Public License; see the file Copying.txt
for details.  The program should compile easily in Windows and most
Unix variants (including Mac OS X).

I started working on Glaurung in the autumn of 2004, when my old chess
engine (Gothmog) got so complex and buggy that there was no point in
trying to improve it further.  My goal with the new engine was to
construct a very simple program with compact code and data
requirements, and to make the code general enough to handle hexagonal
chess with just a small number of changes.  Scatha, Glaurung's
hexagonal twin brother, is available as a separate download.


2. Using the program
--------------------

In order to use Glaurung, you need a chess GUI with support for the
UCI or xboard protocol.  Installing Glaurung in a UCI compatible GUI
(like Arena, Shredder, Fritz, José or Sigma Chess) should be
straightforward.  Using it with an xboard compatible GUI (like xboard,
Winboard or ChessMaster 10000) is slightly more tricky, you will have
to install and use Fabien Letouzey's excellent PolyGlot utility.
PolyGlot is available from the download section of the WBEC site
(http://wbec-ridderkerk.nl).  Please use the polyglot.ini file
supplied with Glaurung.


3. UCI options
--------------

The most important components of Glaurung's evaluation function can be
configured through the UCI interface (edit the polyglot.ini file if
you use Glaurung in xboard or Winboard).  You can try to modify the
settings if you want to change the program's style of play.  It is not
at all clear that the default settings are optimal.  If you discover
some settings which seem to be clearly stronger than the defaults,
please let me know.

The configurable options in Glaurung 1.2.1 are:

* "Aggressiveness" (between 0 and 300, the default is 130).  This is
  the weight given to the king safety evaluation of the opponent.  Big
  values will make Glaurung more willing to sacrifice material or make
  positional concessions in order to attack the enemy king. 

* "Cowardice" (between 0 and 300, the default is 100).  This is the
  weight given to Glaurung's own king safety.  With high values,
  Glaurung will be very cautious about its own king.  Low values will
  result in more reckless play.

* "Passed pawns (middle game)" and "Passed pawns (endgame)" (between 0
  and 300, the defaults are 100 and 140).  The weight given to the
  passed pawn evaluation.  High values will make Glaurung assign big
  bonuses to passed pawns.

* "Pawn structure (middle game)" and "Pawn structure (endgame)"
  (between 0 and 300, the defaults are 150 and 150).  The weight of
  the pawn structure evaluation.  With high values, Glaurung will try
  harder to avoid pawn structure defects like isolated, double and
  backward pawns.

* "Mobility (middle game)" and "Mobility (endgame)" (between 0 and
  300, the defaults are 160 and 150).  Mobility is a measure of the
  number of possible moves for each piece on the board.

* "Space" (between 0 and 300, the default is 100) is the weight of the
  evaluation of space and central control.  The default value of 100 is
  rather high and speculative, it is possible that a slightly lower 
  value would perform better in normal chess.  In FRC (also known as
  Chess960), however, values even higher than 100 seem to work well.

* "Development" (between 0 and 300, the default is 130) controls the
  evaluation of development.  With high values, Glaurung will make a
  bigger effort to activate its pieces quickly in the opening.

* "Static evaluation cache" (on or off, default is on).  The static
  evaluation cache is used to store data about the positions Glaurung
  has already evaluated.  Enabling the static evaluation cache makes
  Glaurung a tiny bit faster at some computers (at the expense of some
  memory use).  This seems to depend on the computer used.  You will
  have to try to find out whether the static evaluation cache improves
  performance on your machine.  At any rate, the difference is not
  big.

* "Static evaluation cache size" (between 1 and 128, the default is
  4).  The size of the evaluation cache, measured in megabytes.  If
  the static evaluation cache seems to help on your computer, you may
  be able to improve the performance even further by increasing the
  cache size.  

* "Static null move pruning" (on or off, the default is on).  When
  this is enabled, Glaurung will use its evaluation function to prune
  some branches of the game tree near the leaves.  This reduces the
  number of positions Glaurung needs to examine to reach a given
  depth, but with a risk of introducing tactical errors.  I think
  Glaurung is tactically stronger with static null move pruning
  disabled, but the positional benefits are probably enough to
  compensate.  

* "Static pruning depth" (between 1 and 6, the default is 3).
  Controls how close to the leaves static null move pruning is
  allowed.  Values above 3 are probably too risky, but I haven't made
  enough tests to be sure.

* "Null move reduction factor (middle game)" and "Null move reduction
  factor (endgame)" (between 1 and 3, the defaults are 3 and 2).  Like
  most chess programs, Glaurung uses the technique known as "recursive
  null move pruning".  Null move pruning greatly speeds up the search,
  at the cost of making non-forcing positional move sequences more
  difficult to find, and introducing a risk of missing zugzwang
  problems.  Reducing the null move reduction factor makes the search
  slower, but more accurate.  The value 3 is almost certainly the best
  in the middle game, but it is not quite clear whether 2 or 3 is
  optimal in the endgame.

* "Late move reductions" ("All nodes", "Non-PV nodes" or "Off", the
  default is "All nodes").  This is another pruning technique, where
  the idea is that non-forcing, bad-looking moves late in the move
  list are searched with a reduced depth.  "All nodes" means that the
  technique is applied at all positions in the game tree.  "Non-PV
  nodes" means that late move reductions are avoided at a class of
  particularly critical tree nodes known as "PV nodes".  I am not sure
  which one of "All nodes" or "Non-PV nodes" is better.

* "Reduce based on" ("Knowledge and history", "Knowledge" or
  "History", the default is "History").  The main criterion used to
  decide which moves to reduce when using late move reductions.
  "Knowledge" means that the program uses its evaluation function to
  decide whether a move is worth searching to full depth, while
  "History" means that the decision is based on how often the move has
  been successful in the past.  "Knowledge and history" is a
  combination of the two.  It is not clear which of the three options
  is the best.

* "Futility pruning" ("All nodes", "Non-PV nodes" or "Off", the default
  is "Non-PV nodes").  A pruning technique used when the remaining
  depth is low:  If the current position looks bad, only promotions,
  checks and big captures are searched.  For instance, if the side to
  move is a queen down, captures of a pawn or a minor piece will not
  be searched.

* "Futility margin 0", "Futility margin 1", "Futility margin 2"
  (between 0 and 1000, the defaults are 100, 150 and 300).  These are
  the safety margins used in futility pruning when the remaining depth
  is 0, 1 or 2.  A value of 100 means one pawn.  Smaller margins will
  speed up the search, but also increase the number of tactical and
  positional errors.

* "Check extension" (between 0 and 60, the default is 60), "Single
  reply to check extension" (between 0 and 60, the default is 45), "Two
  replies to check extension" (between 0 and 60, the default is 20),
  "Mate threat extension" (between 0 and 60, the default is 45) and
  "Pawn push to 7th rank extension" (between 0 and 60, the default is
  45).  These settings control how much the search depth is increased
  in different kinds of situations.  A value of 60 means a full ply.

* "Threat depth" (between 0 and 12, the default is 5).  In the last
  few plies of its search, Glaurung searches some kinds of tactical
  and positional threats more deeply.  The "threat depth" setting
  controls how close to the leaves this is done.

* "Checks in quiescence search" (between 0 and 11, the default is 3).
  Glaurung, like most chess programs, uses a special kind of search
  called a quiescence search at the end of the normal search.  In the
  quiescence search, only captures, promotions and some checks are
  searched.  The "checks in quiescence search" parameter determine how
  many plies of checks are allowed in the quiescence search.  Higher
  values will enable the program to find some tactical shots a bit
  earlier, at the price of increasing the tree size.  The optimal
  value is probably somewhere in the range 1-3.

* "Hash quiescence search" (on or off, the default is on).  The "hash
  table" is a huge chunk of memory the program uses to store the
  search results of positions it has encountered previously in the
  search.  You can choose whether the program should use the hash
  table in the quiescence search.  Disabling the hash table in the
  quiescense search will increase the nodes/second count of the
  program, but also increase the number of nodes needed to reach a
  given depth.  On single-CPU systems, it is almost certainly best to
  keep the hash table enabled in the quiescence search.  It is
  possible, however, that disabling hashing in the quiescence search
  will speed up the search on certain kinds of multi-CPU systems (with
  at least 4 CPUs).

* "Position learning" (on or off, the default is off).  When this
  setting is enabled, Glaurung will remember the positions it has
  searched in the past, and make use of the search results when it
  encounters the same positions again.  This data is saved to disk (in
  the file named "learn.bin"), and is used again even if you exit and
  restart the program.  Position learning probably doesn't have any
  impact on playing strength, but it can be useful when using the
  program for interactive analysis.

* "Number of threads" (between 1 and 4, the default is 2).  Only
  available in the SMP version of Glaurung.  For optimal performance,
  this should match the number of CPUs in your computer.  Note that if
  you have a dual-core CPU (like the Intel Core Duo or the AMD64 X2),
  this counts as two CPUs.

* "Minimum tree split depth" (between 4 and 7, the default is 5).
  Only available in the SMP version of Glaurung.  This controls how
  close to the leaves the program allows splitting the trees between
  the available CPUs.  It seems that 4 or 5 works best on dual-CPU
  systems, but it is possible that higher values will perform better
  on computers with a bigger number of CPUs.


4. Opening book
---------------

An opening book for Glaurung is available as a separate download.
This book is quite bad, and not tuned for Glaurung's style of play.
If your favorite GUI includes an opening book, using the GUI book
rather than Glaurung's own book is recommended.

Please note that Glaurung 1.0 and later versions use a new book
format.  The opening book from Glaurung Mainz and older versions will
not work in Glaurung 1.0.


5. Compiling the source code
----------------------------

The procedure for compiling the source code depends on the OS and C
compiler you are using.  On most Unix systems with GCC installed, you
should be able to compile the program simply by unpacking the source
code, cd-ing to the directory containing the source files, and typing
'make'.  There is only one very important thing to be aware of:

IMPORTANT: If you compile the source code unmodified, you will get an
SMP binary which by default runs with two threads.  This binary will
be very slow and weak if you run it on a single-CPU computer, unless
you remember to set the "Number of threads" CUI parameter to 1.  A
better solution is to compile a binary without SMP support.  This is
done by editing the glaurung.h file and commenting out the line with
"#define SMP" (near the top of the file).


6. Acknowledgments
------------------

Thanks to the big, friendly and helpful amateur computer chess
community, chess programming is no longer a very difficult endeavour
(unless you want to become a world champion).  The list of friendly
programmers who have helped me learn the craft of chess programming is
long.  I have learned a lot from Ryan Benitez, Dieter Buerssner,
Anthony Cozzie, Vincent Diepeveen, Dusan Dobes, Sune Fischer, Robert
Hyatt, Sergei Markoff, Richard Pijl, Fritz Reul, Ed Schroder, Chris
Whittington, and many other programmers at the Computer Chess Club and
the Winboard Forum.  A special thanks to the following three people:

* Peter Fendrich, who first introduced me to chess programming.

* Grzegorz Sidorowicz, for encouraging me to write a hexagonal chess
  program, and for his advice during the development process.

* Fabien Letouzey, for generously sharing thoughts, ideas and code,
  for creating Fruit and PolyGlot, and most of all for being the best
  of my many friends in the computer chess community.

No less important than the programmers are the many enthusiasts who
run matches and tournaments between amateur chess engines.  Without
their help, chess programming would not be nearly as fun to do.  A big
thanks to Robert Allgeuer, Graham Banks, Christian Bartsch, Roger
Brown, Patrick Buchmann, Dann Corbit, Olivier Deville, Leo Dijksman,
Wolfgang Draeger, Peter Eizenhammer, Igor Gorelikov, Eelco de Groot,
Lars Hallerström, Heinz van Kempen, Christian Koch, Gabriel Leperlier,
Günther Simon, Kurt Utzinger, Ciro Vignotto, Uschi, and all the other
testers out there.

Thanks to Jim Ablett, Dann Corbit, Bryan Hofmann and Fritz Reul for
compiling optimised Windows binaries of my program.


7. Feedback
-----------

If you have questions, comments or wishes for new features in future
versions of Glaurung, feel free to contact me.  My e-mail address is
tord@glaurungchess.com.

