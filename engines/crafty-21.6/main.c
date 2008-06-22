#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"
#if defined(UNIX) || defined(AMIGA)
#  include <unistd.h>
#  include <pwd.h>
#  include <sys/types.h>
#endif
#if defined(NUMA) && defined(LINUX)
#  include <numa.h>
#endif
#include <signal.h>

/* last modified 03/08/07 */
/*
 *******************************************************************************
 *                                                                             *
 *  Crafty, copyright 1996-2007 by Robert M. Hyatt, Ph.D., Associate Professor *
 *  of Computer and Information Sciences, University of Alabama at Birmingham. *
 *                                                                             *
 *  Crafty is a team project consisting of the following members.  These are   *
 *  the people involved in the continuing development of this program, there   *
 *  are no particular members responsible for any specific aspect of Crafty.   *
 *                                                                             *
 *     Michael Byrne, Pen Argyle, PA.                                          *
 *     Robert Hyatt, University of Alabama at Birmingham.                      *
 *     Tracy Riegle, Houston, TX.                                              *
 *     Peter Skinner, Edmonton, AB  Canada.                                    *
 *                                                                             *
 *  All rights reserved.  No part of this program may be reproduced in any     *
 *  form or by any means, for other than your personal use, without the        *
 *  express written permission of the authors.  This program may not be used   *
 *  in whole, nor in part, to enter any computer chess competition without     *
 *  written permission from the authors.  Such permission will include the     *
 *  requirement that the program be entered under the name "Crafty" so that    *
 *  the program's ancestry will be known.                                      *
 *                                                                             *
 *  Copies of the source must contain the original copyright notice intact.    *
 *                                                                             *
 *  Any changes made to this software must also be made public to comply with  *
 *  the original intent of this software distribution project.  These          *
 *  restrictions apply whether the distribution is being done for free or as   *
 *  part or all of a commercial product.  The authors retain sole ownership    *
 *  and copyright on this program except for 'personal use' explained below.   *
 *                                                                             *
 *  personal use includes any use you make of the program yourself, either by  *
 *  playing games with it yourself, or allowing others to play it on your      *
 *  machine,  and requires that if others use the program, it must be clearly  *
 *  identified as "Crafty" to anyone playing it (on a chess server as one      *
 *  example).  Personal use does not allow anyone to enter this into a chess   *
 *  tournament where other program authors are invited to participate.  IE you *
 *  can do your own local tournament, with Crafty + other programs, since this *
 *  is for your personal enjoyment.  But you may not enter Crafty into an      *
 *  event where it will be in competition with other programs/programmers      *
 *  without permission as stated previously.                                   *
 *                                                                             *
 *  Crafty is the "son" (direct descendent) of Cray Blitz.  it is designed     *
 *  totally around the bit-board data structure for reasons of speed of ex-    *
 *  ecution, ease of adding new knowledge, and a *significantly* cleaner       *
 *  overall design.  it is written totally in ANSI C with some few UNIX system *
 *  calls required for I/O, etc.                                               *
 *                                                                             *
 *  main() is the driver for the chess program.  its primary function is to    *
 *  cycle between asking the user for a move and calling for a tree search     *
 *  to produce a move for the program.  after accepting an input string from   *
 *  the user, this string is first passed to Option() which checks to see if   *
 *  it is a command to the program.  if Option() returns a non-zero result,    *
 *  the input was a command and was executed, otherwise the input should be    *
 *  passed to input() for conversion to the internal move format.              *
 *                                                                             *
 *  the following diagrams show how the bits are numbered in Crafty's bitboard *
 *  data structures, and how the bits are numbered and rotated.  Note that bit *
 *  zero (0) is the LSB of a BITBOARD value.                                   *
 *                                                                             *
 *  Normal:                                                                    *
 *                                                                             *
 *  H8 G8 F8 E8 D8 C8 B8 A8                                                    *
 *  H7 G7 F7 E7 D7 C7 B7 A7                                                    *
 *  H6 G6 F6 E6 D6 C6 B6 A6                                                    *
 *  H5 G5 F5 E5 D5 C5 B5 A5                                                    *
 *  H4 G4 F4 E4 D4 C4 B4 A4                                                    *
 *  H3 G3 F3 E3 D3 C3 B3 A3                                                    *
 *  H2 G2 F2 E2 D2 C2 B2 A2                                                    *
 *  H1 G1 F1 E1 D1 C1 B1 A1                                                    *
 *                                                                             *
 *  63 62 61 60 59 58 57 56                                                    *
 *  55 54 53 52 51 50 49 48                                                    *
 *  47 46 45 44 43 42 41 40                                                    *
 *  39 38 37 36 35 34 33 32                                                    *
 *  31 30 29 28 27 26 25 24                                                    *
 *  23 22 21 20 19 18 17 16                                                    *
 *  15 14 13 12 11 10  9  8                                                    *
 *   7  6  5  4  3  2  1  0                                                    *
 *                                                                             *
 *  Right 90:                                                                  *
 *                                                                             *
 *   7 15 23 31 39 47 55 63                                                    *
 *   6 14 22 30 38 46 54 62                                                    *
 *   5 13 21 29 37 45 53 61                                                    *
 *   4 12 20 28 36 44 52 60                                                    *
 *   3 11 19 27 35 43 51 59                                                    *
 *   2 10 18 26 34 42 50 58                                                    *
 *   1  9 17 25 33 41 49 57                                                    *
 *   0  8 16 24 32 40 48 56                                                    *
 *                                                                             *
 *  Right 45:                                                                  *
 *                                                                             *
 *                63                                                           *
 *              55  62                                                         *
 *            47  54  61                                                       *
 *          39  46  53  60             63  55  62  47  54  61  39  46          *
 *        31  38  45  52  59           53  60  31  38  45  52  59  23          *
 *      23  30  37  44  51  58         30  37  44  51  58  15  22  29          *
 *    15  22  29  36  43  50  57       36  43  50  57   7  14  21  28          *
 *   7  14  21  28  35  42  49  56     35  42  49  56   6  13  20  27          *
 *     6  13  20  27  34  41  48       34  41  48   5  12  19  26  33          *
 *       5  12  19  26  33  40         40   4  11  18  25  32   3  10          *
 *         4  11  18  25  32           17  24   2   9  16   1   8   0          *
 *           3  10  17  24                                                     *
 *             2   9  16                                                       *
 *               1   8                                                         *
 *                 0                                                           *
 *                                                                             *
 *  Left 45:                                                                   *
 *                                                                             *
 *                56                                                           *
 *              57  48                                                         *
 *            58  49  40                                                       *
 *          59  50  41  32             56  57  48  58  49  40  59  50          *
 *        60  51  42  33  24           41  32  60  51  42  33  24  61          *
 *      61  52  43  34  25  16         52  43  34  25  16  62  53  44          *
 *    62  53  44  35  26  17   8       35  26  17   8  63  54  45  36          *
 *  63  54  45  36  27  18   9   0     27  18   9   0  55  46  37  28          *
 *    55  46  37  28  19  10   1       19  10   1  47  38  29  20  11          *
 *      47  38  29  20  11   2          2  39  30  21  12   3  31  22          *
 *        39  30  21  12   3           13   4  23  14   5  15   6   7          *
 *          31  22  13   4                                                     *
 *            23  14   5                                                       *
 *              15   6                                                         *
 *                 7                                                           *
 *                                                                             *
 *                                                                             *
 *  version  description                                                       *
 *                                                                             *
 *    1.0    first version of the bit-board program to play a legitimate game  *
 *           even though significant features are missing:  transposition      *
 *           table, sophisticated scoring, etc.                                *
 *                                                                             *
 *    1.1    added the minimal window search.  at each ply in the tree, the    *
 *           first branch is searched with the normal alpha/beta window, while *
 *           remaining nodes are searched with value/value+1 which was         *
 *           returned from searching the first branch.  If such a search       *
 *           returns the upper bound, this position is once again searched     *
 *           with the normal window.                                           *
 *                                                                             *
 *    1.2    added the classic null-move search.  the program searches the     *
 *           sub-tree below the null move (typically) one play shallower than  *
 *           the normal search, saving a lot of time.                          *
 *                                                                             *
 *    1.3    added the transposition table support.  this also includes the    *
 *           code in Iterate() necessary to propagate the principal variation  *
 *           from one iteration to the next to improve move ordering.          *
 *                                                                             *
 *    1.4    modified the transposition table to use three tables, one for 64  *
 *           bits of white entry, one for 64 bits of black entry, and one with *
 *           the remaining 32 bits of white and black entry combined into one  *
 *           64 bit word.  eliminated the "bit fields" since they seemed to be *
 *           erratic on most compilers and made portability nearly impossible. *
 *                                                                             *
 *    1.5    pawn scoring added.  this required three additions to the code:   *
 *           (1) InitializePawnMasks() which produces the necessary masks to   *
 *           let us efficiently detect isolated, backward, passed, etc. pawns; *
 *           (2) a pawn hash table to store recently computed pawn scores so   *
 *           it won't be too expensive to do complex analysis;  (3) Evaluate() *
 *           now evaluates pawns if the current pawn position is not in the    *
 *           pawn hash table.                                                  *
 *                                                                             *
 *    1.6    piece scoring added, although it is not yet complete.  also, the  *
 *           search now uses the familiar zero-width window search for all but *
 *           the first move at the root, in order to reduce the size of the    *
 *           tree to a nearly optimal size.  this means that a move that is    *
 *           only one point better than the first move will "fail high" and    *
 *           have to be re-searched a second time to get the true value.  if   *
 *           the new best move is significantly better, it may have to be      *
 *           searched a third time to increase the window enough to return the *
 *           score.                                                            *
 *                                                                             *
 *    1.7    replaced the old "killer" move ordering heuristic with the newer  *
 *           "history" ordering heuristic.   this version uses the 12-bit key  *
 *           formed by <from><to> to index into the history table.             *
 *                                                                             *
 *    1.8    added pondering for both PC and UNIX-based machines.  also other  *
 *           improvements include the old Cray Blitz algorithm that takes the  *
 *           P.V. returned by the tree search, and "extends" it by looking up  *
 *           positions in the transposition table, which improves move         *
 *           ordering significantly.  repetitions are now handled correctly.   *
 *                                                                             *
 *    1.9    added an opening book with flags to control which moves are       *
 *           selected for play.  the book maintenance code is stubbed directly *
 *           into the program, so that no additional executables are needed.   *
 *                                                                             *
 *    1.10   added king safety + hashing (as done in the old Cray Blitz).      *
 *           nothing novel other than the use of bit-masks to speed up some of *
 *           the tests.                                                        *
 *                                                                             *
 *    1.11   additional evaluation knowledge plus log_file so that program     *
 *           saves a record of the game statistics for later analysis.  added  *
 *           the "annotate" command to make the program analyze a game or part *
 *           of a game for testing/debugging.                                  *
 *                                                                             *
 *    1.12   added ICS (Internet Chess Server) support for Xboard support so   *
 *           that Crafty can play on ICS in an automated manner.  added new    *
 *           commands to be compatible with Xboard.  Crafty also has a new     *
 *           command-line interface that allows options to be entered on the   *
 *           command-line directly, ie:  "crafty alarm=off verbose=2" will     *
 *           start the program, set the move alarm off, and set verbose to     *
 *           2.  this allows an "alias" to easily customize the program.       *
 *                                                                             *
 *    1.13   added time-control logic to the program.  it now monitors how     *
 *           much time both it and its opponent uses when thinking about a     *
 *           move to make.  when pondering, it only times itself from the      *
 *           point that a move is actually entered.                            *
 *                                                                             *
 *    1.14   added the piece/square tables to the program to move static       *
 *           scoring to the root of the tree since it never changes (things    *
 *           like centralization of pieces, etc.)  also some minor tuning of   *
 *           numbers to bring positional score "swings" down some.             *
 *                                                                             *
 *    1.15   added edit so that positions can be altered (and so ICS games     *
 *           can be resumed after they are adjourned).  also added a "force"   *
 *           command to force the program to play a different move than the    *
 *           search selected.  search timing allocation slightly altered to    *
 *           improve ICS performance.                                          *
 *                                                                             *
 *    1.16   significant adjustments to evaluation weights to bring positional *
 *           scores down to below a pawn for "normal" positions.  some small   *
 *           "tweaks" to king safety as well to keep the king safer.           *
 *                                                                             *
 *    1.17   added "development" evaluation routine to encourage development   *
 *           and castling before starting on any tactical "sorties."  also     *
 *           repaired many "bugs" in evaluation routines.                      *
 *                                                                             *
 *    1.18   added the famous Cray Blitz "square of the king" passed pawn      *
 *           evaluation routine.  this will evaluate positions where one       *
 *           side has passed pawns and the other side has no pieces, to see    *
 *           if the pawn can outrun the defending king and promote.  note that *
 *           this is rediculously fast because it only requires one AND        *
 *           to declare that a pawn can't be caught!                           *
 *                                                                             *
 *    2.0    initial version preparing for search extension additions.  this   *
 *           version has a new "next_evasion()" routine that is called when    *
 *           the king is in check.  it generates sensible (nearly all are      *
 *           legal) moves which include capturing the checking piece (if there *
 *           is only one), moving the king (but not along the checking ray),   *
 *           and interpositions that block the checking ray (if there is only  *
 *           one checking piece.                                               *
 *                                                                             *
 *    2.1    search is now broken down into three cleanly-defined phases:      *
 *           (1) basic full-width search [Search()]; (2) extended tactical     *
 *           search [extend()] which includes winning/even captures and then   *
 *           passed pawn pushes to the 6th or 7th rank (if the pawn pushes     *
 *           are safe);  (3) normal quiescence search [Quiesce()] which only   *
 *           includes captures that appear to gain material.                   *
 *                                                                             *
 *    2.2    king safety code re-written and cleaned up.  Crafty was giving    *
 *           multiple penalties which was causing the king safety score to be  *
 *           extremely large (and unstable.)  now, if it finds something wrong *
 *           with king safety, it only penalizes a weakness once.              *
 *                                                                             *
 *    2.3    king safety code modified further, penalties were significant     *
 *           enough to cause search anomolies.  modified rook scoring to avoid *
 *           having the rook trapped in the corner when the king is forced to  *
 *           move rather than castle, and to keep the rook in a position to be *
 *           able to reach open files in one move, which avoids getting them   *
 *           into awkward positions where they become almost worthless.        *
 *                                                                             *
 *    2.4    king safety code completely rewritten.  it now analyzes "defects" *
 *           in the king safety field and counts them as appropriate.  these   *
 *           defects are then summed up and used as an index into a vector of  *
 *           of values that turns them into a score in a non-linear fashion.   *
 *           increasing defects quickly "ramp up" the score to about 1/3+ of   *
 *           a pawn, then additional faults slowly increase the penalty.       *
 *                                                                             *
 *    2.5    first check extensions added.  in the extension search (stage     *
 *           between full-width and captures-only, up to two checking moves    *
 *           can be included, if there are checks in the full-width part of    *
 *           the search.  if only one check occurs in the full-width, then     *
 *           only one check will be included in the extension phase of the     *
 *           selective search.                                                 *
 *                                                                             *
 *    2.6    evaluation modifications attempting to cure Crafty's frantic      *
 *           effort to develop all its pieces without giving a lot of regard   *
 *           to the resulting position until after the pieces are out.         *
 *                                                                             *
 *    2.7    new evaluation code to handle the "outside passed pawn" concept.  *
 *           Crafty now understands that a passed pawn on the side away from   *
 *           the rest of the pawns is a winning advantage due to decoying the  *
 *           king away from the pawns to prevent the passer from promoting.    *
 *           the advantage increases as material is removed from the board.    *
 *                                                                             *
 *    3.0    the 3.* series of versions will primarily be performance en-      *
 *           hancements.  the first version (3.0) has a highly modified        *
 *           version of MakeMove() that tries to do no unnecessary work.  it   *
 *           is about 25% faster than old version of MakeMove() which makes    *
 *           Crafty roughly 10% faster.  also calls to Mask() have been        *
 *           replaced by constants (which are replaced by calls to Mask() on   *
 *           the Crays for speed) to eliminate function calls.                 *
 *                                                                             *
 *    3.1    significantly modified king safety again, to better detect and    *
 *           react to king-side attacks.  Crafty now uses the recursive null-  *
 *           move search to depth-2 instead of depth-1, which results in       *
 *           slightly improved speed.                                          *
 *                                                                             *
 *    3.2    null-move restored to depth-1.  depth-2 proved unsafe as Crafty   *
 *           was overlooking tactical moves, particularly against itself,      *
 *           which lost several "won" games.                                   *
 *                                                                             *
 *    3.3    additional king-safety work.  Crafty now uses the king-safety     *
 *           evaluation routines to compare king safety for both sides.  if    *
 *           one side is "in distress" pieces are attracted to that king in    *
 *           "big hurry" to either attack or defend.                           *
 *                                                                             *
 *    3.4    "threat extensions" added.  simply, this is a null-move search    *
 *           used to determine if a move is good only because it is a horizon  *
 *           effect type move.  we do a null move search after a move fails    *
 *           high anywhere in the tree.  the window is normally lowered by 1.5 *
 *           pawns, the idea being that if the fail-high move happens in a     *
 *           position that fails "really low" with a null move, then this move *
 *           might be a horizon move.  to test this, re-search this move with  *
 *           the depth increased by one.                                       *
 *                                                                             *
 *    3.5    50-move rule implemented.  a count of moves since the last pawn   *
 *           move or capture is kept as part of the position[] structure.  it  *
 *           is updated by MakeMove().  when this number reaches 100 (which    *
 *           in plies is 50 moves) RepetitionCheck() will return the draw      *
 *           score immediately, just as though the position was a repetition   *
 *           draw.                                                             *
 *                                                                             *
 *    3.6    search extensions cleaned up to avoid excessive extensions which  *
 *           produced some wild variations, but which was also slowing things  *
 *           down excessively.                                                 *
 *                                                                             *
 *    3.7    endgame strategy added.  two specifics: KBN vs K has a piece/sq   *
 *           table that will drive the losing king to the correct corner.  for *
 *           positions with no pawns, scoring is altered to drive the losing   *
 *           king to the edge and corner for mating purposes.                  *
 *                                                                             *
 *    3.8    hashing strategy modified.  Crafty now stores search value or     *
 *           bound, *and* positional evaluation in the transposition table.    *
 *           this avoids about 10-15% of the "long" evaluations during the     *
 *           middlegame, and avoids >75% of them in endgames.                  *
 *                                                                             *
 *    4.0    evaluation units changed to "millipawns" where a pawn is now      *
 *           1000 rather than the prior 100 units.  this provides more         *
 *           "resolution" in the evaluation and will let Crafty have large     *
 *           positional bonuses for significant things, without having the     *
 *           small positional advantages add up and cause problems.  V3.8      *
 *           exhibited a propensity to "sac the exchange" frequently because   *
 *           of this.  it is hoped that this is a thing of the past now.       *
 *           also, the "one legal reply to check" algorithm is now being used. *
 *           in short, if one side has only one legal reply to a checking move *
 *           then the other side is free to check again on the next ply. this  *
 *           only applies in the "extension" search, and allows some checks    *
 *           that extend() would normally not follow.                          *
 *                                                                             *
 *    4.1    extension search modified.  it now "tracks" the basic iteration   *
 *           search depth up to some user-set limit (default=6).  for shallow  *
 *           depths, this speeds things up, while at deeper depths it lets the *
 *           program analyze forcing moves somewhat deeper.                    *
 *                                                                             *
 *    4.2    extension search modified.  fixed a problem where successive      *
 *           passed-pawn pushes were not extended correctly by extend() code.  *
 *           threat-extension margin was wrong after changing the value of a   *
 *           pawn to 1000, it is now back to 1.5 pawns.                        *
 *                                                                             *
 *    4.3    hash scoring "repaired."  as the piece/square tables changed, the *
 *           transposition table (positional evaluation component) along with  *
 *           the pawn and king-safety hash tables prevented the changes from   *
 *           affecting the score, since the hashed scores were based on the    *
 *           old piece/square table values.  now, when any piece/square table  *
 *           is modified, the affected hash tables are cleared fo evaluation   *
 *           information.                                                      *
 *                                                                             *
 *    4.4    piece/square tables simplified, king tropism scoring moved to     *
 *           Evaluate() where it is computed dynamically now as it should be.  *
 *                                                                             *
 *    4.5    book move selection algorithm replaced.  Crafty now counts the    *
 *           number of times each book move was played as the book file is     *
 *           created.  since these moves come (typically) from GM games, the   *
 *           more frequently a move appears, the more likely it is to lead to  *
 *           a sound position.  Crafty then enumerates all possible book moves *
 *           for the current position, computes a probability distribution for *
 *           each move so that Crafty will select a move proportional to the   *
 *           number of times it was played in GM games (for example, if e4 was *
 *           played 55% of the time, then Crafty will play e4 55% of the time) *
 *           although the special case of moves played too infrequently is     *
 *           handled by letting the operator set a minimum threshold (say 5)   *
 *           Crafty won't play moves that are not popular (or are outright     *
 *           blunders as the case may be.)  pushing a passed pawn to the 7th   *
 *           rank in the basic search [Search() module] now extends the search *
 *           by two plies unless we have extended this ply already (usually a  *
 *           check evasion) or unless we have extended the whole line to more  *
 *           than twice the nominal iteration depth.                           *
 *                                                                             *
 *    5.0    selective search extensions removed.  with the extensions now in  *
 *           the basic full-width search, these became more a waste of time    *
 *           than anything useful, and removing them simplifies things quite   *
 *           a bit.                                                            *
 *                                                                             *
 *    5.1    pondering logic now has a "puzzling" feature that is used when    *
 *           the search has no move to ponder.  it does a short search to find *
 *           a move and then ponders that move, permanently eliminating the    *
 *           "idle" time when it has nothing to ponder.                        *
 *                                                                             *
 *    5.2    evaluation terms scaled down to prevent positional scores from    *
 *           reaching the point that sacrificing material to avoid simple      *
 *           positional difficulties begins to look attractive.                *
 *                                                                             *
 *    5.3    performance improvement produced by avoiding calls to MakeMove()  *
 *           when the attack information is not needed.  since the first test  *
 *           done in Quiesce() is to see if the material score is so bad that  *
 *           a normal evaluation and/or further search is futile, this test    *
 *           has been moved to inside the loop *before* Quiesce() is           *
 *           recursively called, avoiding the MakeMove() work only to          *
 *           discover that the resulting position won't be searched further.   *
 *                                                                             *
 *    5.4    new Swap() function that now understands indirect attacks through *
 *           the primary attacking piece(s).  this corrects a lot of sloppy    *
 *           move ordering as well as make the "futility" cutoffs added in     *
 *           in version 5.3 much more reliable.                                *
 *                                                                             *
 *    5.5    checks are now back in the quiescence search.  Crafty now stores  *
 *           a negative "draft" in the transposition table rather than forcing *
 *           any depth < 0 to be zero.  the null-move search now searches the  *
 *           null-move to depth-1 (R=1) rather than depth-2 (R=2) which seemed *
 *           to cause some tactical oversights in the search.                  *
 *                                                                             *
 *    5.6    improved move ordering by using the old "killer move" idea.  an   *
 *           additional advantage is that the killers can be tried before      *
 *           generating any moves (after the captures.)  quiescence now only   *
 *           includes "safe" checks (using Swap() to determine if it is a safe *
 *           checking move.                                                    *
 *                                                                             *
 *    5.7    king safety now "hates" a pawn at b3/g3 (white) or b6/g6 (black)  *
 *           to try and avoid the resulting mate threats.                      *
 *                                                                             *
 *    5.8    EvaluateOutsidePassedPawns() fixed to correctly evaluate those    *
 *           positions where both sides have outside passed pawns.  before     *
 *           this fix, it only evaluated positions where one side had a passed *
 *           pawn, which overlooked those won/lost positions where both sides  *
 *           have passed pawns but one is "distant" or "outside" the other.    *
 *                                                                             *
 *    5.9    removed "futility" forward pruning.  exhaustive testing has       *
 *           proved that this causes significant tactical oversights.          *
 *                                                                             *
 *    5.10   added code to handle king and pawn vs king, which understands     *
 *           the cases where the pawn can't outrun the king, but has to be     *
 *           assisted along by the king.                                       *
 *                                                                             *
 *    5.11   two king-safety changes.  (1) the program's king safety score is  *
 *           now "doubled" to make it much less likely that it will try to win *
 *           a pawn but destroy it's king-side.  (2) the attack threshold has  *
 *           been lowered which is used to key the program that it is now      *
 *           necessary to move pieces to defend the king-side, in an effort to *
 *           protect a king-side that is deemed somewhat unsafe.               *
 *                                                                             *
 *    5.12   improved null-move code by computing the Knuth/Moore node type    *
 *           and then only trying null-moves at type 2 nodes.  this has        *
 *           resulted in a 2x speedup in test positions.                       *
 *                                                                             *
 *    5.13   optimization to avoid doing a call to MakeMove() if it can be     *
 *           avoided by noting that the move is not good enough to bring the   *
 *           score up to an acceptable level.                                  *
 *                                                                             *
 *    5.14   artificially isolated pawns recognized now, so that Crafty won't  *
 *           push a pawn so far it can't be defended.  also, the bonus for a   *
 *           outside passed pawn was nearly doubled.                           *
 *                                                                             *
 *    5.15   passed pawns supported by a king, or connected passed pawns now   *
 *           get a large bonus as they advance.  minor fix to the ICC resume   *
 *           feature to try to avoid losing games on time.                     *
 *                                                                             *
 *    6.0    converted to rotated bitboards to make attack generation *much*   *
 *           faster.  MakeMove() now can look up the attack bit vectors        *
 *           rather than computing them which is significantly faster.         *
 *                                                                             *
 *    6.1    added a "hung piece" term to Evaluate() which penalizes the side  *
 *           to move if a piece is attacked by a lesser piece, or a piece is   *
 *           attacked and not defended at all.  additionally, a new scoring    *
 *           term was added to detect a weak back rank (where the king does    *
 *           not attack an empty square on the 2nd rank, and there are no      *
 *           horizontally sliding pieces [rook or queen] on the first rank to  *
 *           guard against back-rank mates.                                    *
 *                                                                             *
 *    6.2    modified the "futility" cutoff to (a) emulate the way the program *
 *           normally searches, but avoiding MakeMove() calls when possible,   *
 *           and (2) not searching a move near the horizon if the material     *
 *           score is hopeless.                                                *
 *                                                                             *
 *    6.3    null-move code moved from NextMove() directly into Search().      *
 *           this results is a "cleaner" implementation, as well as fixing an  *
 *           error in the node type, caused by Search() thinking that after    *
 *           the first move tried fails to cause a cutoff, that suddenly this  *
 *           node is a type=3 node (Knuth and Moore).  this bug would then     *
 *           introduce null-moves into later nodes that are a waste of time.   *
 *                                                                             *
 *    6.4    pawn scoring modified.  passed pawns were scored low enough that  *
 *           Crafty would let the opponent create one in the endgame (as long  *
 *           as it wasn't an "outside" passed pawn).  this required adjusting  *
 *           isolated pawns as well.  all "weak" pawns (pawns on open files    *
 *           that aren't defended by a pawn) are not penalized so much if      *
 *           there aren't any rooks/queens to attack on the file.              *
 *                                                                             *
 *    7.0    removed the to.attack and from.attack bitboards.  these are now   *
 *           computed as needed, using the rotated bitboards.  hung piece      *
 *           stuff removed due to lack of any verified benefit.                *
 *                                                                             *
 *    7.1    modified next.c and nextc.c so that they check "mvv_lva_ordering" *
 *           to determine which capture ordering strategy to use.  note that   *
 *           setting this to "1" (default at present) disables the forward     *
 *           pruning in quiescence search that wants to cull losing captures.  *
 *                                                                             *
 *    7.2    major clean-up of MakeMove() using macros to make it easier to    *
 *           read and understand.  ditto for other modules as well.  fixed a   *
 *           bug in Evaluate() where bishop scoring failed in endgame          *
 *           situations, and discouraged king centralization.                  *
 *                                                                             *
 *    7.3    Evaluate() is no longer called if material is too far outside the *
 *           current alpha/beta window.  the time-consuming part of Evaluate() *
 *           is no longer done if the major scoring contributors in Evaluate() *
 *           haven't pulled the score within the alpha/beta window, and the    *
 *           remainder of Evaluate() can't possible accomplish this either.    *
 *           gross error in EvaluatePawns() fixed, which would "forget" all    *
 *           of the pawn scoring done up to the point where doubled white      *
 *           pawns were found.  error was xx=+ rather than xx+=, which had     *
 *           an extremely harmful effect on pawn structure evaluation.         *
 *                                                                             *
 *    7.4    performance improvements produced by elimination of bit-fields.   *
 *           this was accomplished by hand-coding the necessary ANDs, ORs, and *
 *           SHIFTs necessary to accomplish the same thing, only faster.       *
 *                                                                             *
 *    7.5    repetition code modified.  it could store at replist[-1] which    *
 *           clobbered the long long word just in front of this array.         *
 *                                                                             *
 *    7.6    null move search now searches with R=2, unless within 3 plies     *
 *           of the quiescence search, then it searches nulls with R=1.        *
 *                                                                             *
 *    8.0    re-vamp of evaluation, bringing scores back down so that Crafty   *
 *           will stop sacrificing the exchange, or a piece for two pawns just *
 *           it thinks it has lots of positional compensation.  the next few   *
 *           versions are going to be tuning or coding modifications to eval.  *
 *                                                                             *
 *    8.1    Futility() re-written to be more efficient, as well as to stop    *
 *           tossing moves out based on the +/- 2 pawn window, which was too   *
 *           speculative.  it still saves roughly 20% in speed over the same   *
 *           searches without futility, but seems to have *no* harmful effects *
 *           in tests run to date.                                             *
 *                                                                             *
 *    8.2    Futility() removed once and for all.  since MakeMove() is so      *
 *           fast after the new attack generation algorithm, this was actually *
 *           slower than not using it.                                         *
 *                                                                             *
 *    8.3    EvaluatePawns() weak pawn analysis bug fixed.  other minor        *
 *           performance enhancements and cleanup.                             *
 *                                                                             *
 *    8.4    dynamic "king tropism" evaluation term now used, which varies     *
 *           based on how exposed the target king is.  the more exposed, the   *
 *           larger the bonus for placing pieces near the king.  new "analyze" *
 *           feature that complements the "annotate" feature that Crafty has   *
 *           had for a while.  "annotate" is used to play over moves that are  *
 *           either in the current game history, or have been read in using    *
 *           the "read <filename>" command.  analyze, on the other hand, will  *
 *           immediately begin searching the current position.  each time the  *
 *           operator enters a move, it will make that move on the board, and  *
 *           then search the resulting position for the other side.  in effect *
 *           this gives a running commentary on a "game in progress".  these   *
 *           moves can be pumped into Crafty in many ways so that "on the fly" *
 *           analysis of a game-in-progress is possible.                       *
 *                                                                             *
 *    8.5    more cleanup.  pawn promotions were searched twice, thanks to the *
 *           killer moves, although often they resulted in no search overhead  *
 *           due to transposition table hits the second time around.  other    *
 *           minor fixes, including one serious "undefined variable" in        *
 *           Evaluate() that caused grief in endings.                          *
 *                                                                             *
 *    8.6    new book file structure.  it is no longer necessary to enter the  *
 *           "number of records" as Crafty now uses a new compressed hashing   *
 *           technique so that the book has no empty space in it, and the size *
 *           is computed "on the fly" producing a smaller book without the     *
 *           user having to compute the size.  tweaks to Evaluate() to cure    *
 *           minor irritating habits.                                          *
 *                                                                             *
 *    8.7    repaired optimization made in null-move search, that forgot to    *
 *           clear "EnPassant_Target".  a double pawn push, followed by a null *
 *           left the side on move "very confused" and would let it play an    *
 *           illegal enpassant capture in the tree. sort.<n> files are now     *
 *           removed after book.bin is created.  also, minor change to book    *
 *           format makes it incompatible with older book versions, but also   *
 *           allows book lines to be as long as desired, and the book size to  *
 *           reach any reasonable size.  dynamic king tropism replaced by a    *
 *           dynamic computation, but with a static king tropism score, rather *
 *           than a score based on king exposure.  there was simply too much   *
 *           interaction, although this may prove workable later.              *
 *                                                                             *
 *    8.8    tweaks to passed pawn scoring.  scores were too low, making       *
 *           Crafty "ignore" them too much.                                    *
 *                                                                             *
 *    8.9    internal iterative deepening is now used in those rare positions  *
 *           where a PV node has no hash move to search.  this does a shallow  *
 *           search to depth-2 to find a good move for ordering.               *
 *                                                                             *
 *    8.10   internal interative deepening modified to handle cases where lots *
 *           of tactics make the deepening search fail high or low, and        *
 *           occasionally end up with no move to try.  this produced a "bad    *
 *           move from hash table" error.                                      *
 *                                                                             *
 *    8.11   minor bug in internal iterative deepening fixed.  also, macros    *
 *           for accessing the "position" data structure are now used to make  *
 *           things a little more readable.                                    *
 *                                                                             *
 *    8.12   fixed minor bugs in quiescence checks, which let Crafty include   *
 *           more checks than intended (default quiescence_checks=2, but the   *
 *           comparison was <= before including a check, which made it include *
 *           three.  Additionally, a hashed check was *always* tried, even if  *
 *           quiescence_checks had already been satisfied.  pawn scoring also  *
 *           had a bug, in that there was a "crack" between opening and middle *
 *           game, where Crafty would conclude that it was in an endgame, and  *
 *           adjust the pawn advance scores accordingly, sometimes causing an  *
 *           odd a4/a5/etc move "out of the blue."  minor bug in next_capture  *
 *           was pruning even exchanges very early in quiescence search.  that *
 *           has now been removed, so only losing exchanges are pruned.        *
 *                                                                             *
 *    8.13   NextCapture() now *always* tries checking moves if the move at    *
 *           the previous ply was a null-move.  this avoids letting the null   *
 *           move hide some serious mating threats.  a minor bug where Crafty  *
 *           could draw by repetition after announcing a mate.  this was a     *
 *           result of finding a mate score in hash table, and, after the      *
 *           search iteration completed, the mate score would terminate the    *
 *           search completely.  now, the search won't terminate until it      *
 *           finds a mate shorter than the previous search did.  minor eval    *
 *           tweaks and bugfixes as well.                                      *
 *                                                                             *
 *    8.14   checks after null moves discontinued.  worked in some cases, but, *
 *           in general made the tree larger for nothing.  eval tweaks to stop *
 *           sacs that resulted in connected passed pawns, often at the        *
 *           expense of a minor piece for a pawn or two, which usually lost.   *
 *           mobility coeffecient increased for all pieces.  asymmetric king   *
 *           safety discontinued.  king safety for both sides is now equally   *
 *           important.  king safety is now also proportional to the number of *
 *           pieces the other side has, so that a disrupted king-side will     *
 *           encourage trading pieces to reduce attacking chances.             *
 *                                                                             *
 *    8.15   weak pawn scoring modified further.  the changes are designed to  *
 *           cause Crafty to keep pawns "mobile" where they can advance,       *
 *           rather than letting them become blocked or locked.                *
 *                                                                             *
 *    8.16   still more weak pawn modifications.  in addition, there is no     *
 *           "rook on half-open file" any longer.  if there are only enemy     *
 *           pawns on the file, and the most advanced one is weak, then the    *
 *           file is treated as though it were open.  technical error in the   *
 *           EvaluateDevelopment() code that caused screwey evaluations is     *
 *           fixed, making Crafty more likely to castle.  :)  Book() now       *
 *           verifies that the current position is in book, before trying any  *
 *           moves to see if the resulting positions are in book.  This avoids *
 *           something like e4 e5 Bb5 a6 Nf3 from causing Crafty to play Nc6   *
 *           which takes it back into book, rather than axb5 winning a piece.  *
 *           this will occasionally backfire and prevent Crafty from trans-    *
 *           posing back into book, but seems safer at present.                *
 *                                                                             *
 *    8.17   piece values changed somewhat, to avoid Crafty's propensity to    *
 *           make unfavorable trades.  an example:  Crafty is faced with the   *
 *           loss of a pawn.  instead, it trades the queen for a rook and      *
 *           bishop, which used to be the same as losing a pawn.  this is not  *
 *           so good, and often would result in a slow loss.  this version     *
 *           also implements several "user-supplied" patches to make Crafty    *
 *           compile cleanly on various machines.  In addition, you no longer  *
 *           have to continually modify types.h for different configurations.  *
 *           the Makefile now supplies a -D<target> to the compiler.  you need *
 *           to edit Makefile and set "target" to the appropriate value from   *
 *           the list provided.  then, when getting a new version, save your   *
 *           Makefile, extract the new source, copy in your makefile and you   *
 *           will be ready, except for those rare occasions where I add a new  *
 *           source module.  other changes are performance tweaks.  one is a   *
 *           simple trick to order captures while avoiding Swap() if possible. *
 *           if the captured piece is more valuable than the capturing piece,  *
 *           we can simply use the difference (pessimistic value) rather than  *
 *           calling Swap() since this pessimistic value is still > 0.  other  *
 *           tweaks to the various Next_*() routines to avoid a little un-     *
 *           necessary work.                                                   *
 *                                                                             *
 *    8.18   book move selection algorithm changed.  note that this is highly  *
 *           speculative, but when best book play is selected, Crafty will     *
 *           use the books.bin file as always.  if there is no move in books,  *
 *           Crafty reverts to book.bin, but now finds all known book moves    *
 *           and puts them into the root move list.  It then does a fairly     *
 *           short search, only considering these moves, and it will play the  *
 *           best one so long as the evaluation is acceptable.  if not, it     *
 *           simply returns as though there was no book move, and executes a   *
 *           search as it normally would.  the book hashing algorithm was also *
 *           modified so that the 64-bit hash key is slightly different from   *
 *           the real hash key.  in effect, the upper 16 bits are only set as  *
 *           a result of the side-not-to-move's pieces.  this means that for a *
 *           given position, all the book moves will be in the same "cluster"  *
 *           which makes the book dramatically faster, since one seek and read *
 *           produces all the possible book moves (plus some others too, since *
 *           the upper 16 bits are not unique enough.)  A significant speed    *
 *           improvement is noticable, particularly with a 60mb opening book.  *
 *           Crafty now understands (if that's the right word) that endings    *
 *           with bishops of opposite colors are to be avoided.  when such an  *
 *           ending is encountered, the total score is simply divided by two   *
 *           to make the ending look more drawish.                             *
 *                                                                             *
 *    8.19   book selection algorithm further modified, so that the result of  *
 *           each game in the GM database is known.  now Crafty will not play  *
 *           a move from book, if all games were lost by the side on move,     *
 *           hopefully avoiding many blunders.  Crafty now understands how to  *
 *           attack if both players castle on opposite sides, by encouraging   *
 *           pawn advances against the kings.  other minor modifications to    *
 *           the eval values.                                                  *
 *                                                                             *
 *    8.20   PVS search finally implemented fully.  problems several months    *
 *           ago prevented doing the PVS search along the PV itself.  this is  *
 *           therefore quite a bit faster, now that it's fully implemented and *
 *           working properly.  elapsed time code modified so that Crafty now  *
 *           uses gettimeofday() to get fractions of a second elapsed time.    *
 *           slight modification time allocation algorithm to avoid using too  *
 *           much time early in the game.                                      *
 *                                                                             *
 *    8.21   courtesy of Mark Bromley, Crafty may run significantly faster on  *
 *           your machine.  there are some options in the Makefile that will   *
 *           eliminate many of the large attack computation long longs, which  *
 *           helps prevent cache thrashing.  on some machines this will be     *
 *           slower, on others 20% (or maybe more) faster.  you'll have to     *
 *           try -DCOMPACT_ATTACKS, and if that's faster, then it's time to    *
 *           try -DUSE_SPLIT_SHIFTS which may help even more.  finally, if you *
 *           are running on a supersparc processor, you can use the fastattack *
 *           assembly module fastattack.s and get another big boost.  (attack  *
 *           function is largest compute user in Crafty at present.) serious   *
 *           search problem fixed.  it turns out that Crafty uses the hash     *
 *           table to pass PV moves from one iteration to the next, but for    *
 *           moves at the root of the tree the hash table has no effect, so a  *
 *           special case was added to RootMoveList to check the list of moves *
 *           and if one matches the PV move, move it to the front of the list. *
 *           this turned out to be critical because after completing a search, *
 *           (say to 9 plies) Crafty makes its move, then chops the first two  *
 *           moves off of the PV and then passes that to iterate to start a    *
 *           search.  this search starts at lastdepth-1 (8 in this case) since *
 *           the n-2 search was already done.  the "bug" showed up however, in *
 *           that RootMoveList() was not checking for the PV move correctly,   *
 *           which meant the root moves were ordered by static eval and static *
 *           exchange evaluation.  Normally not a serious problem, just that   *
 *           move ordering is not so good.  however, suppose that the opponent *
 *           takes a real long time to make a move (say 30 seconds) so that    *
 *           Crafty completes a 10 ply search.  it then starts the next search *
 *           at depth=9, but with the wrong move first.  if the target time is *
 *           not large enough to let it resolve this wrong move and get to the *
 *           other moves on the list, Crafty is "confused" into playing this   *
 *           move knowing absolutely nothing about it.  the result is that it  *
 *           can play a blunder easily.  the circumstances leading to this are *
 *           not common, but in a 60 move game, once is enough.  PV was pretty *
 *           well mis-handled in carrying moves from one search to another     *
 *           (not from one iteration to another, but from one complete search  *
 *           to another) and has been fixed.  a cute glitch concerning storing *
 *           PV from one iteration to another was also fixed, where the score  *
 *           stored was confusing the following search.                        *
 *                                                                             *
 *    8.22   EPD support (courtesy of Steven Edwards [thanks]) is now standard *
 *           in Crafty.  for porting, I'll provide a small test run which can  *
 *           be used to validate Crafty once it's been compiled.               *
 *                                                                             *
 *    8.23   cleanup/speedup in hashing.  HashProbe() and HashStore() now      *
 *           carefully  cast the boolean operations to the most efficient size *
 *           to avoid 64bit operations when only the right 32 bits are         *
 *           significant. RepetitionCheck() code completely re-written to      *
 *           maintain two repetition lists, one for each side.  Quiesce() now  *
 *           handles the repetition check a little different, being careful to *
 *           not call it when it's unimportant, but calling it when            *
 *           repetitions are possible.                                         *
 *                                                                             *
 *    8.24   tweaks for king tropism to encourage pieces to collect near the   *
 *           king, or to encourage driving them away when being attacked.  a   *
 *           modification to Evaluate() to address the problem where Crafty    *
 *           is forced to play Kf1 or Kf8, blocking the rook in and getting    *
 *           into tactical difficulties as a result.  Book problem fixed where *
 *           BookUp was attempting to group moves with a common ancestor       *
 *           position together.  unfortunately, captures were separated from   *
 *           this group, meaning capture moves in the book could never be      *
 *           played.  if a capture was the only move in book, it sort of       *
 *           worked because Crafty would drop out of book (not finding the     *
 *           capture) and then the search would "save" it.  however, if there  *
 *           was a non-capture alternative, it would be forced to play it,     *
 *           making it play gambits, and, often, bad ones.  tablebase support  *
 *           is now in.  the tablebase files can be downloaded from the ftp    *
 *           machine at chess.onenet.net, pub/chess/TB.  currently, Steven     *
 *           Edwards has all interesting 4 piece endings done.  to make this   *
 *           work, compile with -DTABLEBASES, and create a TB directory where  *
 *           Crafty is run, and locate the tablebase files in that directory.  *
 *           if you are running under UNIX, TB can be a symbolic or hard link  *
 *           to a directory anywhere you want.                                 *
 *                                                                             *
 *    8.25   minor repair on draw by repetition.  modified how books.bin was   *
 *           being used.  now, a move in books.bin has its flags merged with   *
 *           the corresponding move from book.bin, but if the move does not    *
 *           exist in book.bin, it is still kept as a book move.  repetitions  *
 *           are now counted as a draw if they occur two times, period.  the   *
 *           last approach was causing problems due to hashing, since the hash *
 *           approach used in Crafty is fairly efficient and frequently will   *
 *           carry scores across several searches.  this resulted in Crafty    *
 *           stumbling into a draw by repetition without knowing.  the con-    *
 *           figuration switch HAS-64BITS has been cleaned up and should be    *
 *           set for any 64bit architecture now, not just for Cray machines.   *
 *                                                                             *
 *    8.26   new search extension added, the well-known "one legal response to *
 *           check" idea.  if there's only one legal move when in check, we    *
 *           extend two plies rather than one, since this is a very forcing    *
 *           move.  also, when one side has less than a rook, and the other    *
 *           has passed pawns, pushing these pawns to the 6th or 7th rank      *
 *           will extend the search one ply, where in normal positions, we     *
 *           only extend when a pawn reaches the 7th rank.                     *
 *                                                                             *
 *    9.0    minor constraint added to most extensions:  we no longer extend   *
 *           if the side on move is either significantly ahead or behind,      *
 *           depending on the extension.  for example, getting out of check    *
 *           won't extend if the side on move is a rook behind, since it's     *
 *           already lost anyway.  we don't extend on passed pawn pushes if    *
 *           the side on move is ahead a rook, since he's already winning.     *
 *           minor adjustments for efficiency as well.  the next few           *
 *           versions in this series will have module names in these comments  *
 *           indicating which modules have been "cleaned" up.  this is an      *
 *           effort at optimizing, although it is currently directed at a line *
 *           by line analysis within modules, rather than major changes that   *
 *           effect more global ideas.  this type of optimization will come at *
 *           a later point in time.                                            *
 *                                                                             *
 *    9.1    NextMove(), NextCapture() and NextEvasion() were re-structured    *
 *           to eliminate unnecessary testing and speed them up significantly. *
 *           EvaluateTrades() was completely removed, since Crafty already has *
 *           positional scores that encourage/discourage trading based on the  *
 *           status of the game.  EvaluateTempo() was evaluated to be a        *
 *           failure and was removed completely.                               *
 *                                                                             *
 *    9.2    Quiesce()) and Search() were modified to be more efficient.  in   *
 *           addition, the null-move search was relaxed so that it always does *
 *           a search to depth-R, even if close to the end of the tree.        *
 *                                                                             *
 *    9.3    Check() is no longer used to make sure a position is legal after  *
 *           MakeMove() called, but before Search() is called recursively.  We *
 *           now use the same approach as Cray Blitz, we make a move and then  *
 *           capture the king at the next ply to prove the position is not a   *
 *           valid move.  if the side-on-move is already in check, we use      *
 *           NextEvasion() which only generates legal moves anyway, so this    *
 *           basically eliminates 1/2 of the calls to Check(), a big win.      *
 *           this resulted in modifications to Search(), Quiesce(), and        *
 *           QuiesceFull().  connected passed pawns on 6th-7th no longer       *
 *           trigger search extensions.  solved some problems like Win at      *
 *           Chess #2, but overall was a loser.                                *
 *                                                                             *
 *    9.4    Lookup now checks the transposition table entry and then informs  *
 *           Search() when it appears that a null move is useless.  this is    *
 *           found when the draft is too low to use the position, but it is at *
 *           least as deep as a null-move search would go, and the position    *
 *           did not cause a fail-high when it was stored.  king-safety was    *
 *           modified again.  the issue here is which king should attract the  *
 *           pieces, and for several months the answer has been the king that  *
 *           is most exposed attracts *all* pieces.  this has been changed to  *
 *           always attract one side's pieces to the other king.  Crafty's     *
 *           asymmetric king-safety was making it overly-defensive, even when  *
 *           the opponent's king was more exposed.  this should cure that and  *
 *           result in more aggressive play.                                   *
 *                                                                             *
 *    9.5    "vestigial code" (left over from who-knows-when) rmoved from      *
 *           Evaluate().  this code used an undefined variable when there was  *
 *           no bishop or knight left on the board, and could add in a penalty *
 *           on random occasions.  quiescence checks removed completely to see *
 *           how this works, since checks extend the normal search significant *
 *           amounts in any case.  QuiesceFull() removed and merged into       *
 *           Quiesce() which is faster and smaller.  first impression: faster, *
 *           simpler, better.  the benefit of no quiescence checks is that the *
 *           exhaustive search goes deeper to find positional gains, rather    *
 *           than following checks excessively.  No noticable loss in tactical *
 *           strength (so far).                                                *
 *                                                                             *
 *    9.6    legal move test re-inserted in Search() since null-moves could    *
 *           make it overlook the fact that a move was illegal.  new assembly  *
 *           code for X86 improves performance about 1/3, very similarly to    *
 *           the results obtained with the sparc-20 assembly code.  this was   *
 *           contributed by Eugene Nalimov and is a welcome addition.          *
 *                                                                             *
 *    9.7    optimizations continuing.  minor bug in pawn evaluation repaired. *
 *           Crafty looked at most advanced white pawn, but least-advanced     *
 *           black pawn on a file when doing its weak pawn evaluation.  the    *
 *           history heuristic was slightly broken, in that it was supposed to *
 *           be incrementing the history count by depth*depth, but this was    *
 *           somehow changed to 7*depth, which was not as good.  assembly      *
 *           language interface fixed to cleanly make Crafty on all target     *
 *           architectures.                                                    *
 *                                                                             *
 *    9.8    the first change was to borrow a time-allocation idea from Cray   *
 *           Blitz.  essentially, when Crafty notices it has used the normal   *
 *           time allotment, rather than exiting the search immediately, it    *
 *           will wait until it selects the next move at the root of the tree. *
 *           the intent of this is that if it has started searching a move     *
 *           that is going to be better than the best found so far, this will  *
 *           take more time, while a worse move will fail low quickly.  Crafty *
 *           simply spends more time to give this move a chance to fail high   *
 *           or else quickly fail low.  a fairly serious bug, that's been      *
 *           around for a long time, has finally been found/fixed.  in simple  *
 *           terms, if the "noise" level was set too high, it could make       *
 *           Crafty actually play a bad move.  the more likely effect was to   *
 *           see "bad move hashed" messages and the first few lines of output  *
 *           from the search often looked funny.  the bug was "noise" was used *
 *           as a limit, until that many nodes had been searched, no output    *
 *           would be produced.  unfortunately, on a fail-high condition, the  *
 *           same code that produced the "++  Nh5" message also placed the     *
 *           fail-high move in the PV.  failing to do this meant that the      *
 *           search could fail high, but not play the move it found.  most     *
 *           often this happened in very fast games, or near the end of long   *
 *           zero-increment games.  it now always saves this move as it should *
 *           regardless of whether it prints the message or not.               *
 *                                                                             *
 *    9.9    interface to Xboard changed from -ics to -xboard, so that -ics    *
 *           can be used with the custom interface.  additional code to        *
 *           communicate with custom interface added.  Search() extensions are *
 *           restricted so that there can not be more than one extension at a  *
 *           node, rather than the two or (on occasion) more of the last       *
 *           version.                                                          *
 *                                                                             *
 *    9.10   converted to Ken Thompson's "Belle" hash table algorithm.  simply *
 *           put, each side has two tables, one that has entries replaced on a *
 *           depth-priority only, the other is an "always replace" table, but  *
 *           is twice as big.  this allows "deep" entries to be kept along     *
 *           with entries close to search point.  basically, when the depth-   *
 *           priority table gets a position stored in it, the displaced        *
 *           position is moved to the always-replace table.  if the position   *
 *           can not replace the depth-priority entry, it always overwrites    *
 *           the other always-replace entry.  however, a position is never put *
 *           in both tables at the same time.                                  *
 *                                                                             *
 *    9.11   bug in Search() that could result in the "draft" being recorded   *
 *           incorrectly in the hash table.  caused by passing depth, which    *
 *           could be one or two plies more than it should be due to the last  *
 *           move extending the search.  RepetitionCheck() completely removed  *
 *           from Quiesce() since only capture moves are included, and it's    *
 *           impossible to repeat a position once a capture has been made.     *
 *                                                                             *
 *    9.12   optimizations: history.c, other minor modifications.              *
 *                                                                             *
 *    9.13   EvaluatePawns() modified significantly to simplify and be more    *
 *           accurate as well.  pawns on open files are now not directly       *
 *           penalized if they are weak, rather the penalty is added when the  *
 *           rooks are evaluated.  pawn hashing modified to add more info to   *
 *           the data that is hashed.  king safety scores toned down almost    *
 *           50% although it is still asymmetric.                              *
 *                                                                             *
 *    9.14   EvaluatePawns() modified further so that it now does the same     *
 *           computations for king safety as the old EvaluateKingSafety*()     *
 *           modules did, only it produces four values, two for each king,     *
 *           for each side of the board (king or queen-side).  this is now     *
 *           hashed with the rest of the pawn scoring, resulting in less       *
 *           hashing and computation, and more hits for king-safety too.  king *
 *           safety modified further.  asymmetric scoring was accidentally     *
 *           disabled several versions ago, this is now enabled again.         *
 *                                                                             *
 *    9.15   Evaluate() now attempts to recognize the case where a knight is   *
 *           trapped on one of the four corner squares, much like a bishop     *
 *           trapped at a2/a7/h2/h7.  if a knight is on a corner square, and   *
 *           neither of the two potential flight squares are safe (checked by  *
 *           Swap()) then a large penalty is given.  this was done to avoid    *
 *           positions where Crafty would give up a piece to fork the king and *
 *           rook at (say) c7, and pick up the rook at a8 and think it was an  *
 *           exchange ahead, when often the knight was trapped and it was      *
 *           two pieces for a rook and pawn (or worse.)  two timing bugs fixed *
 *           in this version:  (1) nodes_per_second was getting clobbered at   *
 *           the end of iterate, which would then corrupt the value stored in  *
 *           nodes_between_time_checks and occasionally make Crafty not check  *
 *           the time very often and use more time than intended; (2) the      *
 *           "don't stop searching after time is out, until the current move   *
 *           at the root of the tree has been searched" also would let Crafty  *
 *           use time unnecessarily.                                           *
 *                                                                             *
 *    9.16   significant changes to the way MakeMove() operates.  rather than  *
 *           copying the large position[ply] structure around, the piece       *
 *           location bitmaps and the array of which piece is on which square  *
 *           are now simple global variables.  this means that there is now an *
 *           UnmakeMove() function that must be used to restore these after a  *
 *           a move has been made.  the benefit is that we avoid copying 10    *
 *           bitmaps for piece locations when typically only one is changed,   *
 *           ditto for the which piece is on which square array which is 64    *
 *           bytes long.  the result is much less memory traffic, with the     *
 *           probability that the bitmaps now stay in cache all the time. the  *
 *           EvaluatePawns() code now has an exponential-type penalty for      *
 *           isolated pawns, but it penalizes the difference between white and *
 *           black isolated pawns in this manner.  king evaluation now         *
 *           evaluates cases where the king moves toward one of the rooks and  *
 *           traps it in either corner.                                        *
 *                                                                             *
 *    9.17   Xboard compatibility version!  now supports, so far as I know,    *
 *           the complete xboard interface, including hint, show thinking,     *
 *           taking back moves, "move now" and so forth.  additionally, Crafty *
 *           now works with standard xboard.  notice that this means that a    *
 *           ^C (interrupt) will no long terminate crafty, because xboard uses *
 *           this to implement the "move now" facility.  this should also      *
 *           work with winboard and allow pondering, since there is now a      *
 *           special windows version of CheckInput() that knows how to check   *
 *           Win95 or WinNT pipes when talking with winboard.                  *
 *                                                                             *
 *    9.18   Xboard compatibility update.  "force" (gnu) mode was broken, so   *
 *           that reading in a PGN file (via xboard) would break.  now, Crafty *
 *           can track the game perfectly as xboard reads the moves in.  king  *
 *           safety modified to discourage g3/g6 type moves without the bishop *
 *           to defend the weak squares.  significant other changes to the     *
 *           Evaluate() procedure and its derivatives.  very nasty trans/ref   *
 *           bug fixed.  been there since transposition tables added.  when    *
 *           storing a mate score, it has to be adjusted since it's backed up  *
 *           as "mate in n plies from root" but when storing, it must be saved *
 *           as "mate in n plies from current position".  trivial, really, but *
 *           I overlooked one important fact:  mate scores can also be upper   *
 *           or lower search bounds, and I was correcting them in the same way *
 *           which is an error.  the effect was that crafty would often find a *
 *           mate in 2, fail high on a move that should not fail high, and end *
 *           up making a move that would mate in 3.  in particularly bad cases *
 *           this would make the search oscillate back and forth and draw a    *
 *           won position.  the fix was to only adjust the score if it's a     *
 *           score, not if it's a bound.  the "age" field of the trans/ref     *
 *           table was expanded to 3 bits.  iterate now increments a counter   *
 *           modulo 8, and this counter is stored in the 3 ID bits of the      *
 *           trans/ref table.  if they are == the transposition_id counter,    *
 *           we know that this is a position stored during the current search. *
 *           if not, it's an "old" position.  this avoids the necessity of     *
 *           stepping through each entry in the trans/ref table (at the begin- *
 *           ning of a search) to set the age bit.  much faster in blitz games *
 *           as stepping through the trans/ref table, entry by entry, would    *
 *           blow out cache.  this idea was borrowed from Cray Blitz, which    *
 *           used this same technique for many years.                          *
 *                                                                             *
 *    9.19   new evaluation code for passed pawns.  Crafty now gives a large   *
 *           bonus for two or more connected passed pawns, once they reach the *
 *           sixth rank, when the opponent has less than a queen remaining.    *
 *           this will probably be tuned as experience produces the special    *
 *           cases that "break" it.  such things as the king too far away or   *
 *           the amount of enemy material left might be used to further im-    *
 *           prove the evaluation.                                             *
 *                                                                             *
 *    9.20   bug in SetBoard() fixed.  validity checks for castling status and *
 *           en passant status was broken for castle status.  it was checking  *
 *           the wrong rook to match castling status, and would therefore not  *
 *           accept some valid positions, including #8 in Win At Chess suite.  *
 *           minor repetition bug fixed, where Crafty would recognize that a   *
 *           three-fold repetition had occurred, but would not claim it when   *
 *           playing on a chess server.  Crafty now does not immediately re-   *
 *           search the first move when it fails low.  rather, it behaves like *
 *           Cray Blitz, and searches all moves.  if all fail low, Crafty will *
 *           then relax (lower) alpha and search the complete list again.      *
 *           this is a simple gamble that there is another move that will      *
 *           "save the day" so that we avoid the overhead of finding out just  *
 *           how bad the first move is, only to have more overhead when a good *
 *           move fails high.  minor repetition bug fixed.  when running test  *
 *           suites of problems, SetBoard() neglected to put the starting      *
 *           position in the repetition list, which would occasionally waste   *
 *           time.  one notable case was Win At Chess #8, where crafty would   *
 *           find Nf7+ Kg8 Nh6+ Kh8 (repeating the original position) followed *
 *           by Rf7 (the correct move, but 4 tempi behind.)  Display() bug     *
 *           fixed.  Crafty now displays the current board position, rather    *
 *           than the position that has been modified by a search in progress. *
 *           castling evaluation modified including a bug in the black side    *
 *           that would tend to make Crafty not castle queen-side as black if  *
 *           the king-side was shredded.  minor bug in Book(). if the book was *
 *           turned off (which is done automatically when using the test com-  *
 *           mand since several of the Win At Chess positions are from games   *
 *           in Crafty's large opening book) Book() would still try to read    *
 *           the file and then use the data from the uninitialized buffer.     *
 *           this would, on occasion, cause Crafty to crash in the middle of   *
 *           a test suite run.                                                 *
 *                                                                             *
 *    9.21   castling evaluation has been significantly modified to handle the *
 *           following three cases better:                                     *
 *           (a) one side can castle at the root of the tree, but can not      *
 *           castle at a tip position.  if the move that gave up the right to  *
 *           castle was *not* a castle move, penalize the score.               *
 *           (b) one side can castle short or long at the root, but has al-    *
 *           ready castled by the time the search reaches a tip position.      *
 *           here the goal is to make sure the player castled to the "better"  *
 *           side by comparing king safety where the king really is, to king   *
 *           safety had the king castled to the other side.  if the latter is  *
 *           "safer" then penalize the current position by the "difference"    *
 *           in king safety to encourage that side to delay castling.  this is *
 *           a problem when Crafty can castle kingside *now*, but the kingside *
 *           has been disrupted somehow.  if the search is not deep enough to  *
 *           see clearing out the queenside and castling long, then it will    *
 *           often castle short rather than not castle at all.  this fix will  *
 *           make it delay, develop the queenside, and castle to a safer king  *
 *           shelter, unless tactics force it to castle short.                 *
 *           (c) one side can castle short or long at the root, but can only   *
 *           castle one way at a tip position, because a rook has been moved.  *
 *           if the remaining castle option is worse than castling to the side *
 *           where the rook was moved, then we penalize the rook move to keep  *
 *           castling to that side open as an option.                          *
 *                                                                             *
 *    9.22   more castling evaluation changes, to tune how/when Crafty chooses *
 *           to castle.  bugs in Option() where certain commands could be ex-  *
 *           ecuted while a search was in progress.  if these commands did     *
 *           anything to the board position, it would break Crafty badly.      *
 *           all that was needed was to check for an active search before some *
 *           commands were attempted, and if a search was in progress, return  *
 *           to abort the search then re-try the command.  when playing games  *
 *           with computers (primarily a chess-server consideration) Crafty is *
 *           now defaulting to "book random 0" to use a short search to help   *
 *           avoid some ugly book lines on occasion.  in this version, *all*   *
 *           positional scores were divided by 2 to reduce the liklihood that  *
 *           crafty would sacrifice material and make up the loss with some    *
 *           sort of positional gain that was often only temporary.  note that *
 *           king safety scores were not reduced while doing this.  new book   *
 *           random options:  0=search, 1=most popular move, 2=move that       *
 *           produces best positional value, 3=choose from most frequently     *
 *           played moves, 4=emulate GM frequency of move selection, 5=use     *
 *           sqrt() on frequencies to give more randomness, 6=random.  for     *
 *           now, computers get book_random=1, while GM's now get 4 (same as   *
 *           before), everyone else gets 5.  until now, there has been no      *
 *           penalty for doubled/tripled pawns.  it now exists.  also, if the  *
 *           king stands on E1/E8, then the king-side king safety term is used *
 *           to discourage disrupting the king-side pawns before castling.     *
 *           Crafty now has a start-up initialization file (as most Unix       *
 *           programs do).  this file is named ".craftyrc" if the macro UNIX   *
 *           is defined, otherwise a "dossy" filename "crafty.rc" is used.     *
 *           Crafty opens this file and executes every command in it as though *
 *           they were typed by the operator.  the last command *must* be      *
 *           "exit" to revert input back to STDIN.                             *
 *                                                                             *
 *    9.23   more evaluation tuning, including the complete removal of the     *
 *           mobility term for rooks/queens.  since rooks already have lots    *
 *           of scoring terms like open files, connected, etc, mobility is     *
 *           redundant at times and often misleading.  The queen's mobility    *
 *           is so variable it is nearly like introducing a few random points  *
 *           at various places in the search.  minor Xboard compatibility bug  *
 *           fixed where you could not load a game file, then have crafty play *
 *           by clicking the "machine white" or "machine black" options.       *
 *                                                                             *
 *    9.24   minor bug in Quiesce() repaired.  when several mate-in-1 moves    *
 *           were available at the root, Crafty always took the last one,      *
 *           which was often an under-promotion to a rook rather than to a     *
 *           queen.  It looked silly and has been fixed so that it will play   *
 *           the first mate-in-1, not the last.  RootMoveList() went to great  *
 *           pains to make sure that promotion to queen occurs before rook.    *
 *           bug in EvaluateOutsidePassedPawns() would fail to recognize that  *
 *           one side had an outside passer, unless both sides had at least    *
 *           one passer, which failed on most cases seen in real games.        *
 *           minor "tweak" to move ordering.  GenerateMoves() now uses the     *
 *           LSB() function to enumerate white moves, while still using    *
 *           MSB() for black moves.  this has the effect of moving pieces *
 *           toward your opponent before moving them away.  a severe oversight *
 *           regarding the use of "!" (as in wtm=!wtm) was found and corrected *
 *           to speed things up some.  !wtm was replaced by wtm^1 (actually,   *
 *           a macro Flip(wtm) is used to make it more readable) which         *
 *           resulted in significant speedup on the sparc, but a more modest   *
 *           improvement on the pentium.                                       *
 *                                                                             *
 *    9.25   minor bug in Book() fixed where it was possible for crafty to     *
 *           play a book move that was hardly ever played.  minor change to    *
 *           time utilization to use a little more time "up front".  tuned     *
 *           piece/square tables to improve development some.  saw Crafty lose *
 *           an occasional game because (for example) the bishop at c1 or c8   *
 *           had not moved, but the king had already castled, which turned the *
 *           EvaluateDevelopment() module "off".  first[ply] removed, since it *
 *           was redundant with last[ply-1].  the original intent was to save  *
 *           a subscript math operation, but the compilers are quite good with *
 *           the "strength-reduction" optimization, making referencing a value *
 *           by first[ply] or last[ply-1] exactly the same number of cycles.   *
 *           passed pawn scores increased.  the reduction done to reduce all   *
 *           scores seemed to make Crafty less attentive to passed pawns and   *
 *           the threats they incur.  Minor bug in Book() fixed, the variable  *
 *           min_percent_played was inoperative due to incorrect test on the   *
 *           book_status[n] value.  pawn rams now scored a little differently, *
 *           so that pawn rams on Crafty's side of the board are much worse    *
 *           than rams elsewhere.  This avoids positional binds where, for ex- *
 *           ample Crafty would like black with pawns at e6 d5 c6, white with  *
 *           pawns at e5 and c5.  black has a protected passed pawn at d5 for  *
 *           sure, but the cramp makes it easy for white to attack black, and  *
 *           makes it difficult for black to defend because the black pawns    *
 *           block the position badly.  king safety tweaked up about 30%, due  *
 *           to using nearly symmetrical scoring, the values had gotten too    *
 *           small and were not overriding minor positional things.            *
 *                                                                             *
 *    9.26   minor bug fixes in time allocation.  this mainly affects Crafty   *
 *           as it plays on a chess server.  the problem is, simply, that the  *
 *           current internal timing resolution is 1/10 of a second, kept in   *
 *           an integer variable.  .5 seconds is stored as 5, for example.     *
 *           this became a problem when the target time for a search dropped   *
 *           below .3 seconds, because the "easy move" code would terminate    *
 *           the search after 1/3 of the target time elapsed if there were no  *
 *           fail lows or PV changes.  unfortunately, 2 divided by 3 (.2 secs  *
 *           /3) is "zero" which would let the search quickly exit, possibly   *
 *           without producing a PV with a move for Crafty to play.  Crafty    *
 *           would play the first PV move anyway, which was likely the PV move *
 *           from the last search.  this would corrupt the board information,  *
 *           often produce the error "illegal move" when the opponent tried to *
 *           move, or, on occasion, blow crafty up.  on a chess server, Crafty *
 *           would simply flag and lose.  after this fix, I played several     *
 *           hundred games with a time control of 100 moves in 1 second and    *
 *           there were no failures.  before the fix, this time control could  *
 *           not result in a single completed game.  if you don't run Crafty   *
 *           on a chess server, this version is not important, probably. a     *
 *           minor fix for move input, so that moves like e2e4 will always be  *
 *           accepted, where before they would sometimes be flagged as errors. *
 *                                                                             *
 *    9.27   this version has an interesting modification to NextCapture().    *
 *           Quiesce() now passes alpha to NextCapture() and if a capture      *
 *           appears to win material, but doesn't bring the score up to the    *
 *           value of alpha, the capture is ignored.  in effect, if we are so  *
 *           far behind that a capture still leaves us below alpha, then there *
 *           is nothing to gain by searching the capture because our opponent  *
 *           can simply stand pat at the next ply leaving the score very bad.  *
 *           one exception is if the previous ply was in check, we simply look *
 *           for any safe-looking capture just in case it leads to mate.  bad  *
 *           book bug with book random=1 or 2 fixed (this is set when playing  *
 *           a computer).  this bug would cause crafty to play an illegal move *
 *           and bust wide open with illegal move errors, bad move hashed, and *
 *           other things.  book randomness also quite a bit better now.       *
 *                                                                             *
 *    9.28   piece/square table added for rooks.  primary purpose is to dis-   *
 *           courage rooks moving to the edge of the board but in front of     *
 *           pawns, where it is easy to trap it.  Crafty now understands the   *
 *           concept of blockading a passed pawn to prevent it from advancing. *
 *           it always understood that advancing one was good, which would     *
 *           tend to encourage blockading, but it would also often ignore the  *
 *           pawn and let it advance a little here, a little there, until it   *
 *           suddenly realized that it was a real problem.  the command to set *
 *           the size of the hash table has been modified.  this command is    *
 *           now "hash n", "hash nK" or "hash nM" to set the hash table to one *
 *           of bytes, Kbytes, or Mbytes.  Note that if the size is not an     *
 *           exact multiple of what crafty needs, it silently reduces the size *
 *           to an optimum value as close to the suggested size as possible.   *
 *           trade bonus/penalty is now back in, after having been removed     *
 *           when the new UnmakeMove() code was added.  crafty tries to trade  *
 *           pawns but not pieces when behind, and tries to trade pieces but   *
 *           not pawns when ahead.  EvaluateDraws() now understands that rook  *
 *           pawns + the wrong bishop is a draw.  minor adjustment to the      *
 *           quiescence-search pruning introduced in 9.27, to avoid excluding  *
 *           captures that didn't lose material, but looked bad because the    *
 *           positional score was low.  slightly increased the values of the   *
 *           pieces relative to that of a pawn to discourage the tendency to   *
 *           trade a piece for two or three pawns plus some positional plusses *
 *           that often would slowly vanish.  null-move search modified to try *
 *           null-moves, even after captures.  this seems to hurt some prob-   *
 *           lem positions, but speeds up others significantly.  seems better  *
 *           but needs close watching.  EvaluateDraws() call moved to the top  *
 *           of Evaluate() to check for absolute draws first.  Quiesce() now   *
 *           always calls Evaluate() which checks for draws before trying the  *
 *           early exit tests to make sure that draws are picked up first.     *
 *           EvaluateDraws() substantially re-written to get rid of lots of    *
 *           unnecessary instructions, and to also detect RP+B of wrong color  *
 *           even if the losing side has a pawn of its own.  Crafty would      *
 *           often refuse to capture that last pawn to avoid reaching an end-  *
 *           game it knew was drawn.                                           *
 *                                                                             *
 *    9.29   new time.c as contributed by Mike Byrne.  basically makes Crafty  *
 *           use more time up front, which is a method of anticipating that    *
 *           Crafty will predict/ponder pretty well and save time later on     *
 *           anyway.  InCheck() is never called in Quiesce() now.  as a        *
 *           result, Crafty won't recognize mates in the q-search.  this has   *
 *           speeded the code up with no visible penalty, other than it will   *
 *           occasionally find a win of material rather than a mate score, but *
 *           this has not affected the problem suite results in a measurable   *
 *           way, other than crafty is now about 10% faster in average type    *
 *           position, and much faster in others.  the latest epd code from    *
 *           Steven Edwards is a part of this version, which includes updated  *
 *           tablebase access code.                                            *
 *                                                                             *
 *   10.0    new time.c with a "monitoring feature" that has two distinct      *
 *           functions:  (1) monitor crafty's time remaining and if it is too  *
 *           far behind the opponent, force it to speed up, or if it is well   *
 *           ahead on time, slow down some;  (2) if opponent starts moving     *
 *           quickly, crafty will speed up as well to avoid getting too far    *
 *           behind.  EvaluateDraws() modified to detect that if one side has  *
 *           insufficient material to win, the score can never favor that side *
 *           which will make Crafty avoid trading into an ending where it has  *
 *           KNN vs KB for example, where KNN seems to be ahead.               *
 *                                                                             *
 *   10.1    new book.c.  crafty now counts wins, losses and draws for each    *
 *           possible book move and can use these to play a move that had a    *
 *           high percentage of wins, vs the old approach of playing a move    *
 *           just because it was played a lot in the past.                     *
 *                                                                             *
 *   10.2    evaluation tuning.  rook on 7th, connected rooks on 7th, etc.,    *
 *           are now more valuable.  Crafty was mistakenly evaluating this     *
 *           too weakly.  book() changed so that the list of moves is first    *
 *           sorted based on winning percentages, but then, after selecting    *
 *           the sub-set of this group, the list is re-sorted based on the     *
 *           raw total games won so that the most popular opening is still the *
 *           most likely to be played.                                         *
 *                                                                             *
 *   10.3    timer resolution changed to 1/100th of a second units, with all   *
 *           timing variables conforming to this, so that it is unnecessary    *
 *           to multiply by some constant to convert one type of timing info   *
 *           to the standard resolution.  bug in evaluate.c fixed.  trapped    *
 *           rook (rook at h1, king at g1 for example) code had a bad sub-     *
 *           script that caused erroneous detection of a trapped rook when     *
 *           there was none.                                                   *
 *                                                                             *
 *   10.4    Quiesce() no longer checks for time exceeded, nor does it do any  *
 *           hashing whatsoever, which makes it significantly faster, while    *
 *           making the trees only marginally bigger.                          *
 *                                                                             *
 *   10.5    Quiesce() now calls GenerateCaptures() to generate capture moves. *
 *           this new move generator module is significantly faster, which     *
 *           speeds the quiescence search up somewhat.                         *
 *                                                                             *
 *   10.6    CastleStatus is now handled slightly differently.  the right two  *
 *           bits still indicate whether or not that side can castle to either *
 *           side, and 0 -> no castling at all, but now, <0 means that no      *
 *           castling can be done, and that castling rights were lost by       *
 *           making a move that was not castling.  this helps in Evaluate()    *
 *           by eliminating a loop to see if one side castled normally or had  *
 *           to give up the right to castle for another (bad) reason.  this is *
 *           simply an efficiency issue, and doesn't affect play or anything   *
 *           at all other than to make the search faster.                      *
 *                                                                             *
 *   10.7    NextMove() now doesn't try history moves forever, rather it will  *
 *           try the five most popular history moves and if it hasn't gotten a *
 *           cutoff by then, simply tries the rest of the moves without the    *
 *           history testing, which is much faster.                            *
 *                                                                             *
 *   10.8    Book() now "puzzles" differently.  In puzzling, it is trying to   *
 *           find a move for the opponent.  since a book move by the opponent  *
 *           will produce an instant move, puzzle now enumerates the set of    *
 *           legal opponent moves, and from this set, removes the set of known *
 *           book moves and then does a quick search to choose the best.  we   *
 *           then ponder this move just in case the opponent drops out of book *
 *           and uses a normal search to find a move.  Crafty now penalizes    *
 *           a pawn that advances, leaving its neighbors behind where both     *
 *           the advancing pawn, and the ones being left behind become weaker. *
 *           the opening phase of the game has been modified to "stay active"  *
 *           until all minor pieces are developed and Crafty has castled, to   *
 *           keep EvaluateDevelopment() active monitoring development.  minor  *
 *           change to DrawScore() so that when playing a computer, it will    *
 *           return "default_draw_score" under all circumstances rather than   *
 *           adjusting this downward, which makes Crafty accept positional     *
 *           weaknesses rather than repeat a position.                         *
 *                                                                             *
 *   10.9    Evaluate() now handles king safety slightly differently, and      *
 *           increases the penalty for an exposed king quite a bit when there  *
 *           is lots of material present, but scales this increase down as the *
 *           material comes off.  this seems to help when attacking or getting *
 *           attacked.  since Quiesce() no longer probes the hash table, the   *
 *           idea of storing static evaluations there became worthless and was *
 *           burning cycles that were wasted.  this has been removed. check    *
 *           extensions relaxed slightly so that if ply is < iteration+10 it   *
 *           will allow the extension.  old limit was 2*iteration.  connected  *
 *           passed pawns on 6th now evaluated differently.  they get a 1 pawn *
 *           bonus, then if material is less than a queen, another 1 pawn      *
 *           bonus, and if not greater than a rook is left, and the king can't *
 *           reach the queening square of either of the two pawns, 3 more      *
 *           more pawns are added in for the equivalent of + a rook.           *
 *                                                                             *
 *   10.10   Evaluate() modified.  king safety was slightly broken, in that    *
 *           an uncastled king did not get a penalty for open center files.    *
 *           new evaluation term for controlling the "absolute 7th rank", a    *
 *           concept from "My System".                                         *
 *                                                                             *
 *   10.11   lazy evaluation implemented.  now as the Evaluate() code is ex-   *
 *           ecuted, crafty will "bail out" when it becomes obvious that the   *
 *           remainder of the evaluation can't bring the score back inside the *
 *           alpha/beta window, saving time.                                   *
 *                                                                             *
 *   10.12   more Jakarta time control commands added so operator can set the  *
 *           time accurately if something crashes, and so the operator can set *
 *           a "cushion" to compensate for operator inattention.  "easy" is    *
 *           more carefully qualified to be a recapture, or else a move that   *
 *           preserves the score, rather than one that appears to win material *
 *           as was done in the past.  king safety tweaked a little so that if *
 *           one side gives up the right to castle, and could castle to a safe *
 *           position, the penalty for giving up the right is substantially    *
 *           larger than before.  a minor bug also made it more likely for     *
 *           black to give up the right to castle than for white.              *
 *                                                                             *
 *   10.13   modifications to Book() so that when using "book random 0" mode   *
 *           (planned for Jakarta) and the search value indicates that we are  *
 *           losing a pawn, we return "out of book" to search *all* the moves, *
 *           not just the moves that are "in book."  This hopefully avoids     *
 *           some book lines that lose (gambit) material unsoundly.            *
 *                                                                             *
 *   10.14   final timing modifications.  puzzling/booking searches now take   *
 *           1/30th of the normal time, rather than 1/10th.  new command       *
 *           "mode=tournament" makes crafty assess DRAW as "0" and also makes  *
 *           it prompt the operator for time corrections as required by WMCCC  *
 *           rules.                                                            *
 *                                                                             *
 *   10.15   Evaluate() tuning to reduce development bonuses, which were able  *
 *           to overwhelm other scores and lead to poor positions.             *
 *                                                                             *
 *   10.16   "lazy" (early exit) caused some problems in Evaluate() since so   *
 *           many scores are very large.  scaled this back significantly and   *
 *           also EvaluateOutsidePassedPawns() could double the score if one   *
 *           side had passers on both sides.  this was fixed.                  *
 *                                                                             *
 *   10.17   crafty's Book() facility has been significantly modified to be    *
 *           more understandable.  book random <n> has the following options:  *
 *           (0) do a search on set of book moves; (1) choose from moves that  *
 *           are played most frequently; (2) choose from moves with best win   *
 *           ratio; (3) choose from moves with best static evaluation; and     *
 *           (4) choose completely randomly.  book width <n> can be used to    *
 *           control how large the "set" of moves will be, with the moves in   *
 *           the "set" being the best (according to the criteria chosen) from  *
 *           the known book moves.  minor tweak to Search() so that it extends *
 *           passed pawn pushes to the 6th or 7th rank if the move is safe,    *
 *           and this is an endgame.                                           *
 *                                                                             *
 *   10.18   new annotate command produces a much nicer analysis file and also *
 *           lets you exert control over what has to happen to trigger a com-  *
 *           ment among other things.  AKA Crafty/Jakarta version.             *
 *                                                                             *
 *   11.1    fractional depth allows fractional ply increments.  the reso-     *
 *           lution is 1/4 of a ply, so all of the older "depth++" lines now   *
 *           read depth+=PLY, where #define PLY 4 is used everywhere.  this    *
 *           gives added flexibility in that some things can increment the     *
 *           depth by < 1 ply, so that it takes two such things before the     *
 *           search actually extends one ply deeper.  Crafty now has full PGN  *
 *           support.  a series of pgn commands (pgn Event 14th WMCCC) allow   *
 *           the PGN tags to be defined, when crafty reads or annotates a PGN  *
 *           file it reads and parses the headers and will display the info    *
 *           in the annotation (.can) file or in the file you specify when you *
 *           execute a "savegame <filename>" command.                          *
 *                                                                             *
 *   11.2    fractional ply increments now implemented.  11.1 added the basic  *
 *           fractional ply extension capabilities, but this version now uses  *
 *           them in Search().  there are several fractional ply extensions    *
 *           being used, all are #defined in types.h to make playing with them *
 *           somewhat easier.  one advantage is that now all extensions are    *
 *           3/4 of a ply, which means the first time any extension is hit, it *
 *           has no effect, but the next three extensions will result in an    *
 *           additional ply, followed by another ply where the extension does  *
 *           nothing, followed by ...  this allowed me to remove the limit on  *
 *           how deep in the tree the extensions were allowed, and also seems  *
 *           to not extend as much unless there's "something" going on.  when  *
 *           the position gets interesting, these kick in.  asymmetric king    *
 *           safety is back in.  Crafty's king safety is a little more im-     *
 *           portant than the opponent's now to help avoid getting its king-   *
 *           side shredded to win a pawn.  a new term, ROOK_ON_7TH_WITH_PAWN   *
 *           to help Crafty understand how dangerous a rook on the 7th is if   *
 *           it is supported by a pawn.  it is difficult to drive off and the  *
 *           pawn provides additional threats as well.                         *
 *                                                                             *
 *   11.3    king safety modifications.  one fairly serious bug is that Crafty *
 *           considered that king safety became unimportant when the total     *
 *           pieces dropped below 16 material points.  note that this was      *
 *           pieces only, not pieces and pawns, which left plenty of material  *
 *           on the board to attack with.  as a result, Crafty would often     *
 *           allow its king-side to be weakened because it was either in an    *
 *           endgame, or close to an endgame.  *incorrectly*, it turns out. :) *
 *           going back to a very old Crafty idea, king tropism is now tied to *
 *           how exposed each king is, with pieces being attracted to the most *
 *           exposed king for attack/defense.                                  *
 *                                                                             *
 *   11.4    tuning on outside passed pawn code.  values were not large enough *
 *           and didn't emphasize how strong such a pawn is.  general passed   *
 *           pawn value increased as well.  minor bug in edit that would let   *
 *           crafty flag in some wild games was fixed.  basically, edit has no *
 *           way to know if castling is legal, and has to assume if a rook and *
 *           king are on the original squares, castling is o.k.  for wild2     *
 *           games in particular, this can fail because castling is illegal    *
 *           (by the rules for wild 2) while it might be that rooks and king   *
 *           are randomly configured to make it look possible.  crafty would   *
 *           then try o-o or o-o-o and flag when the move was rejected as      *
 *           illegal.  Richard Lloyd suggested a speed-up for the annotate     *
 *           command which I'm using temporarily.  Crafty now searches all     *
 *           legal moves in a position, and if the best move matches the game  *
 *           move, the second search of just the move played is not needed.  I *
 *           was searching just the game move first, which was a waste of time *
 *           in many positions.  I'll resume this later, because I want to see *
 *           these values:  (1) score for move actually played; (2) score for  *
 *           the rest of the moves only, not including the move actually       *
 *           played, to see how often a player finds a move that is the *only* *
 *           good move in a position.                                          *
 *                                                                             *
 *   11.5    more fractional ply extension tuning.  a few positions could blow *
 *           up the search and go well beyond 63 plies, the max that Crafty    *
 *           can handle.  now, extensions are limited to no more than one ply  *
 *           of extensions for every ply of search.  note that "in check" is   *
 *           extended on the checking move ply, not on the out of check ply,   *
 *           so that one-reply-to-check still extends further.  minor changes  *
 *           to time.c to further help on long fast games.  another important  *
 *           timing bug repaired.  if Crafty started an iteration, and failed  *
 *           high on the first move, it would not terminate the search until   *
 *           this move was resolved and a score returned.  this could waste a  *
 *           lot of time in already won positions.  interesting bug in the     *
 *           capture search pruning fixed.  at times, a piece would be hung,   *
 *           but the qsearch would refuse to try the capture because it would  *
 *           not bring the score back to above alpha.  unfortunately, taking   *
 *           the piece could let passed pawns race in undisturbed which would  *
 *           affect the score.  this pruning is turned off when there are not  *
 *           at least two pieces left on the board.  another bug in the move   *
 *           generator produced pawn promotions twice, once when captures were *
 *           generated, then again when the rest of the moves are produced.    *
 *           this was also repaired.  small book now will work.  the BookUp()  *
 *           code now assumes white *and* black won in the absence of a valid  *
 *           PGN Result tag, so that the small book will work correctly.       *
 *                                                                             *
 *   11.6    modifications to time allocation in a further attempt to make     *
 *           Crafty speed up if time gets short, to avoid flagging.  it is now *
 *           *very* difficult to flag this thing.  :)  minor evaluation tweaks *
 *           and a fix to Quiesce() to speed it up again after a couple of bad *
 *           fixes slowed things down.                                         *
 *                                                                             *
 *   11.7    minor modification to Evaluate().  rooks behind a passed pawn are *
 *           good, but two rooks behind the pawn don't help if the pawn is     *
 *           blockaded and can't move, unless the two rooks are not the same   *
 *           color as the pawn.                                                *
 *                                                                             *
 *   11.8    first stage of "book learning" implemented.  Crafty monitors the  *
 *           search evaluation for the first 10 moves out of book.  it then    *
 *           computes a "learn value" if it thinks this set of values shows    *
 *           that the book line played was very good or very bad.  this value  *
 *           is added to a "learn count" for each move in the set of book      *
 *           moves it played, with the last move getting the full learn value, *
 *           and moves closer to the start of the game getting a smaller       *
 *           percentage.  (see learn.c for more details).  these values are    *
 *           used by Book() to help in selecting/avoiding book lines.  Crafty  *
 *           produces a "book.lrn" file that synthesizes this information into *
 *           a portable format that will be used by other crafty programs,     *
 *           once the necessary code is added later on.                        *
 *                                                                             *
 *   11.9    an age-old problem caused by null-move searching was eliminated   *
 *           in this version.  often the null-move can cause a move to fail    *
 *           high when it should not, but then the move will fail low on the   *
 *           re-search when beta is relaxed.  this would, on occasion, result  *
 *           in Crafty playing a bad move for no reason.  now, if a fail high  *
 *           is followed by a fail-low, the fail high condition is ignored.    *
 *           this can be wrong, but with null-move pruning, it can also be     *
 *           even "more wrong" to accept a fail high move after it fails low   *
 *           due to a null-move failure, than it would be right to accept the  *
 *           fail high/fail low that is caused by trans/ref table anomalies.   *
 *                                                                             *
 *   11.10   Crafty is now using the Kent, et. al, "razoring" algorithm, which *
 *           simply eliminates the last ply of full-width searching and goes   *
 *           directly to the capture search if the move before the last full-  *
 *           width ply is uninteresting, and the Material eval is 1.5 pawns    *
 *           below alpha.  It's a "modest futility" idea that doesn't give up  *
 *           on the uninteresting move, but only tries captures after the move *
 *           is played in the tree.  net result is 20-30% average faster times *
 *           to reach the same depth.  minor mod to book.lrn to include Black, *
 *           White and Date PGN tags just for reference.  next learning mod is *
 *           another "book random n" option, n=3.  this will use the "learned" *
 *           score to order book moves, *if* any of them are > 0.  what this   *
 *           does is to encourage Crafty to follow opening lines that have     *
 *           been good, even if the learn count hasn't reached the current     *
 *           threshold of 1,000.  this makes learning "activate" faster.  this *
 *           has one hole in it, in that once crafty learns that one move has  *
 *           produced a positive learn value, it will keep playing that move   *
 *           (since no others will yet have a positive value) until it finally *
 *           loses enough to take the learn value below zero.  this will be    *
 *           taken care of in the next version, hopefully.                     *
 *                                                                             *
 *   11.11   new "book random 4" mode that simply takes *all* learning scores  *
 *           for the set of legal book moves, translates them so that the      *
 *           worst value is +1 (by adding -Min(all_scores)+1 to every learn    *
 *           value) and then squaring the result.  this encourages Crafty to   *
 *           follow book lines that it has learned to be good, while still     *
 *           letting it try openings that it has not yet tried (learn value    *
 *           =0) and even lets it try (albeit rarely) moves that it has        *
 *           learned to be bad.  minor evaluation tweaking for king placement  *
 *           in endgames to encourage penetration in the center rather than on *
 *           a wing where the king might get too far from the "action."        *
 *                                                                             *
 *   11.12   LearnFunction() now keeps positional score, rather than using a   *
 *           constant value for scores < PAWN_VALUE, to improve learning       *
 *           accuracy.  book learn <filename> [clear] command implemented to   *
 *           import learning files from other Crafty programs.                 *
 *                                                                             *
 *   11.13   endgame threshold lowered to the other side having a queen or     *
 *           less (9) rather than (13) points.  queen+bishop can be very       *
 *           dangerous to the king for example, or two rooks and a bishop.     *
 *           learning "curve" modified.  it was accidentally left in a sort    *
 *           of "geometric" shape, with the last move getting the full learn   *
 *           value, the next one back getting 1/2, the next 1/3, etc.   now    *
 *           it is uniformly distributed from front to back.  if there are 20  *
 *           moves, the last gets the full value, the next gets 19/20, etc..   *
 *           also the "percentage played" was hosed and is fixed.              *
 *                                                                             *
 *   11.14   minor modification to book learn 4 code so that when you start    *
 *           off with *no* learned data, Book() won't exclude moves from the   *
 *           possible set of opening moves just because one was not played     *
 *           very often.  due to the lack of "ordering" info in this case, it  *
 *           would often discover the second or third move in the list had not *
 *           been played very often and cull the rest of the list thinking it  *
 *           was ordered by the number of times it was played.  new channel=n  *
 *           command works with old whisper command, but takes what Crafty     *
 *           would normally whisper and directs it to channel "n" instead.     *
 *           primarily used with custom interface when observing a game on a   *
 *           server.  this lets other observers either listen or ignore the    *
 *           analysis Crafty produces by using +chan n or -chan n.  this code  *
 *           contains all of Frank's xboard patches so that analyze mode and   *
 *           so forth works cleanly.  a new book random option <5> modifies    *
 *           the probability of playing a move by letting the popularity of a  *
 *           move affect the learned-value sorting algorithm somewhat. minor   *
 *           adjustment in pawn ram asymmetric term to simply count rams and   *
 *           not be too concerned about which half of the board they are on.   *
 *           adjustment to weak pawn code.  also increased bonus for king      *
 *           tropism to attract pieces toward enemy king to improve attacking. *
 *           code that detects drawn K+RP+wrong bishop had a bug in that on    *
 *           occasion, the defending king might not be able to reach the       *
 *           queening square before the opposing king blocks it out.  this     *
 *           would let some positions look like draws when they were not. king *
 *           safety now uses square(7-distance(piece,king)) as one multiplier  *
 *           to really encourage pieces to get closer to the king.  in cases   *
 *           whre one king is exposed, all pieces are attracted to that king   *
 *           to attack or defend.   this is turned off during the opening.     *
 *           minor 50-move rule draw change to fix a bug, in that the game is  *
 *           not necessarily a draw after 50 moves by both sides, because one  *
 *           side might be mated by the 50th move by the other side.  this     *
 *           occurred in a game Crafty vs Ferret, and now works correctly.     *
 *                                                                             *
 *   11.15   modified LearnBook() so that when Crafty terminates, or resigns,  *
 *           or sees a mate, it will force LearnBook() to execute the learning *
 *           analysis even if 10 moves have not been made sine leaving the     *
 *           book.  Crafty now trusts large positive evals less when learning  *
 *           about an opening, since such evals are often the result of the    *
 *           opponent's blunder, rather than a really  good opening line.      *
 *           second learning stage implemented.  Crafty maintains a permanent  *
 *           hash file that it uses to store positions where the search value  *
 *           (at the root of the tree) suddenly drop, and then it "seeds" the  *
 *           real transposition table with these values at the start of each   *
 *           of each search so that information is available earlier the next  *
 *           time this game is played.  position.bin has the raw binary data   *
 *           this uses, while position.lrn has the "importable" data.  new     *
 *           import <filename> [clear] command imports all learning data now,  *
 *           eliminating the old book learn command.  LearnFunction() modified *
 *           to handle "trusted" values (negative scores, because we are sure  *
 *           that Crafty won't make an outright blunder very often) and        *
 *           "untrusted" values (positive values often caused by the opponent  *
 *           hanging a piece.  trusted values are scaled up if the opponent is *
 *           weaker than crafty since a weaker opponent forcing a negative     *
 *           eval means the position must really be bad, and are scaled down   *
 *           somewhat if the opponent is stronger than crafty (from the rating *
 *           information from ICC or the operator using the rating command.)   *
 *           untrusted values are scaled down harshly, unless the opponent is  *
 *           much stronger than crafty, since it is unlikely such an opponent  *
 *           would really blunder, while weaker opponents drastically scale    *
 *           untrusted value (which is positive, remember) down.  minor depth  *
 *           problem fixed in learning code.  the depth used in LearnFunction  *
 *           was not the depth for the search that produced the "learn value"  *
 *           the LearnBook() chooses, it was the depth for the search last     *
 *           done.  now, in addition to the 10 last search values, I store the *
 *           depth for each as well.  when a particular search value is used   *
 *           to "learn", the corresponding (correct) depth is also now used.   *
 *           these learn values are now limited to +6000/-6000 because in one  *
 *           book line, Crafty discovered it was getting mated in 2 moves at   *
 *           the end of the book line which was 30 moves deep.  if you try to  *
 *           distribute a "mate score" as the learned value, it will instantly *
 *           make every move for the last 26 moves look too bad to play.  this *
 *           is not desirable, rather the last few moves should be unplayable, *
 *           but other moves further back should be o.k.  another bug that let *
 *           Crafty overlook the above mate also fixed.  the search value was  *
 *           not correct if Crafty got mated, which would avoid learning in    *
 *           that case.  this has been fixed, although it was obviously a rare *
 *           problem anyway.  minor draw bug fixed, where crafty would offer   *
 *           a draw when time was way low, caused by the resolution change a   *
 *           few months back, and also it would offer a draw after the         *
 *           opponent moved, even if he made a blunder.  it now only offers a  *
 *           draw after moving to make sure it's reasonable.  Crafty now won't *
 *           resign if there is a deep mate, such as a mate in 10+, because we *
 *           want to be sure that the opponent can demonstrate making progress *
 *           before we toss in the towel.  LearnBook() now learns on all games *
 *           played.  the old algorithm had a serious problem in that negative *
 *           scores were trusted fully, positive scores were treated with low  *
 *           confidence, and scores near zero were ignored totally.  the net   *
 *           result was that learning values became more and more negative as  *
 *           games were played.  now equal positions are also factored in to   *
 *           the learning equation to help pull some of these negative values  *
 *           back up.  Book() now excludes moves that have not been played     *
 *           many times (if there is at least one move that has) for book      *
 *           random = 2, 3 and 4.  This stops some of the silly moves.         *
 *           position learning is turned off after 15 moves have passed since  *
 *           leaving book, to avoid learning things that won't be useful at a  *
 *           later time.  hashing changed slightly to include "permanent"      *
 *           entries so that the learned stuff can be copied into the hash     *
 *           table with some confidence that it will stay there long enough to *
 *           be used.                                                          *
 *                                                                             *
 *   11.16   king tropism toned down a little to not be quite so intent on     *
 *           closeness to the kings, so that other positional ideas don't get  *
 *           "lost" in the eval.  back to normal piece values (1,3,3,5,9) for  *
 *           a while.  optimizations in Quiesce() speeded things up about 2%.  *
 *           pawns pushed toward the king are not so valuable any more so that *
 *           Crafty won't prefer to hold on to them rather than trading to     *
 *           open a file(s) on the enemy king.  BookLearn() call was moved in  *
 *           Resign() so that it first learns, then resigns, so that it won't  *
 *           get zapped by a SIGTERM right in the middle of learning when      *
 *           xboard realizes the game is over.  edit/setboard logic modified   *
 *           so that it is now possible to back up, and move forward in a game *
 *           that was set up via these commands.                               *
 *                                                                             *
 *   11.17   EvaluatePawns() modified to eliminate "loose pawn" penalty which  *
 *           was not particularly effective and produced pawn scores that were *
 *           sometimes misleading.  several optimizations dealing with cache   *
 *           efficiency, primarily changing int's to signed char's so that     *
 *           multiple values fit into a cache line together, to eliminate some *
 *           cache thrashing.  PopCnt() no longer used to recognize that we    *
 *           have reached an endgame database, there's now a counter for the   *
 *           total number of pieces on the board, as it's much faster to inc   *
 *           and dec that value rather than count 1 bits.  tweaks to MakeMove  *
 *           and UnmakeMove to make things a couple of percent faster, but a   *
 *           whole lot cleaner.  ditto for Swap and Quiesce.  more speed, and  *
 *           cleaner code.  outside passed pawn scored scaled down except when *
 *           the opponent has no pieces at all.  "lazy eval" cleaned up.  we   *
 *           now have two early exits, one before king safety and one after    *
 *           king safety.  there are two saved values so we have an idea of    *
 *           how large the positional scores have gotten to make this work.    *
 *           bug in passed pawn code was evaluating black passed pawns as less *
 *           valuable than white.  fixed and passed pawn scores increased      *
 *           slightly.  isolated pawn scoring modified so the penalty is pro-  *
 *           portional to the number of isolani each side has, rather than the *
 *           old approach of penalizing the "excess" isolani one side has over *
 *           the other side.  seems to be more accurate, but we'll see.  fixed *
 *           a rather gross bug in ValidateMove() related to the way castling  *
 *           status not only indicates whether castling is legal or not, but   *
 *           if it's not, whether that side castled or move the king/rooks.    *
 *           this let ValidateMove() fail to correctly detect that a castling  *
 *           move from the hash table might be invalid, which could wreck the  *
 *           search easily.  this was an oversight from the new status code.   *
 *           serious book bug fixed.  BookUp() was not counting wins and       *
 *           losses correctly, a bug introduced to make small.pgn work. minor  *
 *           bug in the "trapped bishop" (a2/h2/a7/h7) code fixed.  minor bug  *
 *           in Swap() also fixed (early exit that was not safe in rare cases.)*
 *                                                                             *
 *   11.18   EvaluatePawns() modified to recognize that if there are two white *
 *           pawns "rammed" by black pawns at (say) c4/c5 and e4/e5, then any  *
 *           pawns on the d-file are also effectively rammed as well since     *
 *           there is no hope for advancing it.  auto232 automatic play code   *
 *           seems to be working, finally.  the problem was Crafty delayed     *
 *           echoing the move back to auto232, if the predicted move was the   *
 *           move played by the opponent.  auto232 gave Crafty 3 seconds and   *
 *           then said "too late, you must be hung."  outpost knight scoring   *
 *           modified to produce scores between 0 and .2 pawns.  a knight was  *
 *           getting too valuable, which caused some confusion in the scoring. *
 *                                                                             *
 *   11.19   slight reduction in the value of passed pawns, as they were       *
 *           getting pretty large.  cleaned up annotate.c to get rid of code   *
 *           that didn't work out.  annotate now gives the PV for the move     *
 *           actually played as well as the move Crafty suggests is best.      *
 *           Crafty now has a reasonable "trade" bonus that kicks in when it   *
 *           has 20 points of material (or less) and is ahead or behind at     *
 *           least 2 pawns.  this trade bonus ranges from 0 to 1000 (one pawn) *
 *           and encourages the side that is winning to trade, while the side  *
 *           that is losing is encouraged to avoid trades.  more minor tweaks  *
 *           for auto232 including trying a delay of 100ms before sending      *
 *           a move.  new annotate command gives the option to get more than   *
 *           one suggested best move displayed, as well as fixes a few bugs    *
 *           in the older code.  fix to bishop + wrong rook pawn code to also  *
 *           recognize the RP + no pieces is just as bad if the king can reach *
 *           the queening square first.                                        *
 *                                                                             *
 *   11.20   cleanup to annotate command.  it now won't predict that one side  *
 *           will follow a book line that only resulted in losses.  also a     *
 *           couple of glitches in annotate where it was possible for a move   *
 *           to take an exhorbitant amount of time if the best move was a      *
 *           book move, but there were no other possible book moves.  the      *
 *           trade bonus now includes trade pawns if behind, but not if ahead  *
 *           as well as now considering being ahead or behind only one pawn    *
 *           rather than the two pawns used previously in 11.19.               *
 *                                                                             *
 *   11.21   additional bug fix in annotate command that would fail if there   *
 *           was only one legal move to search.  passed pawn values now have   *
 *           an added evaluation component based on material on the board, so  *
 *           that they become more valuable as material is traded.             *
 *                                                                             *
 *   11.22   test command modified.  test <filename> [N] (where N is optional  *
 *           and defaults to 99) will terminate a test position after N con-   *
 *           secutive iterations have had the correct solution.  bug in        *
 *           Quiesce() fixed, which would incorrectly prune (or fail to prune) *
 *           some captures, due to using "Material" which is computed with     *
 *           respect to white-to-move.  this was fixed many versions ago, but  *
 *           the fix was somehow lost.  fix to EvaluateDraws that mistakenly   *
 *           declared some endings drawn when there were rookpawns on both     *
 *           sides of the board, and the king could get in front of one. minor *
 *           fix to RepetitionCheck() that was checking one too many entries.  *
 *           no harmful effect other than one extra iteration in the loop that *
 *           would make "purify/purity" fail as well as slow things down 1% or *
 *           so.                                                               *
 *                                                                             *
 *   11.23   logpath=, bookpath= and tbpath= command line options added to     *
 *           direct logs, books and tb files to the indicated path.  these     *
 *           only work as command line options, and can't be used in normal    *
 *           places since the files are already opened and in use. a bug in    *
 *           Evaluate() would call EvaluatePawns() when there were no pawns,   *
 *           breaking things on many systems.                                  *
 *                                                                             *
 *   12.0    rewrite of Input/Output routines.  Crafty no longer relies on the *
 *           C library buffered I/O routine scanf() for input.  this made it   *
 *           basically impossible to determine when to read data from the key- *
 *           board, which made xboard/winboard difficult to interface with.    *
 *           now Crafty does its own I/O using read(), which is actually much  *
 *           cleaner and easier.  minor bug where a fail high in very short    *
 *           time controls might not get played...                             *
 *                                                                             *
 *   12.1    clean-up of Main().  the code had gotten so obtuse with the       *
 *           pondering call, plus handling Option() plus move input, that it   *
 *           was nearly impossible to follow.  It is now *much* cleaner and    *
 *           easier to understand/follow.                                      *
 *                                                                             *
 *   12.2    continued cleanup of I/O, particularly the way main() is          *
 *           structured, to make it more understandable.  rewritten time.c     *
 *           to make it more readable and understandable, not to mention       *
 *           easier to modify.  fixed a timing problem where Crafty could be   *
 *           pondering, and the predicted move is made followed immediately by *
 *           "force", caused when the opponent makes a move and loses on time, *
 *           or makes a move and resigns.  this would leave the engine state   *
 *           somewhat confused, and would result in the "new" command not      *
 *           reinitializing things at all, which would hang crafty on xboard   *
 *           or winboard.                                                      *
 *                                                                             *
 *   12.3    modified piece values somewhat to increase their worth relative   *
 *           to a pawn, to try to stop the tendency to sac a piece for 3 pawns *
 *           and get into trouble for doing so.  minor fixes in NewGame() that *
 *           caused odd problems, such as learning positions after 1. e4.  the *
 *           position.lrn/.bin files were growing faster than they should.     *
 *           other minor tweaks to fix a few broken commands in Option().      *
 *           slight reduction in trade bonus to match slightly less valuable   *
 *           pawns.                                                            *
 *                                                                             *
 *   12.4    added ABSearch() macro, which makes Search() much easier to read  *
 *           by doing the test to call Search() or Quiesce() in the macro      *
 *           where it is hidden from sight.  bugs in the way the log files     *
 *           were closed and then used caused crashed with log=off.            *
 *                                                                             *
 *   12.5    development bonus for central pawns added to combat the h4/a3     *
 *           sort of openings that would get Crafty into trouble.  it now will *
 *           try to seize the center if the opponent dallies around.           *
 *                                                                             *
 *   12.6    bug in EvaluateDraws() that would erroneously decide that a KNP   *
 *           vs K was drawn if the pawn was a rook pawn and the king could get *
 *           in front of it, which was wrong.  another minor bug would use     *
 *           EvaluateMate() when only a simple exchange ahead, which would     *
 *           result in sometimes giving up a pawn to reach such a position.    *
 *           minor bug in SetBoard() would incorrectly reset many important    *
 *           game state variables if the initial position was set to anything  *
 *           other than the normal starting position, such as wild 7.  this    *
 *           would make learning add odd PV's to the .lrn file.  development   *
 *           bonus modified topenalize moving the queen before minor pieces,   *
 *           and not moving minor pieces at all.  it is now possible to build  *
 *           a "wild 7" book, by first typing "wild 7", and then typing the    *
 *           normal book create command.  Crafty will remember to reset to the *
 *           "wild 7" position at the start of each book line.  note that it   *
 *           is not possible to have both wild 7 book lines *and* regular book *
 *           lines in the same book.                                           *
 *                                                                             *
 *   12.7    failsoft added, so that scores can now be returned outside the    *
 *           alpha/beta window.  minor null-move threat detection added where  *
 *           a mate in 1 score, returned by a null-move search, causes a one   *
 *           ply search extension, since a mate in one is a serious threat.    *
 *           razoring is now disabled if there is *any* sort of extension in   *
 *           the search preceeding the point where razoring would be applied,  *
 *           to avoid razoring taking away one ply from a search that was ex-  *
 *           tended (for good reasons) earlier.  fail-soft discarded, due to   *
 *           no advantages at all, and a slight slowdown in speed.  rewrite of *
 *           pawn hashing, plus a rewrite of the weak pawn scoring code to     *
 *           make it significantly more accurate, while going a little slower  *
 *           (but since hashing hits 99% of the time, the slower speed is not  *
 *           noticable at all.)  evaluation tweaking as well.                  *
 *                                                                             *
 *   12.8    continued work on weak pawn analysis, as well as a few minor      *
 *           changes to clean the code up.                                     *
 *                                                                             *
 *   13.0    preparation for the Paris WMCCC version starts here.  first new   *
 *           thing is the blocked pawn evaluation code.  this recognizes when  *
 *           a pawn is immobolized and when a pawn has lever potential, but    *
 *           is disabled if playing a computer opponent.  passed pawn scoring  *
 *           modified to eliminate duplicate bonuses that were added in        *
 *           EvaluatePawns as well as EvaluatePassedPawns.  Trade bonus code   *
 *           rewritten to reflect trades made based on the material when the   *
 *           search begins.  this means that some things have to be cleared in *
 *           the hash table after a capture is really made on the board, but   *
 *           prevents the eval from looking so odd near the end of a game.     *
 *           minor bug with book random 0 fixed.  if there was only one book   *
 *           move, the search could blow up.                                   *
 *                                                                             *
 *   13.1    all positional scores reduced by 1/4, in an attempt to balance    *
 *           things a little better.  also more modifications to the weak and  *
 *           blocked pawn code.  added evaluation code to help with KRP vs KR, *
 *           so that the pawn won't be advanced too far before the king comes  *
 *           to its aid.  ditto for defending, it knows that once the king is  *
 *           in front of the pawn, it is a draw.                               *
 *                                                                             *
 *   13.2    blocked pawn scoring changed slightly to not check too far to see *
 *           if a pawn can advance.  also pawns on center squares are weighted *
 *           more heavily to encourage keeping them there, or trying to get    *
 *           rid of them if the opponent has some there.  discovered that      *
 *           somehow, the two lines of code that add in bonuses for passed     *
 *           pawns were deleted as I cleaned up and moved code around.  these  *
 *           were reinserted (missing from 13.0 on).                           *
 *                                                                             *
 *   13.3    modified tablebase code to support 5 piece endings.  there is now *
 *           a configuration option (see Makefile) to specify 3, 4 or 5 piece  *
 *           endgame databases.  more evaluation tuning.                       *
 *                                                                             *
 *   13.4    modified null-move search.  if there is more than a rook left for *
 *           the side on move, null is always tried, as before.  if there is   *
 *           a rook or less left, the null move is only tried within 5 plies   *
 *           of the leaf positions, so that as the search progresses deeper,   *
 *           null-move errors are at least moved away from the root.  many     *
 *           evaluation changes, particularly to king safety and evaluating    *
 *           castling to one side while the other side is safer.  also it now  *
 *           handles pre-castled positions better.                             *
 *                                                                             *
 *   13.5    "from-to" display patch from Jason added.  this shows the from    *
 *           and to squares on a small diagram, oriented to whether Crafty is  *
 *           playing black or white.  the intent is to minimize operator       *
 *           errors when playing black and the board coordinates are reversed. *
 *           more eval changes.                                                *
 *                                                                             *
 *   13.6    weak pawns on open files now add value to the opponent's rooks    *
 *           since they are the pieces that will primarily use an open file to *
 *           attack a weak pawn.                                               *
 *                                                                             *
 *   13.7    minor eval tweaks, plus fixes for the CR/LF file reading problems *
 *           in windows NT.                                                    *
 *                                                                             *
 *   13.8    adjustments to book.c, primarily preventing Crafty from playing   *
 *           lines that had very few games in the file, because those are      *
 *           often quite weak players.  minor fix to InputMoves() so that a    *
 *           move like bxc3 can *never* be interpreted as a bishop move.  a    *
 *           bishop move must use an uppercase B, as in Bxc3.  bug in the      *
 *           king safety for white only was not checking for open opponent     *
 *           files on the king correctly.                                      *
 *                                                                             *
 *   13.9    minor adjustment to time allocation to allow "operator time" to   *
 *           affect time per move.  this is set by "operator <n>" where <n> is *
 *           time in seconds per move that should be "reserved" to allow the   *
 *           operator some typing/bookkeeping time.  new command "book         *
 *           trigger <n>" added so that in tournament mode, when choosing a    *
 *           book line, Crafty will revert to book random 0 if the least       *
 *           popular move was played fewer times than <n>.  this is an attempt *
 *           to avoid trusting narrow book lines too much while still allowing *
 *           adequate randomness.  if the least frequently played move in the  *
 *           set of book moves was played fewer times than this, then a search *
 *           over all the book moves is done.  If the best one doesn't look    *
 *           so hot, crafty drops out of book and searches *all* legal moves   *
 *           instead.                                                          *
 *                                                                             *
 *   13.10   minor adjustments.  this is the gold Paris version that is going  *
 *           with Jason.  any changes made during the event will be included   *
 *           in the next version.                                              *
 *                                                                             *
 *   14.0    major eval modification to return to centipawn evaluation, rather *
 *           then millipawns.  this reduces the resolution, but makes it a lot *
 *           easier to understand evaluation changes.  significant eval mods   *
 *           regarding king safety and large positional bonuses, where the ad- *
 *           vantage is not pretty solid.  note that old book learning will    *
 *           not work now, since the evals are wrong.  old position learning   *
 *           must be deleted completely.  see the read.me file for details on  *
 *           what must be done about book learning results.  new egtb=n option *
 *           to replace the older -DTABLEBASES=n Makefile option, so that the  *
 *           tablebases can be enabled or disabled without recompiling.        *
 *                                                                             *
 *   14.1    glitch in EvaluateDevelopment() was producing some grossly large  *
 *           positional scores.  also there were problems with where the       *
 *           PreEvaluate() procedure were called, so that it could be called   *
 *           *after* doing RootMoveslist(), but before starting a search.  this*
 *           caused minor problems with hashing scores.  one case was that it  *
 *           was possible for a "test suite" to produce slightly different     *
 *           scores than the same position run in normal mode.  this has been  *
 *           corrected.  st=n command now supports fractional times to .01     *
 *           second resolution.                                                *
 *                                                                             *
 *   14.2    MATE reduced to 32767, which makes all scores now fit into 16     *
 *           bits.  added code to EvaluatePawns() to detect the Stonewall      *
 *           pawn formation and not like it as black.  also it detects a       *
 *           reversed Stonewall formation (for black) and doesn't like it as   *
 *           white.  EvaluateOutsidePassedPawns() removed.  functionality is   *
 *           incorporated in EvaluatePawns() and is hashed, which speeds the   *
 *           evaluation up a bit.  king safety is now fully symmetric and is   *
 *           folded into individual piece scoring to encourage pieces to       *
 *           attack an unsafe king.                                            *
 *                                                                             *
 *   14.3    minor adjustments to the king safety code for detecting attacks   *
 *           initiated by pushing kingside pawns.  flip/flop commands added to *
 *           mirror the board either horizontally or vertically to check for   *
 *           symmetry bugs in the evaluation.  other eval tuning changes.      *
 *                                                                             *
 *   14.4    queen value increased to stop trading queen for two rooks.  book  *
 *           learning slightly modified to react quicker.  also scores are now *
 *           stored in the book file as floats to get rid of an annoying trun- *
 *           cation problem that was dragging scores toward zero.  the book    *
 *           file now has a "version" so that old book versions won't cause    *
 *           problems due to incorrect formats.  null-move mated threat ex-    *
 *           tension was modified.  if null-move search fails high, I fail     *
 *           high as always, if it fails low, and it says I get mated in N     *
 *           moves, I extend all moves at this ply, since something is going   *
 *           on.  I also carry this threat extension into the hash table since *
 *           a hash entry can say "don't do null move, it will fail low."  I   *
 *           now have a flag that says not only will null-move fail low, it    *
 *           fails to "mated in N" so this ply needs extending even without a  *
 *           null-move search to tell it so.  book learning greatly modified   *
 *           in the way it "distributes" the learned values, in an effort to   *
 *           make learning happen faster.  I now construct a sort of "tree"    *
 *           so I know how many book alternatives Crafty had at each move it   *
 *           at each book move it played.  I then assign the whole learn value *
 *           to all moves below the last book move where there was a choice,   *
 *           and also assign the whole learn value to the move where there     *
 *           was a choice.  I then divide the learn value by the number of     *
 *           choices and assign this to each book move (working backward once  *
 *           again) until the next point where there were choices.  this makes *
 *           sure that if there is a choice, and it is bad, it won't be played *
 *           again, even if this choice was at move 2, and the remainder of    *
 *           the book line was completely forced.  all in an effort to learn   *
 *           more quickly.                                                     *
 *                                                                             *
 *   14.5    annotate bug fixed where if there was only one legal move, the    *
 *           annotation would stop with no warning.  BookUp() now produces a   *
 *           more useful error message, giving the exact line number in the    *
 *           input file where the error occurred, to make fixing them easier.  *
 *           if you are playing without a book.bin, 14.4 would crash in the    *
 *           book learning code.  this is now caught and avoided.  BookUp()    *
 *           now knows how to skip analysis in PGN files, so you can use such  *
 *           files to create your opening book, without having problems.  it   *
 *           understands that nesting () {} characters "hides" the stuff in-   *
 *           side them, as well as accepting non-standard PGN comments that    *
 *           are inside [].  Annotate() now will annotate a PGN file with      *
 *           multiple games, although it will use the same options for all of  *
 *           the games.  PGN headers are preserved in the .can file.  annotate *
 *           now will recognize the first move in a comment (move) or {move}   *
 *           and will search that move and give analysis for it in addition to *
 *           the normal output.                                                *
 *                                                                             *
 *   14.6    minor change to book random 4 (use learned value.)  if all the    *
 *           learned values are 0, then use the book random 3 option instead.  *
 *           bug in 50-move counter fixed.  Learn() could cause this to be set *
 *           to a value that didn't really reflect the 50-move status, and     *
 *           cause games to be drawn when they should not be.  modified the    *
 *           "Mercilous" attack code to recognize a new variation he worked    *
 *           out that sacrifices a N, R and B for a mating attack.  no more.   *
 *                                                                             *
 *   14.7    "verbose" command removed and replaced by a new "display" command *
 *           that sets display options.  use "help display" for more info on   *
 *           how this works.  the "mercilous" attack scoring is only turned on *
 *           when playing "mercilous".  but there is a new "special" list that *
 *           you can add players too if you want, and this special scoring is  *
 *           turned on for them as well.                                       *
 *                                                                             *
 *   14.8    new scoring term to penalize unbalanced trades.  IE if Crafty has *
 *           to lose a pawn, it would often trade a knight for two pawns in-   *
 *           stead, which is actually worse.  this new term prevents this sort *
 *           of trades.                                                        *
 *                                                                             *
 *   14.9    "mercilous" attack code modified to handle a new wrinkle he (and  *
 *           one other player) found.                                          *
 *                                                                             *
 *   14.10   new "bench" command runs a test and gives a benchmark comparison  *
 *           for crafty and compares this to a P6/200 base machine.  minor bug *
 *           disabled the "dynamic draw score" and fixed it at zero, even if   *
 *           the opponent was much weaker (rating) or behind on time.  also    *
 *           draw_score was not reset to 0 at start of each new game, possibly *
 *           leaving it at +.20 after playing a higher-rated opponent.         *
 *                                                                             *
 *   14.11   release to make mercilous attack detection code the default, to   *
 *           prevent the rash of mercilous attacks on the chess servers.       *
 *                                                                             *
 *   14.12   modified tuning of evaluation.  scores were reduced in the past,  *
 *           to discourage the piece for two pawns sort of trades, but since   *
 *           this was basically solved in 14.8, scores are going "back up".    *
 *           particularly passed pawn scores.  Crafty now accepts draw offers  *
 *           if the last search result was <= the current result returned by   *
 *           DrawScore().  it also honors draw requests via xboard when        *
 *           against a human opponent as well, and will flag the game as over. *
 *           minor modification to annotate.c to display move numbers in the   *
 *           PV's to match the PV output format used everywhere else in        *
 *           Crafty.  a new type of learning, based on results, has been added *
 *           and is optional (learn=7 now enables every type of learning.)     *
 *           this type of learning uses the win/lose game result to flag an    *
 *           opening that leads to a lost game as "never" play again.  the     *
 *           book move selection logic has been modified.  there are four com- *
 *           ponents used in choosing book moves:  frequency of play; win/lose *
 *           ratio; static evaluation; and learned score.  There are four      *
 *           weights that can be modified with the bookw command, that control *
 *           how these 4 values are used to choose book moves.  each weight is *
 *           a floating point value between 0 and 1, and controls how much the *
 *           corresponding term factors in to move selection.                  *
 *                                                                             *
 *   14.13   fixed a book parsing bug that now requires a [Site "xxx"] tag in  *
 *           any book file between lines for the "minplay" option of book      *
 *           create to work properly.                                          *
 *                                                                             *
 *   15.0    this is the first version to support a parallel search using      *
 *           multiple processors on a shared-memory machinel.  this version    *
 *           uses the "PVS" algorithm (Principal Variation Search) that is an  *
 *           early form of "Young Brothers Wait".  this is not the final       *
 *           search algorithm that will be used, but it is relatively easy to  *
 *           implement, so that the massive data structure changes can be de-  *
 *           bugged before getting too fancy.  the major performance problem   *
 *           with this approach is that all processors work together at a node *
 *           and when one finishes, it has to wait until all others finish     *
 *           before it can start doing anything more.  this adds up to a       *
 *           significant amount of time and really prevents good speedups on   *
 *           multiprocessor machines.  this restriction will be eliminanted in *
 *           future versions, but it makes debugging much simpler for the      *
 *           first version.  after much agonizing, I finally chose to write my *
 *           own "spinlock" macros to avoid using the pthread_mutex_lock stuff *
 *           that is terribly inefficient due to its trying to be cute and     *
 *           yield the processor rather than spinning, when the lock is al-    *
 *           ready set.  I'd rather spin than context-switch.                  *
 *                                                                             *
 *   15.1    this version actually unleashes the full design of the parallel   *
 *           search, which lets threads split away from the "pack" when        *
 *           they become idle, and they may then jump in and help another      *
 *           busy thread.  this eliminates the significant delays that         *
 *           occur near the end of a search at a given ply.  now as those pro- *
 *           cessors drop out of the search at that ply, they are reused at    *
 *           other locations in the tree without any significant delays.       *
 *                                                                             *
 *   15.2    WinNT support added.  also fixed a small bug in Interrupt() that  *
 *           could let it exit with "busy" set so that it would ignore all     *
 *           input from that point forward, hanging the game up.  added a new  *
 *           "draw accept" and "draw decline" option to enable/disable Crafty  *
 *           accepting draw offers if it is even or behind.  turned on by      *
 *           an IM/GM opponent automatically.  Thread pools now being used to  *
 *           avoid the overhead of creating/destroying threads at a high rate  *
 *           rate of speed.  it is now quite easy to keep N processors busy.   *
 *                                                                             *
 *   15.3    CPU time accounting modified to correctly measure the actual time *
 *           spent in a parallel search, as well as to modify the way Crafty   *
 *           handles time management in an SMP environment.  a couple of bugs  *
 *           fixed in book.c, affecting which moves were played.  also veri-   *
 *           fied that this version will play any ! move in books.bin, even if *
 *           it was not played in the games used to build the main book.bin    *
 *           file.                                                             *
 *                                                                             *
 *   15.4    this version will terminate threads once the root position is in  *
 *           a database, to avoid burning cpu cycles that are not useful. a    *
 *           flag "done" is part of each thread block now.  when a thread goes *
 *           to select another move to search, and there are no more left, it  *
 *           sets "done" in the parent task thread block so that no other pro- *
 *           cessors will attempt to "join the party" at that block since no   *
 *           work remains to be done.  book selection logic modified so that   *
 *           frequency data is "squared" to improve probabilities.  also, the  *
 *           frequency data is used to cull moves, in that if a move was not   *
 *           played 1/10th of the number of times that the "most popular" move *
 *           was played, then that move is eliminated from consideration.      *
 *                                                                             *
 *   15.5    changes to "volatile" variables to enhance compiler optimization  *
 *           in places where it is safe.  added a function ThreadStop() that   *
 *           works better at stopping threads when a fail high condition       *
 *           occurs at any nodes.  it always stopped all sibling threads at    *
 *           the node in question, but failed to stop threads that might be    *
 *           working somewhere below the fail-high node.  ThreadStop() will    *
 *           recursively call itself to stop all of those threads. significant *
 *           increase in king centralization (endgame) scoring to encourage    *
 *           the king to come out and fight rather than stay back and get      *
 *           squeezed to death.  minor change to queen/king tropism to only    *
 *           conside the file distance, not ranks also.  bug in interupt.c     *
 *           fixed.  this bug would, on very rare occasion, let crafty read in *
 *           a move, but another thread could read on top of this and lose the *
 *           move.  xboard would then watch the game end with a <flag>.        *
 *                                                                             *
 *   15.6    ugly repetition draw bug (SMP only) fixed.  I carefully copied    *
 *           the repetition list from parent to child, but also copied the     *
 *           repetition list pointer...  which remained pointing at the parent *
 *           repetition list.  which failed, of course.                        *
 *                                                                             *
 *   15.7    problem in passing PV's back up the search fixed.  the old bug of *
 *           a fail high/fail low was not completely handled, so that if the   *
 *           *last* move on a search failed high, then low, the PV could be    *
 *           broken or wrong, causing Crafty to make the wrong move, or else   *
 *           break something when the bogus PV was used.  piece/square tables  *
 *           now only have the _w version initialized in data.c, to eliminate  *
 *           the second copy which often caused errors.  Initialize() now will *
 *           copy the _w tables to the _b tables (reflected of course.)        *
 *                                                                             *
 *   15.8    trade bonus modified to not kick in until one side is two pawns   *
 *           ahead or behind, so that trading toward a draw is not so common.  *
 *           fixed a whisper bug that would cause Crafty to whisper nonsense   *
 *           if it left book, then got back in book.  it also now whispers the *
 *           book move it played, rather than the move it would play if the    *
 *           opponent played the expected book move, which was confusing.      *
 *                                                                             *
 *   15.9    bug in positions with one legal move would abort the search after *
 *           a 4 ply search, as it should, but it was possible that the result *
 *           from the aborted search could be "kept" which would often make    *
 *           Crafty just "sit and wait" and flag on a chess server.            *
 *                                                                             *
 *   15.10   fixed "draw" command to reject draw offers if opponent has < ten  *
 *           seconds left and no increment is being used.  fixed glitch in     *
 *           LearnResult() that would crash crafty if no book was being used,  *
 *           and it decides to resign.  modified trade bonus code to eliminate *
 *           a hashing inconsistency.  minor glitch in "show thinking" would   *
 *           show bad value if score was mate.  added Tim Mann's new xboard/   *
 *           winboard "result" command and modified the output from Crafty to  *
 *           tell xboard when a game is over, using the new result format that *
 *           Tim now expects.  note that this is xboard 3.6.9, and earlier     *
 *           versions will *not* work correctly (ok on servers, but not when   *
 *           you play yourself) as the game won't end correctly due to the     *
 *           change in game-end message format between the engine and xboard.  *
 *                                                                             *
 *   15.11   modified SMP code to not start a parallel search at a node until  *
 *           "N" (N=2 at present) moves have been search.  N was 1, and when   *
 *           move ordering breaks down the size of the tree gets larger.  this *
 *           controls that much better.  fixed an ugly learning bug.  if the   *
 *           last move actually in the game history was legal for the other    *
 *           side, after playing it for the correct side, it could be played   *
 *           a second time, which would break things after learning was done.  *
 *           an example was Rxd4 for white, where black can respond with Rxd4. *
 *           changes for the new 3.6.10 xboard/winboard are also included as   *
 *           well as a fix to get book moves displayed in analysis window as   *
 *           it used to be done.                                               *
 *                                                                             *
 *   15.12   "the" SMP repetition bug was finally found and fixed.  CopyToSMP  *
 *           was setting the thread-specific rephead_* variable *wrong* which  *
 *           broke so many things it was not funny.  evaluation tuning in this *
 *           version as well to try to "center" values in a range of -X to +X  *
 *           rather than 0 to 2X.  trade bonus had a bug in the pawn part that *
 *           not only encouraged trading pawns when it should be doing the     *
 *           opposite, but the way it was written actually made it look bad to *
 *           win a pawn.  more minor xboard/winboard compatibility bugs fixed  *
 *           so that games end when they should.  DrawScore() had a quirk that *
 *           caused some problems, in that it didn't know what to do with non- *
 *           zero draw scores, and could return a value with the wrong sign at *
 *           times.  it is now passed a flag, "crafty_is_white" to fix this.   *
 *           modification so that crafty can handle the "FEN" PGN tag and set  *
 *           the board to the correct position when it is found.  xboard       *
 *           options "hard" and "easy" now enable and disable pondering.       *
 *                                                                             *
 *   15.13   modification to "bad trade" code to avoid any sort of unbalanced  *
 *           trades, like knight/bishop for 2-3 pawns, or two pieces for a     *
 *           rook and pawn.  more new xboard/winboard fixes for Illegal move   *
 *           messages and other engine interface changes made recently.  minor *
 *           change to null move search, to always search with the alpha/beta  *
 *           window of (beta-1,beta) rather than (alpha,beta), which is very   *
 *           slightly more efficient.                                          *
 *                                                                             *
 *   15.14   rewrite of ReadPGN() to correctly handle nesting of various sorts *
 *           of comments.  this will now correctly parse wall.pgn, except for  *
 *           promotion moves with no promotion piece specified.  the book      *
 *           create code also now correctly reports when you run out of disk   *
 *           space and this should work under any system to let you know when  *
 *           you run out of space.                                             *
 *                                                                             *
 *   15.15   major modifications to Book() and BookUp().  BookUp() now needs   *
 *           1/2 the temp space to build a book that it used to need (even     *
 *           less under windows).  also, a book position is now 16 bytes in-   *
 *           stead of 20 (or 24 under windows) further reducing the space      *
 *           requirements.  the "win/lose/draw" counts are no longer absolute, *
 *           rather they are relative so they can be stored in one byte. A new *
 *           method for setting "!" moves in books.bin is included in this     *
 *           version.  for any move in the input file used to make books.bin,  *
 *           you can add a {play nn%} string, which says to play this move nn% *
 *           of the time, regardless of how frequently it was played in the    *
 *           big book file.  for example, e4 {play 50%} says to play e4 50% of *
 *           the time.  note two things here:  (1) if the percentages for all  *
 *           of white's first moves add up to a number > 100, then the         *
 *           percentage played is taken as is, but all will be treated as if   *
 *           they sum to 100 (ie if there are three first moves, each with a   *
 *           percentage of 50%, they will behave as though they are all 33%    *
 *           moves).  (2) for any moves not marked with a % (assuming at least *
 *           one move *is* marked with a percent) then such moves will use the *
 *           remaining percentage left over applied to them equally. note that *
 *           using the % *and* the ! flags together slightly changes things,   *
 *           because normally only the set of ! moves will be considered, and  *
 *           within that set, any with % specified will have that percent used *
 *           as expected.  but if you have some moves with !, then a percent   *
 *           on any of the *other* moves won't do a thing, because only the !  *
 *           moves will be included in the set to choose from.                 *
 *                                                                             *
 *   15.16   bug in the king tropism code, particularly for white pieces that  *
 *           want to be close to the black king, fixed in this version.  new   *
 *           History() function that handles all history/killer cases, rather  *
 *           than the old 2-function approach.  ugly RepetitionCheck() bug     *
 *           fixed in CopyToSMP().  this was not copying the complete replist  *
 *           due to a ply>>2 rather than ply>>1 counter.                       *
 *                                                                             *
 *   15.17   adjustments to "aggressiveness" to slightly tone it down.  minor  *
 *           fix to avoid the odd case of whispering one move and playing an-  *
 *           other, caused by a fail-high/fail-low overwriting the pv[1] stuff *
 *           and then Iterate() printing that rather than pv[0] which is the   *
 *           correct one.  new LegalMove() function that strengthens the test  *
 *           for legality at the root, so that it is impossible to ponder a    *
 *           move that looks legal, but isn't.  modifications to king safety   *
 *           to better handle half-open files around the king as well as open  *
 *           files.  EGTB "swindler" added.  if the position is drawn at the   *
 *           root of the tree, then all losing moves are excluded from the     *
 *           move list and the remainder are searched normally with the EGTB   *
 *           databases disabled, in an effort to give the opponent a chance to *
 *           go wrong and lose.  fixed "mode tournament" and "book random 0"   *
 *           so that they will work correctly with xboard/winboard, and can    *
 *           even be used to play bullet games on a server if desired. minor   *
 *           fix to attempt to work around a non-standard I/O problem on the   *
 *           Macintosh platform dealing with '\r' as a record terminator       *
 *           rather than the industry/POSIX-standard \n terminator character.  *
 *                                                                             *
 *   15.18   fix to the "material balance" evaluation term so that it will not *
 *           like two pieces for a rook (plus pawn) nor will it like trading a *
 *           piece for multiple pawns.  a rather gross bug in the repetition   *
 *           code (dealing with 50 move rule) could overwrite random places in *
 *           memory when the 50 move rule approached, because the arrays were  *
 *           not long enough to hold 50 moves, plus allow the search to go     *
 *           beyond the 50-move rule (which is legal and optional) and then    *
 *           output moves (which uses ply=65 data structures).  this let the   *
 *           repetition (50-move-rule part) overwrite things by storing well   *
 *           beyond the end of the repetition list for either side.  minor fix *
 *           to EGTB "swindle" code.  it now only tries the searches if it is  *
 *           the side with swindling chances.  ie it is pointless to try for   *
 *           a swindle in KRP vs KR if you don't have the P.  :)  some very    *
 *           substantial changes to evaluate.c to get things back into some    *
 *           form of synch with each other.                                    *
 *                                                                             *
 *   15.19   more evaluation changes.  slight change to the Lock() facility    *
 *           as it is used to lock the hash table.  modifications to the book  *
 *           selection logic so that any move in books.bin that is not in the  *
 *           regular book.bin file still can be played, and will be played if  *
 *           it has a {play xxx%} or ! option.  new option added to the book   *
 *           create command to allow the creation of a better book.  this      *
 *           option lets you specify a percentage that says "exclude a book    *
 *           move it if didn't win xx% as many games as it lost.  IE, if the   *
 *           book move has 100 losses, and you use 50% for the new option, the *
 *           move will only be included if there are at least 50 wins.  this   *
 *           allows culling lines that only lost, for example.  new bad trade  *
 *           scoring that is simpler.  if one side has one extra minor piece   *
 *           and major pieces are equal, the other side has traded a minor for *
 *           pawns and made a mistake.  if major pieces are not matched, and   *
 *           one side has two or more extra minors, we have seen either a rook *
 *           for two minor pieces (bad) or a queen for three minor pieces (bad *
 *           also).  horrible bug in initializing min_thread_depth, which is   *
 *           supposed to control thrashing.  the SMP search won't split the    *
 *           tree within "min_thread_depth" of the leaf positions.  due to a   *
 *           gross bug, however, this was initialized to "2", and would have   *
 *           been the right value except that a ply in Crafty is 4.  the       *
 *           mtmin command that adjusts this correctly multiplied it by 4,     *
 *           but in data.c, it was left at "2" which lets the search split way *
 *           too deeply and can cause thrashing.  it now correctly defaults to *
 *           120 (2*PLY) as planned.  Crafty now *only* supports               *
 *           winboard/xboard 4.0 or higher, by sending the string "move xxx"   *
 *           to indicate its move.  this was done to eliminate older xboard    *
 *           versions that had some incompatibilities with crafty that were    *
 *           causing lots of questions/problems.  xboard 4.0 works perfectly   *
 *           and is the only recommended GUI now.                              *
 *                                                                             *
 *   15.20   new evaluation term to ensure that pawns are put on squares of    *
 *           the opposite color as the bishop in endings where one side only   *
 *           has a single bishop.  another new evaluation term to favor        *
 *           bishops over knights in endings with pawns on both sides of the   *
 *           board.  search extensions now constrained so that when doing an   *
 *           N-ply search, the first 2N plies can extend normally, but beyond  *
 *           that the extensions are reduced by one-half.  this eliminates a   *
 *           few tree explosions that wasted lots of time but didn't produce   *
 *           any useful results.  this version solves 299/300 of the Win at    *
 *           Chess positions on a single-cpu pentium pro 200mhz machine now.   *
 *           new evaluation term to reward "pawn duos" (two pawns side by side *
 *           which gives them the most flexibility in advancing.  a change to  *
 *           the bishops of opposite color to not just consider B vs B drawish *
 *           when the B's are on opposite colors, but to also consider other   *
 *           positons like RB vs RB drawish with opposite B's.                 *
 *                                                                             *
 *   16.0    hash functions renamed to HashProbe() and HashStore().  The store *
 *           functions (2) were combined to eliminate some duplicate code and  *
 *           shrink the cache footprint a bit.  adjustment to "losing the      *
 *           right to castle" so that the penalty is much less if this is done *
 *           when trading queens, since a king in the center becomes less of a *
 *           problem there. several eval tweaks.  support for Eugene Nalimov's *
 *           new endgame databases that reduce the size by 50%.  added a new   *
 *           cache=xxx command to set the tablebase cache (more memory means   *
 *           less I/O of course).  the "egtb" command now has two uses.  if    *
 *           use egtb=0, you can disable tablebases for testing.  otherwise,   *
 *           you just add "egtb" to your command line or .craftyrc file and    *
 *           Crafty automatically recognizes the files that are present and    *
 *           sets up to probe them properly. added an eval term to catch a     *
 *           closed position with pawns at e4/d3/c4 and then avoiding the      *
 *           temptation to castle into an attack.  most of the evaluation      *
 *           discontinuities have been removed, using the two new macros       *
 *           ScaleToMaterial() and InverseScaleToMaterial().  Scale() is used  *
 *           to reduce scores as material is removed from the board, while     *
 *           InverseScale() is used to increase the score as material is       *
 *           removed.  this removed a few ugly effects of things happening     *
 *           right around the EG_MAT threshold.                                *
 *                                                                             *
 *   16.1    bug in EGTBProbe() which used the wrong variable to access the    *
 *           enpassant target square was fixed.  the cache=x command now       *
 *           checks for a failed malloc() and reverts to the default cache     *
 *           size to avoid crashes.  major eval tuning changes.  cache bug     *
 *           would do an extra malloc() and if it is done after the "egtb"     *
 *           command it would crash.  analyze mode now turns off the "swindle" *
 *           mode.                                                             *
 *                                                                             *
 *   16.2    more evaluation changes, specifically to bring king safety down   *
 *           to reasonable levels.  support for the DGT electronic chess board *
 *           is now included (but only works in text mode, not in conjunction  *
 *           with xboard/winboard yet.  fix to HashStore() that corrected a    *
 *           problem with moving an entry from tablea to tableb, but to the    *
 *           wrong address 50% of the time (thanks to J. Wesley Cleveland).    *
 *                                                                             *
 *   16.3    performance tweaks plus a few evaluation changes.  An oversight   *
 *           would let crafty play a move like exd5 when cxd5 was playable.    *
 *           IE it didn't follow the general rule "capture toward the center." *
 *           this has been fixed.  king safety ramped up just a bit.           *
 *                                                                             *
 *   16.4    search extension fixed.  one-reply was being triggered when there *
 *           was only one capture to look at as well, which was wrong.  minor  *
 *           fix to king safety in Evaluate().  adjustments to preeval to fix  *
 *           some "space" problems caused by not wanting to advance pawns at   *
 *           all, plus some piece/square pawn values that were too large near  *
 *           the opponent's king position.  new swindle on*off command allows  *
 *           the user to disable "swindle mode" so that crafty will report     *
 *           tablebase draws as draws.  swindle mode is now disabled auto-     *
 *           matically in analysis or annotate modes.  DrawScore() now returns *
 *           a draw score that is not nearly so negative when playing humans.  *
 *           the score was a bit large (-.66 and -.33) so that this could tend *
 *           to force Crafty into losing rather than drawn positions at times. *
 *           EGTB probe code now monitors how the probes are affecting the nps *
 *           and modifies the probe depth to control this.  IE it adjusts the  *
 *           max depth of probes to attempt to keep the NPS at around 50% or   *
 *           thereabouts of the nominal NPS rate.  fixed a nasty bug in the    *
 *           EGTB 'throttle' code.  it was possible that the EGTB_mindepth     *
 *           could get set to something more than 4 plies, then the next       *
 *           search starts off already in a tablebase ending, but with this    *
 *           probe limit, it wouldn't probe yet Iterate() would terminate the  *
 *           search after a couple of plies.  and the move chosen could draw.  *
 *           new code submitted by George Barrett, which adds a new command    *
 *           "html on".  Using this will cause the annotate command to produce *
 *           a game.html file (rather than game.can) which includes nice board *
 *           displays (bitmapped images) everywhere Crafty suggests a different*
 *           move.  you will need to download the bitmaps directory files to   *
 *           make this work.  note that html on enables this or you will get   *
 *           normal annotation output in the .can file.  final hashing changes *
 *           made.  now crafty has only two hash tables, the 'depth preferred' *
 *           and 'always store' tables, but not one for each side.             *
 *                                                                             *
 *   16.5    minor glitch in internal iterative deepening code (in search.c)   *
 *           could sometimes produce an invalid move.  crafty now probes the   *
 *           hash table to find the best move which works in all cases.        *
 *           interesting tablebase bug fixed.  By probing at ply=2, the        *
 *           search could overlook a repetition/50 move draw, and turn a won   *
 *           position into a draw.  Crafty now only probes at ply > 2, to      *
 *           let the RepetitionCheck() function have a chance.  added code by  *
 *           Dan Corbett to add environment variables for the tablebases,      *
 *           books, logfiles and the .craftyrc file paths.  the environment    *
 *           variables CRAFTY_TB_PATH, CRAFTY_BOOK_PATH, CRAFTY_LOG_PATH and   *
 *           CRAFTY_RC_PATH should point to where these files are located and  *
 *           offer an alternative to specifying them on the command line.      *
 *           final version of the EGTB code is included in this version.  this *
 *           allows Crafty to use either compressed (using Andrew Kadatch's    *
 *           compressor, _not_ zip or gzip) or non-compressed tablebases.  it  *
 *           will use non-compressed files when available, and will also use   *
 *           compressed files that are available so long as there is no non-   *
 *           compressed version of the same file.  it is allowable to mix and  *
 *           match as you see fit, but with all of the files compressed, the   *
 *           savings is tremendous, roughly a factor of 5 in space reduction.  *
 *                                                                             *
 *   16.6    major rewrite of king-safety pawn shelter code to emphasize open  *
 *           files (and half-open files) moreso than just pawns that have been *
 *           moved.  dynamic EGTB probe depth removed.  this caused far too    *
 *           many search inconsistencies.  a fairly serious SMP bug that could *
 *           produce a few hash glitches was found.  rewrite of the 'king-     *
 *           tropism' code completed.  now the pieces that are 'crowding' the  *
 *           king get a bigger bonus if there are more of them.  ie it is more *
 *           than twice as good if we have two pieces close to the king, while *
 *           before this was purely 'linear'.  minor fix to book.c to cure an  *
 *           annotate command bug that would produce odd output in multi-game  *
 *           PGN files.                                                        *
 *                                                                             *
 *   16.7    minor bug in 'book create' command would produce wrong line num-  *
 *           bers if you used two book create commands without restarting      *
 *           crafty between uses.  replaced "ls" command with a !cmd shell     *
 *           escape to allow _any_ command to be executed by a shell. change   *
 *           to bishop scoring to avoid a bonus for a bishop pair _and_ a good *
 *           bishop sitting at g2/g7/etc to fill a pawn hole.  if the bishop   *
 *           fills that hole, the bishop pair score is reduced by 1/2 to avoid *
 *           scores getting too large.  another ugly SMP bug fixed.  it was    *
 *           for the CopyFromSMP() function to fail because Search() put the   *
 *           _wrong_ value into tree->value.  the "don't castle into an unsafe *
 *           king position" code was scaled up a bit as it wasn't quite up to  *
 *           detecting all cases of this problem.  the parallel search has     *
 *           been modified so that it can now split the tree at the root, as   *
 *           well as at deeper nodes.  this has improved the parallel search   *
 *           efficiency noticably while also making the code a bit more        *
 *           complex.  this uses an an adaptive algorithm that pays close      *
 *           attention to the node count for each root move.  if one (or more) *
 *           moves below the best move have high node counts (indicating that  *
 *           these moves might become new 'best' moves) then these moves are   *
 *           flagged as "don't search in parallel" so that all such moves are  *
 *           searched one by one, using all processors so that a new best move *
 *           if found faster.  positional scores were scaled back 50% and the  *
 *           king safety code was again modified to incorporate pawn storms,   *
 *           which was intentionally ignored in the last major revision.  many *
 *           other scoring terms have been modified as well to attempt to      *
 *           bring the scores back closer to something reasonable.             *
 *                                                                             *
 *   16.8    bug in evaluate.c (improper editing) broke the scoring for white  *
 *           rooks on open files (among other things.)  new twist on null-     *
 *           move search...  Crafty now uses R=3 near the root of the tree,    *
 *           and R=2 near the top.  it also uses null-move so long as there is *
 *           a single piece on the board, but when material drops to a rook or *
 *           less, null move is turned off and only used in the last 7 plies   *
 *           to push the zugzwang errors far enough off that they can be       *
 *           avoided, hopefully.                                               *
 *                                                                             *
 *   16.9    tuning to king safety.  King in center of board was way too high  *
 *           which made the bonus for castling way too big.  more fine-tuning  *
 *           on the new 'tropism' code (that tries to coordinate piece attacks *
 *           on the king).  it understands closeness and (now) open files for  *
 *           the rooks/queens.  modified blocked center pawn code so that an   *
 *           'outpost' in front of an unmoved D/E pawn is made even stronger   *
 *           since it restrains that pawn and cramps the opponent.             *
 *                                                                             *
 *   16.10   all scores are back to 16.6 values except for king safety, as     *
 *           these values played well.  king safety is quite a bit different   *
 *           and now has two fine-tuning paramaters that can be set in the     *
 *           crafty.rc file (try help ksafety for more details, or see the new *
 *           crafty.doc for more details.  suffice it to say that you can now  *
 *           tune it to be aggressive or passive as you wish.                  *
 *                                                                             *
 *   16.11   adjustment to king safety asymmetry to make Crafty a bit more     *
 *           cautious about starting a king-side attack.  new "ksafe tropism"  *
 *           command allows the tropism scores (pulling pieces toward opponent *
 *           king) to be adjusted up or down (up is more aggressive).          *
 *                                                                             *
 *   16.12   evaluation adjustment options changed.  the new command to modify *
 *           this stuff is "evaluation option value".  For example, to change  *
 *           the asymmetry scoring for king safety, you now use "evaluation    *
 *           asymmetry 120".  see "help evaluation" for more details.  There   *
 *           is a new "bscale" option to adjust the scores for 'blocked' type  *
 *           positions, and I added a new "blockers_list" so that players that *
 *           continually try to lock things up to get easy draws can be better *
 *           handled automatically.  The command is "list B +name".  there are *
 *           other adjustable evaluation scaling parameters now (again, use    *
 *           "help evaluation" to see the options.)                            *
 *                                                                             *
 *   16.13   bug in Evaluate() fixed.  king safety could produce impossibly    *
 *           large scores due to negative subscript values.  minor change to   *
 *           root.c to allow partial tablebase sets while avoiding the ugly    *
 *           potential draw problem.  this was supplied by Tim Hoooebeek and   *
 *           seems to work ok for those wanting to have files like kpk with-   *
 *           out the corresponding promotion files.                            *
 *                                                                             *
 *   16.14   bug in Evaluate() fixed.  king safety could produce impossibly    *
 *           large scores due to a subscript two (2) larger than expected for  *
 *           max values.  A couple of other minor tweaks to rook on 7th as     *
 *           well.  setboard now validates enpassant target square to be sure  *
 *           that an enpassant capture is physically possible, and that the    *
 *           target square is on the right rank with pawns in the right place. *
 *                                                                             *
 *   16.15   bug in EGTBProbe() usage fixed.  it was possible to call this     *
 *           function before tablebases were initialized, or when there were   *
 *           more than 3 pieces on one side, which would break a subscript.    *
 *                                                                             *
 *   16.16   changes to the way EvaluatePassedPawn() works.  it now does a     *
 *           reasonable job of penalizing blockaded passed pawns.  also a bug  *
 *           in king scoring used a variable set from the previous call to the *
 *           Evaluate() procedure, which could produce bizarre effects.  a few *
 *           minor eval glitches that caused asymmetric scores unintentionally *
 *           were removed.                                                     *
 *                                                                             *
 *   16.17   minor "hole" in SMP code fixed.  it was possible that a move      *
 *           displayed as the best in SearchOutput() would not get played.     *
 *           very subtle timing issue dealing with the search timing out and   *
 *           forgetting to copy the best move back to the right data area.     *
 *           minor fixes to the modified -USE_ATTACK_FUNCTIONS option that     *
 *           was broken when the And()/Or()/ShiftX() macros were replaced by   *
 *           their direct bitwise operator replacements.                       *
 *                                                                             *
 *   16.18   adjustments to king tropism scoring terms (these attract pieces   *
 *           toward the opponent king in a coordinated way).  the scoring term *
 *           that kept the queen from going to the opposite side of the board  *
 *           was not working well which would also cause attacking problems.   *
 *           razoring code has been disabled, as it neither helps or hurts on  *
 *           tactical tests, and it creates a few hashing problems that are    *
 *           annoying.  bug in HashStorePV() that would store the PV into the  *
 *           hash table, but possibly in the wrong table entry, which could    *
 *           stuff a bad move in a hash entry, or overwrite a key entry that   *
 *           could have been useful later.  book random 0 was slightly wrong   *
 *           as it could not ignore book moves if the search said that the     *
 *           score was bad.  also the search would not time-out properly on a  *
 *           forced move, it would use the entire time alotted which was a big *
 *           waste of time when there was only one legal move to make. a very  *
 *           interesting bug was found in storing mate bounds in the hash      *
 *           table, one I had not heard of before.  I now store two MATE       *
 *           bounds, either > MATE-300, or < -MATE+300, which is conservative  *
 *           but safe.  Another change to Iterate() to make it avoid exiting   *
 *           as soon as a mate is found, so that it can find the shortest mate *
 *           possible.                                                         *
 *                                                                             *
 *   16.19   savepos now pads each rank to 8 characters so that programs that  *
 *           don't handle abbreviated FEN will be able to parse Crafty's FEN   *
 *           output without problems.  threads are no longer started and       *
 *           stopped before after searches that seem to not need multiple      *
 *           threads (such as when the starting position is in the databases   *
 *           or whatever) because in fast games, it can start and stop them    *
 *           after each search, due to puzzling for a ponder move, and this is *
 *           simply to inefficient to deal with, and burning the extra cpus is *
 *           only bad if the machine is used for other purposes.  and when the *
 *           machine is not dedicated to chess only, the SMP search is very    *
 *           poor anyway.  new lockless hashing (written by Tim Mann) added    *
 *           to improve SMP performance.  new eval term that handles various   *
 *           types of candidate passed pawns, most commonly the result of a    *
 *           position where one side has an offside majority that later turns  *
 *           into an outside passed pawn.  new EGTBPV() procedure added.  this *
 *           code will print the entire PV of a tablebase mating line.  if it  *
 *           given an option of ! (command is "egtb !") it will add a ! to any *
 *           move where there is only one optimal choice.  Crafty will now     *
 *           automatically display the EGTB PV if you give it a setboard FEN   *
 *           command, or if you just give it a raw FEN string (the setboard    *
 *           command is now optional except in test suites).  this version now *
 *           supports the 6 piece database files.  to include this support,    *
 *           you need to -DEGTB6 when compiling everything.  the majority code *
 *           has been temporarily removed so that this version can be released *
 *           to get the 6 piece ending stuff out.                              *
 *                                                                             *
 *   17.0    connected passed pawn scoring modified so that connected passers  *
 *           don't get any sort of bonus, except for those cases where the     *
 *           opponent has a rook or more.  this will avoid liking positions    *
 *           where crafty has two connected passers on the d/e files, and the  *
 *           opponent has passers on the b/g files.  the split passers win if  *
 *           all pieces are traded, while the connected passers are better     *
 *           when pieces are present.  a new scoring term evaluates the        *
 *           "split" passers similar to outside passers, this at the request   *
 *           (make that demand) of GM Roman Dzindzichashvili. Book() now finds *
 *           the most popular move as the move to ponder.  this eliminated all *
 *           'puzzling' searches which result in clearing the hash tables two  *
 *           times for every book move, which can slow it down when a large    *
 *           hash table is used.  new book option for playing against computer *
 *           opponents was written for this version.  Crafty now supports two  *
 *           "books.bin" type files, books.bin and bookc.bin (the bookc create *
 *           command can be used to make bookc.bin).  bookc will only be used  *
 *           when crafty is playing a computer.  this is supplied by xboard or *
 *           winboard when playing on a server, or can be included int the     *
 *           crafty.rc/.craftyrc file when playing directly.  bookc.bin will   *
 *           be used when playing a computer only, and should be used to avoid *
 *           unsound lines that are fine against humans, but not against other *
 *           computers.  if you don't use a bookc.bin, it will use the normal  *
 *           books.bin as always.  if you use both, it will only use bookc.bin *
 *           in games that have been started and then given the 'computer'     *
 *           command.  minor adjustment to EGTB probe code so that it will     *
 *           always probe TBs at ply=2 (if the right number of pieces are on   *
 *           the board) but won't probe beyond ply=2 unless the move at the    *
 *           previous ply was a capture/promotion and the total pieces drops   *
 *           into the proper range for TB probes.  this makes the 6 piece      *
 *           files far more efficient as before it would continuously probe    *
 *           after reaching 6 piece endings, even if it didn't have the right  *
 *           file.  Now after the capture that takes us to a 6 piece ending    *
 *           we probe one time...  and if there is no hit we don't probe at    *
 *           the next node (or any successors) unless there is another capture *
 *           or promotion that might take us to a database we have.  the book  *
 *           (binary) format has once again been modified, meaning that to use *
 *           16.20 and beyond the book.bin/books.bin files must be re-built    *
 *           from the raw PGN input.  this new format includes an entry for    *
 *           the CAP project score, so that deep searches can be used to guide *
 *           opening book lines.  a new weight (bookw CAP) controls how much   *
 *           this affects book move ordering/selection.  a new import command  *
 *           will take the raw CAPS data and merge it into the book.bin after  *
 *           the file has been built.  serious bug in SetBoard() would leave   *
 *           old EP status set in test suites.  this has been fixed.  outpost  *
 *           knight code was modified so that a knight in a hole is good, a    *
 *           knight in a hole supported by a pawn is better, supported by two  *
 *           pawns is still better, and if the opponent has no knights or a    *
 *           bishop that can attack this knight it is even better.  the out-   *
 *           post bonus for a bishop was removed.  a pretty serious parallel   *
 *           search bug surfaced.  in non-parallel searches, Crafty _always_   *
 *           completed the current ply=1 move after the time limit is reached, *
 *           just to be sure that this move isn't going to become a new best   *
 *           move.  however, when parallel searching, this was broken, and at  *
 *           the moment time runs out, the search would be stopped if the      *
 *           parallel split was done at the root of the tree, which means that *
 *           where the search would normally find a new best move, it would    *
 *           not.  this has been fixed.  new "store <val>" command can be used *
 *           to make "position learning" remember the current position and the *
 *           score (val) you supply.  this is useful in analyze mode to move   *
 *           into the game, then let crafty know that the current position is  *
 *           either lost or won (with a specific score).                       *
 *                                                                             *
 *   17.1    book structure fixed, since compilers can't quite agree on how    *
 *           structures ought to be aligned, for reasons not clear to me.  a   *
 *           serious eval bug that could produce gross scores when one side    *
 *           had two queens was fixed.                                         *
 *                                                                             *
 *   17.2    isolated pawn scoring tweaked a bit, plus a couple of bugs in the *
 *           way EvaluateDevelopment() was called were fixed.                  *
 *                                                                             *
 *   17.3    passed pawn scores increased somewhat to improve endgame play.    *
 *                                                                             *
 *   17.4    minor bug with "black" command (extra line from unknown origin)   *
 *           would make "black" command fail to do anything.  minor tweaks to  *
 *           passed pawn scoring again...  and a slight performance improve-   *
 *           ment in how EvaluateKingSafety() is called.  code for "bk"        *
 *           from xboard was somehow lost.  it now provides a book hint.       *
 *                                                                             *
 *   17.5    rewrite of outside passed pawn/pawn majority code.  it is now     *
 *           much faster by using pre-computed bitmaps to recognize the right  *
 *           patterns.                                                         *
 *                                                                             *
 *   17.6    minor fix in interupt.c, which screwed up handling some commands  *
 *           while pondering.  minor fix to score for weak back rank.  score   *
 *           was in units of 'defects' but should have been in units of        *
 *           "centipawns".   minor bug in "drawn.c" could mis-classify some    *
 *           positions as drawn when they were not.                            *
 *                                                                             *
 *   17.7    repair to DrawScore() logic to stop the occasional backward sign  *
 *           that could create some funny-looking scores (-20 and +20 for      *
 *           example).  minor fix to majority code to recognize the advantage  *
 *           of having a majority when the opponent has no passers or majority *
 *           even if the candidate in the majority is not an 'outside' passer  *
 *           candidate.  minor change to passed pawns so that a protected      *
 *           passed pawn is not considered a winning advantage if the          *
 *           opponent has two or more passed pawns.  but in input_status       *
 *           would cause an infinite loop if you reset a game to a position    *
 *           that was in book, after searching a position that was not in      *
 *           the book.  bug in position learning fixed also.  this was caused  *
 *           by the new hashing scheme Tim Mann introduced to avoid locking    *
 *           the hash table.  I completed the changes he suggested, but forgot *
 *           about how it might affect the position learning since it is also  *
 *           hash-based.  needless to say, I broke it quite nicely, thank you. *
 *                                                                             *
 *   17.8    this is the version used in the first ICC computer chess          *
 *           tournament.  Crafty won with a score of 7.0/8.0 which included    *
 *           only 2 draws and no losses.  changes are minimal except for a few *
 *           non-engine syntax changes to eliminate warnings and fix a bad bug *
 *           in 'bench.c' that would crash if there was no books.bin file.     *
 *                                                                             *
 *   17.9    LearnPosition() called with wrong arguments from main() which     *
 *           effectively disabled position learning.  this was broken in 17.7  *
 *           but is now fixed.                                                 *
 *                                                                             *
 *   17.10   minor change to "threat" extension now only extends if the null-  *
 *           move search returns "mated in 1" and not "mated in N".  this      *
 *           tends to shrink the trees a bit with no noticable effect in       *
 *           tactical strength.  EvaluatePawns() was not doing a reasonable    *
 *           job of recognizing blocked pawns and candidate passers.  it did   *
 *           not do well in recognizing that the pawn supporting a candidate   *
 *           could not advance far enough to help make a real passed pawn.     *
 *           minor change to RepetitionCheck() to not count two-fold repeats   *
 *           as draws in the first two plies, which prevents some odd-looking  *
 *           repeats at the expense of a little inefficiency.  Ugly repetition *
 *           bug fixed.  rephead was off by one for whatever side crafty was   *
 *           playing which would screw up repetition detection in some cases.  *
 *           minor bug in main() that would report stalemate on some mates     *
 *           when the ponder score was forgotten.                              *
 *                                                                             *
 *   17.11   Fail high/low logic changed to move the ++ output into Iterate()  *
 *           where the -- output was already located.  (This was done for      *
 *           consistecy only, it was not a problem.  New function to detect    *
 *           draws RepetitionCheckBook() was added to count two-fold repeats   *
 *           as draws while in book.  This lets Crafty search to see if it     *
 *           wants tht draw or not, rather than just repeating blindly.  Minor *
 *           bug in "go"/"move" command fixed.  The command did not work if    *
 *           the engine was pondering.  minor change to Evaluate() that makes  *
 *           BAD_TRADE code more acurate.  minor change to pawn majority code  *
 *           to fix two bugs.  white pawns on g2/h2 with black pawn on h7 was  *
 *           not seen as a majority (outside candidate passer) but moving the  *
 *           black pawn to g7 made it work fine.   Also if both sides had an   *
 *           equal number of pawns (black pawn at a7/b7, white pawns at b2/c2  *
 *           the code would not notice black had an outside passer candidate   *
 *           since pawns were 'equal' in number.                               *
 *                                                                             *
 *   17.12   BookUp() will now create a book with all sorts of games in it, so *
 *           long as the various games have the FEN string to properly set the *
 *           initial chess board position.                                     *
 *                                                                             *
 *   17.13   endgame evaluation problem fixed.  king scoring now dynamically   *
 *           chooses the right piece/square table depending on which side of   *
 *           the board has pawns, rather than using root pre-processing which  *
 *           could make some gross errors.  glitch with majorities would make  *
 *           an "inside majority candidate" offset a real outside passed pawn  *
 *           even if the candidate would not be outside.  a suggestion by      *
 *           Blass Uri (CCC) was added.  this adds .01 to tablebase scores if  *
 *           the side on move is ahead in material, and -.01 if the side on    *
 *           move is behind in material (only for drawn positions.)  the       *
 *           intent is to favor positions where you are ahead in material      *
 *           rather than even in material, which gives 'swindle mode' a chance *
 *           to work.  bug in EvaluateDraws() would mis-categorize some B+RP   *
 *           (wrong bishop) as drawn, even if the losing king could not make   *
 *           it to the corner square in time.                                  *
 *                                                                             *
 *   17.14   another endgame evaluation problem fixed.  the outside passed     *
 *           pawn code worked well, up until the point the pawn had to be      *
 *           given up to decoy the other side's king away from the remainder   *
 *           of the pawns.  Crafty now understands the king being closer to    *
 *           the pawns than the enemy king, and therefore transitions from     *
 *           outside passer to won king-pawn ending much cleaner.  new command *
 *           "selective" as requested by S. Lim, which allows the user to      *
 *           set the min/max null move R values (default=2/3).  they can be    *
 *           set to 0 which disables null-move totally, or they can be set     *
 *           larger than the default for testing.  minor changes to init.c     *
 *           sent by Eugene Nalimov to handle 64 bit pointer declarations for  *
 *           win64 executable compilation.  NetBSD changes included along with *
 *           a new Makefile that requires no editing to use for any known      *
 *           configuration ("make help" will explain how to use it).  this was *
 *           submitted by Johnny Lam.  serious changes to the outside passed   *
 *           pawn code.  the evaluator now understands that outside passers    *
 *           on _both_ sides of the board is basically winning.  same goes for *
 *           candidate passers.                                                *
 *                                                                             *
 *   18.0    bug in EvaluateDraws() could incorrectly decide that if one side  *
 *           had only rook pawns in a king/pawn ending, the ending was a draw. *
 *           even if the other side had pawns all over the board.  passed pawn *
 *           scores increased a bit.  minor change to "bad trade" code to turn *
 *           off in endings.  S list removed.  the trojan horse check is now   *
 *           automatically enabled when the key position is recognized at the  *
 *           root of the tree.  it is disabled once the key position is no     *
 *           longer seen at the root.  bug in BookUp() would break if a FEN    *
 *           string was included in a game used for input.  SetBoard() was     *
 *           setting castling status incorrectly.  internal iterative          *
 *           deepening bug could (on very rare occasions) cause crafty to try  *
 *           to search an illegal move that would bomb the search.  this       *
 *           version fully supports the new xboard protocol version 2.  one    *
 *           other major change is that the eval is now consistently displayed *
 *           as +=good for white, -=good for black.  in the log file.  In the  *
 *           console output window.  and when whispering/kibitzing on a chess  *
 *           server.  this should eliminate _all_ confusion about the values   *
 *           that are displayed as there are now no exceptions to the above    *
 *           policy of any kind.  Book() was changed so that if it notices     *
 *           that the opponent has a "stonewall pattern" set up (IE crafty     *
 *           is black, has a pawn at e7 or e6, and the opponent has pawns at   *
 *           d4/f4) then it won't play a castle move from book.  It will do a  *
 *           normal search instead and let the evaluation guide it on whether  *
 *           to castle or not (generally it won't unless it is forced).        *
 *                                                                             *
 *   18.1    easy move code broken, so that no move ever appeared to be "easy" *
 *           even if it was the only possible recapture move to make.  a minor *
 *           problem in analysis mode dealing with pawn promotions was fixed.  *
 *           it was possible for a move like h8=Q to be rejected even though   *
 *           it was perfectly legal.                                           *
 *                                                                             *
 *   18.2    minor bug in analyze mode would break the "h" command when black  *
 *           was on move, and show one less move for either side that had      *
 *           actually been played in the game.  another bug also reversed the  *
 *           sign of a score whispered in analysis mode.  recapture extension  *
 *           is disabled by default.  to turn it on, it is necessary to use    *
 *           -DRECAPTURE when compiling search.c and option.c.  LearnBook()    *
 *           has been modified to 'speed up' learning.  see the comments in    *
 *           that module to see how it was changed.  LearnResult() has been    *
 *           removed.  LearnBook() is now used to do the same thing, except    *
 *           that a good (or bad) score is used.                               *
 *                                                                             *
 *   18.3    minor bug in "avoid_null_move" test used R=2 for the test rather  *
 *           than testing R=2/3 as the real null-move search uses.  the kibitz *
 *           for "Hello from Crafty Vx.xx" has been moved so that it works     *
 *           with the new xboard/winboard 4.2.2 versions.  book learning was   *
 *           badly broken in the previous version and has been fixed/tested.   *
 *                                                                             *
 *   18.4    recapture extension was left in SearchSMP() erroneously.  this    *
 *           has now been protected by a #ifdef just like it was in Search().  *
 *           bug in RepetitionCheck() was causing problems in SMP versions.    *
 *           The entire repetition list code was modified to clean this up.    *
 *           the problem was most noticable on things like fine #70.  bug in   *
 *           LearnImportBook() confused the learn value sign, due to the other *
 *           changes to make +=white all the time.  opposite bishop scoring    *
 *           has been beefed up a bit to avoid these drawish endings.          *
 *                                                                             *
 *   18.5    minor change to RootMove() to use Quiesce() rather than the more  *
 *           complicated way it was ordering with Evaluate()/EnPrise().  this  *
 *           is no faster, but it is simpler and eliminated the need for the   *
 *           EnPrise() function totally, making the code a bit smaller.  bug   *
 *           in EvaluateDraws() would let it think that the bishop+wrong rook  *
 *           pawn endings were winnable if both kings were very close to the   *
 *           queening square, even with the wrong bishop.                      *
 *                                                                             *
 *   18.6    "new" no longer produces a new log.nnn/game.nnn file if no moves  *
 *           have actually been played.  minor change to rook scoring gives a  *
 *           penalty when a rook has no horizontal (rank) mobility, to avoid   *
 *           moves like Ra2 protecting the pawn on b2, etc. glitch in the      *
 *           code that initializes is_outside[][] and is_outside_c[][] could   *
 *           cause missed outside pawn cases to happen.  this has been there   *
 *           a long time.                                                      *
 *                                                                             *
 *   18.7    BOOK_CLUSTER_SIZE increased to 2000 to handle making really large *
 *           books.  a book made without this change could produce clusters    *
 *           that would cause memory overwrites.                               *
 *                                                                             *
 *   18.8    recapture extension turned back on for a while.  changes to the   *
 *           evaluation code, particularly EvaluatePawns() to make it more     *
 *           efficient and accurate.  IE it was possible for an isolated pawn  *
 *           to be penalized for being isolated, weak, and blocked, which made *
 *           little sense.                                                     *
 *                                                                             *
 *   18.9    Book() modified to increase the responsiveness of book learning.  *
 *           the new code, plus the default weights for the book parameters    *
 *           now make Crafty learn very aggressively and repeat good opening   *
 *           lines and avoid bad ones.                                         *
 *                                                                             *
 *   18.10   minor bug in book.c would let crafty play lines that were very    *
 *           rarely played even though there were others that had been played  *
 *           far more times and were more reliable.  king safety scores ramped *
 *           up a bit and made more "responsive".                              *
 *                                                                             *
 *   18.11   minor bug in EvaluateDevelopment() found by Bruce Moreland.  the  *
 *           pawn ram code is now disabled when playing a computer, although   *
 *           the normal 'blocked pawn' code is always active.  bug in the code *
 *           that penalizes a rook with no horizontal mobility was fixed.  if  *
 *           the first rook scored had horizontal mobility, the second rook    *
 *           appeared to have this mobility as well, which was wrong.  pawn    *
 *           hash statistics were wrong on longer searches due to an int       *
 *           overflow on a multiply and divide calculation.  this has been     *
 *           re-ordered to avoid the overflow.  for unknown reasons, epd       *
 *           support was disabled.  it is now enabled as it should be.  some   *
 *           strange adjustements to root_alpha/root_beta were removed from    *
 *           searchr.c.  they were probably left-over from some sort of test.  *
 *                                                                             *
 *   18.12   bug in EvaluateDraws() fixed to not call KBB vs KN a draw if the  *
 *           correct tablebase is not available.  bishop pair scores now vary  *
 *           depending on how many pawns are left on the board.  a pair is not *
 *           worth a lot if there are 7-8 pawns left as most diagonals will be *
 *           blocked by pawns.  Test() modified so that it will now run using  *
 *           an EPD test suite with am/bm and id tags.  the old testfile for-  *
 *           mat will continue to work for a while, but Test() now notices the *
 *           EPD format and processes it correctly.  a new way of handling the *
 *           search extensions is in place.  with the old approach, one ply    *
 *           could not extend more than one full ply.  with the new approach,  *
 *           borrowed from Deep Blue, two consecutive plies can not extend     *
 *           more than two plies total.  It averages out to be the same, of    *
 *           course, but the effect is a bit different.  Now it is possible    *
 *           for a check and recapture to be applied at the same ply, where    *
 *           they could not before (since a check was already a full one-ply   *
 *           extension).  whether this is better or not is not clear yet, but  *
 *           it is worth careful analysis.  EvaluateDraws() has been replaced  *
 *           by EvaluateWinner().  This function returns an indicator that     *
 *           specifices whether white, black, both or neither can win in the   *
 *           present position.                                                 *
 *                                                                             *
 *   18.13   Deep Blue extension limit removed and restored to one ply of      *
 *           extension per ply of search.  pruning in q-search fixed so that   *
 *           a capture will be considered if it takes the total material on    *
 *           the board down to a bishop or less for the opponent, as that can  *
 *           greatly influence the evaluation with the EvaluateWinner() code.  *
 *           as the 50 move rule draws near, the hash table scores are marked  *
 *           as invalid every 5 moves so that hashing can't hide potential     *
 *           50-move-rule draws.  lazy evaluation code modified to be more     *
 *           conservative, since in endgames the positional score can be a     *
 *           large change.  EvaluatePassedPawnRaces() fixed so that if one     *
 *           side has two pawns that are far enough apart, it will recognize   *
 *           that even though the king is "in the square" of either, it can't  *
 *           always stay in the square of one if it has to capture the other.  *
 *           pawn hash signature restored to 64 bits after testing proved that *
 *           32 was producing an unacceptable number of collisions.  search    *
 *           node counter is now 64 bits as well to avoid overflows.  bug in   *
 *           the outside passed pawn code fixed (bad mask).                    *
 *                                                                             *
 *   18.14   Minor bug in ResignOrDraw() code caused Crafty to not offer draws *
 *           although it would accept them when appropriate.  Rook vs Minor    *
 *           is now evaluated as "neither side can win" an oversight in the    *
 *           EvaluateWinner() code.  minor bug in ResignOrDraw() would fail to *
 *           offer draws due to the +0.01/-0.01 draw scores returned by the    *
 *           EGTB probe code.                                                  *
 *                                                                             *
 *   18.15   change in endgame draw recognition to handle the case where one   *
 *           side appears to be in a lost ending but is stalemated.  the code  *
 *           now evaluates such positions as "DrawScore()" instead.  the code  *
 *           to accept/decline draws has been modified.  when a draw offer is  *
 *           received, a global variable "draw_offer_pending" is set to 1.     *
 *           when the search for a move for crafty terminates, crafty then     *
 *           uses this value to decide whether to accept or decline the draw.  *
 *           this means that the accept/decline won't happen until _after_ the *
 *           search has a chance to see if something good is happening that    *
 *           should cause the draw to be declined, closing a timing hole that  *
 *           used to exist that let a few "suspects" get away with draws that  *
 *           should not have happened (ie crafty has - scores for a long time, *
 *           the opponent suddenly fails low and sees he is losing and offers  *
 *           a draw quickly.  Crafty would accept before doing a search and    *
 *           noticing that it was suddenly winning.)  minor evaluation change  *
 *           to notice that K+B+right RP vs K+B is not necessarily won if the  *
 *           weaker side has a bishop of the right color.                      *
 *                                                                             *
 *   19.0    significant change to the search extension limits.  first, the    *
 *           limit of no more than 1 ply of extensions per ply has been tossed *
 *           out.  now, any number of extensions are allowed in the first N    *
 *           plies, where N=iteration_depth of the current iteration.  After   *
 *           the first N plies, extensions are reduced by 50% for the next N   *
 *           plies.  They are then reduced by another 50% for the next N plies *
 *           and then completely disabled after that.  IE for a 12 ply search, *
 *           all extensions (even > one ply) are allowed for the first 12      *
 *           plies, then the extensions are reduced by 1/2 for the next 12     *
 *           plies, then by 1/4 for the next 12 plies, then turned off from    *
 *           that point forward.  minor tweak (suggested by GCP) to reduce the *
 *           time limit by 1/4 for ponder=off games was done in time.c.  fix   *
 *           to EvaluateWinner() to correctly realize that KR[BN] vs KRR is a  *
 *           draw for the KRR side if it doesn't have at least a pawn left.    *
 *           minor bug in RejectBookMove() would reject all moves if the op-   *
 *           ponent had a stonewall-type pawn set-up.  it was supposed to only *
 *           reject castling into the attack.  minor change to code in the     *
 *           EvaluateMaterial() function to lower the penalty for sacrificing  *
 *           the exchange.  it was considered just as bad as trading a rook    *
 *           for two pawns which was wrong.  change to hashing code so that we *
 *           can now determine that a hash entry came from the EGTB so that    *
 *           PVs are displayed with <EGTB> when appropriate, not <EGTB> if it  *
 *           originally came from the EGTB but later <HT> when it was picked   *
 *           up from the hash table instead.  minor changes to search/searchmp *
 *           to make them identical in "look" where possible, for consistency  *
 *           in source reading if nothing else.  if the first argument on the  *
 *           command-line is "xboard" or if the environment variable           *
 *           "CRAFTY_XBOARD" is set, crafty sends a "feature done=0" command   *
 *           to tell xboard it has not yet initialized things.  significant    *
 *           changes to EvaluateWinner() to recognize new cases of draws such  *
 *           as Q+minor+nopawns vs Q+pawns as unwinnable by the Q+minor side.  *
 *           other cases were fixed/improved as well.                          *
 *                                                                             *
 *   19.1    changes to the outside passed pawn and outside candidate pawn     *
 *           code to more correctly recognize when one side has a simple end-  *
 *           game position that is easy to win.  futility pruning and razoring *
 *           (Jeremiah Penery) was added.  to endable it, you will need to add *
 *           -DFUTILITY to the Makefile options, otherwise it is disabled by   *
 *           default.  EvaluateWinner() had a bug dealing with KR vs KN or     *
 *           KRR vs KRN(B) that has been fixed.                                *
 *                                                                             *
 *   19.2    CCT-5 version 01/20/03.                                           *
 *           changes to the LimitExtensions() macro.  the extensions are now   *
 *           a bit more aggressive, but after 2*iteration_depth, then they     *
 *           taper off smoothly so that by the time the depth reaches          *
 *           4*iteration_depth, the extensions are cut to zero.  fixed bug in  *
 *           EvaluatePawns() that missed candidate passed pawns so that the    *
 *           new endgame stuff didn't work completely.  change to hash.c to    *
 *           combine the two hash tables into one so that the two probed       *
 *           entries are adjacent in memory to be more cache friendly.  A bug  *
 *           in moving a replaced entry from depth-preferred to always-store   *
 *           caused the moved entry to go to the wrong address which would     *
 *           make it impossible to match later.  new hash table layout is more *
 *           cache-friendly by putting one entry from depth-preferred table    *
 *           with two entries from always-store, so that they often end up in  *
 *           the same cache-line.                                              *
 *                                                                             *
 *   19.3    change to EvaluateMaterial to realize that a rook for five pawns  *
 *           is also likely a "bad trade."  adaptive hash table size code was  *
 *           added so that the hash size is set automatically based on the     *
 *           estimated NPS and time per move values for a specific "level"     *
 *           command setting.   RepetitionCheck() rewritten.  the old code had *
 *           an unexplained bug that would overlook repetitions in a parallel  *
 *           search in rare cases.  the old cold was complex enough that it    *
 *           was time to rewrite it and simplify it significantly.             *
 *                                                                             *
 *   19.4    initial depth "seed" value changed to iteration_depth + 1/2 ply,  *
 *           so that fractional extensions kick in earlier rather than deeper  *
 *           in the search.  this performs _much_ better in tactical tests     *
 *           such as WAC and similar suites.  minor book fix for a bug that    *
 *           could cause a crash with book=off in xboard/winboard.             *
 *                                                                             *
 *   19.5    default draw score set to 1, because endgame table draws can be   *
 *           0, -.01 or +.01, which translates to -1, 0 or 1 in real scores    *
 *           inside Crafty.  +1 means a draw where white has extra material    *
 *           and that would break accepting draws with such a score.  a few    *
 *           NUMA-related changes.  one global variable was made thread-       *
 *           private to avoid cache thrashing.  split blocks are now allocated *
 *           by each individual processor to make them local to the specific   *
 *           processor so that access is much faster.  CopyToSMP() now tries   *
 *           to allocate a block for a thread based on the thread's ID so that *
 *           the split block will be in that thread's local memory.  a few     *
 *           other NUMA-related changes to help scaling on NUMA machines.      *
 *                                                                             *
 *   19.6    new egtb.cpp module that cuts decompression indices memory by 50% *
 *           with no harmful side-effects.  fixes to NUMA code to make SMP and *
 *           non-SMP windows compiles go cleanly.                              *
 *                                                                             *
 *   19.7    changes to draw code so that Crafty will first claim a draw and   *
 *           then play the move, to avoid any confusion in whether the draw    *
 *           was made according to FIDE rules or not.  minor bug in evaluate() *
 *           dealing with candidate passed pawns fixed.  A few additions to    *
 *           support my AMD Opteron inline assembly for MSB(), LSB()  *
 *           and PopCnt() procedures.                                          *
 *                                                                             *
 *   19.8    changes to lock.h to (a) eliminate NT/alpha, since Microsoft no   *
 *           longer supports the alpha, which makes lock.h much more readable. *
 *           CLONE is no longer an option either, further simplyfying the .h   *
 *           files.  new mode option "match" which sets an aggressive learning *
 *           mode, which is now the default.  the old learning mode can be set *
 *           by using the command "mode normal".  memory leak in new windows   *
 *           NUMA code fixed by Eugene Nalimov.  AMD fix to make the history   *
 *           counts thread-local rather than global (to avoid excessive cache  *
 *           invalidate traffic).                                              *
 *                                                                             *
 *   19.9    two new pieces of code submitted by Alexander Wagner.  the first  *
 *           adds speech to crafty for unix users.  /opt/chess/sounds needs to *
 *           exist and the common/sounds.tar.gz file needs to be untarred in   *
 *           directory.  "speech on*off" controls it.  a new annotatet command *
 *           outputs the annotated file in LaTeX format for those that prefer  *
 *           that platform.  lots of source reformatting to make indenting and *
 *           other things more consistent, using the unix "indent" utility.    *
 *           singular extension (simplistic approach) has been added and needs *
 *           -DSINGULAR to activate it.  once it has been compiled in, you can *
 *           turn it on/off by setting the singular extension depth using the  *
 *           ext command.  default is on if you compile it in.  ext/sing=0     *
 *           disable it.  changes to non-COMPACT_ATTACKS code to shrink the    *
 *           array sizes.  this was done primarily for the Opteron where the   *
 *           COMPACT_ATTACKS stuff was a bit slower than the direct look-up    *
 *           approach.  this change reduced the table sizes by 75%.  a small   *
 *           change to Evaluate() to better handle the 50-move draw problem.   *
 *           what used to happen was when the counter hit 100 (100 plies since *
 *           last capture or pawn push) the score just dumped to DrawScore()   *
 *           instantly.  it was possible that by the time the draw was seen,   *
 *           it was too late to do anything to avoid it without wrecking the   *
 *           position.  What happens now is that once the 50-move counter      *
 *           reaches 80 plies (40 moves by both sides with no pawn push or     *
 *           capture) the score starts dropping toward DrawScore() no matter   *
 *           which side is winning.  Dave Slate called this a "weariness       *
 *           factor" in that after playing 40 moves with no progress, the      *
 *           evaluation shows that the program is getting "weary".  the idea   *
 *           is that the score starts to slip over the last 10 moves by each   *
 *           side to that if either can do something to reset the counter,     *
 *           they will do it sooner rather than later.                         *
 *                                                                             *
 *   19.10   a fix to the EvaluateWinner() code to recognize that while KRB vs *
 *           KR can not normally be won by the KRB side, we require that the   *
 *           KR side not be trapped on the edge of the board, where it can be  *
 *           mated.  FUTILITY code put back in.  19.9 will be the SE version   *
 *           for those wanting to play with it.  new "learn" command option to *
 *           allow the user to set the position learning parameters that are   *
 *           used to trigger position learning and disable position learning   *
 *           after the game is already lost.  the command syntax is as follows *
 *           "learn trigger cutoff" and are expressed as fractions of a pawn   *
 *           with a decimel point.  the default is learn .33 -2.0 which says   *
 *           to do position learning when the score drops 1/3 of a pawn, but   *
 *           turn it off after the score reaches -2.00 as the game is already  *
 *           lost and learning won't help at this point.  this is the CCT-6    *
 *           version exactly as played in the CCT-6 tournament.                *
 *                                                                             *
 *   19.11   a fix to the Annotate() code that could, in certain cases, fail   *
 *           to display N moves when asked.  this happened when there were     *
 *           fewer than N moves total, and on occasion it would not display    *
 *           all the moves that were possible, omitting the last one.  fix to  *
 *           egtb.cpp to correctly set 16 bit index mode for a few of the      *
 *           recent 6-piece tables.                                            *
 *                                                                             *
 *   19.12   fix to allocating split blocks that did not let all blocks get    *
 *           used, which would produce slow-downs on large parallel boxes      *
 *           (cpus > 8-16).  change to fail-high/fail-low window adjustment.   *
 *           I now use the old Cray Blitz approach ("Using time wisely -       *
 *           revisited", JICCA) where a fail-high (or low) now adjusts the     *
 *           root alpha or beta bound by 1 pawn on the first fail, another two *
 *           pawns on the second failure, and finally relaxes the bound to     *
 *           +/- infinity on the third fail for the same move.  this speeds up *
 *           searching many fail-high/fail-low conditions, although it will    *
 *           occasionally cause the search to take a bit longer.               *
 *                                                                             *
 *   19.13   fix to evaluating split passed pawns.  code is cleaner and is not *
 *           applied if the opposing side has any pieces at all since a piece  *
 *           and the king can stop both.  new egtb.cpp that opens the tables   *
 *           approximately 20-25% faster is included in this version (code by  *
 *           Eugene Nalimov of course).                                        *
 *                                                                             *
 *   19.14   new "eval" command (eval list and eval help to start) allow a     *
 *           user to modify all internal evaluation values via commands that   *
 *           may be entered directly or via the .craftyrc/crafty.rc init file. *
 *           this was mainly done for the automated evaluation tuning project  *
 *           I am working on with Anthony Cozzie, but it will be useful for    *
 *           merging Mike Byrne's "personality" stuff as well.  new command    *
 *           "personality load/save <filename>" which saves eval and search    *
 *           parameters to create new personalities that can be loaded at any  *
 *           time.  "crafty.cpf" is the "default" personality file that is     *
 *           used at start-up if it exists.  evaluation tuning changes based   *
 *           on some results from the new annealing code, although all of the  *
 *           annealed values are not yet fully understood nor utilized yet.    *
 *           LearnBook() is now used to learn good and bad game results.  IE   *
 *           if crafty wins with a particular opening, it will remember it as  *
 *           good and try it again, in addition to the previous method that    *
 *           would remember bad openings and avoid them.  it also now handles  *
 *           draws as well which can make slightly bad openings appear better. *
 *           minor change to SMP code to eliminate the possibility of a shared *
 *           variable getting overwritten unintentionally.  several changes to *
 *           evaluation weights and evaluation code as testing for the WCCC    *
 *           continues.  new "help" command uses a file "crafty.hlp" which now *
 *           contains all the help information.  this makes the help info      *
 *           easier to maintain and gets rid of a bunch of printf()s in the    *
 *           Option() source (option.c).  rewrite of the "list" code.  Crafty  *
 *           now supports six lists, AK (auto-kibitz), B (blocker), C (comp),  *
 *           GM, IM and SP (special player).  The SP list has two extra items  *
 *           that can be specified to go with a player's name, namely a book   *
 *           filename (to replace the normal books.bin, but not book.bin) and  *
 *           a personality file that will be loaded each time this particular  *
 *           named opponent plays.  the format is available in the new help    *
 *           facility.  bug fix for outside passed pawn code that would cause  *
 *           an outside passer to appear to be a winning advantage even if the *
 *           opponent has a protected passer, which easily negates the outside *
 *           passer's threat.                                                  *
 *                                                                             *
 *   19.15   fix to outside passed pawn code that requires pawns on both sides *
 *           of the board for the side with an "outside passer" or "outside    *
 *           candidate" to avoid some bizarre evaluations. sel 0/0 now works   *
 *           without crashing Crafty.  this would fail in previous versions as *
 *           the hash signature would be modified but not restored.  slightly  *
 *           more conservative limit on using null-move search to head off a   *
 *           few notable zugzwang problems was added.  fix to time control     *
 *           code to remove a hole that could cause a divide-by-zero at a time *
 *           control boundary.  Stonewall detection removed completely as it   *
 *           appears to be no longer needed.  rook scoring changed to better   *
 *           evaluate "open files" by measuring mobility on them.  complete    *
 *           removal of Phase() (phase.c) and references to the opening,       *
 *           middlegame and endgame phases as they were no longer referenced   *
 *           anywhere in the code.                                             *
 *                                                                             *
 *   19.16   fix to "Trojan code" to eliminate the time limit exclusion since  *
 *           many users still have old and slow hardware, and the time limit   *
 *           was not set correctly when PreEvaluate() was called anyway.  the  *
 *           code to display fail-high/fail-low information was cleaned up so  *
 *           that the +1 or +3 now makes sense from the black side where the   *
 *           score is really going down (good for black) rather than showing   *
 *           a +3 fail high (when Crafty is black) and the score is really     *
 *           going to drop (get better for black).  Now the fail-high-fail-low *
 *           +/- sign is also relative to +=good for white like the scores     *
 *           have been for years.  adjustments to pawn evaluation terms to     *
 *           improve the scoring balance.  "new" now terminates parallel       *
 *           threads (they will be re-started when needed) so that we don't    *
 *           burn CPU time when not actually playing a game.                   *
 *                                                                             *
 *   19.17   changes to pawn evaluation to limit positional scores that could  *
 *           get a bit out of sane boundaries in some positions.               *
 *                                                                             *
 *   19.18   HashProbe() no longer adjusts alpha/beta bounds if the entry is   *
 *           not good enough to terminate the search here.  this has helped    *
 *           speed things up (reduced size of tree) over many test positions   *
 *           so either it was buggy or not worthwhile.  regardless, it is now  *
 *           'gone'.  connected passed pawns now scored as a simple pair of    *
 *           pawns that are better as they are advanced, the old connected     *
 *           passed pawns on the 6th rank special code has been removed.       *
 *                                                                             *
 *   19.19   RepetitionDraw() had a bug that would cause it to miss a draw     *
 *           claim on the 50th move, often making a strange (losing) move that *
 *           would not lose if the draw is was claimed, but which would cause  *
 *           a loss if the draw was not claimed because the piece might be     *
 *           instantly captured if the opponent can play a move.               *
 *                                                                             *
 *   19.20   bug in the EvaluateMaterial() (bad trade) code that would not     *
 *           penalize a single piece vs 3 pawns properly.  now the penalty is  *
 *           added in unless the side with the piece has nothing else to go    *
 *           with it at all (no pawns or other pieces).  pawn scoring changed, *
 *           doubled pawns were scored too badly because the penalties were    *
 *           added twice (as expected) but they were set as if they were just  *
 *           added once.  eval command also had a bug in displaying the pawn   *
 *           evaluation parameters.  move input changed to accept pawn         *
 *           promotions of the form a8Q (this is needed as ChessBase violates  *
 *           the PGN/SAN standard that mandates a8=Q as the proper syntax for  *
 *           pawn promotions.)  annoying glitch in epdglue.c that would        *
 *           produce the wrong score for positions with exactly one legal move *
 *           was fixed.  New InvalidPosition() function verifies that FEN      *
 *           setup positions are reasonable, without extra pawns or too many   *
 *           pieces total, etc.  passed pawn to 7th search extension removed,  *
 *           mate threat extension tuned down to 1/2 ply.  bug in SetBoard()   *
 *           fixed.  this bug made it impossible to import many epd records    *
 *           due to incorrectly handling the wtm flag.  this was introduced in *
 *           the recent changes to disallow certain types of illegal positions *
 *           that were impossible (more than 9 queens of one color, etc.) new  *
 *           eval term for space added.  this simply counts the number of      *
 *           squares on each rank attacked by pawns, and then multiplies by a  *
 *           constant that scales the attacks so that attacking ranks on the   *
 *           opponent's side of the board is more valuable than attacking      *
 *           squares on our side of the board and vice-versa.  significant     *
 *           coding changes for the unix parallel search.  POSIX threads are   *
 *           gone, due to too many differences between vendor's implementation *
 *           details.  Crafty now uses SYSV shared memory to share the search  *
 *           data (this is exactly the same parallel search approach always    *
 *           used, but with a completely different implementation) and fork()  *
 *           to spawn processes for each CPU.  it simply became too much work  *
 *           to figure out what each vendor was doing about CPU time, how      *
 *           threads were scheduled, plus debug thread library implementations *
 *           that were often buggy.  there are no performance benefits to this *
 *           approach other than falling back to features found in all Unix    *
 *           implementations.  new NUMA changes to make sure that the local    *
 *           thread "blocks" are actually allocated on the NUMA node where     *
 *           the process actually runs, rather than on a remote node that      *
 *           will cause extra memory latency for often-used memory data.  bug  *
 *           in EvaluatePawns() caused the outside passer / outside            *
 *           candidate bonus to be triggered when the opponent has a simple    *
 *           protected passed pawn.  since the decoy value is nil with a       *
 *           protected passer (we can't take the supporing pawn or the passer  *
 *           will run) the outside candidate or passer doesn't help.  bug in   *
 *           king safety caused pieces to be attracted to the opponent's king, *
 *           even in simple endgames, inflating/deflating the score for a      *
 *           feature that was pointless.  (2005 WCCC final version).           *
 *                                                                             *
 *   20.0    first in a new series.  first change is to produce an endian-     *
 *           independent opening book.  the format has not changed so that old *
 *           book.bin/books.bin files will work fine, but they may now be      *
 *           freely between big-endian and little-endian architectures.  this  *
 *           makes the binary format compatible between a PC and a Sun or HP   *
 *           box, for example, so that just one book.bin file is needed.       *
 *                                                                             *
 *   20.1    first step toward a complete redesign of the evaluation code in   *
 *           Evaluate() (evaluate.c).  this first set of changes are mainly    *
 *           restructuring related, an attempt to collect the various bits of  *
 *           evaluation code that are related to a common theme (i.e. all      *
 *           bishop scoring, all passed pawn scoring, etc) are not contained   *
 *           in one routine, with a sensible name.  this makes it much easier  *
 *           to find evaluation code and modify it, without having bits and    *
 *           pieces scattered all over the place.  perhaps the most signifi-   *
 *           cant is that the current evaluation has dropped the asymmetric    *
 *           king safety, and later the asymmetric blocked pawn code will go   *
 *           as well.  to do this, I did have to make some changes in terms    *
 *           of the "tropism" code.  the basic idea is that white's "tropism"  *
 *           bonus in incremented for each white piece that attacks the black  *
 *           king, but it is also decrement for each black piece that attacks  *
 *           the black king, so that a defender offsets an attacker.  this has *
 *           certainly changed the "personality" of how it plays.  it is now   *
 *           far more aggressive, and further changes planned for the future   *
 *           will hopefully improve on this change.  it is playing quite a bit *
 *           better, but whether this aggressiveness is "over the top" remains *
 *           to be seen.  fix to "won kp ending" logic.  if one king is closer *
 *           to the opponent's "average pawn square" than the other, by at     *
 *           least 2 moves, then that side is credited as having a won k+p     *
 *           ending. new code for time allocation testing added.  a new        *
 *           "timebook <factor> <moves>" command that says use "factor" extra  *
 *           time (factor is expressed as a percent, 100 means use 100% extra  *
 *           time) tapered off for "moves" out of book.  for example,          *
 *           "timebook 100 10" says use 100% extra time on first non-book move *
 *           followed by 90% extra on the next move, 80% on the next, until    *
 *           after 10 moves we are back to the normal time average.            *
 *                                                                             *
 *   20.2    significant evaluation changes to try to limit positional scores  *
 *           so that new tuning can be accomplished.  in particular, the king  *
 *           safety code has been greatly simplified, now having two separate  *
 *           components, one for pawn structure, one for piece tropism.  a new *
 *           SearchControl() procedure now handles all the search extensions   *
 *           in one centralized place, shared by normal and parallel search    *
 *           code.  the plan is that eventually this piece of code will also   *
 *           be able to recommend search reductions as well as extensions to   *
 *           speed the tree traversal process significantly with a form of     *
 *           of forward pruning that is commonly called "search reductions".   *
 *                                                                             *
 *   20.3    search reduction code added.  part of this dates back to 1997     *
 *           when Bruce Moreland and I played with the idea of reducing the    *
 *           depth on the last part of the move list when it seemed to become  *
 *           fairly certain that no fail-high was going to happen.  that was a *
 *           big search speed improvement, but also risky.  recently, several  *
 *           started to do this again, except they added one fairly useful     *
 *           constraint, that the "history value" for a specific move has to   *
 *           be below some threshold before a reduction can happen.  the idea  *
 *           is that we don't want to reduce the depth of moves that have      *
 *           failed high in the past, because they might fail high again if    *
 *           they are not reduced too much.  Tord Romstad suggested an         *
 *           additional improvement, namely that if a reduced move does fail   *
 *           high, re-search with the proper (non-reduced) depth to verify     *
 *           that it will fail high there as well.  all of this is included    *
 *           in version 20.3, but the values (reduction amount, history        *
 *           threshold, min depth to do a reduction) need serious testing and  *
 *           tuning.  the current values are simply "legal" but hardly could   *
 *           be considered optimal without substantial testing.  new code to   *
 *           "age" history counters added.  after each iteration, this code    *
 *           divides each counter by 2, to scale the values back, so that      *
 *           moves that are no longer causing fail highs will have a history   *
 *           value that won't prevent reduction pruning.  the "minimum depth"  *
 *           value indicates how much search to leave after doing a reduction  *
 *           in the tree.  A value of 1 ply guarantees that after a reduction  *
 *           is done, there will always be one full-width ply of search done   *
 *           after such reductions to avoid gross tactical oversights.  tuning *
 *           to extensions to reduce the tree size.  the recapture extension   *
 *           has been completely removed, while the check extension has been   *
 *           left at 1.0 as in the past.  the mate threat and one-legal-reply  *
 *           extensions are now both set to .75 after extensive testing.  this *
 *           is the CCT8 version of crafty.                                    *
 *                                                                             *
 *   20.4    history counters changed.  there is now one large history[8192]   *
 *           array to simplify indexing.  more importantly, these values are   *
 *           now limited to a max value of 32000.  during the update process,  *
 *           if any value reaches that limit, all values are divided by 2 to   *
 *           prevent deep searches from producing very large history values    *
 *           which would essentially disable late move reductions based on the *
 *           big history values.  the reduce/history=n command now uses values *
 *           0 <= n <= 100.  a value of 100 will cause all non-tactical moves  *
 *           to be reduced (most aggressive) while a value of 0 will result in *
 *           no moves being reduced (most conservative).  the value, loosely   *
 *           interpreted, means "reduce if a move fails high < n% of the time  *
 *           when at least one move fails high in a search."  the default is   *
 *           currently 50%, but further testing is needed.                     *
 *                                                                             *
 *   20.5    old "mask" code removed and replaced by constants, since this is  *
 *           never intended to run on a Cray specifically any longer.  change  *
 *           to "won king and pawn ending" to make it more accurate, this code *
 *           is used when there are nothing but pawns left, all on one side of *
 *           board, and one king is closer to a capturable pawn than the other *
 *           king is.  this is intended to help in outside passed pawn games   *
 *           where one side has to eventually give up the outside passer to    *
 *           decoy the opposing king away from the rest of the pawns.  new     *
 *           king safety now factors in king pawn shelter and opponent piece   *
 *           tropism into one score, but the score is now an arithmetic        *
 *           value that goes up more quickly as both indices increase, to do a *
 *           more accurate evaluation of safety and attacking chances.  change *
 *           to bishop mobility, which now goes in units of 2 rather than 1,   *
 *           to increase the value of mobility somewhat.  also mobility is now *
 *           'centered' in that it is computed as (squares - 6) * 2, to keep   *
 *           the bishop value from going way over its normal range with these  *
 *           new and somewhat larger numbers.                                  *
 *                                                                             *
 *   20.6    new eval code to look for bishops that are blocked in the forward *
 *           direction by friendly pawns.  that basically turns a bishop into  *
 *           a "tall pawn" since movement in the critical direction is not     *
 *           possible.                                                         *
 *                                                                             *
 *   20.7    manually tuned kinf_safety[][] array values.  modified the new    *
 *           bishop code to only consider the "long diagonal" if the bishop    *
 *           is in either 9-square corner on its own side of the board, so     *
 *           that the short diagonal being open won't offset the long          *
 *           diagonal that is blocked.  bishop-pair bonus is now adjusted by   *
 *           how open or closed the center is.  If 3 of the four center pawns  *
 *           are gone, the center is open and the bishop pair bonus is set to  *
 *           the max.  If the four center pawns are locked (e4/e5/d5/d6 for    *
 *           example) then the bishop pair bonus is eliminated.  if the center *
 *           is somewhere in the middle of those extremes, then the bishop     *
 *           pair bonus is present but reduced.  castling now is a bit more    *
 *           intelligent.  if a side has not castled, then moving either rook  *
 *           receives a penalty, where moving the king or the last unmoved     *
 *           rook receives a larger penalty.  if the king has not castled, its *
 *           'safety' score is based on the most safe position of the possible *
 *           options.  if neither rook has moved, then the score is based on   *
 *           the safest of the three locations, either in the center where it  *
 *           is, or on the safest wing.  If uncastled, this safaty is always   *
 *           reduced a bit to encourage castling before it becomes too late to *
 *           do so.  this was done to avoid a problem where the queen rook had *
 *           been moved, Crafty had not castled, and it pushed the kingside    *
 *           pawns making it unsafe to castle there, leaving the center as the *
 *           best place, yet had it not pushed the kingside pawns, castling    *
 *           would have been a better alternative.   two new 16 word vectors,  *
 *           safety_vector[]/tropism_vectorp[] are used to set the edge values *
 *           for the king_safetyp[][] array.  interior values are filled in    *
 *           based on these two vectors, making it much easier to tweak the    *
 *           king safety scores without pulling your hair out.                 *
 *                                                                             *
 *   20.8    when queens come off, the previous version cut the tropism scores *
 *           and pawn shelter scores by 1/2 each, which had the effect of      *
 *           dropping the overall score by 75% (the score is a geometric       *
 *           computation).  The safety/tropism values are now dropped, but by  *
 *           a smaller amount, since bishops + rooks + knights are still a     *
 *           dangerous threat.                                                 *
 *                                                                             *
 *   20.9    simple lazy eval (Mike Byrne) added.  this simply avoids the more *
 *           expensive piece evaluations if the pawn scoring and material      *
 *           leave the score well outside the alpha/beta search window.  looks *
 *           like a 20% speed improvement in general.                          *
 *                                                                             *
 *   20.10   change to king safety pawn structure.  open files around the king *
 *           are dangerous, but the h/g (or b/a) files are more dangerous than *
 *           the f-e-d-c files since they are much harder to defend against    *
 *           with the castled king in the way.  modified the way the king      *
 *           safety matrix is computed so that at the tropism/pawnstructure    *
 *           values are more sane.  It currently will get the same value for   *
 *           array indices of 5,0, 4,1, 3,2, 2,3, 1,4, or 0,5, which is better *
 *           than what it was doing.  I plan to tweak this more later to make  *
 *           3,2 or 2,3 worse than 4,1 or 1,4 and 0,5 or 5,0, as the latter    *
 *           mean "unsafe king but no piece pressure" or "piece pressure but   *
 *           king pawn shelter is safe" whereas the middle values mean both    *
 *           components of an attack are present, unsafe king position and the
 *           pieces are closing in.                                            *
 *                                                                             *
 *   20.11   minor fix to late move reduction code.  turns out it is possible  *
 *           to reach the block of code if (first_move) { } with status set to *
 *           REMAINING_MOVES (this means no captures, no killer, no hash move, *
 *           no history move, etc).  That would let me try a reduction, and if *
 *           it failed high, we would use that score as-is.  we now re-search  *
 *           a fail-high here just like we did in the other block of code so   *
 *           that a fail-high on a reduction search is never trusted.          *
 *                                                                             *
 *   20.12   further modifications to king safety initialization code to try   *
 *           scale back the values a bit to control score limits.              *
 *                                                                             *
 *   20.13   fix to bench.c to remove two file closes that would wreck the     *
 *           program after the bench command was finished.  also the           *
 *           SMP-time-to-ply measurement was removed since it had no meaning.  *
 *           old FUTILITY code re-inserted along with an extension limit       *
 *           modification by Mike Byrne to avoid limiting the search extension *
 *           on one-reply extensions only.  new lock.h submitted by Andreas    *
 *           Guettinger to support spinlocks on the PPC architecture (Linux).  *
 *           some -D configuration options were changed so that none are       *
 *           needed to compile the "standard" crafty.  futility is normally on *
 *           now, and -DNOFUTILITY is required to compile it out.  the new     *
 *           Makefile gives the configuration options, but the only ones that  *
 *           would normally need setting are the SMP and CPUS= options if you  *
 *           have a SMP platform.                                              *
 *                                                                             *
 *   20.14   fix to EvaluateWinningChances() to correctly evaluate KRP vs KR   *
 *           type endings.  previously this was done in the wrong place and    *
 *           the score would favor the side with the pawn significantly, where *
 *           the score is now zero.  minor bugfix to code that detects that an *
 *           illegal position has been set up.  it caught every possible       *
 *           problem except for positions with a king (or kings) missing.      *
 *                                                                             *
 *   20.15   change to how Crafty chooses where to split.  previously, there   *
 *           was a min remaining depth limit to prevent Crafty from trying to  *
 *           split too close to the frontier nodes.  now that is specified as  *
 *           a percentage of the nominal search depth.  for example, the       *
 *           default value is 50%, which says that on a 16 ply search, we can  *
 *           split if at least 8 plies of search are left.  this provides      *
 *           better split overhead than a simple limit that doesn't take the   *
 *           actual search depth into consideration.  history data arranged to *
 *           be more cache friendly.  the three values for a common history    *
 *           index value are now stored in adjacent memory words to take       *
 *           advantage of pre-fetching within a cache line.  Additional        *
 *           tuning of the king safety matrix.                                 *
 *                                                                             *
 *   20.16   Evaluation of knights, bishops, rooks, queens and kings is now    *
 *           done on a 1000 point scale, then the sum is divided by 10.  This  *
 *           allows us to use the same hashing mechanism, but with finer       *
 *           tuning precision.  minor queen eval tweak for 7th rank position.  *
 *                                                                             *
 *   20.17   New book learning, with a simplified book system.  the export     *
 *           files (book.lrn, position.lrn) no longer are created/used, the    *
 *           learn mechanism no longer touches the real chess board which      *
 *           could cause problems in certain xboard/winboard timing            *
 *           situations.  one major learning change is that we now only learn  *
 *           things from "crafty's perspective".  that is, if Crafty loses a   *
 *           game as black, it won't think that opening is good when it plays  *
 *           white since it might well not understand how to win using that    *
 *           particular opening.  it will only "learn" on the actual moves it  *
 *           plays in a game.  old "history heuristic" removed.  testing       *
 *           showed that the LMR idea produced better results without the      *
 *           history ordering, since now more moves are reduced, but moves     *
 *           with good history values don't get reduced.                       *
 *                                                                             *
 *   21.0    finally did the bit-renumbering task so that bit 0 = LSB = A1,    *
 *           to eliminate the 63-n translation to the numbering scheme used    *
 *           on the Cray architecture.  for all bit operations now, LSB=0,     *
 *           MSB=7, 15, 31 or 63 depending on the data size.  a few minor      *
 *           bugs were fixed along the way as these changes were debugged.     *
 *           minor bug in EvaluateKings() where it tested for a "won ending"   *
 *           and used a test that was too aggressive.  this test did not get   *
 *           things quite right when the two kings were very close together    *
 *           and "opposition" prevented one king from moving closer to the     *
 *           pawns.                                                            *
 *                                                                             *
 *   21.1    new piece scoring from Tracy, which changes the way pieces are    *
 *           scored based on squares they attack.                              *
 *                                                                             *
 *   21.2    the scores are now scaled better for the transition from middle-  *
 *           game to end-game.  Passed pawn scores climb as material is        *
 *           removed from the board, to prevent them from overwhelming the     *
 *           middlegame king safety scores.  We do exactly the same scaling on *
 *           king-safety scores, but they are scaled downward as material is   *
 *           removed so that they "phase out" as the endgame is reached.       *
 *           weak pawn code changed to more accurately identify weak pawns.    *
 *           these are totaled and then used to index a scoring array that     *
 *           penalizes the number of weak pawns on each side.  pawn islands    *
 *           are now recognized and each side is penalized according to the    *
 *           number of islands he has, more being worse.                       *
 *                                                                             *
 *   21.3    "magic" move generation is now used, which eliminates the rotated *
 *           bitboard approach completely.  not a significant speed change,    *
 *           but it is far simpler overall.                                    *
 *                                                                             *
 *   21.4    misc eval changes.  more king safety changes to include a tropism *
 *           distance of 1 for bishops or rooks that can slide to intercept    *
 *           any square surrounding the enemy king.  reduced rook slide score  *
 *           by 40%.
 *                                                                             *
 *   21.5    passed pawn extension revisited.  bad trade was giving a penalty  *
 *           for being down an exchange (or a bonus for being up an exchange)  *
 *           which was not expected behavior.  this has been fixed.  EGTB      *
 *           initialization was being done during the first pass over the      *
 *           RC file, which was too early as the rest of the engine had not    *
 *           been initialized.  now the "egtb" command is the only thing that  *
 *           triggers initialization, and is only processed during the second  *
 *           pass over the RC file after paths have been properly set up.      *
 *           Abs() function bug fix.                                           *
 *                                                                             *
 *   21.6    passed pawn evaluation changed with respect to distant passed     *
 *           pawns and distant majorities.  now, if both have a pawn majority  *
 *           we check to see if one is "distant" (away from the enemy king) as *
 *           this represents a significant time advantage because the other    *
 *           side has to waste moves to reach and capture the pawn to prevent  *
 *           promotion.  LMR no longer uses the history counters, which proved *
 *           to be essentially random numbers.  LMR decisions are now based    *
 *           solely on static characteristics of an individual move, rather    *
 *           than trying to determine how the move affected the search at      *
 *           other points in the tree.  new wtm bonus added to evaluation.     *
 *           EvaluateMate() bug fixed where the score was set to a non-zero    *
 *           value which broke EvaluateMate() completely.  new mobility code   *
 *           for bishops/rooks encourages better piece placement.  note that   *
 *           there are many other evaluation changes too numerous to list here *
 *           in detail.                                                        *
 *                                                                             *
 *******************************************************************************
 */
int main(int argc, char **argv)
{
  int move, presult, readstat;
  int value = 0, i, result;
  TREE *tree;
  FILE *personality;

#if defined(UNIX)
  char path[1024];
  struct passwd *pwd;
#endif

#if !defined(UNIX)
  char crafty_rc_file_spec[FILENAME_MAX];
#endif
/* Collect environmental variables */
  char *directory_spec = getenv("CRAFTY_BOOK_PATH");

  shared = SharedMalloc(sizeof(SHARED), 0);
  if (directory_spec)
    strncpy(book_path, directory_spec, sizeof book_path);
  directory_spec = getenv("CRAFTY_LOG_PATH");
  if (directory_spec)
    strncpy(log_path, directory_spec, sizeof log_path);
  directory_spec = getenv("CRAFTY_TB_PATH");
  if (directory_spec)
    strncpy(tb_path, directory_spec, sizeof tb_path);
  directory_spec = getenv("CRAFTY_RC_PATH");
  if (directory_spec)
    strncpy(rc_path, directory_spec, sizeof rc_path);
  if (getenv("CRAFTY_XBOARD")) {
    Print(4095, "feature done=0\n");
    done = 0;
  } else if (argc > 1 && !strcmp(argv[1], "xboard")) {
    Print(4095, "feature done=0\n");
    done = 0;
  }
/*
 ************************************************************
 *                                                          *
 *   first, parse the command-line options and pick off the *
 *   ones that need to be handled before any initialization *
 *   is attempted (mainly path commands at present.)        *
 *                                                          *
 ************************************************************
 */
  shared->local[0] =
      (TREE *) ((~(size_t) 127) & (127 + (size_t) SharedMalloc(sizeof(TREE) +
              127, 0)));
  shared->local[0]->used = 1;
  shared->local[0]->stop = 0;
  shared->local[0]->ply = 1;
  shared->local[0]->nprocs = 0;
  shared->local[0]->thread_id = 0;
  tree = shared->local[0];
  input_stream = stdin;
  for (i = 0; i < 256; i++)
    args[i] = (char *) malloc(128);
  if (argc > 1) {
    for (i = 1; i < argc; i++) {
      if (strstr(argv[i], "path") || strstr(argv[i], "log")) {
        strcpy(buffer, argv[i]);
        result = Option(tree);
        if (result == 0)
          printf("ERROR \"%s\" is unknown command-line option\n", buffer);
        display = tree->pos;
      }
    }
  }
/*
 ************************************************************
 *                                                          *
 *   now, read the crafty.rc/.craftyrc initialization file  *
 *   and process the commands that need to be handled prior *
 *   to initializing things (path commands).                *
 *                                                          *
 ************************************************************
 */
#if defined(UNIX)
  input_stream = fopen(".craftyrc", "r");
  if (!input_stream)
    if ((pwd = getpwuid(getuid()))) {
      sprintf(path, "%s/.craftyrc", pwd->pw_dir);
      input_stream = fopen(path, "r");
    }
  if (input_stream)
#else
  sprintf(crafty_rc_file_spec, "%s/crafty.rc", rc_path);
  if ((input_stream = fopen(crafty_rc_file_spec, "r")))
#endif
    while (1) {
      readstat = Read(1, buffer);
      if (readstat < 0)
        break;
      if (!strstr(buffer, "path"))
        continue;
      result = Option(tree);
      if (result == 0)
        printf("ERROR \"%s\" is unknown rc-file option\n", buffer);
      if (input_stream == stdin)
        break;
    }
/*
 ************************************************************
 *                                                          *
 *   if NUMA is enabled, report on the current machine      *
 *   configuration.                                         *
 *                                                          *
 ************************************************************
 */
#if defined(NUMA) && defined(LINUX)
  if (numa_available() >= 0) {
    unsigned long cpus[8];

    numa_node_to_cpus(0, cpus, 64);
    printf("\nMachine is NUMA, %d nodes (%d cpus/node)\n\n",
        numa_max_node() + 1, PopCnt(cpus[0]));
  }
#endif
/*
 ************************************************************
 *                                                          *
 *   initialize chess board to starting position.           *
 *                                                          *
 ************************************************************
 */
  Initialize();
/*
 ************************************************************
 *                                                          *
 *   now, parse the command-line options and pick off the   *
 *   ones that need to be handled after initialization is   *
 *   completed.                                             *
 *                                                          *
 ************************************************************
 */
  if (argc > 1) {
    for (i = 1; i < argc; i++)
      if (strcmp(argv[i], "c"))
        if (!strstr(argv[i], "path")) {
          strcpy(buffer, argv[i]);
          result = Option(tree);
          if (result == 0)
            printf("ERROR \"%s\" is unknown command-line option\n", buffer);
        }
  }
  display = tree->pos;
  initialized = 1;
  move_actually_played = 0;
/*
 ************************************************************
 *                                                          *
 *   now, read the crafty.rc/.craftyrc initialization file  *
 *   and process the commands that need to be handled after *
 *   engine initialization has been completed.              *
 *                                                          *
 ************************************************************
 */
#if defined(UNIX)
  input_stream = fopen(".craftyrc", "r");
  if (!input_stream)
    if ((pwd = getpwuid(getuid()))) {
      sprintf(path, "%s/.craftyrc", pwd->pw_dir);
      input_stream = fopen(path, "r");
    }
  if (input_stream)
#else
  sprintf(crafty_rc_file_spec, "%s/crafty.rc", rc_path);
  if ((input_stream = fopen(crafty_rc_file_spec, "r")))
#endif
    while (1) {
      readstat = Read(1, buffer);
      if (readstat < 0)
        break;
      if (strstr(buffer, "path"))
        continue;
      result = Option(tree);
      if (result == 0)
        printf("ERROR \"%s\" is unknown rc-file option\n", buffer);
      if (input_stream == stdin)
        break;
    }
  input_stream = stdin;
#if defined(UNIX)
  if (xboard)
    signal(SIGINT, SIG_IGN);
  signal(SIGCHLD, SignalInterrupt);
#endif
  Print(128, "\nCrafty v%s (%d cpus)\n\n", version, Max(shared->max_threads,
          1));
  if (ics)
    printf("*whisper Hello from Crafty v%s! (%d cpus)\n", version,
        Max(shared->max_threads, 1));
  NewGame(1);
/*
 ************************************************************
 *                                                          *
 *   check to see if we can find a "crafty.cpf" personality *
 *   file which contains the default personality settings   *
 *   to be used unless overridden by the user.              *
 *                                                          *
 ************************************************************
 */
  if ((personality = fopen("crafty.cpf", "r"))) {
    fclose(personality);
    Print(4095, "using default personality file \"crafty.cpf\"\n");
    sprintf(buffer, "personality load crafty.cpf");
    (void) Option(tree);
  }
/*
 ************************************************************
 *                                                          *
 *   prompt user and read input string for processing.  as  *
 *   long as Option() returns a non-zero value, continue    *
 *   reading lines and calling Option().  when Option()     *
 *   fails to recogize a command, then try InputMove() to   *
 *   determine if this is a legal move.                     *
 *                                                          *
 ************************************************************
 */
  while (1) {
    presult = 0;
    do {
      if (new_game)
        NewGame(0);
      shared->opponent_start_time = ReadClock();
      input_status = 0;
      display = tree->pos;
      move = 0;
      presult = 0;
      if (done == 0 && xboard) {
        done = 1;
        Print(128, "feature done=1\n");
      }
      do {
        if (presult != 2)
          presult = 0;
        result = 0;
        if (pong) {
          Print(4095, "pong %d\n", pong);
          pong = 0;
        }
        display = tree->pos;
        if (presult != 2 && (shared->move_number != 1 || !wtm))
          presult = Ponder(wtm);
        if (presult == 1)
          value = shared->last_root_value;
        else if (presult == 2)
          value = ponder_value;
        if (presult == 0 || presult == 2) {
          if (!ics && !xboard) {
            if (wtm)
              printf("White(%d): ", shared->move_number);
            else
              printf("Black(%d): ", shared->move_number);
            fflush(stdout);
          }
          readstat = Read(1, buffer);
          if (log_file) {
            if (wtm)
              fprintf(log_file, "White(%d): %s\n", shared->move_number, buffer);
            else
              fprintf(log_file, "Black(%d): %s\n", shared->move_number, buffer);
          }
          if (readstat < 0 && input_stream == stdin) {
            strcpy(buffer, "end");
            (void) Option(tree);
          }
        }
        if (presult == 1)
          break;
        shared->opponent_end_time = ReadClock();
        result = Option(tree);
        if (result == 0) {
          nargs = ReadParse(buffer, args, " 	;");
          move = InputMove(tree, args[0], 0, wtm, 0, 0);
          result = !move;
          if (move)
            last_pv.path[1] = 0;
        } else {
          input_status = 0;
          if (result == 3)
            presult = 0;
        }
      } while (result > 0);
      if (presult == 1)
        move = ponder_move;
/*
 ************************************************************
 *                                                          *
 *   make the move (using internal form) returned by        *
 *   InputMove() and then change the side on move (wtm).    *
 *                                                          *
 ************************************************************
 */
      if (result == 0) {
        fseek(history_file, ((shared->move_number - 1) * 2 + 1 - wtm) * 10,
            SEEK_SET);
        fprintf(history_file, "%9s\n", OutputMove(tree, move, 0, wtm));
        MakeMoveRoot(tree, move, wtm);
        move_actually_played = 1;
        last_opponent_move = move;
        if (RepetitionDraw(tree, 0) == 1) {
          Print(128, "%sI claim a draw by 3-fold repetition.%s\n", Reverse(),
              Normal());
          value = DrawScore(wtm);
          if (xboard)
            Print(4095, "1/2-1/2 {Drawn by 3-fold repetition}\n");
        }
        if (RepetitionDraw(tree, 0) == 2) {
          Print(128, "%sI claim a draw by the 50 move rule.%s\n", Reverse(),
              Normal());
          value = DrawScore(wtm);
          if (xboard)
            Print(4095, "1/2-1/2 {Drawn by 50-move rule}\n");
        }
        if (Drawn(tree, last_search_value) == 2) {
          Print(128, "%sI claim a draw due to insufficient material.%s\n",
              Reverse(), Normal());
          if (xboard)
            Print(4095, "1/2-1/2 {Insufficient material}\n");
        }
        wtm = Flip(wtm);
        if (wtm)
          shared->move_number++;
        time_used_opponent =
            shared->opponent_end_time - shared->opponent_start_time;
        if (!force)
          Print(1, "              time used: %s\n",
              DisplayTime(time_used_opponent));
        TimeAdjust(time_used_opponent, opponent);
      } else {
        tree->position[1] = tree->position[0];
        presult = 0;
      }
      ValidatePosition(tree, 0, move, "Main(1)");
    } while (force);
/*
 ************************************************************
 *                                                          *
 *   now call Iterate() to compute a move for the current   *
 *   position.  (note this is not done if Ponder() has al-  *
 *   computed a move.)                                      *
 *                                                          *
 ************************************************************
 */
    shared->crafty_is_white = wtm;
    if (presult == 2) {
      if ((From(ponder_move) == From(move)) && (To(ponder_move) == To(move)) &&
          (Piece(ponder_move) == Piece(move)) &&
          (Captured(ponder_move) == Captured(move)) &&
          (Promote(ponder_move) == Promote(move))) {
        presult = 1;
        if (!book_move)
          predicted++;
      } else
        presult = 0;
    }
    ponder_move = 0;
    shared->thinking = 1;
    if (presult != 1) {
      strcpy(shared->kibitz_text, "n/a");
      last_pv.pathd = 0;
      last_pv.pathl = 0;
      display = tree->pos;
      value = Iterate(wtm, think, 0);
    }
/*
 ************************************************************
 *                                                          *
 *   we've now completed a search and need to handle a      *
 *   pending draw offer based on what the search found.     *
 *                                                          *
 ************************************************************
 */
    if (draw_offer_pending) {
      int drawsc = abs_draw_score;

      draw_offer_pending = 0;
      if (shared->move_number < 40 || !accept_draws)
        drawsc = -300;
      if (value <= drawsc && (shared->tc_increment != 0 ||
              shared->tc_time_remaining_opponent >= 1000)) {
        if (xboard)
          Print(4095, "tellics draw\n");
        else {
          Print(128, "Draw accepted.\n");
          if (audible_alarm)
            printf("%c", audible_alarm);
          if (speech) {
            char announce[128];

            strcpy(announce, SPEAK);
            strcat(announce, " Drawaccept");
            system(announce);
          }
        }
        Print(4095, "1/2-1/2 {Draw agreed}\n");
        strcpy(pgn_result, "1/2-1/2");
      } else {
        if (xboard) {
          Print(4095, "tellics decline\n");
          Print(128, "Decline\n");
        } else
          Print(4095, "Draw declined.\n");
      }
    }
/*
 ************************************************************
 *                                                          *
 *   we've now completed a search and need to do some basic *
 *   bookkeeping.                                           *
 *                                                          *
 ************************************************************
 */
    last_pv = tree->pv[0];
    last_value = value;
    if (abs(last_value) > (MATE - 300))
      last_mate_score = last_value;
    shared->thinking = 0;
    if (!last_pv.pathl) {
      if (value == -MATE + 1) {
        over = 1;
        if (wtm) {
          Print(4095, "0-1 {Black mates}\n");
          strcpy(pgn_result, "0-1");
        } else {
          Print(4095, "1-0 {White mates}\n");
          strcpy(pgn_result, "1-0");
        }
        if (speech) {
          char announce[128];

          strcpy(announce, SPEAK);
          strcat(announce, " Checkmate");
          system(announce);
        }
      } else {
        over = 1;
        if (!xboard) {
          printf("%s", Reverse());
          Print(128, "stalemate\n");
          if (speech) {
            char announce[128];

            strcpy(announce, SPEAK);
            strcat(announce, " Stalemate");
            system(announce);
          }
          printf("%s", Normal());
        } else
          Print(4095, "1/2-1/2 {stalemate}\n");
      }
    } else {
      if ((value > MATE - 300) && (value < MATE - 2)) {
        Print(128, "\nmate in %d moves.\n\n", (MATE - value) / 2);
        Kibitz(1, wtm, 0, 0, (MATE - value) / 2, tree->nodes_searched, 0, " ");
      } else if ((-value > MATE - 300) && (-value < MATE - 1)) {
        Print(128, "\nmated in %d moves.\n\n", (MATE + value) / 2);
        Kibitz(1, wtm, 0, 0, -(MATE + value) / 2, tree->nodes_searched, 0, " ");
      }
/*
 ************************************************************
 *                                                          *
 *   see if we need to claim a draw due to either the 50    *
 *   move rule, 3-fold repetition, or insufficient material *
 *   as the case may be.  if so, we should make the claim   *
 *   before making the move that results in the draw.       *
 *                                                          *
 ************************************************************
 */
      tree->position[MAXPLY] = tree->position[0];
      MakeMove(tree, MAXPLY, last_pv.path[1], wtm);
      tree->rep_list[++tree->rep_game] = HashKey;
      if (RepetitionDraw(tree, MAXPLY + 1) == 1) {
        Print(128, "%sI claim a draw by 3-fold repetition after my move.%s\n",
            Reverse(), Normal());
        if (xboard)
          Print(4095, "1/2-1/2 {Drawn by 3-fold repetition}\n");
        value = DrawScore(wtm);
      }
      if (RepetitionDraw(tree, MAXPLY + 1) == 2) {
        Print(128, "%sI claim a draw by the 50 move rule after my move.%s\n",
            Reverse(), Normal());
        if (xboard)
          Print(4095, "1/2-1/2 {Drawn by 50-move rule}\n");
        value = DrawScore(wtm);
      }
      if (Drawn(tree, last_search_value) == 2) {
        Print(128,
            "%sI claim a draw due to insufficient material after my move.%s\n",
            Reverse(), Normal());
        if (xboard)
          Print(4095, "1/2-1/2 {Insufficient material}\n");
      }
      UnmakeMove(tree, MAXPLY, last_pv.path[1], wtm);
      --tree->rep_game;
      ResignOrDraw(tree, value);
/*
 ************************************************************
 *                                                          *
 *   now output the move chosen by the search, and the      *
 *   "result" string if necessary.                          *
 *                                                          *
 ************************************************************
 */
      if (wtm) {
        if (!xboard && !ics) {
          Print(128, "\n");
          printf("%s", Reverse());
          if (audible_alarm)
            printf("%c", audible_alarm);
          if (speech) {
            char announce[128];
            char *moveptr = OutputMove(tree, last_pv.path[1], 0, wtm);

            strcpy(announce, SPEAK);
            strcat(announce, moveptr);
            system(announce);
          }
          Print(128, "White(%d): %s ", shared->move_number, OutputMove(tree,
                  last_pv.path[1], 0, wtm));
          printf("%s", Normal());
          Print(128, "\n");
        } else if (xboard) {
          if (log_file)
            fprintf(log_file, "White(%d): %s\n", shared->move_number,
                OutputMove(tree, last_pv.path[1], 0, wtm));
          printf("move %s\n", OutputMove(tree, last_pv.path[1], 0, wtm));
        } else
          Print(128, "*%s\n", OutputMove(tree, last_pv.path[1], 0, wtm));
      } else {
        if (!xboard && !ics) {
          Print(128, "\n");
          printf("%s", Reverse());
          if (audible_alarm)
            printf("%c", audible_alarm);
          if (speech) {
            char announce[128];
            char *moveptr = OutputMove(tree, last_pv.path[1], 0, wtm);

            strcpy(announce, SPEAK);
            strcat(announce, moveptr);
            system(announce);
          }
          Print(128, "Black(%d): %s ", shared->move_number, OutputMove(tree,
                  last_pv.path[1], 0, wtm));
          printf("%s", Normal());
          Print(128, "\n");
        } else if (xboard) {
          if (log_file)
            fprintf(log_file, "Black(%d): %s\n", shared->move_number,
                OutputMove(tree, last_pv.path[1], 0, wtm));
          printf("move %s\n", OutputMove(tree, last_pv.path[1], 0, wtm));
        } else
          Print(128, "*%s\n", OutputMove(tree, last_pv.path[1], 0, wtm));
      }
      if (value == MATE - 2) {
        if (wtm) {
          Print(4095, "1-0 {White mates}\n");
          strcpy(pgn_result, "1-0");
        } else {
          Print(4095, "0-1 {Black mates}\n");
          strcpy(pgn_result, "0-1");
        }
      }
      time_used = shared->program_end_time - shared->program_start_time;
      Print(1, "              time used: %s\n", DisplayTime(time_used));
      TimeAdjust(time_used, crafty);
      fseek(history_file, ((shared->move_number - 1) * 2 + 1 - wtm) * 10,
          SEEK_SET);
      fprintf(history_file, "%9s\n", OutputMove(tree, last_pv.path[1], 0, wtm));
      last_search_value = value;
      MakeMoveRoot(tree, last_pv.path[1], wtm);
      move_actually_played = 1;
#if !defined(TEST)
      if (log_file && shared->time_limit > 300)
#endif
        DisplayChessBoard(log_file, tree->pos);
#if defined(TEST)
      strcpy(buffer, "score");
      Option(tree);
#endif
/*
 ************************************************************
 *                                                          *
 *   save the ponder_move from the current principal        *
 *   variation, then shift it left two moves to use as the  *
 *   starting point for the next search.  adjust the depth  *
 *   to start the next search at the right iteration.       *
 *                                                          *
 ************************************************************
 */
      if (last_pv.pathl > 1 && VerifyMove(tree, 0, Flip(wtm), last_pv.path[2])) {
        ponder_move = last_pv.path[2];
        for (i = 1; i <= (int) last_pv.pathl - 2; i++)
          last_pv.path[i] = last_pv.path[i + 2];
        last_pv.pathl = (last_pv.pathl > 2) ? last_pv.pathl - 2 : 0;
        last_pv.pathd -= 2;
        if (last_pv.pathd > last_pv.pathl)
          last_pv.pathd = last_pv.pathl;
        if (last_pv.pathl == 0)
          last_pv.pathd = 0;
      } else {
        last_pv.pathd = 0;
        last_pv.pathl = 0;
        ponder_move = 0;
      }
    }
    wtm = Flip(wtm);
    if (book_move) {
      shared->moves_out_of_book = 0;
      predicted++;
      if (ponder_move)
        sprintf(book_hint, "%s", OutputMove(tree, ponder_move, 0, wtm));
    } else
      shared->moves_out_of_book++;
    if (wtm)
      shared->move_number++;
    ValidatePosition(tree, 0, last_pv.path[1], "Main(2)");
    if (kibitz) {
      if (shared->kibitz_depth)
        Kibitz(2, !wtm, shared->kibitz_depth,
            shared->end_time - shared->start_time, value, tree->nodes_searched,
            tree->egtb_probes_successful, shared->kibitz_text);
      else
        Kibitz(4, !wtm, 0, 0, 0, 0, 0, shared->kibitz_text);
    }
/*
 ************************************************************
 *                                                          *
 *   now execute LearnBook() to determine if the book line  *
 *   was bad or good.  then follow up with another call to  *
 *   LearnBook() if the score indicates checkmate.          *
 *                                                          *
 ************************************************************
 */
    if (shared->moves_out_of_book) {
      LearnBook(tree, wtm, last_value, last_pv.pathd + 2, 0, 0);
    } else if (learn_positions_count < 63) {
      learn_seekto[learn_positions_count] = book_learn_seekto;
      learn_key[learn_positions_count] = book_learn_key;
      learn_nmoves[learn_positions_count++] = book_learn_nmoves;
    }
    if (abs(value) > MATE - 200) {
      int val = (shared->crafty_is_white) ? 300 : -300;

      if (value < 0)
        val = -val;
      LearnBook(tree, wtm, val, 0, 1, 2);
    }
    if (mode == tournament_mode) {
      strcpy(buffer, "clock");
      Option(tree);
      Print(128, "if clocks are wrong, use 'clock' command to adjust them\n");
    }
  }
}
