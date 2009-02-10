
####################
# Player Info window

set playerInfoName ""

proc playerInfo {{player ""}} {
  global playerInfoName
  global spffile
  if {$player == ""} { set player $playerInfoName }
  if {[catch {sc_name info -htext $player} pinfo]} { return }
  set playerInfoName $player
  set ::rgraph(player) $player
  set w .playerInfoWin
  if {! [winfo exists $w]} {
    toplevel $w
    setWinLocation $w
    wm title $w "Scid: [tr ToolsPInfo]"
    wm minsize $w 40 5
    pack [frame $w.b2] -side bottom -fill x
    pack [frame $w.b] -side bottom -fill x
    button $w.b.graph -text [tr ToolsRating] \
      -command {::tools::graphs::rating::Refresh player $playerInfoName}
    button $w.b.edit -text $::tr(PInfoEditRatings) -command {
      makeNameEditor
      setNameEditorType rating
      set editName $playerInfoName
      set editNameSelect crosstable
    }
    button $w.b2.report -text [tr ToolsPlayerReport] \
      -command {::preport::preportDlg $playerInfoName}
    dialogbutton $w.b2.help -textvar ::tr(Help) -command {helpWindow PInfo}
    dialogbutton $w.b2.update -textvar ::tr(Update) -command {playerInfo $playerInfoName}
    dialogbutton $w.b2.close -textvar ::tr(Close) -command "focus .; destroy $w"
    packbuttons right $w.b2.close $w.b2.update $w.b2.help
    packbuttons left $w.b.graph $w.b.edit
    packbuttons left $w.b2.report

    autoscrollframe $w.frame text $w.text -font font_Regular -background white \
      -width $::winWidth($w) -height $::winHeight($w) -setgrid 1 -wrap none
    #scrollbar $w.ybar -command "$w.text yview"
    #pack $w.ybar -side right -fill y
    #text $w.text -font font_Regular -background white \
    #  -width $::winWidth($w) -height $::winHeight($w) \
    #  -setgrid 1 -wrap none -yscrollcommand "$w.ybar set"
    label $w.photo -background white
    #pack $w.text -side top -fill both -expand yes
    pack $w.frame -side top -fill both -expand yes
    bind $w <Escape> "focus .; destroy $w"
    ::htext::init $w.text
    ::htext::updateRate $w.text 0
    bind $w <Escape> "focus .; destroy $w"
    bind $w <F1> {helpWindow PInfo}
    bind $w <Configure> "recordWinSize $w"
    standardShortcuts $w
  }
  set player [trimEngineName $player]
  if {[info exists spffile($player)]} {
    image create photo photoPInfo -data [getphoto $player]
    $w.photo configure -image photoPInfo -anchor ne
    place $w.photo -in $w.text -relx 1.0 -x -1 -rely 0.0 -y 1 -anchor ne
  } else {
    place forget $w.photo
  }
  $w.text configure -state normal
  $w.text delete 1.0 end
  ::htext::display $w.text $pinfo
  $w.text configure -state disabled
  ::windows::gamelist::Refresh
  ::maint::Refresh
  #raiseWin $w
}

