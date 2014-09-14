# Copyright (C) 1999-2004 Shane Hudson
# Copyright (C) 2006-2009 Pascal Georges
# Copyright (C) 2008-2011 Alexander Wagner
# Copyright (C) 2013-2014 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# Scid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Scid.  If not, see <http://www.gnu.org/licenses/>.

###
### main.tcl: Routines for creating and updating the main window.
###

############################################################
# Keyboard move entry:
#   Handles letters, digits and BackSpace/Delete keys.
#   Note that king- and queen-side castling moves are denoted
#   "OK" and "OQ" respectively.
#   The letters n, r, q, k, o and l are promoted to uppercase
#   automatically. A "b" can match to a b-pawn or Bishop move,
#   so in some rare cases, a capital B may be needed for the
#   Bishop move to distinguish it from the pawn move.

set moveEntry(Text) ""
set moveEntry(List) {}

# Bind Alt+letter key to nothing, to stop Alt+letter from
# matching the move entry bindings, so Alt+letter ONLY invokes
# the menus:
foreach key {a b c d e f g h i j k l m n o p q r s t u v w x y z} {
    bind $dot_w <Alt-$key> {
        # nothing
    }
}

proc moveEntry_Clear {} {
    global moveEntry
    set moveEntry(Text) ""
    set moveEntry(List) {}
}

proc moveEntry_Complete {} {
    global moveEntry
    set len [llength $moveEntry(List)]
    if {$len > 0} {
        set move [lindex $moveEntry(List) 0]
        if {$move == "OK"} { set move "O-O" }
        if {$move == "OQ"} { set move "O-O-O" }
        moveEntry_Clear
        addSanMove $move
    }
}

proc moveEntry_Backspace {} {
    global moveEntry
    set moveEntry(Text) [string range $moveEntry(Text) 0 \
            [expr {[string length $moveEntry(Text)] - 2}]]
    set moveEntry(List) [sc_pos matchMoves $moveEntry(Text) $moveEntry(Coord)]
    updateStatusBar
}

proc moveEntry_Char {ch} {
    global moveEntry
    set oldMoveText $moveEntry(Text)
    set oldMoveList $moveEntry(List)
    append moveEntry(Text) $ch
    set moveEntry(List) [sc_pos matchMoves $moveEntry(Text) $moveEntry(Coord)]
    set len [llength $moveEntry(List)]
    if {$len == 0} {
        # No matching moves, so do not accept this character as input:
        set moveEntry(Text) $oldMoveText
        set moveEntry(List) $oldMoveList
    } elseif {$len == 1} {
        # Exactly one matching move, so make it if AutoExpand is on,
        # or if it equals the move entered. Note the comparison is
        # case insensitive to allow for 'b' to match both pawn and
        # Bishop moves.
        set move [string tolower [lindex $moveEntry(List) 0]]
        
        if {$moveEntry(AutoExpand) > 0  ||
            ![string compare [string tolower $moveEntry(Text)] $move]} {
            return [moveEntry_Complete]
        }
    } elseif {$len == 2} {
        # Check for the special case where the user has entered a b-pawn
        # capture that clashes with a Bishop move (e.g. bxc4 and Bxc4):
        set first [string tolower [lindex $moveEntry(List) 0]]
        set second [string tolower [lindex $moveEntry(List) 1]]
        if {[string equal $first $second]} {
            set moveEntry(List) [list $moveEntry(Text)]
            return [moveEntry_Complete]
        }
    }
    updateStatusBar
}

# updateTitle:
#   Updates the main Scid window title.
#
proc updateTitle {} {
    set title "Scid - "
    set fname [sc_base filename]
    set fname [file tail $fname]
    append title "$fname ($::tr(game) "
    append title "[::utils::thousands [sc_game number]] / "
    append title "[::utils::thousands [sc_base numGames]])"
    ::setTitle . $title
    set white [sc_game info white]
    set black [sc_game info black]
    if {[string length $white] > 2 &&  [string length $black] > 2} {
        if {$fname == {[clipbase]} } { set fname clipbase }
        set altered ""
        if {[sc_game altered]} { set altered "*" }
        ::setTitle .main "($fname$altered): $white -- $black"
    } else {
        ::setTitle .main $title
    }
}

# updateStatusBar:
#   Updates the main Scid window status bar.
#
proc updateStatusBar {} {
    # Check if translations have not been set up yet:
    if {! [info exists ::tr(Database)]} { return }

    if {[info exists ::guessedAddMove]} {
        set ::gameLastMove [lindex $::guessedAddMove 1]
        ::board::setInfoAlert .main.board [lindex $::guessedAddMove 0] "\[click to change\]" "blue" ".main.menuaddchoice"
        unset ::guessedAddMove
        return
    }

    global moveEntry
    if {$moveEntry(Text) != ""} {
        set msg "\[ $moveEntry(Text) \]  "
        foreach thisMove $moveEntry(List) {
            append msg "$thisMove "
        }
        ::board::setInfoAlert .main.board "Enter Move:" "$msg" "blue" ""
        return
    }

    set comment [sc_pos getComment]
    # remove technical comments, notify only human readable ones
    regsub -all {\[%.*\]} $comment {} comment

    if {$comment != ""} {
        ::board::setInfoAlert .main.board "Comment:" "$comment" "green" "makeCommentWin"
        return
    }
    

    set statusBar ""
    set move [sc_game info previousMoveNT]
    if {$move != ""} {
      regsub {K} $move "\u2654" move
      regsub {Q} $move "\u2655" move
      regsub {R} $move "\u2656" move
      regsub {B} $move "\u2657" move
      regsub {N} $move "\u2658" move
      set number "[sc_pos moveNumber]"
      if {[sc_pos side] == "white"} {
        incr number -1
        append number ".."
      }
      append statusBar "Last move"
      if {[sc_var level] != 0} { append statusBar " (var)" }
      append statusBar ": $number.$move\n"
    }

    set result [sc_game info result]
    if {$result == "=-="} { set result "\u00BD-\u00BD" }
    append statusBar "[sc_game info date] - [sc_game info event] ($result)"
    ::board::setInfo .main.board "$statusBar"
}

proc updateMainToolbar {} {


#TODO: properly group toolbar code
# bind .main.fbutton.button.end <Button-$::MB3> ::tactics::findBestMove
# button .main.fbutton.button.comment -image tb_comment_unavail -command {makeCommentWin}
# button .main.fbutton.button.autoplay -image tb_play -command toggleAutoplay
# button .main.fbutton.button.trial -image tb_trial -command {setTrialMode toggle}

  if {[sc_pos isAt start]} {
    ::board::setButtonCmd .main.board back ""
    catch { unset ::gameInfoBar(tb_BD_Start) }
  } else {
    ::board::setButtonCmd .main.board back "::move::Back"
    set ::gameInfoBar(tb_BD_Start) "::move::Start"
  }
  if {[sc_pos isAt end] || [sc_pos isAt vend]} {
    ::board::setButtonCmd .main.board forward ""
    catch { unset ::gameInfoBar(tb_BD_End) }
  } else {
    ::board::setButtonCmd .main.board forward "::move::Forward"
    set ::gameInfoBar(tb_BD_End) "::move::End"
  }

  if {[sc_var level] == 0} {
    catch { unset ::gameInfoBar(tb_BD_VarDelete) }
    catch { unset ::gameInfoBar(tb_BD_VarPromote) }
    catch { unset ::gameInfoBar(tb_BD_VarLeave) }
    catch { unset ::gameInfoBar(tb_BD_BackToMainline) }
  } else {
    set ::gameInfoBar(tb_BD_VarDelete) { ::pgn::deleteVar [sc_var number] }
    set ::gameInfoBar(tb_BD_VarPromote) { ::pgn::mainVar }
    set ::gameInfoBar(tb_BD_VarLeave) { ::move::ExitVar }
    set ::gameInfoBar(tb_BD_BackToMainline) { while {[sc_var level] != 0} {::move::ExitVar} }
  }

  if {[sc_game altered] && ![sc_base isReadOnly [sc_base current] ]} {
    set ::gameInfoBar(tb_BD_Save) "gameReplace"
  } else {
    catch { unset ::gameInfoBar(tb_BD_Save) }
  }
  set ::gameInfoBar(tb_BD_SaveAs) "gameSave 0"

  if {[sc_game undo size] > 0} {
    set ::gameInfoBar(tb_BD_Undo) "undoFeature undo"
    set ::gameInfoBar(tb_BD_Revert) "::game::Reload"
  } else {
    catch { unset ::gameInfoBar(tb_BD_Undo) }
    catch { unset ::gameInfoBar(tb_BD_Revert) }
  }
  if {[sc_game redo size] > 0} {
    set ::gameInfoBar(tb_BD_Redo) "undoFeature redo"
  } else {
    catch { unset ::gameInfoBar(tb_BD_Redo) }
  }

  if {[::game::Hprev_btnstate] == "normal"} {
    set ::gameInfoBar(tb_BD_HPrev) "::game::LoadHistory -1"
  } else {
    catch { unset ::gameInfoBar(tb_BD_HPrev) }
  }
  if {[::game::Hnext_btnstate] == "normal"} {
    set ::gameInfoBar(tb_BD_HNext) "::game::LoadHistory +1"
  } else {
    catch { unset ::gameInfoBar(tb_BD_HNext) }
  }

return
    updateVarMenus

    wm withdraw .tooltip
    set comment [sc_pos getComment]
    # remove technical comments, notify only human readable ones
    regsub -all {\[%.*\]} $comment {} comment
    if {$comment != ""} {
         .main.fbutton.button.comment configure -image tb_comment_avail -relief flat
         ::utils::tooltip::Set .main.fbutton.button.comment $comment
    } else {
         .main.fbutton.button.comment configure -image tb_comment_unavail -relief flat
         ::utils::tooltip::UnSet .main.fbutton.button.comment
    }
}



proc toggleRotateBoard {} {
    ::board::flip .main.board
}




############################################################
### The board:

proc toggleShowMaterial {} {
    if { $::gameInfo(showMaterial) } {
        grid configure .main.board.mat
    } else  {
        grid remove .main.board.mat
    }
    updateBoard
}

# MouseWheel in main window:
proc main_mousewheelHandler {direction} {
    if {$direction < 0} {
        ::move::Back
    } else {
        ::move::Forward
    }
}

# setBoard:
#   Resets the squares of the board according to the board string
#   "boardStr" and the piece bitmap size "psize".
#
proc setBoard {board boardStr psize {rotated 0}} {
    for {set i 0} { $i < 64 } { incr i } {
        if {$rotated > 0} {
            set piece [string index $boardStr [expr {63 - $i}]]
        } else {
            set piece [ string index $boardStr $i ]
        }
        $board.$i configure -image $::board::letterToPiece($piece)$psize
    }
}

################################################################################
# added by Pascal Georges
# returns a list of num moves from main line following current position
################################################################################
proc getNextMoves { {num 4} } {
    set tmp ""
    set count 0
    while { [sc_game info nextMove] != "" && $count < $num} {
        append tmp " [sc_game info nextMove]"
        sc_move forward
        incr count
    }
    sc_move back $count
    return $tmp
}
################################################################################
# displays a box with main line and variations for easy selection with keyboard
################################################################################
proc showVars {} {
    if {$::autoplayMode == 1} { return }
    
    # No need to display an empty menu
    if {[sc_var count] == 0} {
        return
    }
    
    if {[sc_var count] == 1 &&  [sc_game info nextMove] == ""} {
        # There is only one variation and no main line, so enter it
        sc_var moveInto 0
        updateBoard
        return
    }

    set w .variations
    if {[winfo exists $w]} { return }
    
    set varList [sc_var list]
    set numVars [sc_var count]
    
    # Present a menu of the possible variations
    toplevel $w
    ::setTitle $w $::tr(Variations)
    setWinLocation $w
    set h [expr $numVars + 1]
    if { $h> 19} { set h 19 }
    listbox $w.lbVar -selectmode browse -height $h -width 20
    pack $w.lbVar -expand yes -fill both -side top
    
    #insert main line
    set move [sc_game info nextMove]
    if {$move == ""} {
        set move "($::tr(empty))"
    } else  {
        $w.lbVar insert end "0: [getNextMoves 5]"
    }
    
    # insert variations
    for {set i 0} {$i < $numVars} {incr i} {
        set move [::trans [lindex $varList $i]]
        if {$move == ""} {
            set move "($::tr(empty))"
        } else  {
            sc_var moveInto $i
            append move [getNextMoves 5]
            sc_var exit
        }
        set str "[expr {$i + 1}]: $move"
        $w.lbVar insert end $str
    }
    $w.lbVar selection set 0
    # bindings
    bind $w <Configure> "recordWinSize $w"
    bind .variations <Return> {catch { event generate .variations <Right> } }
    bind .variations <ButtonRelease-1> {catch { event generate .variations <Right> } }
    bind .variations <Right> {
        set cur [.variations.lbVar curselection]
        destroy .variations
        if {$cur == 0} {
            sc_move forward; updateBoard -animate
        } else  {
            sc_var moveInto [expr $cur - 1]; updateBoard -animate
        }
    }
    bind .variations <Up> { set cur [.variations.lbVar curselection] ; .variations.lbVar selection clear $cur
        set sel [expr $cur - 1]
        if {$sel < 0} { set sel 0 }
        .variations.lbVar selection set $sel ; .variations.lbVar see $sel}
    bind .variations <Down> { set cur [.variations.lbVar curselection] ; .variations.lbVar selection clear $cur
        set sel [expr $cur + 1]
        if {$sel >= [.variations.lbVar index end]} { set sel end }
        .variations.lbVar selection set $sel ; .variations.lbVar see $sel}
    bind .variations <Left> { destroy .variations }
    bind .variations <Escape> { catch { event generate .variations <Destroy> } }
    # in order to have the window always on top : this does not really work ...
    bind .variations <Visibility> {
        if { "%s" != "VisibilityUnobscured" } {
            focus .variations
            raise .variations
        }
    }
    bind .variations <FocusOut> {
        focus .variations
        raise .variations
    }
    
    # Needed or the main window loses the focus
    if { $::docking::USE_DOCKING } {
        bind .variations <Destroy> { focus -force .main }
    }

    catch { focus .variations }
    catch { grab $w }
    update
}
################################################################################
#
################################################################################

# updateBoard:
#    Updates the main board.
#    If a parameter "-pgn" is specified, the PGN text is also regenerated.
#    If a parameter "-animate" is specified, board changes are animated.
#
proc updateBoard {args} {
    set pgnNeedsUpdate 0
    set animate 0
    foreach arg $args {
        if {! [string compare $arg "-pgn"]} { set pgnNeedsUpdate 1 }
        if {! [string compare $arg "-animate"]} { set animate 1 }
    }

    if {$pgnNeedsUpdate} { ::pgn::Refresh $pgnNeedsUpdate }

    ::board::resize .main.board $::boardSize
    ::board::setmarks .main.board [sc_pos getComment]
    ::board::update .main.board [sc_pos board] $animate

    after cancel ::notify::PosChanged
    update idletasks
    after idle ::notify::PosChanged
}


# updateGameInfo:
#    Update the game status window .main.gameInfo
#
proc updateGameInfo {} {
    global gameInfo

    .main.gameInfo configure -state normal
    .main.gameInfo delete 0.0 end
    ::htext::display .main.gameInfo [sc_game info -hide $gameInfo(hideNextMove) \
            -material $gameInfo(showMaterial) \
            -cfull $gameInfo(fullComment) \
            -fen $gameInfo(showFEN) -tb $gameInfo(showTB)]
    if {$gameInfo(wrap)} {
        .main.gameInfo configure -wrap word
        .main.gameInfo tag configure wrap -lmargin2 10
        .main.gameInfo tag add wrap 1.0 end
    } else {
        .main.gameInfo configure -wrap none
    }
    .main.gameInfo configure -state disabled
    updatePlayerPhotos
}

# readPhotoFile executed once at startup for each SPF file. Loads SPI file if it exists.
# Otherwise it generates index information and tries to write SPI file to disk (if it can be done)
proc readPhotoFile {fname} {
    global photobegin
    global photosize
    global spffile
    set count 0
    set writespi 0
    
    if {! [regsub {\.spf$} $fname {.spi} spi]} {
        # How does it happend?
        return
    }
    
    # If SPI file was found then just source it and exit
    if { [file readable $spi]} {
        set count [array size spffile]
        source $spi
        set newcount [array size spffile]
        if {[expr $newcount - $count] > 0} {
            ::splash::add "Found [expr $newcount - $count] player photos in [file tail $fname]"
            ::splash::add "Loading information from index file [file tail $spi]"
            return
        }
    }
    
    # Check for the absence of the SPI file and check for the write permissions
    if { ![file exists $spi] && ![catch {open $spi w} fd_spi]} {
        # SPI file will be written to disk by scid
        set writespi 1
    }
    
    if {! [file readable $fname]} { return }
    
    set fd [open $fname]
    while {[gets $fd line] >= 0} {
        # search for the string      photo "Player Name"
        if { [regexp {^photo \"(.*)\" \{$} $line -> name] } {
            set count [expr $count + 1 ]
            set begin [tell $fd]
            # skip data block
            while {1} {
                set end [tell $fd]
                gets $fd line
                if {[regexp {.*\}.*} $line ]} {break}
            }
            set trimname [trimString $name]
            set size [expr $end - $begin ]
            set photobegin($trimname) $begin
            set photosize($trimname) $size
            set spffile($trimname) $fname
            if { $writespi } {
                # writing SPI file to disk
                puts $fd_spi "set \"photobegin($trimname)\" $begin"
                puts $fd_spi "set \"photosize($trimname)\" $size"
                puts $fd_spi "set \"spffile($trimname)\" \"\$fname\""
            }
        }
    }
    if {$count > 0 && $writespi} {
        ::splash::add "Found $count player photos in [file tail $fname]"
        ::splash::add "Index file [file tail $spi] was generated succesfully"
    }
    if {$count > 0 && !$writespi} {
        ::splash::add "Found $count player photos in [file tail $fname]"
        ::splash::add "Could not generate index file [file tail $spi]"
        ::splash::add "Use spf2spi script to generate [file tail $spi] file "
    }
    
    if { $writespi } { close $fd_spi }
    close $fd
}


#convert $data string tolower case and strip the first two blanks.
proc trimString {data} {
    set data [string tolower $data]
    set strindex [string first "\ " $data]
    set data [string replace $data $strindex $strindex]
    set strindex [string first "\ " $data]
    set data [string replace $data $strindex $strindex]
    return $data
}


# retrieve photo from the SPF file using index information
proc getphoto {name} {
    global photobegin
    global photosize
    global spffile
    set data ""
    if {[info exists spffile($name)]} {
        set fd [open $spffile($name)]
        seek $fd $photobegin($name) start
        set data [read $fd $photosize($name) ]
        close $fd
    }
    return $data
}

proc addPhotoAlias {aliasname name} {
    global photobegin
    global photosize
    global spffile
    global droppedaliases
    if {[info exists spffile([trimString $name])]} {
        set photobegin([trimString $aliasname]) $photobegin([trimString $name])
        set photosize([trimString $aliasname]) $photosize([trimString $name])
        set spffile([trimString $aliasname]) $spffile([trimString $name])
    } else {
        set droppedaliases [expr $droppedaliases + 1 ]
    }
}

# photobegin($name) - file offset of the photo for the player $name
# photobegin($name) - size (in bytes) of the photo for the player $name
# spffile($name) - location of the SPF file where photo for the player $name is stored
array set photobegin {}
array set photosize {}
array set spffile {}

# variable droppedaliases counts the number of the dropped aliases.
# Alias is dropped if the player hasn't photo.
set droppedaliases 0

# Directories where Scid searches for the photo files
set photodirs [list $scidDataDir $scidUserDir $scidConfigDir [file join $scidShareDir "photos"]]

# Read all Scid photo (*.spf) files in the Scid data/user/config directories:
foreach dir $photodirs {
    foreach photofile [glob -nocomplain -directory $dir "*.spf"] {
        readPhotoFile $photofile
    }
}

# Read all Scid photo aliases (*.spa)
foreach dir $photodirs {
    foreach spa [glob -nocomplain -directory $dir "*.spa"] {
        if {! [file readable $spa]} { return }
        set count [array size spffile]
        set droppedcount $droppedaliases
        source $spa
        set newcount [array size spffile]
        set newdroppedcount $droppedaliases
        if {[expr $newcount - $count] > 0} {
            ::splash::add "Found [expr $newcount - $count] player aliases in [file tail $spa]"
        }
        if {[expr $newdroppedcount - $droppedcount] > 0} {
            ::splash::add "Dropped [expr $newdroppedcount - $droppedcount] player aliases in [file tail $spa]"
        }
    }
}


set photo(oldWhite) {}
set photo(oldBlack) {}

# Try to change the engine name: ignore version number, try to ignore blanks
proc trimEngineName { engine } {
    global spffile
    set engine [sc_name retrievename $engine]
    
    set engine [string tolower $engine]
    
    if { [string first "deep " $engine] == 0 } {
        # strip "deep "
        set engine [string range $engine 5 end]
    }
    # delete two first blank to make "The King" same as "TheKing"
    # or "Green Light Chess" as "Greenlightchess"
    set strindex [string first "\ " $engine]
    set engine [string replace $engine $strindex $strindex]
    set strindex [string first "\ " $engine]
    set engine [string replace $engine $strindex $strindex]
    set strindex [string first "," $engine]
    set slen [string len $engine]
    if { $strindex == -1 && $slen > 2 } {
        #seems to be a engine name:
        # search until longest name matches an engine name
        set slen [string len $engine]
        for { set strindex $slen} {![info exists spffile([string range $engine 0 $strindex])]\
                    && $strindex > 2 } {set strindex [expr {$strindex - 1}] } { }
        set engine [string range $engine 0 $strindex]
    }
    return $engine
}

# updatePlayerPhotos
#   Updates the player photos in the game information area
#   for the two players of the current game.
#
proc updatePlayerPhotos {{force ""}} {
    global photo
    global spffile
    if {$force == "-force"} {
        # Force update even if it seems unnecessary. This is done
        # when the user selects to show or hide the photos.
        set photo(oldWhite) {}
        set photo(oldBlack) {}
        place forget .main.photoW
        place forget .main.photoB
    }
    if {! $::gameInfo(photos)} { return }
    #get photo from player
    set white [sc_game info white]
    set black [sc_game info black]
    
    catch { set white [trimEngineName $white] }
    catch { set black [trimEngineName $black] }
    
    if {$black != $photo(oldBlack)} {
        set photo(oldBlack) $black
        place forget .main.photoB
        if {[info exists spffile($black)]} {
            image create photo photoB -data [getphoto $black ]
            .main.photoB configure -image photoB -anchor ne
            place .main.photoB -in .main.gameInfo -x -1 -relx 1.0 -anchor ne
            # force to update white, black size could be changed
            set photo(oldWhite) {}
        }
    }
    set distance [expr {[image width photoB] + 2}]
    if { $distance < 10 } { set distance 82 }
    if {$white != $photo(oldWhite)} {
        set photo(oldWhite) $white
        place forget .main.photoW
        if {[info exists spffile($white)]} {
            image create photo photoW -data [getphoto $white ]
            .main.photoW configure -image photoW -anchor ne
            place .main.photoW -in .main.gameInfo -x -$distance -relx 1.0 -anchor ne
        }
    }
    bind .main.photoW <ButtonPress-1> "togglePhotosSize"
    bind .main.photoB <ButtonPress-1> "togglePhotosSize"
    set ::photosMinimized 0
}
################################################################################
# Toggles photo sizes
################################################################################
set photosMinimized 0
proc togglePhotosSize {} {
    set distance [expr {[image width photoB] + 2}]
    if { $distance < 10 } { set distance 82 }
    
    if {$::photosMinimized} {
        set ::photosMinimized 0
        if { [winfo ismapped .main.photoW] } {
            place .main.photoW -in .main.gameInfo -x -$distance -relx 1.0 -relheight 1 -width [image width photoW] -anchor ne
        }
        if { [winfo ismapped .main.photoB] } {
            place .main.photoB -in .main.gameInfo -x -1 -relx 1.0 -relheight 1 -width [image width photoB] -anchor ne
        }
    } else  {
        set ::photosMinimized 1
        if { [winfo ismapped .main.photoW] } {
            place .main.photoW -in .main.gameInfo -x -17 -relx 1.0 -relheight 0.15 -width 15 -anchor ne
        }
        if { [winfo ismapped .main.photoB] } {
            place .main.photoB -in .main.gameInfo -x -1 -relx 1.0  -relheight 0.15 -width 15 -anchor ne
        }
    }
    
}
#########################################################
### Chess move input

# Globals for mouse-based move input:

set selectedSq -1
set bestSq -1

set EMPTY 0
set KING 1
set QUEEN 2
set ROOK 3
set BISHOP 4
set KNIGHT 5
set PAWN 6

################################################################################
#
################################################################################
proc getPromoPiece {} {
    set w .promoWin
    set ::result 2
    toplevel $w
    # wm transient $w .main
    ::setTitle $w "Scid"
    wm resizable $w 0 0
    set col "w"
    if { [sc_pos side] == "black" } { set col "b" }
    ttk::button $w.bq -image ${col}q45 -command "set ::result 2 ; destroy $w"
    ttk::button $w.br -image ${col}r45 -command "set ::result 3 ; destroy $w"
    ttk::button $w.bb -image ${col}b45 -command "set ::result 4 ; destroy $w"
    ttk::button $w.bn -image ${col}n45 -command "set ::result 5 ; destroy $w"
    pack $w.bq $w.br $w.bb $w.bn -side left
    bind $w <Escape> "set ::result 2 ; destroy $w"
    bind $w <Return> "set ::result 2 ; destroy $w"
    update
    catch { grab $w }
    tkwait window $w
    return $::result
}

# confirmReplaceMove:
#   Asks the user what to do when adding a move when a move already
#   exists.
#   Returns a string value:
#      "replace" to replace the move, truncating the game.
#      "var" to add the move as a new variation.
#      "cancel" to do nothing.
#

proc confirmReplaceMove {} {
    if {[winfo exists $::reviewgame::window]} {
        return "var"
    }
    if {! $::askToReplaceMoves || $::trialMode} {
        return "replace"
    }

    option add *Dialog.msg.wrapLength 4i interactive
    catch {tk_dialog .dialog "Scid: $::tr(ReplaceMove)?" \
                $::tr(ReplaceMoveMessage) "" 0 \
                $::tr(ReplaceMove) $::tr(NewMainLine) \
                $::tr(AddNewVar) [tr EditTrial] \
                $::tr(Cancel)} answer
    option add *Dialog.msg.wrapLength 3i interactive
    if {$answer == 0} { return "replace" }
    if {$answer == 1} { return "mainline" }
    if {$answer == 2} { return "var" }
    if {$answer == 3} { setTrialMode 1; return "replace" }
    return "cancel"
}

proc addNullMove {} {
    addMove null null
}

proc addMove { sq1 sq2 } {
    global EMPTY
    set nullmove 0
    if {$sq1 == "null"  &&  $sq2 == "null"} { set nullmove 1 }
    if {!$nullmove  &&  [sc_pos isLegal $sq1 $sq2] == 0} {
        # Illegal move, but if it is King takes king then treat it as
        # entering a null move:
        set board [sc_pos board]
        set k1 [string tolower [string index $board $sq1]]
        set k2 [string tolower [string index $board $sq2]]
        if {$k1 == "k"  &&  $k2 == "k"} { set nullmove 1 } else { return }
    }
    if {$nullmove} {
        if {[sc_pos isCheck]} { return }
        set moveUCI "0000"
    } else {
        set moveUCI [::board::san $sq2][::board::san $sq1]
    }
    addMoveUCI $moveUCI
}

proc addSanMove { {san} } {
    set err [catch { sc_game SANtoUCI $san } moveUCI ]
    if {! $err} { addMoveUCI $moveUCI }
    return $err
}

# addMoveUCI:
#   Adds the move indicated if it is legal.
#   If the move is a promotion, getPromoPiece will be called
#   to get the promotion piece from the user.
#   The move will be animated.
#
proc addMoveUCI {{moveUCI} {action ""}} {
    set sq1 [::board::sq [string range $moveUCI 0 1] ]
    set sq2 [::board::sq [string range $moveUCI 2 3] ]
    if { [::fics::setPremove $sq1 $sq2] || ! [::fics::playerCanMove] || ! [::reviewgame::playerCanMove]} { return } ;# not player's turn

    if { [string length $moveUCI] == 4 && $sq1 != $sq2 && [sc_pos isPromotion $sq1 $sq2] } {
        switch -- [getPromoPiece] {
            2 { set promoLetter "q"}
            3 { set promoLetter "r"}
            4 { set promoLetter "b"}
            5 { set promoLetter "n"}
            default {set promoLetter ""}
        }
        append moveUCI $promoLetter
    }

    if {! $::annotateMode} {
        if {[::move::Follow $moveUCI]} { return [updateBoard -animate] }
    }


    if {![sc_pos isAt vend]} {
        if {$action == ""} {
            set replacedmove ""
            set n [sc_var count]
            if {$n == 0} {
                sc_move forward
                if {[sc_pos isAt vend]} {
                    set replacedmove [sc_game info previousMoveNT]
                }
                sc_move back
            }
            if {$replacedmove != ""} {
                set ::guessedAddMove [list "Replaced Move $replacedmove"]
            } else {
                set action "var"
            }
        }

        switch -- $action {
            mainline { set ::guessedAddMove [list "New Main Line"]}
            var      { set ::guessedAddMove [list "New Variation"]}
            replace  { set ::guessedAddMove [list "Replaced Main Line"]}
        }
        lappend ::guessedAddMove $moveUCI
    }

    undoFeature save
    if {[winfo exists .commentWin]} {
        ::commenteditor::storeComment
        .commentWin.cf.text delete 0.0 end
    }
    if {($action == "mainline" || $action == "var") && ![sc_pos isAt vend]} {
        sc_var create
    }

    if {$moveUCI == "0000"} {
        sc_move addSan null
    } else {
        sc_move addUCI $moveUCI
    }
    if {$action == "mainline"} {
        sc_var promote
        sc_move forward 1
    }

    set ::sergame::lastPlayerMoveUci ""
    if {[winfo exists ".serGameWin"]} {
        set ::sergame::lastPlayerMoveUci "$moveUCI"
    }

    if {[winfo exists .fics]} {
        if { [::fics::playerCanMove] } {
            if { [string length $moveUCI] == 5 } {
                set promoletter [ string tolower [ string index $moveuci end ] ]
                ::fics::writechan "promote $promoletter"
            }
            ::fics::writechan [ string range [sc_game info previousMoveUCI] 0 3 ]
        }
    }

    if {$::novag::connected} {
        ::novag::addMove "$moveUCI"
    }

    set san [sc_game info previous]
    after idle [list ::utils::sound::AnnounceNewMove $san]

    updateBoard -pgn -animate
}

# enterSquare:
#   Called when the mouse pointer enters a board square.
#   Finds the best matching square for a move (if there is a
#   legal move to or from this square), and colors the squares
#   to indicate the suggested move.
#
proc enterSquare { square } {	
    global bestSq bestcolor selectedSq suggestMoves
    if {$selectedSq == -1} {
        set bestSq -1
        if {$suggestMoves && [expr {abs($::fics::playing) != 1}]} {
            set bestSq [sc_pos bestSquare $square]
            if {$bestSq != -1} {
                ::board::colorSquare .main.board $square $bestcolor
                ::board::colorSquare .main.board $bestSq $bestcolor        
            }
        }
    }
}

# leaveSquare:
#    Called when the mouse pointer leaves a board square.
#    Recolors squares to normal (lite/dark) color.
#
proc leaveSquare { square } {
    global selectedSq bestSq
    if {$selectedSq == -1} {
        ::board::colorSquare .main.board $bestSq
        ::board::colorSquare .main.board $square  
    }
}

# pressSquare:
#    Called when the left mouse button is pressed on a square. Sets
#    that square to be the selected square.
#
proc pressSquare { square } {
    global selectedSq highcolor
    
    if { ![::fics::playerCanMove] || ![::reviewgame::playerCanMove] } { return } ;# not player's turn
    
    # if training with calculations of var is on, just log the event
    if { [winfo exists .calvarWin] } {
        ::calvar::pressSquare $square
        return
    }
    
    if {$selectedSq == -1} {
        set selectedSq $square
        ::board::colorSquare .main.board $square $highcolor
        # Drag this piece if it is the same color as the side to move:
        set c [string index [sc_pos side] 0]  ;# will be "w" or "b"
        set p [string index [::board::piece .main.board $square] 0] ;# "w", "b" or "e"
        if {$c == $p} {
            ::board::setDragSquare .main.board $square
        }
    } else {
        ::board::setDragSquare .main.board -1
        ::board::colorSquare .main.board $selectedSq
        ::board::colorSquare .main.board $square
        if {$square != $selectedSq} {
            addMove $square $selectedSq
        }
        set selectedSq -1
        enterSquare $square
    }
}

# releaseSquare:
#   Called when the left mouse button is released over a square.
#   If the square is different to that the button was pressed on, it
#   is a dragged move; otherwise it is just selecting this square as
#   part of a move.
#
proc releaseSquare { w x y } {
    if { [winfo exists .calvarWin] } { return }
    
    global selectedSq bestSq
    
    ::board::setDragSquare $w -1
    set square [::board::getSquare $w $x $y]
    if {$square < 0} {
        set selectedSq -1
        return
    }

    if {$square == $selectedSq} {
        if {$::suggestMoves} {
            # User pressed and released on same square, so make the
            # suggested move if there is one:
            set selectedSq -1
            ::board::colorSquare $w $bestSq
            ::board::colorSquare $w $square
            addMove $square $bestSq
            enterSquare $square
        } else {
            # Current square is the square user pressed the button on,
            # so we do nothing.
        }
    } else {
        # User has dragged to another square, so try to add this as a move:
        addMove $square $selectedSq
        ::board::colorSquare $w $selectedSq
        set selectedSq -1
        ::board::colorSquare $w $square
    }
}


# backSquare:
#    Handles the retracting of a move (when the right mouse button is
#    clicked on a square). Recolors squares to normal color also.
#    If the move is the last in the game or variation, is is removed
#    by truncating the game after retracting the move.
#
proc backSquare {} {
    global selectedSq bestSq
    set lastMoveInLine 0
    if {[sc_pos isAt vend]} {
        set lastMoveInLine 1
    }
    sc_move back
    
    # RMB used to delete the move if it was the last in a line. Removed it as there is no undo.
    # if {[sc_pos isAt vstart] && [sc_var level] != 0} {
    # ::pgn::deleteVar [sc_var number]
    # } elseif {$lastMoveInLine} {
    # sc_game truncate
    # }
    
    set selectedSq -1
    set bestSq -1
    # update the board without -pgn option because of poor performance with long games
    updateBoard -animate
    ::utils::sound::AnnounceBack
}


##
## Auto-playing of moves:
##
set autoplayMode 0

set tempdelay 0
trace variable tempdelay w {::utils::validate::Regexp {^[0-9]*\.?[0-9]*$}}
# ################################################################################
# Set the delay between moves in options menu
################################################################################
proc setAutoplayDelay {} {
    global autoplayDelay tempdelay
    set tempdelay [expr {$autoplayDelay / 1000.0}]
    set w .apdialog
    if { [winfo exists $w] } { focus $w ; return }
    toplevel $w
    ::setTitle $w "Scid"
    wm resizable $w 0 0
    ttk::label $w.label -text $::tr(AnnotateTime:)
    pack $w.label -side top -pady 5 -padx 5
    spinbox $w.spDelay -background white -width 4 -textvariable tempdelay -from 1 -to 300 -increment 1
    pack $w.spDelay -side top -pady 5
    
    set b [ttk::frame $w.buttons]
    pack $b -side top -fill x
    ttk::button $b.cancel -text $::tr(Cancel) -command {
        destroy .apdialog
        focus .
    }
    ttk::button $b.ok -text "OK" -command {
        if {$tempdelay < 0.1} { set tempdelay 0.1 }
        set autoplayDelay [expr {int($tempdelay * 1000)}]
        destroy .apdialog
        focus .
    }
    pack $b.cancel $b.ok -side right -padx 5 -pady 5
    bind $w <Escape> { .apdialog.buttons.cancel invoke }
    bind $w <Return> { .apdialog.buttons.ok invoke }
    focus $w.spDelay
}
################################################################################
#
################################################################################
proc toggleAutoplay { } {
    global autoplayMode autoplayDelay
    if {$autoplayMode == 0} {
        set autoplayMode 1
        # Change the autoplay icon in the main window
        #
        # Start with some delay
        # Only to spawn the autoplay on a new thread
        #
        after 500 autoplay
    } else {
        cancelAutoplay
    }
}

################################################################################
#
################################################################################
proc autoplay {} {
    global autoplayDelay autoplayMode annotateMode analysis
    
    # Was autoplay stopped by the user since the last time the timer ran out?
    # If so, silently exit this handler
    #
    if { $autoplayMode == 0 } {
        return
    }
    
    # Add annotation if needed
    #
    if { $annotateMode } {
        addAnnotation
    }
    
    if { $::initialAnalysis } {
        # Stop analysis if it is running
        # We do not want initial super-accuracy
        #
        stopEngineAnalysis 1
        set annotateMode 1
        # First do the book analysis (if this is configured)
        # The latter condition is handled by the operation itself
        set ::wentOutOfBook 0
        bookAnnotation 1
        # Start the engine
        startEngineAnalysis 1 1
    
    # Autoplay comes in two flavours:
    # + It can run through a game, with or without annotation
    # + It can be annotating just opening sections of games
    # See if such streak ends here and now
    #
    } elseif { [sc_pos isAt end] || ($annotateMode && $::isBatchOpening && ([sc_pos moveNumber] > $::isBatchOpeningMoves)) } {
        
        # Stop the engine
        #
        stopEngineAnalysis 1
        
        # Are we running a batch analysis?
        #
        if { $annotateMode && $::isBatch } {
            # First replace the game we just finished
            #
            set gameNo [sc_game number]
            if { $gameNo != 0 } {
                sc_game save $gameNo
            }
            
            # See if we must advance to the next game
            #
            if { $gameNo < $::batchEnd } {
                incr gameNo
                sc_game load $gameNo
                updateTitle
                updateBoard -pgn
                # First do book analysis
                #
                set ::wentOutOfBook 0
                bookAnnotation 1
                # Start with initial assessment of the position
                #
                set ::initialAnalysis 1
                # Start the engine
                #
                startEngineAnalysis 1 1
            } else {
                # End of batch, stop
                #
                cancelAutoplay
                return
            }
        } else {
            # Not in a batch, just stop
            #
            cancelAutoplay
            return
        }
    } elseif { $annotateMode && $::isAnnotateVar } {
        # A construction to prune empty variations here and now
        # It makes no sense to discover only after some engine
        # time that we entered a dead end.
        #
        set emptyVar 1
        while { $emptyVar } {
            set emptyVar 0
            # Are we at the end of a variation?
            # If so, pop back into the parent
            #
            if { [sc_pos isAt vend] } {
                sc_var exit
                set lastVar [::popAnalysisData]
            } else {
                set lastVar [sc_var count]
            }
            # Is there a subvariation here?
            # If so, enter it after pushing where we are
            #
            if { $lastVar > 0 } {
                incr lastVar -1
                sc_var enter $lastVar
                ::pushAnalysisData $lastVar
                # Check if this line is empty
                # If so, we will pop back immediately in the next run
                #
                if { [sc_pos isAt vstart] && [sc_pos isAt vend] } {
                    set emptyVar 1
                } else {
                    # We are in a new line!
                    # Tell the annotator (he might be interested)
                    #
                    updateBoard -pgn
                    set ::atStartOfLine 1
                }
            } else {
                # Just move ahead following the current line
                #
                ::move::Forward
            }
        }
    } else {
        # Just move ahead following the main line
        #
        ::move::Forward
    }
    
    # Respawn
    #
    after $autoplayDelay autoplay
}
################################################################################
#
################################################################################
proc cancelAutoplay {} {
    global autoplayMode annotateMode annotateModeButtonValue
    set autoplayMode 0
    set annotateMode 0
    set annotateModeButtonValue 0
    after cancel autoplay
}
################################################################################
#
################################################################################

bind $dot_w <Return> {
    if {[winfo exists .analysisWin1] && $analysis(analyzeMode1)} {
        .analysisWin1.b1.move invoke
    }
}

bind $dot_w <Escape> cancelAutoplay

set trialMode 0

proc setTrialMode {mode} {
    global trialMode
    if {$mode == "toggle"} {
        set mode [expr {1 - $trialMode}]
    }
    if {$mode == $trialMode} { return }
    if {$mode == "update"} { set mode $trialMode }
    
    if {$mode == 1} {
        set trialMode 1
        sc_game push copy
        .main.fbutton.button.trial configure -image tb_trial_on
    } else {
        set trialMode 0
        sc_game pop
        .main.fbutton.button.trial configure -image tb_trial
    }
    updateBoard -pgn
}

proc undoFeature {action} {
    if {! $::trialMode} {
        if {$action == "save"} {
            sc_game undoPoint
        } elseif {$action == "undo"} {
            sc_game undo
            notify::GameChanged
        } elseif {$action == "redo"} {
            sc_game redo
            notify::GameChanged
        }
    }
}

################################################################################
# In docked mode, resize board automatically
################################################################################
proc resizeMainBoard {} {
  if { ! $::docking::USE_DOCKING } { return }

  if { $::autoResizeBoard } {
    update idletasks
    set availw [ expr [winfo width .main.board] - [winfo reqwidth .main.board] ]
    set availh [ lindex [grid bbox .main 0 4] 3]
    if {$availh == 0} { set availh [expr 1 + [winfo height .fdockmain] - [lindex [grid bbox .main] 3] ] }

    set oldSize [::board::size .main.board]
    if {$availh < $availw} {
      set maxSize [ expr $oldSize + $availh / 8]
    } else  {
      set maxSize [ expr $oldSize + $availw / 8]
    }

    set newSize [lindex $::boardSizes 0]
    foreach size $::boardSizes {
      if {$size > $maxSize} { break; }
      set newSize $size
    }

    if {$newSize != $oldSize} {
      set restore_bind "bind .main <Configure> [bind .main <Configure>]"
      bind .main <Configure> {}
      ::board::resize2 .main.board $newSize
      set ::boardSize [::board::size .main.board]
      update idletasks
      after idle "$restore_bind"
    }
  }
}
################################################################################
# sets visibility of gameInfo panel at the bottom of main board
proc toggleGameInfo {} {
  if {$::showGameInfo} {
    grid .main.gameInfoFrame -row 3 -column 0 -sticky nsew
  } else  {
    grid forget .main.gameInfoFrame
  }
  updateGameInfo
  update idletasks
}
################################################################################

proc CreateMainWin { {w} } {
  setTitle $w [ ::tr "Board" ]
  standardShortcuts $w

  ::board::new $w.board $::boardSize
  ::board::showMarks $w.board 1
  if {$::boardCoords} { ::board::coords $w.board }

  ::board::addNamesBar $w.board gamePlayers
  ::board::addInfoBar $w.board gameInfoBar

  menu .main.menuaddchoice -bg white -font font_Regular
  .main.menuaddchoice add command -label " Undo" -image tb_BD_Undo -compound left \
      -command {undoFeature undo}
  .main.menuaddchoice add command -label " $::tr(ReplaceMove)" -image tb_BD_Replace -compound left \
      -command {sc_game undo; addMoveUCI $::gameLastMove replace}
  .main.menuaddchoice add command -label " $::tr(NewMainLine)" -image tb_BD_NewMainline -compound left \
      -command {sc_game undo; addMoveUCI $::gameLastMove mainline}
  .main.menuaddchoice add command -label " $::tr(AddNewVar)" -image tb_BD_NewVar -compound left \
      -command {sc_game undo; addMoveUCI $::gameLastMove var}

  InitToolbar .main.tb

  for {set i 0} { $i < 64 } { incr i } {
    ::board::bind $w.board $i <Enter> "enterSquare $i"
    ::board::bind $w.board $i <Leave> "leaveSquare $i"
    ::board::bind $w.board $i <ButtonPress-1> "pressSquare $i"
    ::board::bind $w.board $i <Control-ButtonPress-1> "drawArrow $i green"
    ::board::bind $w.board $i <Control-ButtonPress-$::MB2> "drawArrow $i yellow"
    ::board::bind $w.board $i <Control-ButtonPress-$::MB3> "drawArrow $i red"
    ::board::bind $w.board $i <Shift-ButtonPress-1> "addMarker $i green"
    ::board::bind $w.board $i <Shift-ButtonPress-$::MB2> "addMarker $i yellow"
    ::board::bind $w.board $i <Shift-ButtonPress-$::MB3> "addMarker $i red"
    ::board::bind $w.board $i <B1-Motion> "::board::dragPiece $w.board %X %Y"
    ::board::bind $w.board $i <ButtonRelease-1> "releaseSquare $w.board %X %Y"
    ::board::bind $w.board $i <ButtonPress-$::MB3> backSquare
  }

  foreach i {o q r n k O Q R B N K} {
    bind $w <$i> "moveEntry_Char [string toupper $i]"
  }
  foreach i {a b c d e f g h 1 2 3 4 5 6 7 8} {
    bind $w <Key-$i> "moveEntry_Char $i"
  }

  bind $w <Control-BackSpace> backSquare
  bind $w <Control-Delete> backSquare
  bind $w <BackSpace> moveEntry_Backspace
  bind $w <Delete> moveEntry_Backspace
  bind $w <space> moveEntry_Complete
  bind $w <ButtonRelease> "focus $w"
  bind $w <Configure> { ::resizeMainBoard }
  bindMouseWheel $w "main_mousewheelHandler"

  if { $::docking::USE_DOCKING} {
    ttk::frame $w.space
    grid $w.space -row 4 -column 0 -columnspan 3 -sticky nsew
    grid rowconfigure $w 3 -weight 0
    grid rowconfigure $w 4 -weight 1
  } else {
    grid rowconfigure $w 3 -weight 1
    wm resizable $w 0 1
    wm withdraw .
    bind $w <Destroy> { destroy . }
  }
  grid columnconfigure $w 0 -weight 1
  grid $w.board -row 2 -column 0 -sticky we ;# -padx 5 -pady 5

  toggleGameInfo
  updateBoard
}


# .gameInfo is the game information widget:
#
autoscrollframe .main.gameInfoFrame text .main.gameInfo
.main.gameInfo configure -width 20 -height 6 -fg black -bg white -wrap none -state disabled -cursor top_left_arrow -setgrid 1
::htext::init .main.gameInfo

# Set up player photos:
image create photo photoW
image create photo photoB
label .main.photoW -background white -image photoW -anchor ne
label .main.photoB -background white -image photoB -anchor ne

# Right-mouse button menu for gameInfo frame:
menu .main.gameInfo.menu -tearoff 0

.main.gameInfo.menu add checkbutton -label GInfoHideNext \
        -variable gameInfo(hideNextMove) -offvalue 0 -onvalue 1 -command updateBoard

.main.gameInfo.menu add checkbutton -label GInfoMaterial -variable gameInfo(showMaterial) -offvalue 0 -onvalue 1 \
        -command { toggleShowMaterial }

.main.gameInfo.menu add checkbutton -label GInfoFEN \
        -variable gameInfo(showFEN) -offvalue 0 -onvalue 1 -command updateBoard

.main.gameInfo.menu add checkbutton -label GInfoMarks \
        -variable gameInfo(showMarks) -offvalue 0 -onvalue 1 -command updateBoard

.main.gameInfo.menu add checkbutton -label GInfoWrap \
        -variable gameInfo(wrap) -offvalue 0 -onvalue 1 -command updateBoard

.main.gameInfo.menu add checkbutton -label GInfoFullComment \
        -variable gameInfo(fullComment) -offvalue 0 -onvalue 1 -command updateBoard

.main.gameInfo.menu add checkbutton -label GInfoPhotos \
        -variable gameInfo(photos) -offvalue 0 -onvalue 1 \
        -command {updatePlayerPhotos -force}

.main.gameInfo.menu add separator

.main.gameInfo.menu add radiobutton -label GInfoTBNothing \
        -variable gameInfo(showTB) -value 0 -command updateBoard

.main.gameInfo.menu add radiobutton -label GInfoTBResult \
        -variable gameInfo(showTB) -value 1 -command updateBoard

.main.gameInfo.menu add radiobutton -label GInfoTBAll \
        -variable gameInfo(showTB) -value 2 -command updateBoard

.main.gameInfo.menu add separator

.main.gameInfo.menu add command -label GInfoDelete -command {
    sc_base gameflag [sc_base current] [sc_game number] invert del
    ::notify::DatabaseModified [sc_base current]
}

.main.gameInfo.menu add cascade -label GInfoMark -menu .main.gameInfo.menu.mark
menu .main.gameInfo.menu.mark
foreach flag $maintFlaglist {
    .main.gameInfo.menu.mark add command -label "" -command "
    sc_base gameflag \[sc_base current\] \[sc_game number\] invert $flag
    ::notify::DatabaseModified [sc_base current]
    "
}

bind .main.gameInfo <ButtonPress-$::MB3> "tk_popup .main.gameInfo.menu %X %Y"
# alternate code that may work better on MacOS ?
# bind .main.gameInfo <ButtonPress-$::MB3> ".main.gameInfo.menu post %X %Y"
bind $dot_w <F9> "tk_popup .main.gameInfo.menu %X %Y"

proc InitToolbar {{tb}} {
	ttk::frame $tb -relief raised -border 1
	button $tb.new -image tb_new -command ::file::New
	button .main.tb.open -image tb_open -command ::file::Open
	button .main.tb.save -image tb_save -command {
	  if {[sc_game number] != 0} {
		#busyCursor .
		gameReplace
		# catch {.save.buttons.save invoke}
		#unbusyCursor .
	  } else {
		gameAdd
	  }
	}
	button .main.tb.close -image tb_close -command ::file::Close
	button .main.tb.finder -image tb_finder -command ::file::finder::Open
	menubutton .main.tb.bkm -image tb_bkm -menu .main.tb.bkm.menu
	menu .main.tb.bkm.menu
	bind .main.tb.bkm <ButtonPress-1> "+.main.tb.bkm configure -relief flat"

	ttk::frame .main.tb.space1 -width 12
	button .main.tb.cut -image tb_cut -command ::game::Clear
	button .main.tb.copy -image tb_copy -command ::gameAddToClipbase
	button .main.tb.paste -image tb_paste \
		-command {catch {sc_clipbase paste}; updateBoard -pgn}
	ttk::frame .main.tb.space2 -width 12
	button .main.tb.gprev -image tb_gprev -command {::game::LoadNextPrev previous}
	button .main.tb.gnext -image tb_gnext -command {::game::LoadNextPrev next}
	ttk::frame .main.tb.space3 -width 12
	button .main.tb.rfilter -image tb_rfilter -command ::search::filter::reset
	button .main.tb.bsearch -image tb_bsearch -command ::search::board
	button .main.tb.hsearch -image tb_hsearch -command ::search::header
	button .main.tb.msearch -image tb_msearch -command ::search::material
	ttk::frame .main.tb.space4 -width 12
	button .main.tb.switcher -image tb_switcher -command ::windows::switcher::Open
	button .main.tb.glist -image tb_glist -command ::windows::gamelist::Open
	button .main.tb.pgn -image tb_pgn -command ::pgn::OpenClose
	button .main.tb.tmt -image tb_tmt -command ::tourney::toggle
	button .main.tb.maint -image tb_maint -command ::maint::OpenClose
	button .main.tb.eco -image tb_eco -command ::windows::eco::OpenClose
	button .main.tb.tree -image tb_tree -command ::tree::make
	button .main.tb.crosst -image tb_crosst -command toggleCrosstabWin
	button .main.tb.engine -image tb_engine -command makeAnalysisWin
	button .main.tb.help -image tb_help -command {helpWindow Index}

	foreach i {new open save close finder bkm cut copy paste gprev gnext \
		  rfilter bsearch hsearch msearch \
		  switcher glist pgn tmt maint eco tree crosst engine help} {
	  .main.tb.$i configure -takefocus 0 -relief flat -border 1 -anchor n -highlightthickness 0
	  bind .main.tb.$i <Any-Enter> "+.main.tb.$i configure -relief groove"
	  bind .main.tb.$i <Any-Leave> "+.main.tb.$i configure -relief flat; statusBarRestore %W; break"
	}

	# Set toolbar help status messages:
	foreach {b m} {
	  new FileNew open FileOpen finder FileFinder
	  save GameReplace close FileClose bkm FileBookmarks
	  gprev GamePrev gnext GameNext
	  cut GameNew copy EditCopy paste EditPaste
	  bsearch SearchCurrent
	  hsearch SearchHeader msearch SearchMaterial
	  switcher WindowsSwitcher glist WindowsGList pgn WindowsPGN tmt WindowsTmt
	  maint WindowsMaint eco WindowsECO tree WindowsTree crosst ToolsCross
	  engine ToolsAnalysis
	} {
	  set helpMessage(.main.tb.$b) $m
	  # ::utils::tooltip::Set $tb.$b $m
	}
	set helpMessage(.main.fbutton.button.addVar) EditAdd
	set helpMessage(.main.fbutton.button.trial) EditTrial
	redrawToolbar
}

proc configToolbar {} {
  set w .tbconfig
  toplevel $w
  wm title $w "Scid: [tr OptionsToolbar]"

  array set ::toolbar_temp [array get ::toolbar]
  pack [ttk::frame $w.f1] -side top -fill x
  foreach i {new open save close finder bkm} {
    checkbutton $w.f1.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f1.$i -side left -ipadx 2 -ipady 2
  }
  pack [ttk::frame $w.f2] -side top -fill x
  foreach i {gprev gnext} {
    checkbutton $w.f2.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f2.$i -side left -ipadx 1 -ipady 1
  }
  pack [ttk::frame $w.f3] -side top -fill x
  foreach i {cut copy paste} {
    checkbutton $w.f3.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f3.$i -side left -ipadx 1 -ipady 1
  }
  pack [ttk::frame $w.f4] -side top -fill x
  foreach i {bsearch hsearch msearch} {
    checkbutton $w.f4.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f4.$i -side left -ipadx 1 -ipady 1
  }
  pack [ttk::frame $w.f5] -side top -fill x
  foreach i {switcher glist pgn tmt maint eco tree crosst engine} {
    checkbutton $w.f5.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f5.$i -side left -ipadx 1 -ipady 1
  }

  addHorizontalRule $w
  pack [ttk::frame $w.b] -side bottom -fill x
  button $w.on -text "+ [::utils::string::Capital $::tr(all)]" -command {
    foreach i [array names toolbar_temp] { set toolbar_temp($i) 1 }
  }
  button $w.off -text "- [::utils::string::Capital $::tr(all)]" -command {
    foreach i [array names toolbar_temp] { set toolbar_temp($i) 0 }
  }
  ttk::button $w.ok -text "OK" -command {
    array set toolbar [array get toolbar_temp]
    catch {grab release .tbconfig}
    destroy .tbconfig
    redrawToolbar
  }
  ttk::button $w.cancel -text $::tr(Cancel) \
      -command "catch {grab release $w}; destroy $w"
  pack $w.cancel $w.ok -side right -padx 2
  pack $w.on $w.off -side left -padx 2
  catch {grab $w}
}

proc redrawToolbar {} {
  global toolbar
  foreach i [winfo children .main.tb] { pack forget $i }
  set seenAny 0
  set seen 0
  foreach i {new open save close finder bkm} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .main.tb.space1 -side left }
  set seen 0
  foreach i {gprev gnext} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .main.tb.space2 -side left }
  set seen 0
  foreach i {cut copy paste} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .main.tb.space3 -side left }
  set seen 0
  foreach i {bsearch hsearch msearch} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .main.tb.space4 -side left }
  set seen 0
  foreach i {switcher glist pgn tmt maint eco tree crosst engine} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seenAny} {
    grid .main.tb -row 0 -column 0 -columnspan 3 -sticky we
  } else {
    grid forget .main.tb
  }
}

proc setToolbar {x} {
  if {$x} {
    grid .main.tb -row 0 -column 0 -columnspan 3 -sticky we
  } else {
    grid forget .main.tb
  }
}

##############################
