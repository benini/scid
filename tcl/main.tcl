###
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
  bind . <Alt-$key> {
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
    if {$moveEntry(AutoExpand)} {
      # Play a bell sound to let the user know the move was accepted already,
      # but only if move announcement is off?
      # bell
    }
    set move [lindex $moveEntry(List) 0]
    if {$move == "OK"} { set move "O-O" }
    if {$move == "OQ"} { set move "O-O-O" }
    set action "replace"
    if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
    if {$action == "replace"} {
      sc_move addSan $move
    } elseif {$action == "var"} {
      sc_var create
      sc_move addSan $move
    } elseif {$action == "mainline"} {
      sc_var create
      sc_move addSan $move
      sc_var exit
      sc_var promote [expr {[sc_var count] - 1}]
      sc_move forward 1
    }
    moveEntry_Clear
    updateBoard -pgn -animate
    ::utils::sound::AnnounceNewMove $move
    if {$action == "replace"} { ::tree::doTraining }
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
      moveEntry_Complete
    }
  } elseif {$len == 2} {
    # Check for the special case where the user has entered a b-pawn
    # capture that clashes with a Bishop move (e.g. bxc4 and Bxc4):
    set first [string tolower [lindex $moveEntry(List) 0]]
    set second [string tolower [lindex $moveEntry(List) 1]]
    if {[string equal $first $second]} {
      set moveEntry(List) [list $moveEntry(Text)]
      moveEntry_Complete
    }
  }
  updateStatusBar
}

# preMoveCommand: called before making a move to store text in the comment
#   editor window and EPD windows.
proc preMoveCommand {} {
  resetAnalysis
  ::commenteditor::storeComment
  storeEpdTexts
}

sc_info preMoveCmd preMoveCommand


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
  wm title . $title
}

# updateStatusBar:
#   Updates the main Scid window status bar.
#
proc updateStatusBar {} {
  global statusBar moveEntry
  ::windows::switcher::Refresh
  ::maint::Refresh
  set statusBar "  "
  
  if {$moveEntry(Text) != ""} {
    append statusBar "Enter move: \[" $moveEntry(Text) "\]  "
    foreach thisMove $moveEntry(List) {
      append statusBar $thisMove " "
    }
    return
  }
  
  # Check if translations have not been set up yet:
  if {! [info exists ::tr(Database)]} { return }
  
  # Show "%%" if base is read-only, "XX" if game altered, "--" otherwise:
  if {[sc_base isReadOnly]} {
    append statusBar "%%"
  } elseif {[sc_game altered]} {
    append statusBar "XX"
  } else {
    append statusBar "--"
  }
  
  set current [sc_base current]
  append statusBar "  $::tr(Database)"
  if {$current != [sc_info clipbase]} {
    append statusBar " $current"
  }
  append statusBar ": "
  set fname [sc_base filename]
  set fname [file tail $fname]
  if {$fname == ""} { set fname "<none>" }
  append statusBar $fname
  
  # Show filter count:
  append statusBar "   $::tr(Filter)"
  append statusBar ": [filterText]"
}


proc toggleRotateBoard {} {
  ::board::flip .board
}

proc toggleCoords {} {
  global boardCoords
  set coords [expr {1 + $boardCoords} ]
  if { $coords > 2 } { set coords 0 }
  set boardCoords $coords
  ::board::coords .board
}

frame .button.space3 -width 15
button .button.flip -image tb_flip -takefocus 0 \
    -command "::board::flip .board"

button .button.coords -image tb_coords -takefocus 0 -command toggleCoords
bind . <KeyPress-0> toggleCoords

button .button.stm -image tb_stm -takefocus 0 -command toggleSTM

proc toggleSTM {} {
  global boardSTM
  set boardSTM [expr {1 - $boardSTM} ]
  ::board::stm .board
}

image create photo autoplay_off -data {
  R0lGODdhFAAUAKEAANnZ2QAAAFFR+wAAACwAAAAAFAAUAAACMYSPqbvBb4JLsto7D94StowI
  IgOG4ugd55oC6+u98iPXSz0r+Enjcf7jtVyoofGoKAAAOw==
}

image create photo autoplay_on -data {
  R0lGODdhFAAUAKEAAP//4AAAAPoTQAAAACwAAAAAFAAUAAACMYSPqbvBb4JLsto7D94StowI
  IgOG4ugd55oC6+u98iPXSz0r+Enjcf7jtVyoofGoKAAAOw==
}

image create photo engine_on -data {
  R0lGODlhGAAYAOf4AFFOdGdOTQBk9AVi9ItNEVhVfAVt8FVafwRt91ZbgGhZYVdcgZNTEF1a
  gVtghV1ih15iiGNjg2ZmhlJrpDB01mdnhxV8+J9iFV1rm2lpimZqkGpqi2trjG1tjm5uj7Fl
  CnBwkXFxkrZpAXJyk2Z2oDeB6nNzlHR0lXV1lnZ2l3B4pDKI+LBwJTSJ+Xx4lHl5mjaK+nN7
  p356l397mIB8mYF9mpF8ebx6KECS+4KGoYOHooaKpUmZ/IeLplSW+2KU5omMp8qFK4uOqZmN
  jXSUz4yPqo2Qq1Ki/tCKKJKSqFOj/9mLGFSk/5+Tk5WVq1+j+5SXs2Ck/JeXrZWYtGGl/ZiY
  ruGRFFqq/3Sj5JqasGSn/+WUBpycspSfuWet/o2i05+ftqCgt42l0Gqv/2uw/6OiuYyp2aSj
  up+mu3Sx/YGv8KamvPSgDaqmt+iiJZ6qxG+3/3ez/6unuHC4/3i0/6mpv4mx7JOw4e6mH8Op
  iKurwXq6/5ez13u7/328/7Guv7KvwKizzrOwwYa9/YDC/6W40Za76+6uQYe//4HD/7ezxIjA
  /8Kzrpi+7bm1xrq2yIrF/ru3ybO60IvG/7y4yrS70ajA37i8zI7I/7K92LO+2Y/K/7q+zr+8
  zZbK/rvAz5DO/5HP/6XJ7L/D0pnO//zASZnR/sHF1aTO95rS/8LG1pvT/77K2MfI0p3V/8XJ
  2cLK36LV/L7N4aPW/crL1aXX/7zQ6cjN3KbY/83N1/TLeKfa/87O2c/Q2qfe/q7b/dDR26jf
  /9HS3Kng/9LT3avi/8vX5f/Yb7Pl/7Tm/7Xn/7ro/Lvp/b3q/vzhkL/s/8Tt/PnjpMXu/cbv
  /sfw/8jx//7ti8nz/8n2/cr3/9D1/tzw/dbz/sv5/9H2/9f0/9n1/9T5/9r2/9v3/9L8/efz
  /9/4/dr7/uH5/tz9/+j5/93//+n6/+L//er7/+j+/f/9xu/8/en//uv///H+//L///n///7/
  /P///////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JFJgFzCdH
  fwYqXKgwh5M3sri5s1eOFa1ODBnWCJOkWjVw6tTF2wbrVsaFNYRg8ugNHbpx4LTJonRyIAlM
  ppA9q8at2rdnzZDlwnjSA5FFoHAla7YTaLJfgUyezFCCDqZauIYpe7bs165Vd4QpOpkCAQIL
  POjMGePlCp1FntS8EnQSggELMLSM6bNoUZ8xT5RgaaXnZAQKJXy89YQL16o+dJR84SSnJoQf
  XkgNexYuXLdfnvpIAlPznwYMaoZVI9cOXbpmsQy1Kf1vgQYVw7ylu2dv3jRRVeoAol17RIou
  tyqhqZJERy8gNqzQbmAix4wkRlz868BhSBA30mlDR8jgwcNABSx0WcMTnrhCAh/YOINnrb17
  gfBLzQd//z0b/evZdx988tHX33si6BdNHgcORAAbh9yQRYMKBQAAhScFBAA7
}

image create photo engine_off -data {
  R0lGODlhGAAYAOfyAOYFO+YGQOgINugJPOcKQVFOdOkOPeAUOWdOTeAUPgBk9AVi9LUpUuEX
  P+AXRItNEeIZQM8hTVhVfOIaRdgeTAVt8FVafwRt9+IdS+UeQuQeR2hZYVdcgZNTEN4nUFtg
  hdUrWM8vVuEqTV5iiOEqUmNjg+MtVGZmhlJrpNY2WjB01mdnhxV8+OYwVp9iFd81WV1rm2lp
  iqtNcd82X2pqi2trjMlCdG1tjm5uj7FlCuQ8Y+Y9X3BwkbZpAb5NhWZ2oDeB6nNzlNxGaHR0
  ldNKdoZtj3Z2l6hdnHB4pDKI+LBwJTSJ+Xl5mjaK+nN7p356l+ROb4B8mdpWc4F9mpF8ebx6
  KECS+61wjIKGoYOHoqt1oIaKpUmZ/K12roeLplSW+2KU5omMp8qFK4uOqZmNjXSUz7J+nY2Q
  q9CKKJKSqNmLGJ+Tk5WVq8eAmV+j+8p+n8SDmpSXs2Ck/GGl/ZiYruGRFNZ/mJqasGSn/+WU
  Bpycsq+UxJ+ftqCgt42l0L6Uqmqv/9OLpGuw/6OiuaSjuqamvPSgDaqmt+iiJW+3/3ez/72b
  wXC4/3i0/6mpv4mx7NGYspOw4e6mH8OpiJWv53q6/9absLGuv7KvwKizzrOwwcSnxYa9/YDC
  /5a76+6uQYHD/4jA/8Kzrpi+7bm1xrq2yIrF/ru3ybO60IvG/7y4yqjA37i8zLK92Nmuw7O+
  2Y/K/7q+zr+8zZbK/rvAz5DO/5HP/6XJ7MW91r/D0ueyxPzASZnR/sHF1aTO95rS/5vT/8bG
  3bjM5cfI0p3V/8LK36LV/L7N4crL1aXX/6bY/83N1/TLeM7O2c/Q2qfe/q7b/dDR26jf/9HS
  3NLT3avi/8vX5f/Yb7Pl/7Tm/7Xn/7vp/eLb5/zhkL/s//njpMXu/cbv/sfw/8jx//7ti8nz
  /9bz/tH2/9f0/9n1/9v3/+fz/9/4/eH5/un6/+r7///9xu/8/f//////////////////////
  /////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JFHiHDy1S
  lwYqXKgQCxszL3TEi7cuFzJZDBlO6ZPGDoAD7ty9Q1esWcaFU8aMgiTgALd27dKNO6bq5EAn
  sHwV03DAgCtz3rxhW4bxJI4ynWxJe9PyRVBs0DKZFChAgMIVQBqlUiYthQADm6BJA+Zp2Z+W
  B6oONHKhAgs3eBq1zCAoFaWPX3suHOG2iZxGldIKOBJhQloDVa0qLKGiCZdEnWqJEJxXgAab
  I8AA8iVtnIaqaR2g4mPzXwkYjaQFa1FZyqhDpf9JuPFjMmUNt+IUwlR6QE+0gQLxDIHFWRgq
  dU4KPhBBBpYsXg/gqEFGDKLkDA+kFbiCRo0IajdFKGFGThL22FSrPshhqBs8cudjo/23fpf7
  6+j/JRb4wJD98vGdBNpA67X3Xn7bEdiDfd9Mgh5iC/X3SRV35HcSAgVYiF5AADs=
}

image create photo finish_on -data {
  R0lGODlhGAAYAOfwAJbK/np6dkJCOh4qQo62+mZmXsrKyoaGgi5Cbtra2qKinhIWSmJiWkpq
  nlp+utri8p6amiI2UjI+rkJajmJiXiY6VqaiokJiyjpSfuru+iImbl6GxnKe8ra2shIeMiYq
  eprG/mqS5iYufmqG/j5OugoODioyhkpmzkJWsvL2/jpaxsLK6jpKtkpGRlJyrl6C3mJ6/mKG
  znqq/jo2Ni4yqhYSCrrC5jpGsgoOMk5qzl6G3vb6/lJSTlp6xjI6lm6a6sbGwjI6mmKK4mJy
  ylp+2lJuzhoeGjZKdnKC0kpexjY+uuLm9m5uapKOjgYOIk5i3lJm5kpa1tLS0sbS8jI2pnqm
  +jJCttba8m6G1prK/hISDhIaKr6+viYmHgYGBmaK7qLO/kZawurq9oKy/i42qlpyzmqO8lp2
  0maO4kJSvnqi7vr6/jY+ss7O6lpWUlJy0lZ61jY6rjpCshYWDoKCfgoWJtLW8nKa8goKDnae
  9l5+1h4aGm6W6maK4lp61lJiwu7y+io6skJWvm5qaoKq8jI6qoJ+fjo+rg4OFmaG3iIeHlZy
  2rq6tkpiwv7+/j5Gvnai9gYKDt7e3n5+es7Oyubq9tbW1qLS/s7S7jZCslZyzmqK3i5GcmqK
  /jZOdhIWEl561nai/k5m0kZWxvb2+j5KtnKe+gYOFhYWFh4uRoq6/qamoj46NnJyapKSjmqO
  7l5aVjY+qmJ+2mKC2mKG3mqO4nqi9jJCdjY6sgoKEm6W8k5iylZy1kJOuk5mylJqynKa6lZu
  zjo+vtbS0p7K/vLy+kZWvjY+tk5exsK+vg4KCi46rgoOFmKC3mqS6l5+2jY+rjpGtmaK5jZC
  tl6Gyurq+lp21nKa9jI6rnai+s7OzlZy0mqO5kJCPmZmYhIWTra2tkpa2jI2qnqm/hISEiYm
  Ilpy0jpCtrq6ugYKEvb2/j5KulJqznKa7kZWwgICCv//////////////////////////////
  /////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHEiwoMGD
  BbUdgNWthTcFkhAaTDbjFCcX1DY0iOBlUAKJAidFcgAADBhbHCDJqOIJFReJFDyoApMFBIgQ
  OPm0G0etBLqDTeqMuUSMGAEhOmj1QcPNGaQYWoYVTKDsxx1CamoR2ZRhExFaifqEyDbBTUEm
  nvL0efHsmZ8pjnbIgvOsGa0QMvBQIogKGLdZevxY4/UmhSNSoN74qXsNg6GBUt6FmmWtyIkL
  F1RocuQoRZkc5kBJi8FqILhU186wwwJoiesH6jgXC+Zr2zNTewauqvCqSBIknIMLtxOmtqka
  AxkN+ILM3ZArmKKvKMa5mqA0YX7pUjTQEjMzxta1RZtmxUqgP5zFkGBBoteuHgIIlpuVBpqc
  GyyilVrjqFK0TJlAE4soRxxA0CQIjFJIHNBAI4ENjoiRyTJxiBMFFIsgIkVBnzSCSxwgknFI
  G9DQEAcVT4wAwy0UGGTBFo+wAWIcZNQIYiGdjICCER8ZFIAT5xzz4YwgYhNOEOQAIZEruYgg
  jBLHsMHGMcIc800XBoD0jzY8pLPABz6YoAEOc9ChJUEJQNAKAwVM0sGZcMYpp0ABAQA7
}

image create photo finish_off -data {
  R0lGODlhGAAYAOeVAAMDAwYGBgkJCQoKCgsLCwwMDA4ODg8PDxERERISEhQUFBUVFRYWFhkZ
  GRsbGx0dHR8fHyUlJSYmJikpKSwsLC0tLTIyMjMzMzQ0NDc3Nzk5OTs7Oz4+PkBAQEFBQUJC
  QkNDQ0REREZGRkdHR0hISElJSUpKSktLS0xMTE5OTk9PT1BQUFFRUVJSUlNTU1VVVecQOVZW
  VldXV1lZWVtbW1xcXF1dXV5eXl9fX2FhYWJiYmNjY2VlZWZmZmdnZ2hoaGlpaWpqamtra21t
  bW5ubm9vb3BwcHFxcXNzc3R0dHV1dXd3d3h4eHl5eXp6ent7e3x8fH19fX5+fn9/f4CAgIGB
  gYKCgoODg4SEhIWFhYaGhoiIiImJiYqKiouLi4yMjI2NjY6Ojo+Pj5CQkJOTk5SUlJeXl5iY
  mJqampubm5ycnJ6enp+fn6KioqOjo6WlpaampqysrLGxsbOzs7a2trq6ur6+vr+/v8DAwMHB
  wcPDw8TExMbGxsjIyMrKys7OztHR0dLS0tPT09TU1NbW1tjY2Nra2tvb297e3uHh4efn5+rq
  6uvr6+zs7O7u7vLy8vPz8/b29vn5+fr6+v7+/v//////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  /////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHEiwoMGD
  Bf9oofFhRI82iBAavJOhQIgiVar0uBBAiCGDMGAMlCLACR4+fNigWfOmzQkGdkISDAlDx4M5
  fPLcuSOmJxkzbarIBKkgTh89euRswZKFixcwY0ImEFTQEIGQcNZ8idLFUZcoWbSEXDNDRkEi
  J9SEnDLlSSBKkqg0CZlFzJsBfwgyMAPGCk0lSCJRigQFxpMpV86smDIwEAA2VpgYARKyRhJK
  IZUMUQKFy5UNA+lQOMOEyJZHikImCkkJ0pEgSaakcTAQToYwRnZoocQbM4zehXDATpNgYJ0J
  XXjYWHJokHOalBrRmIFjSBkIAwkZCGPDhYoTJkypwPjh+wWLFzF8NPFAUIKVGSRQpGABo8Uk
  SotCniAxQkgJLQRJ4cENIYhAQkh7UMLICSCEtAMRShwQSEEK8CCCCDCI0EEJgJDAgQgeBBES
  CDoY5EYD9GWoYQcdXBgCGF6E9JFBToRUwoU4urjDBwnQdBAMBGBwQgklkEBCCUM6EIEfAg01
  UEh/tDCAAxZ8oEEFCCxghUT/OGlIGkfkwIMUdHDZpJlopnlQQAA7
}

button .button.autoplay -image autoplay_off -command toggleAutoplay
button .button.trial -image tb_trial -command {setTrialMode toggle}

foreach i {start back forward end intoVar exitVar addVar autoplay \
      flip coords stm trial} {
  .button.$i configure -relief flat -border 1 -highlightthickness 0 \
      -anchor n -takefocus 0
  bind .button.$i <Any-Enter> "+.button.$i configure -relief groove"
  bind .button.$i <Any-Leave> "+.button.$i configure -relief flat; statusBarRestore %W; break"
}

pack .button.start .button.back .button.forward .button.end \
    .button.space .button.intoVar .button.exitVar .button.addVar .button.space2 \
    .button.autoplay .button.trial .button.space3 .button.flip .button.coords \
    .button.stm -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0


############################################################
### The board:

::board::new .board $boardSize "showmat"
#.board.bd configure -relief solid -border 2
::board::showMarks .board 1
if {$boardCoords} {
  ::board::coords .board
}
if {$boardSTM} {
  ::board::stm .board
}

# .gameInfo is the game information widget:
#
autoscrollframe .gameInfoFrame text .gameInfo
.gameInfo configure -width 20 -height 6 -fg black -bg white -wrap none \
    -state disabled -cursor top_left_arrow -setgrid 1
::htext::init .gameInfo

# Right-mouse button menu for gameInfo frame:
menu .gameInfo.menu -tearoff 0

.gameInfo.menu add checkbutton -label GInfoHideNext \
    -variable gameInfo(hideNextMove) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoMaterial \
    -variable gameInfo(showMaterial) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoFEN \
    -variable gameInfo(showFEN) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoMarks \
    -variable gameInfo(showMarks) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoWrap \
    -variable gameInfo(wrap) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoFullComment \
    -variable gameInfo(fullComment) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoPhotos \
    -variable gameInfo(photos) -offvalue 0 -onvalue 1 \
    -command {updatePlayerPhotos -force}

.gameInfo.menu add separator

.gameInfo.menu add radiobutton -label GInfoTBNothing \
    -variable gameInfo(showTB) -value 0 -command updateBoard

.gameInfo.menu add radiobutton -label GInfoTBResult \
    -variable gameInfo(showTB) -value 1 -command updateBoard

.gameInfo.menu add radiobutton -label GInfoTBAll \
    -variable gameInfo(showTB) -value 2 -command updateBoard

.gameInfo.menu add separator

.gameInfo.menu add command -label GInfoDelete -command {
  catch {sc_game flag delete [sc_game number] invert}
  updateBoard
  ::windows::gamelist::Refresh
}

.gameInfo.menu add cascade -label GInfoMark -menu .gameInfo.menu.mark
menu .gameInfo.menu.mark
foreach flag $maintFlaglist {
  .gameInfo.menu.mark add command -label "" -command "
  catch {sc_game flag $flag \[sc_game number\] invert}
  updateBoard
  ::windows::gamelist::Refresh
  "
}

bind .gameInfo <ButtonPress-3> "tk_popup .gameInfo.menu %X %Y"
bind . <F9> "tk_popup .gameInfo.menu %X %Y"


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

# updateVarMenus:
#   Updates the menus for moving into or deleting an existing variation.
#   Calls sc_var list and sc_var count to get the list of variations.
#
proc updateVarMenus {} {
  set varList [sc_var list]
  set numVars [sc_var count]
  .button.intoVar.menu delete 0 end
  .menu.edit.del delete 0 end
  .menu.edit.first delete 0 end
  .menu.edit.main delete 0 end
  # PG: add the move of main line
  if {$numVars > 0} {
    set move [sc_game info nextMove]
    if {$move == ""} { set move "($::tr(empty))" }
    .button.intoVar.menu add command -label "0: $move" -command "sc_move forward; updateBoard" -underline 0
  }
  for {set i 0} {$i < $numVars} {incr i} {
    set move [lindex $varList $i]
    set state normal
    if {$move == ""} {
      set move "($::tr(empty))"
      set state disabled
    }
    set str "[expr {$i + 1}]: $move"
    set commandStr "sc_var moveInto $i; updateBoard"
    if {$i < 9} {
      .button.intoVar.menu add command -label $str -command $commandStr \
          -underline 0
    } else {
      .button.intoVar.menu add command -label $str -command $commandStr
    }
    set commandStr "sc_var delete $i; updateBoard -pgn"
    .menu.edit.del add command -label $str -command $commandStr
    set commandStr "sc_var first $i; updateBoard -pgn"
    .menu.edit.first add command -label $str -command $commandStr
    set commandStr "sc_var promote $i; updateBoard -pgn"
    .menu.edit.main add command -label $str -command $commandStr \
        -state $state
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
#  Pascal Georges :
# displays a box with main line and variations for easy selection with keyboard
################################################################################
proc showVars {} {
  
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
  
  sc_info preMoveCmd {}
  
  set w .variations
  if {[winfo exists $w]} { return }
  
  set varList [sc_var list]
  set numVars [sc_var count]
  
  # Present a menu of the possible variations
  toplevel $w
  wm title $w $::tr(Variations)
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
    sc_info preMoveCmd preMoveCommand
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
  #in order to have the window always on top : this does not really work ...
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
  
  sc_info preMoveCmd preMoveCommand
  
  focus .variations
  update
  grab $w
}
################################################################################
#
################################################################################
# V and Z key bindings: move into/out of a variation.
#
bind . <KeyPress-v> { showVars }
bind . <KeyPress-z> {.button.exitVar invoke}

# editMyPlayerNames
#   Present the dialog box for editing the list of player
#   names from whose perspective the board should be shown
#   whenever a game is loaded.
#
proc editMyPlayerNames {} {
  global myPlayerNames
  set w .editMyPlayerNames
  if {[winfo exists $w]} { return }
  toplevel $w
  wm title $w "Scid: [tr OptionsBoardNames]"
  pack [frame $w.b] -side bottom -fill x
  
  autoscrollframe $w.desc text $w.desc.text \
      -foreground black -background gray90 \
      -width 50 -height 8 -wrap word -cursor top_left_arrow
  $w.desc.text insert end [string trim $::tr(MyPlayerNamesDescription)]
  $w.desc.text configure -state disabled
  pack $w.desc -side top -fill x
  autoscrollframe $w.f text $w.f.text \
      -background white -width 50 -height 10 -wrap none
  foreach name $myPlayerNames {
    $w.f.text insert end "\n\"$name\""
  }
  pack $w.f -side top -fill both -expand yes
  button $w.b.white -text $::tr(White) -command {
    .editMyPlayerNames.f.text insert end "\"[sc_game info white]\"\n"
  }
  button $w.b.black -text $::tr(Black) -command {
    .editMyPlayerNames.f.text insert end "\"[sc_game info black]\"\n"
  }
  button $w.b.help -text $::tr(Help) \
      -command {helpWindow Options MyPlayerNames}
  button $w.b.ok -text OK -command editMyPlayerNamesOK
  button $w.b.cancel -text $::tr(Cancel) -command "grab release $w; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 5 -pady 5
  pack $w.b.white $w.b.black $w.b.help -side left -padx 5 -pady 5
  grab $w
}

proc editMyPlayerNamesOK {} {
  global myPlayerNames
  set w .editMyPlayerNames
  set text [string trim [$w.f.text get 1.0 end]]
  set myPlayerNames {}
  foreach name [split $text "\n"] {
    set name [string trim $name]
    if {[string match "\"*\"" $name]} {
      set name [string trim $name "\""]
    }
    if {$name != ""} { lappend myPlayerNames $name }
  }
  grab release $w
  destroy $w
}

# flipBoardForPlayerNames
#   Check if either player in the current game has a name that matches
#   a pattern in the specified list and if so, flip the board if
#   necessary to show from that players perspective.
#
proc flipBoardForPlayerNames {namelist {board .board}} {
  set white [sc_game info white]
  set black [sc_game info black]
  foreach pattern $namelist {
    if {[string match $pattern $white]} {
      ::board::flip $board 0
      return
    }
    if {[string match $pattern $black]} {
      ::board::flip $board 1
      return
    }
  }
}

# updateBoard:
#    Updates the main board. Also updates the navigation buttons, disabling
#    those that have no effect at this point in the game.
#    Also ensure all menu settings are up to date.
#    If a parameter "-pgn" is specified, the PGN text is also regenerated.
#    If a parameter "-animate" is specified, board changes are animated.
#
proc updateBoard {args} {
  global boardSize gameInfo
  set pgnNeedsUpdate 0
  set animate 0
  foreach arg $args {
    if {! [string compare $arg "-pgn"]} { set pgnNeedsUpdate 1 }
    if {! [string compare $arg "-animate"]} { set animate 1 }
  }
  
  # Remove marked squares informations.
  # (This must be done _before_ updating the board!)
  ::board::mark::clear .board
  
  ::board::resize .board $boardSize
  ::board::update .board [sc_pos board] $animate
  ::board::material .board
  
  # Draw arrows and marks, color squares:
  
  foreach {cmd discard} [::board::mark::getEmbeddedCmds [sc_pos getComment]] {
    set type   [lindex $cmd 0]
    set square [::board::sq [lindex $cmd 1]]
    set color  [lindex $cmd end]
    if {[llength $cmd] < 4} { set cmd [linsert $cmd 2 ""] }
    set dest   [expr {[string match {[a-h][1-8]} [lindex $cmd 2]] \
          ? [::board::sq [lindex $cmd 2]] : [lindex $cmd 2]}]
    # add mark to board
    eval ::board::mark::add .board $type $square $dest $color
  }
  
  # Update the status of each navigation button:
  if {[sc_pos isAt start]} {
    .button.start configure -state disabled
  } else { .button.start configure -state normal }
  if {[sc_pos isAt end]} {
    .button.end configure -state disabled
  } else { .button.end configure -state normal }
  if {[sc_pos isAt vstart]} {
    .button.back configure -state disabled
  } else { .button.back configure -state normal }
  if {[sc_pos isAt vend]} {
    .button.forward configure -state disabled
  } else { .button.forward configure -state normal }
  # Cannot add a variation to an empty line:
  if {[sc_pos isAt vstart]  &&  [sc_pos isAt vend]} {
    .menu.edit entryconfig [tr EditAdd] -state disabled
    .button.addVar configure -state disabled
    bind . <Control-a> {}
  } else {
    .menu.edit entryconfig [tr EditAdd] -state normal
    .button.addVar configure -state normal
    bind . <Control-a> {sc_var create; updateBoard -pgn}
  }
  if {[sc_var count] == 0} {
    .button.intoVar configure -state disabled
    .menu.edit entryconfig [tr EditDelete] -state disabled
    .menu.edit entryconfig [tr EditFirst] -state disabled
    .menu.edit entryconfig [tr EditMain] -state disabled
  } else {
    .button.intoVar configure -state normal
    .menu.edit entryconfig [tr EditDelete] -state normal
    .menu.edit entryconfig [tr EditFirst] -state normal
    .menu.edit entryconfig [tr EditMain] -state normal
  }
  updateVarMenus
  if {[sc_var level] == 0} {
    .button.exitVar configure -state disabled
  } else {
    .button.exitVar configure -state normal
  }
  
  if {![sc_base inUse]  ||  $::trialMode  ||  [sc_base isReadOnly]} {
    .tb.save configure -state disabled
  } else {
    .tb.save configure -state normal
  }
  .gameInfo configure -state normal
  .gameInfo delete 0.0 end
  ::htext::display .gameInfo [sc_game info -hide $gameInfo(hideNextMove) \
      -material $gameInfo(showMaterial) \
      -cfull $gameInfo(fullComment) \
      -fen $gameInfo(showFEN) -tb $gameInfo(showTB)]
  if {$gameInfo(wrap)} {
    .gameInfo configure -wrap word
    .gameInfo tag configure wrap -lmargin2 10
    .gameInfo tag add wrap 1.0 end
  } else {
    .gameInfo configure -wrap none
  }
  .gameInfo configure -state disabled
  updatePlayerPhotos
  updateEpdWins
  if {[winfo exists .analysisWin1]} { updateAnalysis 1 }
  if {[winfo exists .analysisWin2]} { updateAnalysis 2 }
  # if {[winfo exists .treeWin]} { ::tree::refresh }
  ::tree::refresh
  if {[winfo exists .commentWin]} { ::commenteditor::Refresh }
  if {[::tb::isopen]} { ::tb::results }
  updateMenuStates
  moveEntry_Clear
  updateStatusBar
  if {[winfo exists .twinchecker]} { updateTwinChecker }
  if {[winfo exists .pgnWin]} { ::pgn::Refresh $pgnNeedsUpdate }
  if {[winfo exists .bookWin]} { ::book::refresh }
  if {[winfo exists .bookTuningWin]} { ::book::refreshTuning }
  if {[winfo exists .noveltyWin]} { updateNoveltyWin }
}

# Set up player photos:

image create photo photoW
image create photo photoB
label .photoW -background white -image photoW -anchor ne
label .photoB -background white -image photoB -anchor ne

proc readPhotoFile {fname} {
  set oldcount [array size ::photo]
  if {! [file readable $fname]} { return }
  catch {source $fname}
  set newcount [expr {[array size ::photo] - $oldcount}]
  if {$newcount > 0} {
    ::splash::add "Found $newcount player photos in [file tail $fname]"
  }
}

proc photo {player data} {
  #convert names tolower case and strip the first two blanks.
  set player [string tolower $player]
  set strindex [string first "\ " $player]
  set player [string replace $player $strindex $strindex]
  set strindex [string first "\ " $player]
  set player [string replace $player $strindex $strindex]
  set ::photo($player) $data
}

array set photo {}

# Read all Scid photo (*.spf) files in the Scid data/user/config directories:
foreach photofile [glob -nocomplain -directory $scidDataDir "*.spf"] {
  readPhotoFile $photofile
}
foreach photofile [glob -nocomplain -directory $scidUserDir "*.spf"] {
  readPhotoFile $photofile
}
foreach photofile [glob -nocomplain -directory $scidConfigDir "*.spf"] {
  readPhotoFile $photofile
}

# Read players.img for compatibility with older versions:
readPhotoFile [file join $scidUserDir players.img]

set photo(oldWhite) {}
set photo(oldBlack) {}

# Try to change the engine name: ignore version number, try to ignore blanks
proc trimEngineName { engine } {
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
    for { set strindex $slen} {![info exists ::photo([string range $engine 0 $strindex])]\
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
  if {$force == "-force"} {
    # Force update even if it seems unnecessary. This is done
    # when the user selects to show or hide the photos.
    set photo(oldWhite) {}
    set photo(oldBlack) {}
    place forget .photoW
    place forget .photoB
  }
  if {! $::gameInfo(photos)} { return }
  #get photo from player
  set white [sc_game info white]
  set black [sc_game info black]
  catch { set white [trimEngineName $white] }
  catch { set black [trimEngineName $black] }
  if {$black != $photo(oldBlack)} {
    set photo(oldBlack) $black
    place forget .photoB
    if {[info exists ::photo($black)]} {
      image create photo photoB -data $::photo($black)
      .photoB configure -image photoB -anchor ne
      place .photoB -in .gameInfo -x -1 -relx 1.0 -anchor ne
      # force to update white, black size could be changed
      set photo(oldWhite) {}
    }
  }
  set distance [expr {[image width photoB] + 2}]
  if { $distance < 10 } { set distance 82 }
  if {$white != $photo(oldWhite)} {
    set photo(oldWhite) $white
    place forget .photoW
    if {[info exists ::photo($white)]} {
      image create photo photoW -data $::photo($white)
      .photoW configure -image photoW -anchor ne
      place .photoW -in .gameInfo -x -$distance -relx 1.0 -anchor ne
    }
  }
  bind .photoW <ButtonPress-1> "togglePhotosSize"
  bind .photoB <ButtonPress-1> "togglePhotosSize"
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
    if { [winfo ismapped .photoW] } {
      place .photoW -in .gameInfo -x -$distance -relx 1.0 -relheight 1 -width [image width photoW] -anchor ne
    }
    if { [winfo ismapped .photoB] } {
      place .photoB -in .gameInfo -x -1 -relx 1.0 -relheight 1 -width [image width photoB] -anchor ne
    }
  } else  {
    set ::photosMinimized 1
    if { [winfo ismapped .photoW] } {
      place .photoW -in .gameInfo -x -17 -relx 1.0 -relheight 0.15 -width 15 -anchor ne
    }
    if { [winfo ismapped .photoB] } {
      place .photoB -in .gameInfo -x -1 -relx 1.0  -relheight 0.15 -width 15 -anchor ne
    }
  }
  
}
#########################################################
### Chess move input

# Globals for mouse-based move input:

set selectedSq -1
set currentSq -1
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
  wm transient $w .
  wm title $w "Scid"
  wm resizable $w 0 0
  set col "w"
  if { [sc_pos side] == "black" } { set col "b" }
  button $w.bq -image ${col}q45 -command "set ::result 2 ; destroy $w"
  button $w.br -image ${col}r45 -command "set ::result 3 ; destroy $w"
  button $w.bb -image ${col}b45 -command "set ::result 4 ; destroy $w"
  button $w.bn -image ${col}n45 -command "set ::result 5 ; destroy $w"
  pack $w.bq $w.br $w.bb $w.bn -side left
  bind $w <Escape> "set ::result 2 ; destroy $w"
  bind $w <Return> "set ::result 2 ; destroy $w"
  update
  grab $w
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
set addVariationWithoutAsking 0

proc confirmReplaceMove {} {
  global askToReplaceMoves trialMode
  
  if {$::addVariationWithoutAsking} { return "var" }
  
  if {! $askToReplaceMoves} { return "replace" }
  if {$trialMode} { return "replace" }
  
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

# addMove:
#   Adds the move indicated by sq1 and sq2 if it is legal. If the move
#   is a promotion, getPromoPiece will be called to get the promotion
#   piece from the user.
#   If the optional parameter is "-animate", the move will be animated.
#
proc addMove { sq1 sq2 {animate ""}} {
  if { $::fics::playing == -1} { return } ;# not player's turn
  
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
  set promo $EMPTY
  if {[sc_pos isPromotion $sq1 $sq2] == 1} {
    # sometimes, addMove is triggered twice
    if { [winfo exists .promoWin] } { return }
    set promo [getPromoPiece]
  }
  
  set promoLetter ""
  switch -- $promo {
    2 { set promoLetter "q"}
    3 { set promoLetter "r"}
    4 { set promoLetter "b"}
    5 { set promoLetter "n"}
    default {set promoLetter ""}
  }
  
  set action "replace"
  if {![sc_pos isAt vend]} {
    set action [confirmReplaceMove]
  }
  if {$action == "replace"} {
    # nothing
  } elseif {$action == "mainline" || $action == "var"} {
    sc_var create
  } else {
    # Do not add the move at all:
    return
  }
  
  if {$nullmove} {
    sc_move addSan null
  } else {
    # if {[winfo exists .commentWin]} { .commentWin.cf.text delete 0.0 end }
    set ::sergame::lastPlayerMoveUci ""
    if {[winfo exists ".serGameWin"]} {
      set ::sergame::lastPlayerMoveUci "[::board::san $sq2][::board::san $sq1]$promoLetter"
    }
    sc_move add $sq1 $sq2 $promo
    set san [sc_game info previous]
    if {$action == "mainline"} {
      sc_var exit
      sc_var promote [expr {[sc_var count] - 1}]
      sc_move forward 1
    }
    after idle [list ::utils::sound::AnnounceNewMove $san]
  }
  
  if {[winfo exists .fics]} {
    
    if { $::fics::playing == 1} {
      if { $promo != $EMPTY } {
        ::fics::writechan "promote $promoLetter"
      }
      ::fics::writechan [ string range [sc_game info previousMoveUCI] 0 3 ]
    }
    # sc_move back
    # sc_game truncatefree
  }
  
  if {$::novag::connected} {
    ::novag::addMove "[::board::san $sq2][::board::san $sq1]$promoLetter"
  }
  
  moveEntry_Clear
  updateBoard -pgn $animate
  
  ::tree::doTraining
  
}

# addSanMove
#   Like addMove above, but takes the move in SAN notation instead of
#   a pair of squares.
#
proc addSanMove {san {animate ""} {noTraining ""}} {
  set action "replace"
  if {![sc_pos isAt vend]} {
    set action [confirmReplaceMove]
  }
  if {$action == "replace"} {
    # nothing
  } elseif {$action == "var" || $action == "mainline"} {
    sc_var create
  } else {
    # Do not add the move at all:
    return
  }
  # if {[winfo exists .commentWin]} { .commentWin.cf.text delete 0.0 end }
  sc_move addSan $san
  if {$action == "mainline"} {
    sc_var exit
    sc_var promote [expr {[sc_var count] - 1}]
  }
  moveEntry_Clear
  updateBoard -pgn $animate
  ::utils::sound::AnnounceNewMove $san
  if {$noTraining != "-notraining"} {
    ::tree::doTraining
  }
}

# enterSquare:
#   Called when the mouse pointer enters a board square.
#   Finds the best matching square for a move (if there is a
#   legal move to or from this square), and colors the squares
#   to indicate the suggested move.
#
proc enterSquare { square } {
  global highcolor currentSq bestSq bestcolor selectedSq suggestMoves
  set currentSq $square
  if {$selectedSq == -1} {
    ::board::recolor .board
    set bestSq -1
    if {$suggestMoves} {
      set bestSq [sc_pos bestSquare $square]
    }
    if {[expr {$bestSq != -1}]} {
      ::board::colorSquare .board $square $bestcolor
      ::board::colorSquare .board $bestSq $bestcolor
    }
  }
}

# leaveSquare:
#    Called when the mouse pointer leaves a board square.
#    Recolors squares to normal (lite/dark) color.
#
proc leaveSquare { square } {
  global currentSq selectedSq bestSq
  #Klimmek: not needed anymore
  #  if {$square != $selectedSq} {
  #    ::board::colorSquare .board $square
  #  }
  if {$bestSq != -1} {
    #Klimmek: changed, because Scid "hangs" very often (after 5-7 moves)
    #    ::board::colorSquare .board $bestSq
    ::board::update .board
  }
}

# pressSquare:
#    Called when the left mouse button is pressed on a square. Sets
#    that square to be the selected square.
#
proc pressSquare { square } {
  if { $::fics::playing == -1} { return } ;# not player's turn
  
  # if training with calculations of var is on, just log the event
  if { [winfo exists .calvarWin] } {
    ::calvar::pressSquare $square
    return
  }
  
  global selectedSq highcolor
  if {$selectedSq == -1} {
    set selectedSq $square
    ::board::recolor .board
    ::board::colorSquare .board $square $highcolor
    # Drag this piece if it is the same color as the side to move:
    set c [string index [sc_pos side] 0]  ;# will be "w" or "b"
    set p [string index [::board::piece .board $square] 0] ;# "w", "b" or "e"
    if {$c == $p} {
      ::board::setDragSquare .board $square
    }
  } else {
    ::board::setDragSquare .board -1
    ::board::colorSquare .board $selectedSq
    ::board::colorSquare .board $square
    if {$square != $selectedSq} {
      addMove $square $selectedSq -animate
    }
    set selectedSq -1
    enterSquare $square
  }
}

# pressSquare2:
#   Called when the middle mouse button is pressed on a square. This
#   makes the suggested best move.
#
proc pressSquare2 { square } {
  if { $::fics::playing == -1} { return } ;# not player's turn
  
  global selectedSq bestSq
  ::board::colorSquare .board $bestSq
  ::board::colorSquare .board $square
  addMove $square $bestSq -animate
  enterSquare $square
}

# releaseSquare:
#   Called when the left mouse button is released over a square.
#   If the square is different to that the button was pressed on, it
#   is a dragged move; otherwise it is just selecting this square as
#   part of a move.
#
proc releaseSquare { w x y } {
  
  if { [winfo exists .calvarWin] } { return }
  
  global selectedSq bestSq currentSq
  
  ::board::setDragSquare $w -1
  set square [::board::getSquare $w $x $y]
  if {$square < 0} {
    set selectedSq -1
    ::board::recolor $w
    return
  }
  
  if {$square == $selectedSq} {
    if {$::suggestMoves} {
      # User pressed and released on same square, so make the
      # suggested move if there is one:
      set selectedSq -1
      ::board::colorSquare $w $bestSq
      ::board::colorSquare $w $square
      addMove $square $bestSq -animate
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
  if {$lastMoveInLine} {
    sc_game truncate
  }
  #Klimmek: not needed anymore, in updateBoard included
  #  ::board::colorSquare .board $selectedSq
  #  ::board::colorSquare .board $bestSq
  set selectedSq -1
  set bestSq -1
  updateBoard -pgn -animate
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
  wm title $w "Scid"
  wm resizable $w 0 0
  label $w.label -text $::tr(AnnotateTime:)
  pack $w.label -side top -pady 5 -padx 5
  spinbox $w.spDelay -background white -width 4 -textvariable tempdelay -from 1 -to 300 -increment 1
  pack $w.spDelay -side top -pady 5
  
  set b [frame $w.buttons]
  pack $b -side top -fill x
  button $b.cancel -text $::tr(Cancel) -command {
    destroy .apdialog
    focus .
  }
  button $b.ok -text "OK" -command {
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
  global autoplayMode
  if {$autoplayMode == 0} {
    set autoplayMode 1
    .button.autoplay configure -image autoplay_on -relief sunken
    autoplay
  } else {
    cancelAutoplay
  }
}

################################################################################
#
################################################################################
proc autoplay {} {
  global autoplayDelay autoplayMode annotateMode analysis
  
  if {$autoplayMode == 0} { return }
  
  if {$annotateMode} {
    if { ![sc_pos isAt start] } { addAnnotation }
  }
  
  # stop game annotation when out of opening
  if { $::isBatch && $annotateMode && $::isBatchOpening && \
        [sc_pos moveNumber] > $::isBatchOpeningMoves } {
    sc_game save [sc_game number]
    if {[sc_game number] < $::batchEnd} {
      sc_game load [expr [sc_game number] + 1]
      if {$::addAnnotatorTag} {
        appendAnnotator " $analysis(name1)"
      }
      set ::wentOutOfBook 0
      updateMenuStates
      updateStatusBar
      updateTitle
      updateBoard -pgn
      addAnnotation
      after $autoplayDelay autoplay
      return
    } else  {
      cancelAutoplay
      return
    }
  }
  
  if { [sc_pos isAt end] } {
    if {$::isBatch && $annotateMode && [sc_game number] != 0} {
      sc_game save [sc_game number]
      if {[sc_game number] < $::batchEnd} {
        sc_game load [expr [sc_game number] + 1]
        if {$::addAnnotatorTag} {
          appendAnnotator " $analysis(name1)"
        }
        set ::wentOutOfBook 0
        updateMenuStates
        updateStatusBar
        updateTitle
        updateBoard -pgn
        addAnnotation
        after $autoplayDelay autoplay
        return
      } else  {
        cancelAutoplay
        return
      }
    } else  {
      if {$annotateMode} { ;# end of game if not mate, add the thinking line
        set move_done [sc_game info previousMoveNT]
        if { [string index $move_done end] != "#"} {
          set text [format "%d:%+.2f" $analysis(depth1) $analysis(score1)]
          set moves $analysis(moves1)
          sc_move back
          sc_info preMoveCmd {}
          sc_var create
          sc_move addSan $move_done
          sc_pos setComment "[sc_pos getComment] $text"
          sc_move_add $moves 1
          sc_var exit
          sc_info preMoveCmd preMoveCommand
          updateBoard -pgn
        }
      }
      cancelAutoplay
      return
    }
  }
  
  # annotate all sub variations
  if { $annotateMode && $::isAnnotateVar } {
    if { [sc_pos isAt vend] } {
      sc_var exit
      set lastVar [::popAnalysisData]
      if { $lastVar > 0 } {
        incr lastVar -1
        sc_var enter $lastVar
        updateBoard -pgn
        ::pushAnalysisData $lastVar
      } else {
        ::move::Forward
      }
    } else {
      if {[sc_var count] > 0} {
        set lastVar [expr [sc_var count] -1]
        sc_var enter $lastVar
        updateBoard -pgn
        ::pushAnalysisData $lastVar
      } else  {
        ::move::Forward
      }
    }
    after $autoplayDelay autoplay
    return
  }
  
  ::move::Forward
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
  .button.autoplay configure -image autoplay_off -relief flat
}
################################################################################
#
################################################################################

bind . <Return> {
  if {[winfo exists .analysisWin1] && $analysis(analyzeMode1)} {
    .analysisWin1.b1.move invoke
  }
}

bind . <Control-z> {toggleAutoplay; break}
bind . <Escape> cancelAutoplay

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
    .button.trial configure -image tb_trial_on
  } else {
    set trialMode 0
    sc_game pop
    .button.trial configure -image tb_trial
  }
  updateBoard -pgn
}


