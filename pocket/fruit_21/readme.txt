
Legal details
-------------

Fruit 2.1 Copyright 2004-2005 Fabien Letouzey.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA

See the file "copying.txt" for details.


General
-------

Today is 2005/06/17.  This is Fruit 2.1 (Peach).

Fruit is a UCI-only chess engine.  This distribution comes up with
Windows, Linux and Mac OS X executable files as well as an opening
book and platform-independent source code.

Sorry that the word "Fruit" looks like "Fritz" (it certainly sounds
different in English).  This is obviously unintentional (or is it not,
yes?  I don't know anymore)!

PS: How would "Deep Fruit" sound? :)


Official distribution URL
-------------------------

The official distribution web site is Leo Dijksman's WBEC Ridderkerk:
http://wbec-ridderkerk.nl/  This is where you should be looking for
Fruit updates in the future.


Version
-------

"2.1, what's with the version number?  I invested $1M on 2.5 at the
stock market and now who's gonna bring my money back???"

Not me!  Version numbers have nothing to do with chess strength, but
with the quantity of code change and the position of the program in
long-term plans.

I decided to enter the Massy tournament (2005/06/12) only two weeks
beforehand, and I had to quickly decide for the version that would
play.  There were only 3 main changes as compared with Fruit 2.0,
because I had also been working on other programming projects.

After the tournament, "Fruit Massy" was tested and it appeared obvious
that some strength had been gained.  Fruit 2.1 is a "hurry release" of
the tournament version.  It took a few more days to fix an interface
problem (hash-table size under Arena) and add opening-book code
(compatible with PolyGlot).

OK so in short I switched from 2.0 to 2.1 because there were few
changes and I don't especially have plans for a 3.0, sorry for that.

For a description of the main additions, see the History section.


Files
-----

The archive contains executable files for Windows, Linux and Mac OS X,
as well as source code and a small opening book.

The file "technical_10.txt" only concerns the - obsolete - version 1.0
of Fruit (because I am too lazy to edit it right now AND also was when
releasing Fruit 2.0 AND also ...).  The search part of it is still
valid for Fruit 2.1 (except for the addition of history pruning).
However the evaluation function has almost been completely re-written.
Again, see the History section for a succinct description.


Compiling
---------

The distribution comes up with Windows, Linux and Mac OS X binaries.
Compiling is therefore not necessary on those systems unless you want
to make a change in the program.  In any case this section describes
the compiling procedure, it is safe to skip it.

Fruit was developed on Linux using g++ (the GNU C++ compiler).

The source code has also been successfully compiled on Windows using
both MSVC and Intel C++ compilers.  I do not know about
FreeBSD/OpenBSD/NetBSD or other POSIX-compliant operating systems, but
I don't expect many problems.

If you had problems getting Fruit compiled on your system, but somehow
managed it in the end, please let me know what changes were necessary
(see the contact section for details).

I have now included my Makefile for Unix systems.  It is a bit weird
(it uses GNU extensions), I hope it works on your OS (let me know if
it doesn't).  Associate the "-march" option with the appropriate
value on your system, and type "make" in the "src" directory.

If you find better optimisation options for g++ please let me know.


XBoard / Winboard
-----------------

Fruit is a UCI-only engine.  This is unlikely to change in the future.

Fruit and other UCI engines can be used with XBoard or WinBoard (or
other xboard-compatible interfaces) with the help of PolyGlot
(UCI-to-xboard adapter).  You can download PolyGlot at
http://wbec-ridderkerk.nl/


Opening book
------------

*** NEW ***

Starting with version 2.1, Fruit handles an opening book,
tada! (<- Windows 3.x sound for those old enough to remember).

I cloned the code from my own software (assuming it was legal)
"PolyGlot", sorry myself (it's OK /Ed).  And some say that open-source
is not useful!

Now, I hear it already.  Tournament directors will want me to
designate an official book that they should use.  To keep download
overhead low, I decided to include only a small book in the main
archive: it's called "book_small.bin".  It is in fact the same as
"fruit.bin" in the PolyGlot 1.3 release.

However, I would prefer that Fruit has access to a larger book during
tournaments.  At the time I am writing this line, "book_corbit.bin" is
planned to be made available on WBEC.

You can build your own book from a PGN file by using PolyGlot on the
command line.  PolyGlot is available for download at
http://wbec-ridderkerk.nl/


Tablebases
----------

Fruit does not use the so-called Nalimov tablebases, sorry for that.
This is unlikely to change in the future.

The reasons for my decision are:

- the source code by Eugene Nalimov is not "free of use"
  (although you don't have to pay for it)

- the design of the code does not work well with Fruit's "small memory
  footprint" requirement (for example the executable file would be at
  least twice as large with the TB code).

It must be said though that I have great respect for Eugene's
contribution to the computer-chess community.

As for Fruit I plan on using selected "bitbases" in the (very far)
future.  For now some draws are recognised by the evaluation function,
and - despite the errors - this somewhat reduces the penalty for not
using tablebases.


UCI options
-----------

You are advised to skip this section unless you are completely crazy
about computer chess.

Here I give you another chance to skip the section, as you should not
be reading this ...

Well you have downloaded Fruit in the first place so I suppose I can't
do anything for you anyway ...  I give up!

- "NullMove Pruning" (Always/Fail High/Never, default: Fail High)

"Always" actually means the usual conditions (not in check, etc ...).
"Fail High" adds the condition that the static evaluation fails high.
Never use "Never" (ever)!  OK you can use "Never" to test a Zugzwang
problem, but ask your Momma first!

I expect that this option has little effect (assuming the first two
choices only).  I only added it because most engines do not use the
fail-high condition.

- "NullMove Reduction" (1-3 plies, default: 3)

3 is rather aggressive, especially in the endgame.  It seems better
than always using 2 though.  I have not experimented with adaptive
solutions.

- "Verification Search" (Always/Endgame/Never, default: Endgame)

This tries to solve some Zugzwang-related problems.  I expect it to
hardly have any effect in games.  The default value should be
sufficient for most-common Zugzwang situations.

- "Verification Reduction" (1-6 plies, default: 5)

5 guarantees that the cost of verification search is negligible in
most cases.  Of course it means Zugzwang problems need a lot of depth
to get solved, if ever!  With such a reduction, verification search is
similar to Vincent Diepeveen's "double null move".

- "History Pruning" (true/false, default: true)

A bit dodgy, but fun to experiment with.  I added it in Fruit 2.0, and
I still haven't found the time to test it seriously ...  It should
help in blitz, but it's possible it actually hurts play in longer
games(!!!).  One day, I should check this.  One day ...

- "History Threshold" (percentage, default: 60%)

This is the thing, as it affects the search tree!  Lower values are
safer, and higher values more aggressive.  THIS VALUE HAS NOT BEEN
TUNED!  There is a good chance Fruit's strength can be improved by
changing this option.

- "Futility Pruning" (true/false, default: false)

Very common but controversial.  Makes the engine a tiny bit
better at tactics but slightly weaker positionally.  It might be
beneficial by a very small amount, but has not been tested in
conjunction with history pruning yet.

- "Futility Margin" (centipawns, default: 100)

This value is somewhat aggressive.  It could lead to problems in
the endgame.  Larger values prune less but will lead to fewer
positional errors.

- "Delta Pruning" (true/false, default: false)

Similar to futility pruning.  Probably safer because it is used
mainly during the middlegame.  Has not been tested with history
pruning either.

- "Delta Margin" (centipawns, default: 50)

Same behaviour as futility margin.  This one is probably safe.

- "Quiescence Check Plies" (0-2 plies, default: 1)

Fruit tries safe (SEE >= 0) checks at the first plies of the
quiescence search.  0 means no checks at all (as in most older
engines).  1 is the same as previous versions of Fruit.  2 is probably
not worth the extra cost.  It could be interesting when solving mate
problems though.

- evaluation options (percentage, default: 100%)

These options are evaluation-feature multipliers.  You can modify
Fruit's playing style to an extent or make Fruit weaker for instance
by setting "Material" to a low value.

"Material" is obvious.  It also includes the bishop-pair bonus.
"Piece Activity": piece placement and mobility.
"King Safety": mixed features related to the king during early phases
"Pawn Structure": all pawn-only features (not passed pawns).
"Passed Pawns": ... can you guess?

I think "Pawn Structure" is not an important parameter.
Who knows what you can obtain by playing with others?


History
-------

2004/03/17 Fruit 1.0, first stable release
------------------------------------------

Fruit was written in early 2003, then hibernated for many months.
I suddenly decided to remove some dust from it and release it after
seeing the great WBEC web site by Leo Dijksman!  Note that Fruit is
nowhere near ready to compete there because of the lack of xboard
support and opening book.  Note from the future: these limitations
seem not to be a problem anymore.

Fruit 1.0 is as close to the original program as possible, with the
main exception of added UCI-handling code (Fruit was using a private
protocol before).  It is a very incomplete program, released "as is",
before I start heavily modifying the code (for good or bad).

You can find a succinct description of some algorithms that Fruit uses
in the file "technical_10.txt" (don't expect much).


2004/06/04 Fruit 1.5, halfway through the code cleanup
------------------------------------------------------

In chronological order:

- added mobility in evaluation (makes Fruit play more actively)

- added drawish-material heuristics (makes Fruit look a bit less stupid
  in some dead-draw endgames)

- tweaked the piece/square tables (especially for knights)

- added time management (play easy moves more quickly, take more time
  when unsure)

- enabled the single-reply extension (to partly compensate for the lack
  of king safety)

- some speed up (but bear in mind mobility is a costly feature, when
  implemented in a straightforward way as I did)


2004/12/24 Fruit 2.0, the new departure
---------------------------------------

The main characteristic of Fruit 2.0 is the "completion" of the
evaluation function (addition of previously-missing major features).

In chronological order:

- separated passed-pawn evaluation from the pawn hash table,
  interaction with pieces can now be taken into account

- added a pawn-shelter penalty; with king placement this forms
  some sort of a simplistic king-safety feature

- added incremental move generation (Fruit was starting to be too slow
  for my taste)

- added futility and delta pruning (not tested in conjunction with
  history pruning and hence not activated by default)

- improved move ordering (bad captures are now postponed)

- added history pruning (not tested seriously at the time I write
  this yet enabled by default, I must be really dumb)

- cleaned up a large amount of code (IMO anyway), this should allow
  easier development in the future


2005/06/17 Fruit 2.1, the unexpected
------------------------------------

Unexpected because participation in the Massy tournament had not been
planned.  What you see is a picture of Fruit right in the middle of
development.  There may even be bugs (but this is a rumour)!

I have completed the eval "even more", not that it's ever complete
anyway.  I have to admit that I had always been too lazy to include
king attacks in previous versions.  However, some programs had fun
trashing Fruit 2.0 mercilessly in 20 moves, no doubt in order to make
me angry.  Now they should need at least 25 moves, don't bother me
again!

- added rook-on-open file bonus; thanks to Vincent Diepeveen for
  reminding me to add this.  Some games look less pathetic now.

- added pawn storms; they don't increase strength but they are so
  ridiculous that I was unable to deactivate them afterwards!

- added PV-node extensions (this is from Toga), e.g. extending
  recaptures only at PV nodes.  Not sure if these extensions help; if
  they do, we all need to recognise Thomas Gaksch's contribution to
  the community!

- added (small) king-attack bonus, the last *huge* hole in the eval;
  now only large holes remain, "be prepared" says he (to himself)!

- added history-pruning re-search; does not help in my blitz tests,
  but might at longer time control; it's also safer in theory,
  everybody else is using it and I was feeling lonely not doing like
  them.  OK, Tord told me that it helped in his programs ...

- added opening book (compatible with PolyGlot 1.3 ".bin" files)

- fixed hash-size UCI option, it should now be easy to configure using
  all interfaces (there used to be problems with Arena, entirely by my
  fault)


Breakpoint
----------

Why a breakpoint now?  For the first time of its life, after the
recent addition of king attacks, Fruit has all major (but admittedly
few others) evaluation components.  Don't get me wrong: they all need
a lot of refinement, but the code layout is there.

When Fruit 1.0 was released, some programmers told their surprise
that the program was playing OK-ish (not that I agreed) despite having
virtually no eval.  They might have wondered whether their larger code
was really useful.

Since then, I have mostly added classical evaluation features.  I
believe that Fruit has gained overall 150 to 200 Elo points by
evaluation alone.  Here I just want to explain that the minimalism of
Fruit 1.0 was never a goal, but the consequence of the "as is" state
of the distribution.

In the end, the moral is safe: eval is good for you!
Also "don't jump at conclusions" seems appropriate.


Future?
-------

Because of this "hurry release", I haven't had the time to continue
cleaning up the code.  This is the main reason why the version number
is only 2.1

I hope to provide a cleaner alternative, perhaps tuned a little, in a
few months.  Maybe it is time to consider adding features like
MultiPV.

Although I believe I could keep on increasing strength by adding more
and more eval terms, I have little interest in doing so.  I would not
learn anything in the process, unless I develop new tuning/testing
techniques.  Ideally I would like to spend more time in alternative
software, like my own GUI perhaps (specific to engine testing/matches).

Nonetheless, a lot can be done like tuning existing code or building
an adapted opening book.  Therefore, don't hesitate to contact me if
you are interested in giving a hand.  Computer testing time is
especially welcome, but be warned that I am quite demanding.  "I can
include test versions in my Fritz-GUI swiss tournament." -> forget it,
as well as my email address please, thanks a lot!

Lastly, don't take it too seriously.  I am tired and always under big
pressure before a release, because I want everything to go smoothly.
Who knows what I will think in a month?


Bug fixes
---------

Contrary to Fruit 2.0, Fruit 2.1 checks the legality of the hash-table
move before playing it.  This could make Fruit 2.0 crash in rare
occasion (like once every 10000 games).  This means that if Fruit 2.1
crashes, the bug is somewhere else.

Fruit 2.1 will now tolerate a hash-table resize after initialisation.
This seems especially important for use with Arena.  Unfortunately, it
also raises the notorious 1MB problem of some "bug"-full interface ...


Known bugs
----------

Fruit always claims that CPU is 100% used.  This is apparently a
problem in the standard C libraries on Windows.  Mailbomb me if fixing
this would save lives (especially children)!  I prefer waiting for
late users to throw away Windows 95/98/ME before adding an
NT/2000/XP/... solution.


Thanks
------

Big thanks go to:

- Joachim Rang and Robert W. Allgeuer for spending so much time
  testing different versions/settings of Fruit and getting actively
  involved in the project in general.  I don't know why they got
  interested in Fruit but the current version would definitely NOT
  exist without them.

- Bryan Hofmann for compiling Fruit (and other engines) for Windows

- Aaron Gordon for the Linux binary and long-term friendship;
  he's the one who showed me CCC years ago!

- George Sobala for the Mac OS X executable

- Leo Dijksman for hosting the Fruit distribution (and also the
  PolyGlot adapter) on his web site (see Links) and all the rest:
  tournament, testing, documentation, etc, ...  For those who have not
  noticed (e.g. people still using a TRS-80), Leo is EXTREMELY serious
  in what he is doing.  A reference in behaviour!

- Ernest Bonnem for making it possible for Fruit to play in the
  Massy 2005 tournament

- Tord Romstad for being my virtual twin brother; who knows if we can
  materialise in the same place some day?

- You, for having patiently waited for this release and still being
  reading this file (don't worry, it's nearly finished)

As usual there are dozens missing, it is simply impossible to include
everybody.


Links
-----

- engine lists, and much more:

Leo Dijksman's WBEC Ridderkerk: http://wbec-ridderkerk.nl/
Alex Schmidt's UCIengines.de: http://www.uciengines.de/

- free chess GUIs:

Tim Mann's Chess Pages: http://www.tim-mann.org/xboard.html
Arena: http://www.playwitharena.com/

- computer-chess fora:

The Computer Chess Club (CCC): http://www.talkchess.com/
Volker Pittlik's Winboard Forum: http://wbforum.volker-pittlik.name/

- mostly programmer stuff (if you have several lives to spend):

Dann Corbit's FTP: ftp://cap.connx.com (do *not* use passive mode)

Sorry for the dozens I simply had to leave away (but you know them if
you went that far) ...


Contact me
----------

You can contact me at fabien_letouzey@hotmail.com

For a long time, I have been waiting in vain for the "Fruit Fan Club"
T-shirts and donations of source-code improvements of several hundreds
Elo points I had been asking for.  About the latter I have to say that
it is not very smart to delay much further: the more you wait and the
more difficult it will be, but I suppose that it had not yet been
challenging enough ...

Anyway, I have decided to launch a new initiative.  What's more boring
than reading one's own code at 3am tracking down a bug that might not
even exist, know what I mean?  I have the solution: let's fix
each others bugs!

The new operation is called "Fix my Bugs and I Fix Yours!" (patent
pending).  It works as follows:

1) You fix one of my bugs (excluding null move) before 2005/09/01
   00:00 UTC (the acronym that does not mean anything in either
   English or French, so that both parties are equally disappointed).

2) I select the most artistic bug fix after the date limit.  A jury
   will be nominated if necessary.

3) I fix a bug of your choice in your program (excluding "it plays bad
   moves"), it's that simple!

This is not irony: contrary to popular belief, there really are bugs
in Fruit.  Even search bugs.  I just couldn't be bothered with fixing
them so far.  Sorry that I can't give you more hints, for now I am
using them to find clones effortlessly.

See you in September!!!


The end
-------

Thanks for listening, and have fun with Fruit!

Fabien Letouzey, 2005/06/17.

