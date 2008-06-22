### file pfinder.tcl: part of Scid.

####################
# Player List window

namespace eval ::plist {}

set plistWin 0

set ::plist::sort Name

proc ::plist::defaults {} {
  set ::plist::name ""
  set ::plist::minGames 0
  set ::plist::maxGames 9999
  set ::plist::minElo 0
  set ::plist::maxElo [sc_info limit elo]
  set ::plist::size 50
}

::plist::defaults

trace variable ::plist::minElo w [list ::utils::validate::Integer [sc_info limit elo] 0]
trace variable ::plist::maxElo w [list ::utils::validate::Integer [sc_info limit elo] 0]
trace variable ::plist::minGames w [list ::utils::validate::Integer 9999 0]
trace variable ::plist::maxGames w [list ::utils::validate::Integer 9999 0]

proc ::plist::toggle {} {
  set w .plist
  if {[winfo exists $w]} {
    destroy $w
  } else {
    ::plist::Open
  }
}

proc ::plist::Open {} {
  global plistWin
  set w .plist
  if {[winfo exists .plist]} { return }
  set plistWin 1

  toplevel $w
  wm title $w "Scid: [tr WindowsPList]"
  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"

  bind $w <F1> {helpWindow PList}
  bind $w <Escape> "$w.b.close invoke"
  bind $w <Return> ::plist::refresh
  bind $w <Destroy> { set plistWin 0 }
  standardShortcuts $w
  bind $w <Up> "$w.t.text yview scroll -1 units"
  bind $w <Down> "$w.t.text yview scroll 1 units"
  bind $w <Prior> "$w.t.text yview scroll -1 pages"
  bind $w <Next> "$w.t.text yview scroll 1 pages"
  bind $w <Key-Home> "$w.t.text yview moveto 0"
  bind $w <Key-End> "$w.t.text yview moveto 0.99"
  #bindMouseWheel $w $w.t.text

  menu $w.menu
  $w configure -menu $w.menu
  $w.menu add cascade -label PListFile -menu $w.menu.file
  menu $w.menu.file
  $w.menu.file add command -label Update -command ::plist::refresh
  $w.menu.file add command -label Close -command "destroy $w"
  $w.menu add cascade -label PListSort -menu $w.menu.sort
  menu $w.menu.sort
  foreach name {Name Elo Games Oldest Newest} {
    $w.menu.sort add radiobutton -label $name -variable ::plist::sort \
      -value $name -command ::plist::refresh
  }

  foreach i {t o1 o2 o3 b} {frame $w.$i}
  $w.t configure -relief sunken -borderwidth 1
  text $w.t.text -width 55 -height 25 -font font_Small -wrap none \
    -fg black -bg white -yscrollcommand "$w.t.ybar set" -setgrid 1 \
    -cursor top_left_arrow -xscrollcommand "$w.t.xbar set" -borderwidth 0
  scrollbar $w.t.ybar -command "$w.t.text yview" -takefocus 0
  scrollbar $w.t.xbar -orient horiz -command "$w.t.text xview" -takefocus 0
  set xwidth [font measure [$w.t.text cget -font] "0"]
  set tablist {}
  foreach {tab justify} {4 r 10 r 18 r 24 r 32 r 35 l} {
    set tabwidth [expr {$xwidth * $tab} ]
    lappend tablist $tabwidth $justify
  }
  $w.t.text configure -tabs $tablist
  $w.t.text tag configure ng -foreground darkBlue
  $w.t.text tag configure date -foreground darkRed
  $w.t.text tag configure elo -foreground darkGreen
  $w.t.text tag configure name -foreground black
  $w.t.text tag configure title -background lightSteelBlue; #-font font_SmallBold

  set font font_Small
  set fbold font_SmallBold

  set f $w.o1
  label $f.nlabel -text $::tr(Player:) -font $fbold
  ::combobox::combobox $f.name -textvariable ::plist::name -width 20 -font $font
  ::utils::history::SetCombobox ::plist::name $f.name
  bindFocusColors $f.name
  focus $f.name
  label $f.size -text $::tr(TmtLimit:) -font $fbold
  ::combobox::combobox $f.esize -width 4 -justify right -textvar ::plist::size \
    -font $font
  trace variable ::plist::size w {::utils::validate::Integer 1000 0}
  bindFocusColors $f.esize
  foreach n {50 100 200 500 1000} {
    $f.esize list insert end $n
  }
  pack $f.esize $f.size -side right
  pack $f.nlabel $f.name -side left

  set f $w.o2
  label $f.elo -text "[tr PListSortElo]:" -font $fbold
  entry $f.emin -textvariable ::plist::minElo
  label $f.eto -text "-"
  entry $f.emax -textvariable ::plist::maxElo
  label $f.games -text "[tr PListSortGames]:" -font $fbold
  entry $f.gmin -textvariable ::plist::minGames
  label $f.gto -text "-"
  entry $f.gmax -textvariable ::plist::maxGames

  foreach entry {emin emax gmin gmax} {
    $f.$entry configure -width 4 -justify right -font $font
    bindFocusColors $f.$entry
    bind $f.$entry <FocusOut> +::plist::check
  }
  pack $f.elo $f.emin $f.eto $f.emax -side left
  pack $f.gmax $f.gto $f.gmin $f.games -side right

  dialogbutton $w.b.defaults -text $::tr(Defaults) -command ::plist::defaults
  dialogbutton $w.b.update -text $::tr(Update) -command ::plist::refresh
  dialogbutton $w.b.close -text $::tr(Close) -command "destroy $w"
  packbuttons left $w.b.defaults
  packbuttons right $w.b.close $w.b.update

  pack $w.b -side bottom -fill x
  pack $w.o3 -side bottom -fill x -padx 2 -pady 2
  pack $w.o2 -side bottom -fill x -padx 2 -pady 2
  pack $w.o1 -side bottom -fill x -padx 2 -pady 2

  pack $w.t -side top -fill both -expand yes
  grid $w.t.text -row 0 -column 0 -sticky news
  grid $w.t.ybar -row 0 -column 1 -sticky news
  grid $w.t.xbar -row 1 -column 0 -sticky news
  grid rowconfig $w.t 0 -weight 1 -minsize 0
  grid columnconfig $w.t 0 -weight 1 -minsize 0

  ::plist::ConfigMenus
  ::plist::refresh
}

proc ::plist::ConfigMenus {{lang ""}} {
  set w .plist
  if {! [winfo exists $w]} { return }
  if {$lang == ""} { set lang $::language }
  set m $w.menu
  foreach idx {0 1} tag {File Sort} {
    configMenuText $m $idx PList$tag $lang
  }
  foreach idx {0 2} tag {Update Close} {
    configMenuText $m.file $idx PListFile$tag $lang
  }
  foreach idx {0 1 2 3 4} tag {Name Elo Games Oldest Newest } {
    configMenuText $m.sort $idx PListSort$tag $lang
  }
}

proc ::plist::refresh {} {
  set w .plist
  if {! [winfo exists $w]} { return }

  busyCursor .
  ::utils::history::AddEntry ::plist::name $::plist::name
  set t $w.t.text
  $t configure -state normal
  $t delete 1.0 end

  $t insert end "\t" title
  foreach i {Games Oldest Newest Elo Name} {
    $t tag configure s$i -font font_SmallBold
    $t tag bind s$i <1> "set ::plist::sort $i; ::plist::refresh"
    $t tag bind s$i <Any-Enter> "$t tag config s$i -foreground red"
    $t tag bind s$i <Any-Leave> "$t tag config s$i -foreground {}"
    $t insert end "\t" title
    $t insert end [tr PListSort$i] [list title s$i]
  }
  $t insert end "\n" title

  update
  set err [catch {sc_name plist -name $::plist::name -size $::plist::size \
            -minGames $::plist::minGames -maxGames $::plist::maxGames \
            -minElo $::plist::minElo -maxElo $::plist::maxElo \
                -sort [string tolower $::plist::sort]} pdata]
  if {$err} {
    $t insert end "\n$pdata\n"
    unbusyCursor .
    return
  }

  set hc yellow
  set count 0
  foreach player $pdata {
    incr count
    set ng [lindex $player 0]
    set oldest [lindex $player 1]
    set newest [lindex $player 2]
    set elo [lindex $player 3]
    set name [lindex $player 4]

    $t tag bind p$count <ButtonPress-1> [list playerInfo $name]
    #$t tag bind p$count <ButtonPress-3> [list playerInfo $name]
    $t tag bind p$count <Any-Enter> \
      "$t tag configure p$count -background $hc"
    $t tag bind p$count <Any-Leave> \
      "$t tag configure p$count -background {}"
    $t insert end "\n"
    $t insert end "\t$count\t" p$count
    $t insert end $ng [list ng p$count]
    $t insert end "\t" p$count
    $t insert end $oldest [list date p$count]
    $t insert end "\t" p$count
    $t insert end "- $newest" [list date p$count]
    $t insert end "\t" p$count
    $t insert end $elo [list elo p$count]
    $t insert end "\t" p$count
    $t insert end $name [list name p$count]
  }
  $t insert end "\n"
  $t configure -state disabled
  unbusyCursor .
}

proc ::plist::check {} {
  if {$::plist::minGames > $::plist::maxGames} {
    set ::plist::maxGames $::plist::minGames
  }
  if {$::plist::minElo > $::plist::maxElo} {
    set ::plist::maxElo $::plist::minElo
  }
}
### End of file pfinder.tcl: part of Scid.
