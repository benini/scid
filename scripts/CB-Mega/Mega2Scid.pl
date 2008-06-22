#!/usr/bin/perl -w
#=========================================================================
#
#    Mega2Scid.pl
#
#    Convert photos from ChessBase Mega Database to scids internal
#    photo format.
#
#    $Id: Mega2Scid.pl,v 1.1 2008/06/22 22:00:20 pgeorges Exp $
#    Last change: <Wed, 2008/03/05 15:59:07 arwagner ingata>
#    Author     : Alexander Wagner
#    Language   : Perl
#
#-------------------------------------------------------------------------
#
#    Copyright (C) 2008 by Alexander Wagner
#
#    This is free software; you can redistribute it and/or modify it
#    under the terms of the GNU Genereal Public License as published
#    by the Free Software Foundation; either version 2, or (at your
#    option) any later version.
#
#    This program is distributed in the hope that it will be usefull,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#    General Public License for more details.
#
#    You should have recieved a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#=========================================================================

use XML::XPath;
use IO::Handle;

my $inputxml = "mega.xml";

# Output file name
my $output   = "ChessBase.spf";

# relative path for palyerbase
my $prefix   = "/media/cdrom";

# the size used in scid (parameter for convert)
my $geometry = "80x100>";

# Use the ramdisk /dev/shm to speed up
my $outimg   = "/dev/shm/tmp.gif";
my $outmime  = "/dev/shm/out.mime64";

#======================================================================

open (OUT, ">$output") or die "Can't open $output: $!\n";

*STDOUT->autoflush(1);

print OUT "# $output\n";
print OUT "#\n";
print OUT "# This file contains photos of players from ChessBase Playerbase.\n";
print OUT "# These photos are converted from jpg to gif and resized to \n";
print OUT "# around 80x100 pixels each and stored as base64-encoded image.\n";
print OUT "#\n";
print OUT "# Copyright Note: These photos may be copyright by ChessBase.\n";
print OUT "# They are used legally only if you own a ChessBase MegaBase\n";
print OUT "# and have converted them from this collection yourself.\n";
print OUT "#\n\n\n";


my $xp       = XML::XPath->new(filename=>$inputxml);
my $nodes    = $xp->find('/cb/p');

foreach $player ($nodes->get_nodelist) {

	$lastname   = $player->find('l');
	$firstname  = $player->find('f');
	$imagefile  = $player->find('i');

	print "$lastname, $firstname: $imagefile\n";

	print OUT "photo \"$lastname, $firstname\" {\n";

	$inimg = "$prefix/$imagefile";
	
	# Convert images to about 80x100px height
	system ("convert  -geometry \"$geometry\" $inimg $outimg");
	system ("rm $outmime");
	
	# encode it using mpack
	system ("mpack -s none -o $outmime $outimg");

	open (IN, "<$outmime") or die "Can't open $outmime: $!\n";

	for (my $i=0; $i<14; $i++) {
		$line = <IN>;
	}

	while ($line = <IN>) {
		next if $line =~ m/^\n/;
		next if $line =~ m/^-----\n/;
		print OUT $line;
	}
	close(IN);

	print OUT "}\n\n";
}
print "info done.\n";

