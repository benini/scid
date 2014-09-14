###
### tools/email.tcl: part of Scid.
### Copyright (C) 1999-2003  Shane Hudson.
###

# Email manager window: closed by default
set emailWin 0


# ::tools::email
#
#   Opens the email chess manager window, for sending moves to opponents.
#
proc ::tools::email {} {
  global emailWin emailData
  set w .emailWin
  if {[winfo exists $w]} {
    destroy .emailWin
    set emailWin 0
    return
  }
  set emailWin 1
  toplevel $w
  wm title $w "Scid: Email Manager"
  wm minsize $w 25 10

  bind $w <Destroy> { set .emailWin 0 }
  bind $w <F1> { helpWindow Email }

  frame $w.f
  frame $w.b
  pack $w.f -side left -fill y
  addVerticalRule $w
  pack $w.b -side right -fill y

  set f $w.f
  label $f.title -text "Opponent list" -font font_Bold
  listbox $f.list -height 16 -width 40 -exportselection false \
    -selectmode browse -selectbackground lightBlue -font font_Fixed \
    -yscrollcommand "$f.scroll set" -background white -setgrid 1
  scrollbar $f.scroll -command "$w.list yview" -takefocus 0
  pack $f -side left -expand true -fill both
  pack $f.title -side top
  pack $f.scroll -side right -fill y
  pack $f.list -side right -expand true -fill both

  bind $f.list <ButtonRelease-1> ::tools::email::refreshButtons
  bind $f.list <Enter> ::tools::email::refreshButtons
  bind $f.list <Key-Up> ::tools::email::refreshButtons
  bind $f.list <Key-Down> ::tools::email::refreshButtons

  bind $f.list <Key-a> {.emailWin.b.add invoke}
  bind $f.list <Key-e> {.emailWin.b.edit invoke}
  bind $f.list <Key-d> {.emailWin.b.delete invoke}
  bind $f.list <Key-l> {.emailWin.b.load invoke}
  bind $f.list <Key-s> {.emailWin.b.send invoke}
  bind $f.list <Key-t> {.emailWin.b.time.m post [winfo pointerx .] [winfo pointery .]}

  set b .emailWin.b

  button $b.add -text "Add..." -underline 0 -command {
    set idx [llength $emailData]
    lappend emailData [list "" "" "" "" ""]
    modifyEmailDetails $idx
    ::tools::email::refresh
  }

  button $b.edit -text "Edit..." -underline 0 -command ::tools::email::EditButton
  button $b.delete -text "Delete..." -underline 0 -command ::tools::email::DeleteButton
  button $b.load -text "Load game" -underline 0 -command ::tools::email::LoadButton
  button $b.send -text "Send email..." -underline 0 -command ::tools::email::SendButton
  menubutton $b.time -text "Time" -underline 0 -indicatoron 1 \
    -menu $b.time.m -relief raised
  menu $b.time.m
  $b.time.m add command -label "Received today" -underline 0 \
    -command {::tools::email::TimesButton r}
  $b.time.m add command -label "Sent today" -underline 0 \
    -command {::tools::email::TimesButton s}
  $b.time.m add command -label "Edit..." -underline 0 \
    -command {::tools::email::TimesButton e}

  button $b.config -text "Settings..." -command ::tools::email::config
  button $b.help -text $::tr(Help) -command { helpWindow Email }
  button $b.close -text $::tr(Close) -command { destroy .emailWin }

  foreach i {add edit delete load send time config help close} {
    $b.$i configure -font font_Small
  }
  pack $b.add $b.edit $b.delete $b.load $b.send $b.time \
    -side top -pady 1 -padx 5 -fill x
  pack $b.close $b.help $b.config -side bottom -pady 1 -padx 5  -fill x

  bind $w <Destroy> { set emailWin 0 }
  set emailData [::tools::email::readOpponentFile]
  focus $w.f.list
  ::tools::email::refresh
}

proc ::tools::email::config {} {
  global email
  set w .emailConfig
  toplevel $w
  wm title $w "Scid"
  label $w.use -text "Send email using:" -font font_Bold
  frame $w.smtp
  radiobutton $w.smtp.b -text "SMTP server:" -variable email(smtp) -value 1
  entry $w.smtp.s -width 30 -textvar email(server) -bg white
  frame $w.sm
  radiobutton $w.sm.b -text "sendmail process:" -variable email(smtp) -value 0
  entry $w.sm.s -width 30 -textvar email(smproc) -bg white
  pack $w.use -side top
  pack $w.smtp $w.sm -side top -fill x
  pack $w.smtp.s $w.smtp.b -side right
  pack $w.sm.s $w.sm.b -side right
  addHorizontalRule $w
  label $w.addr -text "Email address fields:" -font font_Bold
  frame $w.from
  label $w.from.lab -text "From:"
  entry $w.from.e -textvar email(from) -width 30 -bg white
  frame $w.bcc
  label $w.bcc.lab -text "Bcc:"
  entry $w.bcc.e -textvar email(bcc) -width 30 -bg white
  pack $w.addr $w.from $w.bcc -side top -fill x
  pack $w.from.e $w.from.lab -side right
  pack $w.bcc.e $w.bcc.lab -side right
  addHorizontalRule $w
  pack [frame $w.b] -side top -fill x
  button $w.b.ok -text [tr OptionsSave] -command {
    .menu.options invoke [tr OptionsSave]
    catch {grab release .emailConfig}
    destroy .emailConfig
  }
  button $w.b.cancel -text $::tr(Cancel) \
    -command "catch {grab release $w}; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 2 -pady 2
  wm resizable $w 1 0
  catch {grab $w}
}

proc ::tools::email::EditButton {} {
  global emailData
  set sel [.emailWin.f.list curselection]
  if {[llength $sel] == 1} {
    set idx [lindex $sel 0]
    if {[llength $emailData] > $idx} {
      modifyEmailDetails $idx
    }
  }
  ::tools::email::refresh
}

proc ::tools::email::DeleteButton {} {
  global emailData
  set sel [.emailWin.f.list curselection]
  if {[llength $sel] != 1} { return }
  set idx [lindex $sel 0]
  if {[llength $emailData] <= $idx} { return }
  set confirm [tk_messageBox -icon question -type yesno -default yes \
                 -parent .emailWin -title "Really delete opponent?" \
                 -message "Do you really want to delete this opponent?"]
  if {$confirm == "yes"} {
      set emailData [lreplace $emailData $idx $idx]
    ::tools::email::writeOpponentFile $emailData
    ::tools::email::refresh
  }
}

proc ::tools::email::LoadButton {} {
  global emailData
  set sel [.emailWin.f.list curselection]
  if {[llength $sel] != 1} { return }
  set idx [lindex $sel 0]
  if {[llength $emailData] <= $idx} { return }
  set details [lindex $emailData $idx]
  if {[llength [lindex $details 3]] > 0} {
    if {[catch {::game::Load [lindex [lindex $details 3] 0]} result]} {
      tk_messageBox -type ok -icon warning -title "Scid" -message $result
    } else {
      sc_move end
    }
  }
}

proc ::tools::email::SendButton {} {
  global emailData
  set sel [.emailWin.f.list curselection]
  if {[llength $sel] != 1} { return }
  set idx [lindex $sel 0]
  if {[llength $emailData] <= $idx} { return }
  set details [lindex $emailData $idx]
  emailMessageEditor $idx [lindex $details 0] [lindex $details 1] \
    [lindex $details 2] [lindex $details 3] [lindex $details 4]
}

set emailTimesIdx 0

proc ::tools::email::TimesButton {type} {
  global emailData emailTimesIdx
  set sel [.emailWin.f.list curselection]
  if {[llength $sel] != 1} { return }
  set idx [lindex $sel 0]
  if {[llength $emailData] <= $idx} { return }
  set details [lindex $emailData $idx]
  while {[llength $details] < 6} { lappend details {} }
  set timeList [lindex $details 5]
  set last [lindex $timeList end]

  if {$type == "r"  || $type == "s"} {
    ::tools::email::addSentReceived $idx $type
    return
  }

  set emailTimesIdx $idx
  set w .emailTimesWin
  if {[winfo exists $w]} { return }
  toplevel $w
  wm title $w "Scid: Email Times"
  label $w.title -text "Email Times for [lindex $details 0]"
  frame $w.t
  text $w.t.text -height 15 -width 30 -font font_Fixed -setgrid 1 \
    -yscrollcommand "$w.t.ybar set" -bg white -fg black
  scrollbar $w.t.ybar -command "$w.t.text yview"
  frame $w.b
  button $w.b.ok -text "OK" -command {
    set details [lindex $emailData $emailTimesIdx]
    set timeList [split [string trim [.emailTimesWin.t.text get 1.0 end]] "\n"]
    set details [lreplace $details 5 5 $timeList]
    set emailData [lreplace $emailData $emailTimesIdx $emailTimesIdx $details]
    ::tools::email::writeOpponentFile $emailData
    grab release .emailTimesWin
    ::tools::email::refresh 0
    catch {focus .emailWin}
    destroy .emailTimesWin
  }
  button $w.b.cancel -text $::tr(Cancel) \
    -command "grab release $w; catch {focus .emailWin}; destroy $w"
  pack $w.title -side top -fill x
  pack $w.t -side top -fill both
  pack $w.t.ybar -side right -fill y
  pack $w.t.text -side left -fill both -expand yes
  pack $w.b -side bottom -fill x
  pack $w.b.cancel $w.b.ok -side right -padx 2 -pady 2
  foreach i $timeList {
    $w.t.text insert end "$i\n"
  }
  grab $w
}

proc ::tools::email::addSentReceived {idx type} {
  global emailData
  if {[llength $emailData] <= $idx} { return }
  set details [lindex $emailData $idx]
  while {[llength $details] < 6} { lappend details {} }
  set timeList [lindex $details 5]
  set last [lindex $timeList end]

  set new ""
  if {$type == "r"} { append new "Received " } else { append new "Sent     " }

  set oppGList [lindex $details 3]
  if {[llength $oppGList] > 0} {
    set oppGNum [lindex $oppGList 0]
    sc_game push
    set mnum "     "
    if {[catch {::game::Load $oppGNum}]} {
    } else {
      sc_move end
      set m [llength [split [sc_game moves coord list]]]
      if {$m > 0} {
        set m [expr int(($m+1)/2)]
        set mnum [format "%3d  " $m]
      }
    }
    sc_game pop
    append new $mnum
  }
  append new [::utils::date::today]
  if {! [string compare $last $new]} { return }
  lappend timeList $new
  set details [lreplace $details 5 5 $timeList]
  set emailData [lreplace $emailData $idx $idx $details]
  ::tools::email::writeOpponentFile $emailData
  ::tools::email::refresh 0
}

proc ::tools::email::refreshButtons {} {
  set sel [.emailWin.f.list curselection]
  if {[llength $sel] > 0} {
    .emailWin.b.edit configure -state normal
    .emailWin.b.delete configure -state normal
    .emailWin.b.load configure -state normal
    .emailWin.b.send configure -state normal
  } else {
    .emailWin.b.edit configure -state disabled
    .emailWin.b.delete configure -state disabled
    .emailWin.b.load configure -state disabled
    .emailWin.b.send configure -state disabled
  }
}

proc ::tools::email::refresh {{clearSelection 1}} {
  global emailWin emailData
  if {! [winfo exists .emailWin]} { return }
  if {$clearSelection} {
    set sel ""
    .emailWin.f.list selection clear 0 end
  } else {
    set sel [lindex [.emailWin.f.list curselection] 0]
  }
  .emailWin.f.list delete 0 end
  # set emailData [lsort -dictionary -index 0 $emailData]
  foreach i $emailData {
    set name [lindex $i 0]
    set time ""
    if {[llength $i] == 6} {
      set timeList [lindex $i 5]
      set time [lindex $timeList end]
    }
    .emailWin.f.list insert end [format "%-14s %s" $name $time]
  }
  if {$sel != ""} {
    .emailWin.f.list selection set $sel
  }
  ::tools::email::refreshButtons
}

#Initial values for globals:
set emailData {}
set emailData_index 0
set emailData_name ""
set emailData_addr ""
set emailData_subj ""
set emailData_glist ""
set emailData_dates ""
set emailData_helpBar {}
array set ::tools::email::helpBar ""

# Force the game numbers list to be digits and spaces only:
trace variable emailData_glist w {::utils::validate::Regexp {^[0-9\ ]*$}}


# emailCount: counter to give each email window a unique name.
set emailCount 0

# emailMessageEditor:
#    Constructs the email message to the opponent and
#    creates the editor window for editing and sending the message.
#
proc emailMessageEditor {idx name addr subj gamelist sig} {
  global emailCount emailData email
  incr emailCount
  if {$emailCount >= 10000} { set emailCount 1 }

  set w ".emailMessageWin$emailCount"
  toplevel $w
  wm title $w "Send email to $name"
  set f [frame $w.fields]

  label $f.fromlab -text "From: "
  entry $f.from -background white
  $f.from insert end $email(from)

  label $f.tolab -text "To: "
  entry $f.to -background white
  $f.to insert end $addr

  label $f.subjlab -text "Subject: "
  entry $f.subj -background white
  $f.subj insert end $subj

  label $f.bcclab -text "Bcc: "
  entry $f.bcc -background white
  $f.bcc insert end $email(bcc)

  button $f.send -text "Send" -command "::tools::email::processMessage $w $idx"
  button $f.cancel -text "Cancel" -command "destroy $w"

  grid $f.send -row 0 -column 3 -rowspan 2 -sticky nesw
  grid $f.cancel -row 2 -column 3 -rowspan 2 -sticky nesw
  grid $f.fromlab -row 0 -column 0 -sticky e
  grid $f.from -row 0 -column 1 -sticky ew
  grid $f.tolab -row 1 -column 0 -sticky e
  grid $f.to -row 1 -column 1 -sticky ew
  grid $f.subjlab -row 2 -column 0 -sticky e
  grid $f.subj -row 2 -column 1 -sticky ew
  grid $f.bcclab -row 3 -column 0 -sticky e
  grid $f.bcc -row 3 -column 1 -sticky ew
  grid columnconfigure $f 1 -weight 1

  set f [frame $w.message]
  pack $w.fields -fill x -padx 4 -pady 4
  pack $w.message -expand yes -fill both -padx 4 -pady 4

  scrollbar $f.ybar -command "$f.text yview"
  scrollbar $f.xbar -orient horizontal -command "$f.text xview"
  text $f.text -yscrollcommand "$f.ybar set" -xscrollcommand "$f.xbar set" \
    -setgrid 1 -width 72 -height 20 -background white -wrap none

  grid $f.text -row 0 -column 0 -sticky news
  grid $f.ybar -row 0 -column 1 -sticky news
  grid $f.xbar -row 1 -column 0 -sticky news

  grid rowconfig $w.message 0 -weight 1 -minsize 0
  grid columnconfig $w.message 0 -weight 1 -minsize 0

  # Right-mouse button cut/copy/paste menu:
  menu $f.text.edit -tearoff 0
  $f.text.edit add command -label "Cut" -command "tk_textCut $f.text"
  $f.text.edit add command -label "Copy" -command "tk_textCopy $f.text"
  $f.text.edit add command -label "Paste" -command "tk_textPaste $f.text"
  bind $f.text <ButtonPress-$::MB3> "tk_popup $f.text.edit %X %Y"

  set text $w.message.text
  # $text insert end "Hi $name,\n\n"
  $text insert end "\n"
  foreach i $gamelist {
    catch {set gamePgn [sc_game pgn -gameNumber $i -width 70 -tags 0 \
                          -variations 0 -comments 0]}
    $text insert end "$gamePgn\n"
  }
  $text insert end $sig
  return
}

proc ::tools::email::processMessage {w idx} {
  global emailData
  set from [$w.fields.from get]
  set to [$w.fields.to get]
  set subj [$w.fields.subj get]
  set bcc [$w.fields.bcc get]
  set message [$w.message.text get 1.0 end]
  if {[string trim $to] == ""} {
    tk_messageBox -icon error -type ok -title "Empty email address" \
      -message "You must specify an email address."
    return
  }
  set cmd {::tools::email::sendMessage $from $to $subj $bcc $message}
  if {[catch $cmd result] != 0} {
    tk_messageBox -icon error -type ok -title "Error sending email" \
      -message "Error sending email: $result"
  } else {
    ::tools::email::addSentReceived $idx s
    tk_messageBox -icon info -type ok -title "Scid" -message $result
    destroy $w
  }
}

proc ::tools::email::sendMessage {from to subject bcc message} {
  global email

  ### Uncomment following line for testing, to avoid sending email:
  # return "Testing, no email was actually sent"

  set copy_id ""
  catch {set copy_id [open [file nativename $email(logfile)] "a+"]}
  if {$copy_id == ""} {
    return -code error "Unable to open $email(logfile)"
  }
  if {$email(smtp)} {
    set cmdargs "-to {$to} -subject {$subject} "
    if {$email(server) != ""} { ::ezsmtp::config -mailhost $email(server) }
    if {$email(from) != ""} {
      if {[catch {::ezsmtp::config -from $from} result]} {
        close $copy_id
        return -code error "Error configuring SMTP: $result"
      }
      append cmdargs "-from {$from} "
    }
    if {$email(bcc) != ""} {
      append cmdargs "-bcc {$bcc} "
    }
    if {[catch {eval "::ezsmtp::send $cmdargs -body {$message}"} result]} {
      close $copy_id
      return -code error "Error sending mail with SMTP: $result"
    }
  } else {
    if {[catch {open "| $email(smproc) -oi -t" "w"} ::tools::email::id]} {
      close $copy_id
      return -code error "Scid could not find the sendmail program: $email(smproc)"
    }
    if {[string trim $from] != ""} {
      puts $::tools::email::id "From: $from"
    }
    puts $::tools::email::id "To: $to"
    puts $::tools::email::id "Subject: $subject"
    if {[string trim $bcc] != ""} {
      puts $::tools::email::id "Bcc: $bcc"
    }
    puts $::tools::email::id ""
    puts $::tools::email::id $message
    close $::tools::email::id
  }
  puts $copy_id  "To: $to"
  puts $copy_id  "Subject: $subject"
  puts $copy_id  ""
  puts $copy_id $message
  close $copy_id
  return "The email message was sent; a copy was appended to $email(logfile)"
}

proc modifyEmailDetails {i} {
  global emailData emailData_name emailData_addr emailData_glist emailData_subj
  global emailData_sig emailData_index emailData_helpBar ::tools::email::helpBar

  toplevel .emailEditor
  set w .emailEditor
  bind $w <F1> { helpWindow Email }
  set emailData_index $i
  if {[lindex [lindex $emailData $i] 0] == ""} {
    wm title $w "Add opponent details"
  } else {
    wm title $w "Edit opponent details"
  }
  set f [frame $w.name]
  label $f.label -text "Name: "
  entry $f.entry -width 30 -background white -textvariable emailData_name
  set ::tools::email::helpBar(name) "Enter the opponent's name"

  set f [frame $w.addr]
  label $f.label -text "Email address: "
  entry $f.entry -width 30 -background white -textvariable emailData_addr
  set ::tools::email::helpBar(addr) "Enter the opponent's email address"

  set f [frame $w.subj]
  label $f.label -text "Subject: "
  entry $f.entry -width 30 -background white -textvariable emailData_subj
  set ::tools::email::helpBar(subj) "Enter the subject for each message"

  set f [frame $w.glist]
  label $f.label -text "Game Numbers: "
  entry $f.entry -width 30 -background white -textvariable emailData_glist
  set ::tools::email::helpBar(glist) \
    "Enter opponent's game numbers, separated by spaces"

  foreach f {name addr subj glist} {
    pack $w.$f -side top -fill x
    pack $w.$f.entry $w.$f.label -side right -anchor e
    set e $w.$f.entry
    bind $e <FocusIn> "$e configure -background lightYellow;
      set emailData_helpBar \$::tools::email::helpBar($f)"
    bind $e <FocusOut> "$e configure -background white"
  }

  addHorizontalRule $w

  set f [frame $w.sig]
  label $f.label -text "Signature: " -anchor n
  text $f.entry -width 30 -height 5 -background white
  bind $f.entry <FocusIn> "$f.entry configure -background lightYellow
    set emailData_helpBar {Enter the closing text for each message}"
  bind $f.entry <FocusOut> "$f.entry configure -background white"

  pack $f -side top -fill x
  pack $f.entry $f.label -side right -anchor n

  addHorizontalRule $w

  set f [frame $w.buttons]
  button $w.buttons.save -text "Save" -command {
    set gNumberErr [::tools::email::validGameNumbers $emailData_glist]
    if {$gNumberErr != -1} {
      tk_messageBox -icon error -type ok -title "Invalid data" \
        -message "The games list contains an invalid game number: $gNumberErr; there are only [sc_base numGames] games in this database."
    } else {
      set emailData [lreplace $emailData $emailData_index \
                       $emailData_index \
                       [list $emailData_name $emailData_addr $emailData_subj \
                          $emailData_glist \
                          [.emailEditor.sig.entry get 1.0 end-1c]]]
      ::tools::email::writeOpponentFile $emailData
      destroy .emailEditor
      ::tools::email::refresh
    }
  }
  button $f.cancel -text "Cancel" -command {
    set emailData [::tools::email::readOpponentFile]
    destroy .emailEditor
    ::tools::email::refresh
  }
  pack $f -side top
  pack $f.save $f.cancel -side left -padx 20 -pady 10

  label $w.helpBar -width 1 -textvariable emailData_helpBar -relief sunken \
    -font font_Small -anchor w
  pack $w.helpBar -side bottom -fill x

  # Set up the initial values in the entry boxes:
  set details [lindex $emailData $emailData_index]
  set emailData_name [lindex $details 0]
  set emailData_addr [lindex $details 1]
  set emailData_subj [lindex $details 2]
  set emailData_glist [lindex $details 3]
  $w.sig.entry insert 1.0 [lindex $details 4]
  grab .emailEditor
}

proc ::tools::email::validGameNumbers {numberList} {
  foreach i $numberList {
    if {$i < 1  ||  $i > [sc_base numGames]} { return $i }
  }
  return -1
}

proc ::tools::email::opponentFilename {} {
  set filename [sc_base filename]
  append filename ".sem"
  return $filename
}

proc ::tools::email::readOpponentFile {} {
  set filename [::tools::email::opponentFilename]
  if {[catch {set f [open $filename "r"]} ]} {
    # puts "Unable to open opponent file"
    return {}
  }
  set data [read -nonewline $f]
  close $f
  return $data
}

proc ::tools::email::writeOpponentFile {data} {
  set filename [::tools::email::opponentFilename]
  if {[catch {set f [open $filename "w"]} ]} {
    # puts "Unable to write opponent file"
    return {}
  }
  puts $f $data
  close $f
}

