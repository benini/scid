
Toga II 1.3.4 (previously know as 1.3x4b) based on Fruit 2.1 by Fabien Letouzey.

Released with permission from Thomas Gaksch following the end of development by Thomas.

 - I would like to publically thank Thomas for his effort and Fabien for the basis of this engine.

 - Compiles by Denis Mendoza

Shaun Brewer



Legal details
-------------

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

Toga II 1.3.4 based on Fruit is a UCI-only chess engine.  This distribution comes up only with
Windows executable and platform-independent source code.


This version performs at a similar level to 1.3.1 however its endgame is more accurate and it uses the EGBBs provided by Daniel Shawul (Scorpio)
- this version was previously know as 1.3x4b (with some setting tweaks see below).

The default settings for 1.3.4 have been adjusted following testing.

Toga Extended History Pruning has been turned off
and History Threshold has been adjusted to 70

For Blitz play Toga Extended History Pruning should be turned on and the History Threshold adjusted to 80
- these setting have shown to improve performance at blitz.



Official distribution 
---------------------

You can download the GNU GPL Package (incl. sources) with Toga II based on Fruit at: http://www.superchessengine.com/



Version
-------

Toga II 1.3.4 based on Fruit 2.1

Following changes and extensions made:

- improved history pruning 
- improved futility pruning
- improved lazy evaluation
- new evaluation features (outpost knight etc.)
- MultiPV Mode

New in 1.2 

- more pruning
- more extensions
- new settings by Dieter Eberle

New in 1.2.1

- new settings
- some minor bugfixes

new in 1.3x4

- changes in eval
- changes in search 
- Endgame bitbases by Daniel Shawul (Scorpio)

new 1.3x4b

- bugfix of the endgame bitbases with help from Daniel Shawul 

new 1.3.4

- default settings adjusted
- Toga Extended History Pruning has been turned off (on in 1.3x4b)
- History Threshold has been adjusted to 70 (75 in 1.3x4b)



A very big thank to Daniel Shawul for sharing his great endgame bitbases and his dll.

EGBBs
-----
    Toga uses the Scorpio endgame bitbases upto 5 pieces.
   
    Installation 
    ------------
       First You have to download the 5men bitbases from Leo Dijksman's WBEC site 
       http://www.wbec-ridderkerk.nl . The egbbs are 340mb in size. Then put them 
       anywhere in your computer. The default path is c:\egbb\ but you can change this in the uci options. 
       The egbbdll.dll must be in the same folder as the bitbase files.

Thanks Fabien Letouzey for the great source code of the program Fruit 2.1.

Special thanks to
Dieter Eberle, Karl-Heinz Söntges, Shaun Brewer for testing Beta Versions.
A big thank to Dieter Eberle for his setting.
Orlando Mouchel for bugfixes and new ideas.
Wilhelm Hudetz for the Logo.

Without their help i wouldn´t be able to increase the playing strenght, compared to Fruit 2.1, by about 100 Elo.


Thomas Gaksch


