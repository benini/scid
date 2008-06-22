### spellchk.tcl
### Part of Scid.
### Copyright (C) 2000-2003 Shane Hudson.

set spellcheckType Player
set spell_maxCorrections 2000
set spellcheckSurnames 0
set spellcheckAmbiguous 1

# readSpellCheckFile:
#    Presents a File Open dialog box for a Scid spellcheck file,
#    then tries to read the file. If the parameter "message" is true
#    (which is the default), a message box indicating the results
#    is displayed.
#
proc readSpellCheckFile {{message 1}} {
  global spellCheckFile
  set ftype { { "Scid Spellcheck files" {".ssp" ".ssp.gz"} } }
  set fullname [tk_getOpenFile -initialdir [pwd] -filetypes $ftype -title "Open Spellcheck file"]
  if {![string compare $fullname ""]} { return 0 }

  if {[catch {sc_name read $fullname} result]} {
      if {$message} {
        tk_messageBox -title "ERROR: Unable to read file" -type ok \
          -icon error -message "Scid could not correctly read the spellcheck file you selected:\n\n$result"
      }
    return 0
  }
  set spellCheckFile $fullname
  if {$message} {
    tk_messageBox -title "Spellcheck file loaded." -type ok -icon info \
      -message "Spellcheck file [file tail $fullname] loaded:\n[lindex $result 0] players, [lindex $result 1] events, [lindex $result 2] sites, [lindex $result 3] rounds.\n\nTo have this file automatically loaded every time you start Scid, select the \"Save Options\" from the Options menu before exiting."
  }
  return 1
}

proc updateSpellCheckWin {type} {
  global spellcheckType spell_maxCorrections spellcheckSurnames
  global spellcheckAmbiguous
  busyCursor .
  .spellcheckWin.text.text delete 1.0 end
  #.spellcheckWin.text.text insert end "Finding player corrections..."
  update idletasks
  catch {sc_name spellcheck -max $spell_maxCorrections \
           -surnames $spellcheckSurnames \
           -ambiguous $spellcheckAmbiguous $type} result
  .spellcheckWin.text.text delete 1.0 end
  .spellcheckWin.text.text insert end $result
  unbusyCursor .
}

proc openSpellCheckWin {type {parent .}} {
  global spellcheckType spell_maxCorrections spellcheckSurnames
  global spellcheckAmbiguous
  set w .spellcheckWin
  if {[winfo exists $w]} {
    tk_messageBox -type ok -icon info -title "Scid: Spellcheck error" \
      -parent $parent \
      -message "The spellcheck window is already open; close it first."
    return
  }
  if {[lindex [sc_name read] 0] == 0} {
    # No spellcheck file loaded, so try to open one:
    if {![readSpellCheckFile]} {
      return
    }
  }
  busyCursor .
  if {[catch {sc_name spellcheck -max $spell_maxCorrections \
                -surnames $spellcheckSurnames \
                -ambiguous $spellcheckAmbiguous $type} result]} {
    unbusyCursor .
    tk_messageBox -type ok -icon info -title "Scid: Spellcheck results" \
      -parent $parent -message $result
    return
  }
  unbusyCursor .
  set spellcheckType $type

  toplevel $w
  wm title $w "Scid: Spellcheck Results"
  wm minsize $w 50 10

  bind $w <F1> { helpWindow Maintenance }
  bind $w <Configure> "recordWinSize $w"

  set f [frame $w.buttons]
  pack $f -side bottom -ipady 1 -fill x

  checkbutton $f.ambig -variable spellcheckAmbiguous -relief raised \
    -text "Ambiguous" -command "updateSpellCheckWin $type"
  pack $f.ambig -side left -padx 2 -ipady 2 -ipadx 3
  if {$type == "Player"} {
    checkbutton $f.surnames -variable spellcheckSurnames -relief raised \
      -text "Surnames" -command "updateSpellCheckWin Player"
    pack $f.surnames -side left -padx 2 -ipady 2 -ipadx 3
  }

  button $f.ok -text "Make Corrections" -underline 0 -command {
    busyCursor .
    set spelltext ""
    catch {set spelltext [.spellcheckWin.text.text get 1.0 end-1c]}
    .spellcheckWin.text.text delete 1.0 end
    .spellcheckWin.text.text insert end \
      "Scid is making the spelling corrections.\nPlease wait..."
    update idletasks
    set spell_result ""
    set result [catch {sc_name correct $spellcheckType $spelltext} spell_result]
    set messageIcon info
    if {$result} { set messageIcon error }
    tk_messageBox -type ok -parent .spellcheckWin -icon $messageIcon \
      -title "Scid: Spellcheck results" -message $spell_result
    unbusyCursor .
    focus .
    destroy .spellcheckWin
    sc_game tags reload
    updateBoard -pgn
    ::windows::gamelist::Refresh
  }
  bind $w <Alt-m> "$f.ok invoke; break"

  button $f.cancel -text "Cancel" -underline 0 -command {
    focus .
    destroy .spellcheckWin
  }
  bind $w <Alt-c> "$f.cancel invoke; break"

  pack $f.cancel $f.ok -side right -padx 5

  set f [frame $w.text]
  pack $w.text -expand yes -fill both
  scrollbar $f.ybar -command "$f.text yview"
  scrollbar $f.xbar -orient horizontal -command "$f.text xview"
  text $f.text -yscrollcommand "$f.ybar set" -xscrollcommand "$f.xbar set" \
    -setgrid 1 -width $::winWidth($w) -height $::winHeight($w) \
    -background white -wrap none
  $f.text configure -tabs \
    [font measure font_Regular  "xxxxxxxxxxxxxxxxxxxxxxxxx"]

  grid $f.text -row 0 -column 0 -sticky news
  grid $f.ybar -row 0 -column 1 -sticky news
  grid $f.xbar -row 1 -column 0 -sticky news

  grid rowconfig $w.text 0 -weight 1 -minsize 0
  grid columnconfig $w.text 0 -weight 1 -minsize 0

  $f.text insert end $result
  focus $f.text
}


