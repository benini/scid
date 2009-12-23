;#########################################################################
;# RobboLito is a UCI chess playing engine by                            #
;# Yakov Petrovich Golyadkin, Igor Igorovich Igoronov, Roberto Pescatore #
;# copyright: (C) 2009 Yakov Petrovich Golyadkin                         #
;# date: 92th and 93rd year from Revolution                              #
;# owners: PUBLICDOMAIN (workers)                                        #
;# dedication: To Vladimir Ilyich                                        #
;#                                                                       #
;# RobboLito is free software: you can redistribute it and/or modify     #
;# it under the terms of the GNU General Public License as published     #
;# by the Free Software Foundation, either version 3 of the License,     #
;# or (at your option) any later version.                                #
;#                                                                       #
;# RobboLito is distributed in the hope that it will be useful, but      #
;# WITHOUT ANY WARRANTY; without even the implied warranty of            #
;# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
;# GNU General Public License for more details.                          #
;#                                                                       #
;# You should have received a copy of the GNU General Public License     #
;# along with this program. If not, see http://www.gnu.org/licenses/.    #
;#########################################################################

.globl BSF
BSF:
	movl 4(%esp),%eax
	testl %eax,%eax
	jz f_hi
	bsfl %eax,%eax
	ret
	f_hi:
	bsfl 8(%esp),%eax
	addl $0x20,%eax
	ret

.globl BSR
BSR:
	movl 8(%esp),%eax
	testl %eax,%eax
	jz l_lo
	bsrl %eax,%eax
	addl $0x20,%eax
	ret
	l_lo:
	bsrl 4(%esp),%eax
	ret
