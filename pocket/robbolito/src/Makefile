#########################################################################
# RobboLito is a UCI chess playing engine by                            #
# Yakov Petrovich Golyadkin, Igor Igorovich Igoronov, Roberto Pescatore #
# copyright: (C) 2009 Yakov Petrovich Golyadkin                         #
# date: 92th and 93rd year from Revolution                              #
# owners: PUBLICDOMAIN (workers)                                        #
# dedication: To Vladimir Ilyich                                        #
#                                                                       #
# RobboLito is free software: you can redistribute it and/or modify     #
# it under the terms of the GNU General Public License as published     #
# by the Free Software Foundation, either version 3 of the License,     #
# or (at your option) any later version.                                #
#                                                                       #
# RobboLito is distributed in the hope that it will be useful, but      #
# WITHOUT ANY WARRANTY; without even the implied warranty of            #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program. If not, see http://www.gnu.org/licenses/.    #
#########################################################################

OUTPUTFILE=robbolito

x86-gcc:
	gcc -O3 -DUSE_X86_ASM -mtune=native -lm -o $(OUTPUTFILE) *.c
	
x86-icc:
	icc -fast -o $(OUTPUTFILE)-$@ *.c


x86-generic-gcc:
	gcc -O3 -mtune=generic -lm -o $(OUTPUTFILE)-$@ *.c
	
x86-generic-icc:
	icc -fast -mia32 -o $(OUTPUTFILE)-$@ *.c

x86-generic-icc-alt:
	icc -fast -mia32 -D_ALT -o $(OUTPUTFILE)-$@ *.c bs.s
	
	
x86_64-generic-gcc:
	gcc -O3 -mtune=generic -Dx86_64 -lm -o $(OUTPUTFILE)-$@ *.c

x86_64-generic-icc:
	icc -fast -msse2 -Dx86_64 -o $(OUTPUTFILE)-$@ *.c
	
	
x86_64-gcc:
	gcc -O3 -mtune=native -Dx86_64 -lm -o $(OUTPUTFILE)-$@ *.c
	
x86_64-icc:
	icc -fast -Dx86_64 -o $(OUTPUTFILE)-$@ *.c

	
# for processors with sse4.2 support
#{-------------------------------------------------------------------------
x86_64-gcc-sse4.2:
	gcc -O3 -mtune=native -Dx86_64 -DHAS_POPCNT -lm -o $(OUTPUTFILE)-$@ *.c
	
x86_64-icc-sse4.2:
	icc -fast -Dx86_64 -DHAS_POPCNT -o $(OUTPUTFILE)-$@ *.c
#}--------------------------------------------------------------------------

clean:
	rm -f $(OUTPUTFILE)
