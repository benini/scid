
####################
# Game Browser window

namespace eval ::gbrowser {}

###################################
# convert FEN to Board 
proc ::gbrowser::FENtoBoard { fen } {
    set b ""
    set end [string first " " $fen] 
    incr end 1
    set m [string index $fen $end] 
    set fen "/$fen"
    set line [string last "/" $fen] 
    while { $line >= 0 } {
        set i [expr $line + 1]
        set c [string index $fen $i]
        while { $c ne "/" && $c ne " " } {
            if { [string is digit $c] } {
                for { set j 0 } { $j < $c } {incr j} { append b "." }
            } else { append b $c }
            incr i 
            set c [string index $fen $i]
        }
        set fen [string replace $fen $line $line " "]
        set line [string last "/" $fen] 
    }
    append b " $m"
    return $b
}

proc ::gbrowser::fillText { n } {
  set w .gb$n
  set t $w.t.text

  $t configure -state normal
  $t delete 1.0 end
  $t insert end "$::gbrowser::header($n)" header
  $t insert end "\n\n"

  set game [lreplace [sc_base getGame $::gbrowser::base($n) $::gbrowser::gnum($n)] 0 0 ]  
  set ::gbrowser::boards($n) [list ]
  set ::gbrowser::depth($n) [list ]
  set ::gbrowser::eval($n) [list ]
  set comments [list ]
  set moves [list ]
  set vars [list ]

  set prevDepth 0
  set prevSub 0
  set m 0
  set tab ""
  set dot 1

  foreach pos $game {
      lassign $pos depth sub fen nag comment san
      if { ! $::gbrowser::showVariants($n) && $depth > 0 } { continue } 
      if { $depth == 0 } {
          set bo "bold"
      } else {
          set bo "vars"
      }
      set nr [lindex $fen 5]
      set bd [FENtoBoard $fen]
      if { $depth > $prevDepth } {
          append tab "  "
          $t insert end "\n${tab}(" [list vars vars]
          set dot 1
      } elseif { $depth < $prevDepth } {
          set C ""
          for { set i $prevDepth } { $i > $depth } { incr i -1 } {
              append C ")"
              set tab [string range $tab 0 end-2]
          }
          $t insert end "$C\n$tab" [list vars vars]
          set dot 1
      } elseif { $sub > $prevSub } {
          $t insert end ")\n${tab}(" [list vars vars]
          set dot 1
      }
      if { [string index $bd end] == "b" } {
          set san " $nr. $san"
      } elseif { $dot } {
          incr nr -1
          set san " $nr. ... $san"
      }
      set dot 0
      if { $comment ne "" } { set dot 1 }
      set prevDepth $depth
      set prevSub $sub
      lappend ::gbrowser::boards($n) $bd
      lappend ::gbrowser::depth($n) $depth
      lappend ::gbrowser::eval($n) [getScorefromComment $comment 10]
      set moveTag m$m
      $t tag bind $moveTag <ButtonRelease-1> "::gbrowser::update $n $m"
      $t tag bind $moveTag <3> "::board::popup $w.popup {$bd} %X %Y {} $w.bd"
      incr m
      $t insert end "[::trans $san]" [list $moveTag $bo]
      $t insert end "$nag " [list nag nags]
      if { $::gbrowser::showComments($n) } { $t insert end "$comment" [list co comments]}
      $t tag bind $moveTag <Any-Enter> \
          "$t tag configure $moveTag -underline 1
              $t configure -cursor hand2"
      $t tag bind $moveTag <Any-Leave> \
          "$t tag configure $moveTag -underline 0
           $t configure -cursor {}
           catch { wm withdraw $w.popup }"
  }
  if { $depth > 0 } { $t insert end ")" [list vars vars] }
  $t configure -state disabled
}

proc ::board::toggleComments {n} {
  set ::gbrowser::showComments($n) [expr {1 - $::gbrowser::showComments($n)}]
  if { $::gbrowser::showComments($n) } {
      .gb$n.b.comment state pressed } else {
          .gb$n.b.comment state active }
}

proc ::board::toggleVariants {n} {
  set ::gbrowser::showVariants($n) [expr {1 - $::gbrowser::showVariants($n)}]
  if { $::gbrowser::showVariants($n) } {
      .gb$n.b.variant state pressed } else {
          .gb$n.b.variant state active }
}

proc ::gbrowser::new {base gnum {ply -1}} {
  if {! [info exists ::gbrowser::size] } { set ::gbrowser::size 65 }
  options.save ::gbrowser::size

  set n 0
  while {[winfo exists .gb$n]} { incr n }
  global ::gbrowser::players$n
  set w .gb$n
  toplevel $w
  if {$base < 1} { set base [sc_base current] }
  if {$gnum < 1} { set game [sc_game number] }

  lassign [sc_base gamesummary $base $gnum] header
  set ::gbrowser::players${n}(nameW) ""
  set ::gbrowser::players${n}(nameB) ""
  set ::gbrowser::header($n) ""
  #scan "nameW -- nameB\nrest of header"
  regexp {(.*)(  --  )(.*)(\n)(.*\n.*)} $header notused ::gbrowser::players${n}(nameW) notused \
      ::gbrowser::players${n}(nameB) notused ::gbrowser::header($n)
  set ::gbrowser::base($n) $base
  set ::gbrowser::gnum($n) $gnum
  set ::gbrowser::showComments($n) 0
  set ::gbrowser::showVariants($n) 0
  set filename [file tail [sc_base filename $base]]
  wm title $w "Scid: [set ::gbrowser::players${n}(nameW)] - [set ::gbrowser::players${n}(nameB)] ($filename: $gnum)"

  pack [ttk::frame $w.b] -side bottom -fill x
  ::board::new $w.bd $::gbrowser::size
  pack $w.bd -side left -padx 4 -pady 4
  applyThemeColor_background $w
#  ::board::addMaterialBar $w.bd
  ::board::addNamesBar $w.bd ::gbrowser::players${n}

  autoscrollText y $w.t $w.t.text Treeview
  $w.t.text configure -wrap word -state normal \
      -width 55 -font font_Small -setgrid 1
  pack $w.t -side right -fill both -expand yes

  bind $w <F1> {helpWindow GameList Browsing}
  bind $w <Escape> "destroy $w"
  bind $w <Home> "::gbrowser::update $n start"
  bind $w <End> "::gbrowser::update $n end"
  bind $w <Left> "::gbrowser::update $n -1"
  bind $w <Right> "::gbrowser::update $n +1"
  bind $w <Up> "::gbrowser::update $n up"
  bind $w <Down> "::gbrowser::update $n down"
  bind $w <minus> {set ::gbrowser::size [::board::resize %W.bd -1]}
  bind $w <Control-Shift-Left> {set ::gbrowser::size [::board::resize %W.bd -1]}
  bind $w <plus> {set ::gbrowser::size [::board::resize %W.bd +1]}
  bind $w <Control-Shift-Right> {set ::gbrowser::size [::board::resize %W.bd +1]}
  bindMouseWheel $w "::gbrowser::mousewheelHandler $n"

  ttk::button $w.b.start -image tb_start -command "::gbrowser::update $n start"
  ttk::button $w.b.back -image tb_prev -command "::gbrowser::update $n -1"
  ttk::button $w.b.up -image tb_up -command "::gbrowser::update $n up"
  ttk::button $w.b.down -image tb_down -command "::gbrowser::update $n down"
  ttk::button $w.b.forward -image tb_next -command "::gbrowser::update $n +1"
  ttk::button $w.b.end -image tb_end -command "::gbrowser::update $n end"
  ttk::frame $w.b.gap -width 3
  ttk::button $w.b.autoplay -image tb_play -command "::gbrowser::autoplay $n"
  ttk::frame $w.b.gap2 -width 3
  ttk::button $w.b.mat -image tb_white -command "::board::toggleMaterial $w.bd"
  ttk::button $w.b.eval -image tb_score -command "::board::toggleEvalBar $w.bd"
  ttk::button $w.b.flip -image tb_flip -command "::gbrowser::flip $n"
  ttk::button $w.b.incr -text "+" -width -1 -command "::board::resize $w.bd +1"
  ttk::button $w.b.decr -text "-" -width -1 -command "::board::resize $w.bd -1"
  ttk::button $w.b.comment -image tb_tabmenu -command "::board::toggleComments $n; ::gbrowser::fillText $n"
  ttk::button $w.b.variant -image tb_tree -command "::board::toggleVariants $n; ::gbrowser::fillText $n"
  ::board::toggleComments $n
  ::board::toggleVariants $n
  set t $w.t.text
  event generate $t <ButtonRelease-1>
  $t tag configure next -background $::pgnColor(Current)
  $t tag configure vars -foreground $::pgnColor(Var)
  $t tag configure comments -foreground $::pgnColor(Comment)
  $t tag configure nags -foreground $::pgnColor(Nag)
  $t tag configure bold -font font_Bold
  ::gbrowser::fillText $n

  pack $w.b.start $w.b.back $w.b.up $w.b.down $w.b.forward $w.b.end $w.b.gap \
      $w.b.autoplay $w.b.gap2 $w.b.flip $w.b.mat $w.b.eval $w.b.incr $w.b.decr -side left -padx 3 -pady 1

  set ::gbrowser::autoplay($n) 0

  if {$gnum > 0} {
    ttk::button $w.b.load -textvar ::tr(LoadGame) -command "sc_base switch $base; ::game::Load $gnum"
    ttk::button $w.b.merge -textvar ::tr(MergeGame) -command "mergeGame $base $gnum"
    pack $w.b.merge $w.b.load -side right -padx 3 -pady 1
  }
  pack $w.b.variant $w.b.comment -side right -padx 3 -pady 1

  wm resizable $w 1 0
  if {$ply < 0} {
    set ply 0
    #TODO: search if game gnum match the current board pos
  }
  ::gbrowser::update $n $ply

  if { [::board::isFlipped .main.board] } {
    ::gbrowser::flip $n
  }
  if {$::gameInfo(showMaterial)} { ::board::toggleMaterial $w.bd }
  if {$::showEvalBar(.main)} {::board::toggleEvalBar $w.bd }
}

proc gbrowser::mousewheelHandler {n direction} {
  if {$direction < 0} {
    ::gbrowser::update $n -1
  } else {
    ::gbrowser::update $n +1
  }
}

proc ::gbrowser::flip {n} {
  ::board::flip .gb$n.bd
}

proc ::gbrowser::update {n ply} {
  set w .gb$n
  if {! [winfo exists $w]} { return }
  set oldply 0
  if {[info exists ::gbrowser::ply($n)]} { set oldply $::gbrowser::ply($n) }
  set var [lindex $::gbrowser::depth($n) $oldply]
  switch $ply {
      "forward" { set ply [expr {$oldply + 1} ] }
      "back" { set ply [expr {$oldply - 1} ] }
      "start" { set ply 0 }
      "end" { set ply 9999 }
      "up" { if { $var == 0 } { return } 
          set ply $::gbrowser::ply($n)
          while { $ply > 0 && $var <= [lindex $::gbrowser::depth($n) $ply] } { incr ply -1 }
      }
      "down" { set ply $::gbrowser::ply($n)
          if { $var <= [lindex $::gbrowser::depth($n) [expr $oldply + 1]]} { set ply [expr $oldply + 1] }
      }
  }

  set direction 0
  if {[string index $ply 0] == "-"  ||  [string index $ply 0] == "+"} {
    set direction $ply
    set ply [expr {$oldply + $ply} ]
  }
  set max [expr {[llength $::gbrowser::boards($n)] - 1} ]
  while { $direction ne 0 && $ply > 0 && $ply < $max && $var != [lindex $::gbrowser::depth($n) $ply] } {
      if { $var > [lindex $::gbrowser::depth($n) $ply] } { incr ply -1; break }
      incr ply $direction
  }
  if {$ply < 0} { set ply 0 }
  if {$ply > $max} { set ply $max }
  set ::gbrowser::ply($n) $ply
  ::board::update $w.bd [lindex $::gbrowser::boards($n) $ply] 1
  ::board::updateEvalBar $w.bd [lindex $::gbrowser::eval($n) $ply]

  set t $w.t.text
  $t configure -state normal
  set moveRange [$t tag nextrange m$ply 1.0]
  $t tag remove next 1.0 end
  set moveRange [$t tag nextrange m$ply 1.0]
  if {[llength $moveRange] == 2} {
    $t tag add next [lindex $moveRange 0] [lindex $moveRange 1]
    $t see [lindex $moveRange 0]
  }
  $t configure -state disabled

  if {$::gbrowser::autoplay($n)} {
    if {$ply >= $max} {
      ::gbrowser::autoplay $n
    } else {
      after cancel "::gbrowser::update $n +1"
      after $::autoplayDelay "::gbrowser::update $n +1"
    }
  }
}

proc ::gbrowser::autoplay {n} {
  if {$::gbrowser::autoplay($n)} {
    set ::gbrowser::autoplay($n) 0
    .gb$n.b.autoplay configure -image tb_play
    return
  } else {
    set ::gbrowser::autoplay($n) 1
    .gb$n.b.autoplay configure -image tb_stop
    ::gbrowser::update $n +1
  }
}
