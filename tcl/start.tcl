#!/bin/sh

# Scid (Shane's Chess Information Database)
#
# Copyright (C) 1999-2004 Shane Hudson
# Copyright (C) 2006-2009 Pascal Georges
# Copyright (C) 2008-2011 Alexander Wagner
# Copyright (C) 2013-2015 Fulvio Benini
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

#
# The following few comments are only for Unix versions of Scid:
#

# The "\" at the end of the comment line below is necessary! It means
#   that the "exec" line is a comment to Tcl/Tk, but not to /bin/sh.
# The next line restarts using tkscid: \
exec `dirname $0`/tkscid "$0" "$@"
# exec tkscid "$0" "$@"

# The above launches tkscid from the same directory that this startup
# script was launched from (which feels as a suitable default scenario).
# Alternatively, you can change the top line of this startup script
# to start tkscid directly from a specific location, e.g.:

# For the above to work, tkscid must be in a directory in your PATH.
# Alternatively, you can set the first line to start tkscid directly
# by specifying the full name of tkscid, eg:
# #!/home/myname/bin/tkscid

############################################################

package require Tcl 8.5
package require Tk  8.5
if {$tcl_version == 8.5} { catch {package require img::png} }

set scidVersion [sc_info version]
set scidVersionDate [sc_info version date]
set scidVersionExpected "4.6.1"

# Check that the version of c++ code matches the version of tcl code
#
if {[string compare $::scidVersion $::scidVersionExpected]} {
  wm withdraw .
  set msg "This is Scid version $::scidVersion, but the scid GUI (tcl/tk code)\n"
  append msg "has the version number $scidVersionExpected.\n"
  tk_messageBox -type ok -icon error -title "Scid: Version Error" -message $msg
  exit 1
}

# Determine operating system platform: unix, windows or macos
#
set windowsOS 0
if {$tcl_platform(platform) == "windows"} { set windowsOS 1 }
set unixOS 0
if {$tcl_platform(platform) == "unix"} { set unixOS 1 }
set macOS 0
if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} { set macOS 1 }

proc InitDirs {} {
  global scidExeDir scidUserDir scidConfigDir scidDataDir scidLogDir scidShareDir scidImgDir scidTclDir
  global scidBooksDir scidBasesDir ecoFile

  # scidExeDir: contains the directory of the Scid executable program.
  # Used to determine the location of various relative data directories.
  set scidExecutable [info nameofexecutable]
  if {[file type $scidExecutable] == "link"} {
    set scidExeDir [file dirname [file readlink $scidExecutable]]
    if {[file pathtype $scidExeDir] == "relative"} {
      set scidExeDir [file dirname [file join [file dirname $scidExecutable]\
        [file readlink $scidExecutable]]]
    }
  } else {
    set scidExeDir [file dirname $scidExecutable]
  }

  # scidUserDir: location of user-specific Scid files.
  # This is "~/.scid" on Unix, and the Scid executable dir on Windows.
  if {$::windowsOS} {
    set scidUserDir $scidExeDir
  } else {
    set scidUserDir [file nativename "~/.scid"]
  }

  # scidConfigDir, scidDataDir, scidLogDir:
  # Location of Scid configuration, data and log files.
  set scidConfigDir [file nativename [file join $scidUserDir "config"]]
  set scidDataDir [file nativename [file join $scidUserDir "data"]]
  set scidLogDir [file nativename [file join $scidUserDir "log"]]

  # scidShareDir, scidImgDir, scidTclDir, scidBooksDir, scidBasesDir, ecoFile:
  # Location of Scid resources
  set scidShareDir [file normalize [file join $scidExeDir "../share/scid"]]
  if {! [file isdirectory $::scidShareDir]} {
    set scidShareDir $::scidExeDir
  }
  set scidTclDir [file nativename [file join $scidShareDir "tcl"]]
  if {! [file isdirectory $scidTclDir]} {
    set scidTclDir [file dirname [info script]]
    set scidShareDir [file normalize "$scidTclDir/../"]
  }
  set scidImgDir [file nativename [file join $scidShareDir "img"]]

  #Default values, can be overwritten by file option
  set scidBooksDir [file nativename [file join $scidShareDir "books"]]
  set scidBasesDir [file nativename [file join $scidShareDir "bases"]]
  set ecoFile [file nativename [file join $scidShareDir "scid.eco"]]

  proc moveOldConfigFiles {} {
    # Moves configuration files from the old (3.4 and earlier) names
    # to the new file names used since Scid 3.5.
    global scidUserDir scidConfigDir

    # Since the options file used to be ".scid", rename it:
    if {[file isfile $scidUserDir]} {
      file rename -force $scidUserDir "$scidUserDir.old"
    }

    # Rename old "~/.scid_sent_emails" if necessary:
    if {[file isfile [file nativename "~/.scid_sent_emails"]]} {
      catch {file rename [file nativename "~/.scid_sent_emails"] $email(logfile)}
    }

    foreach {oldname newname} {
      scidrc options.dat
      scid.opt options.dat
      scid.bkm bookmarks.dat
      scid.rfl recentfiles.dat
      engines.lis engines.dat
    } {
      set oldpath [file nativename [file join $scidUserDir $oldname]]
      set newpath [file nativename [file join $scidConfigDir $newname]]
      if {[file readable $oldpath]  &&  ![file readable $newpath]} {
        if {[catch {file rename $oldpath $newpath} err]} {
          tk_messageBox -message "Error moving $oldpath to $newpath: $err"
        }
      }
    }
  }
  moveOldConfigFiles

  # Create the config, data and log directories if they do not exist:
  proc makeScidDir {dir} {
    if {! [file isdirectory $dir]} {
      file mkdir $dir
    }
  }
  makeScidDir $scidUserDir
  makeScidDir $scidConfigDir
  makeScidDir $scidDataDir
  makeScidDir $scidLogDir
}
InitDirs

#############################################################
#
# NAMESPACES
#
# The main Tcl/Tk namespaces used in the Scid application are
# initialized here, so that default values can be set up and
# altered when the user options file is loaded.
#
foreach ns {
  ::splash
  ::utils
  ::utils::date ::utils::font ::utils::history ::utils::pane ::utils::string
  ::utils::sound ::utils::validate ::utils::win
  ::file
  ::file::finder ::file::maint ::maint
  ::bookmarks
  ::edit
  ::game
  ::gbrowser
  ::search
  ::search::filter ::search::board ::search::header ::search::material
  ::windows
  ::windows::gamelist ::windows::stats ::tree ::tree::mask ::windows::tree
  ::windows::switcher ::windows::eco ::crosstab ::pgn ::book
  ::tools
  ::tools::analysis ::tools::email
  ::tools::graphs
  ::tools::graphs::filter ::tools::graphs::absfilter ::tools::graphs::rating ::tools::graphs::score
  ::tb ::optable
  ::board ::move
  ::tacgame ::sergame ::opening ::tactics ::calvar ::uci ::fics ::reviewgame ::novag
  ::config ::docking
  ::pinfo
  ::commenteditor
  ::unsafe
} {
  namespace eval $ns {}
}

proc ::splash::add {text} {
#TODO: decide what to do with all the splash messages (delete?)
}


# Reversed mouse buttons in mac (::MB2 and ::MB3 are middle and right mouse buttons respectively.):
if { $macOS } {
  set ::MB2 3
  set ::MB3 2
} else {
  set ::MB2 2
  set ::MB3 3
}


####################################################
# safeSource() - source a file using a safe interpreter
# @filename:  the absolute path to the file to source (load and execute)
# @args:      pairs of varname value that are visible to the sourced code
#
# This function execute the code inside a safe tcl interpreter and override
# "set" to import the variables of the executed code in the ::unsafe namespace.
# Attention must be paid to not evaluate ::unsafe vars, for example:
# set ::unsafe::badcode {tk_messageBox -message executeme}
# eval $::unsafe::badcode
# after idle $::unsafe::badcode

proc safeSource {filename args} {
  if {![info exists ::safeInterp]} {
    set ::safeInterp [::safe::interpCreate]
    interp hide $::safeInterp set
    interp alias $::safeInterp set {} ::safeSet $::safeInterp
  }
  set f [file nativename "$filename"]
  set d [file dirname $f]
  set n [file tail $f]
  foreach {varname value} $args {
    $::safeInterp eval [list set $varname $value]
  }
  $::safeInterp eval [list set vdir [::safe::interpAddToAccessPath $::safeInterp $d]]
  $::safeInterp eval "source \$vdir/$n"
  foreach {varname value} $args {
    $::safeInterp eval [list unset $varname]
  }
}
proc safeSet {i args} {
  #TODO: do not import local variables
  #if {[$::safeInterp eval info level] == 0}
  foreach {varname value} $args {
    set ::unsafe::$varname $value
  }
  interp invokehidden $i set {*}$args
}

####################################################
# Load default/saved values
source [file nativename [file join $::scidTclDir "options.tcl"]]


# Check for old (single-directory) tablebase option:
if {[info exists initialDir(tablebase)]} {
  set initialDir(tablebase1) $initialDir(tablebase)
}

set ::docking::USE_DOCKING $windowsDock

proc createFonts {} {
  foreach name {Regular Menu Small Tiny Fixed} {
    set opts $::fontOptions($name)
    font create font_$name \
      -family [lindex $opts 0] -size [lindex $opts 1] \
      -weight [lindex $opts 2] -slant [lindex $opts 3]
  }

  set fontsize [font configure font_Regular -size]
  set font [font configure font_Regular -family]
  font create font_Bold -family $font -size $fontsize -weight bold
  font create font_BoldItalic -family $font -size $fontsize -weight bold -slant italic
  font create font_Italic -family $font -size $fontsize -slant italic
  font create font_H1 -family $font -size [expr {$fontsize + 8} ] -weight bold
  font create font_H2 -family $font -size [expr {$fontsize + 6} ] -weight bold
  font create font_H3 -family $font -size [expr {$fontsize + 4} ] -weight bold
  font create font_H4 -family $font -size [expr {$fontsize + 2} ] -weight bold
  font create font_H5 -family $font -size [expr {$fontsize + 0} ] -weight bold

  set fontsize [font configure font_Small -size]
  set font [font configure font_Small -family]
  font create font_SmallBold -family $font -size $fontsize -weight bold
  font create font_SmallItalic -family $font -size $fontsize -slant italic
}
createFonts

# Load theme
ttk::style theme use $::lookTheme

# Use default font everywhere
ttk::style configure TLabel -font font_Regular
ttk::style configure TButton -font font_Regular
ttk::style configure TRadiobutton -font font_Regular
ttk::style configure TCheckbutton -font font_Regular
ttk::style configure TMenubutton -font font_Regular
ttk::style configure TCombobox -font font_Regular
ttk::style configure TEntry -font font_Regular
ttk::style configure TNotebook.Tab -font font_Regular

# Style definitions
ttk::style configure Bold.TCheckbutton -font font_Bold
ttk::style configure Small.TCheckbutton -font font_Small

ttk::style configure Small.TButton -font font_Small
ttk::style configure Bold.TButton -font font_Bold
ttk::style configure Pad0.Small.TButton -padding 0

ttk::style configure Small.TRadiobutton -font font_Small
ttk::style configure Regular.TRadiobutton -font font_Regular
ttk::style configure Bold.TRadiobutton -font font_Bold
ttk::style configure SmallBold.TRadiobutton -font font_SmallBold

ttk::style configure pad0.TMenubutton -padding 0 -indicatorwidth 0 -indicatorheight 0  -font font_Small

# font_Regular is the default font for widgets:
option add *Font font_Regular

# Use font_Menu for menu entries:
option add *Menu*Font font_Menu

proc InitImg {} {
	global scidImgDir boardStyle boardStyles textureSquare

	#Set app icon
	set scidIconFile [file nativename [file join $scidImgDir "scid.gif"]]
	if {[file readable $scidIconFile]} {
		wm iconphoto . -default [image create photo -file "$scidIconFile"]
	}

	#Load all img/buttons/_filename_.gif
	set dname [file join $::scidImgDir buttons]
	foreach {fname} [glob -directory $dname *.gif] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -file $fname
	}

	#Load all img/buttons/_filename_.png
	set dname [file join $::scidImgDir buttons]
	foreach {fname} [glob -directory $dname *.png] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -format png -file $fname
	}

	#Load all img/boards/_filename_.gif
	set textureSquare {}
	set dname [file join $::scidImgDir boards]
	foreach {fname} [glob -directory $dname *.gif] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -file $fname
		if {[string range $iname end-1 end] == "-l"} {
			lappend textureSquare [string range $iname 0 end-2]
		}
	}
	
	#Search available piece sets
	set boardStyles {}
	set dname [file join $::scidImgDir pieces]
	foreach {piecetype} [glob -directory $dname *] {
		if {[file isdirectory $piecetype] == 1} {
			lappend boardStyles [file tail $piecetype]
		}
	}

	#Load all img/flags/_filename_.gif
	set dname [file join $::scidImgDir flags]
	foreach {fname} [glob -directory $dname *.gif] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -file $fname
	}
}
if {[catch {InitImg}]} {
	tk_messageBox -type ok -icon error -title "Scid: Error" \
		-message "Cannot load images.\n$::errorCode\n\n$::errorInfo"
	exit
}

# Set numeric format
sc_info decimal $::locale(numeric)

# Start in the clipbase, if no database is loaded at startup.
set ::clipbase_db [sc_info clipbase]
sc_base switch $::clipbase_db
set ::curr_db [sc_base current]


set tcl_files {
language.tcl
errors.tcl
utils.tcl
utils/date.tcl
utils/font.tcl
utils/graph.tcl
utils/history.tcl
utils/pane.tcl
utils/sound.tcl
utils/string.tcl
utils/tooltip.tcl
utils/validate.tcl
utils/win.tcl
misc/misc.tcl
htext.tcl
file.tcl
file/finder.tcl
file/bookmark.tcl
file/recent.tcl
file/spellchk.tcl
file/maint.tcl
edit.tcl
game.tcl
game/browser.tcl
windows.tcl
windows/gamelist.tcl
windows/pgn.tcl
windows/book.tcl
windows/comment.tcl
windows/eco.tcl
windows/stats.tcl
windows/tree.tcl
windows/crosstab.tcl
windows/pfinder.tcl
windows/tourney.tcl
windows/switcher.tcl
search/search.tcl
search/board.tcl
search/header.tcl
search/material.tcl
contrib/ezsmtp/ezsmtp.tcl
tools/email.tcl
tools/import.tcl
tools/optable.tcl
tools/preport.tcl
tools/pinfo.tcl
tools/analysis.tcl
tools/wbdetect.tcl
tools/graphs.tcl
tools/tablebase.tcl
tools/ptracker.tcl
help/help.tcl
help/tips.tcl
keyboard.tcl
menus.tcl
board.tcl
move.tcl
main.tcl
tools/correspondence.tcl
tools/uci.tcl
end.tcl
tools/tacgame.tcl
tools/sergame.tcl
tools/calvar.tcl
tools/fics.tcl
tools/opening.tcl
tools/tactics.tcl
tools/reviewgame.tcl
utils/metadata.tcl
tools/inputengine.tcl
tools/novag.tcl
utils/bibliography.tcl
}

foreach f $tcl_files {
    source [file nativename [file join $::scidTclDir "$f"]]
}

###
### End of file: start.tcl
