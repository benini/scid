###
### windows/stats.tcl: Filter Statistics window for Scid
###

set ::windows::stats::isOpen 0

proc ::windows::stats::Open {} {
  set w .statsWin
  if {[winfo exists $w]} {
    focus .
    destroy $w
    set ::windows::stats::isOpen 0
    return
  }
  toplevel $w
  wm title $w "Scid: Filter Statistics"
  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"

  menu $w.menu
  $w configure -menu $w.menu
  $w.menu add cascade -label StatsFile -menu $w.menu.file
  $w.menu add cascade -label StatsOpt -menu $w.menu.opt
  menu $w.menu.file
  $w.menu.file add command -label StatsFilePrint -command {
    set ftype {
      { "Text files" {".txt"} }
      { "All files"  {"*"}    }
    }
    set fname [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Save text file"]
    if {$fname != ""} {
      if {[catch {set tempfile [open $fname w]}]} {
        tk_messageBox -title "Scid: Error saving file" -type ok -icon warning \
          -message "Unable to save the file: $fname\n\n"
      } else {
        puts $tempfile [.statsWin.stats get 1.0 end-1c]
        close $tempfile
      }
    }
  }
  $w.menu.file add separator
  $w.menu.file add command -label StatsFileClose -accelerator Esc \
      -command "destroy $w"

  menu $w.menu.opt
  $w.menu.opt add cascade -label $::tr(OprepStatBoth) -menu $w.menu.opt.elo
  menu $w.menu.opt.elo
  foreach i [lsort -decreasing [array names ::windows::stats::display r*]] {
    set elo [string range $i 1 end]
    $w.menu.opt.elo add checkbutton -label "$::tr(OprepStatBoth) $elo+" \
      -variable ::windows::stats::display($i) -command ::windows::stats::Refresh
  }
  $w.menu.opt add separator
  $w.menu.opt add cascade -label $::tr(OprepStatSince) \
    -menu $w.menu.opt.year
  menu $w.menu.opt.year
  foreach i [lsort [array names ::windows::stats::display y*]] {
    set year [string range $i 1 end]
    $w.menu.opt.year add checkbutton \
      -label "$::tr(OprepStatSince) $year.01.01" \
      -variable ::windows::stats::display($i) -command ::windows::stats::Refresh
  }

#  text $w.stats -borderwidth 0 \
    -width $::winWidth($w) -height $::winHeight($w) -font font_Fixed \
    -foreground black -background white -cursor top_left_arrow -wrap none \
      -setgrid 1 -yscrollcommand {.statsWin.sb set } 
  autoscrollframe $w.statsasb text $w.stats -width 80 -height 40\
      -foreground black -background white -font font_Fixed\
       -wrap none 

  pack $w.statsasb -side top -fill both -expand yes
  set ::windows::stats::isOpen 1
  bind $w <Control-q> "destroy $w"
  bind $w <Escape> "destroy $w"
  bind $w <F1> { helpWindow Index }
  bind $w <Destroy> {
    set ::windows::stats::isOpen 0
  }
  standardShortcuts $w
#Klimmek: enable Resize vertical
  wm resizable $w 0 1
  ::windows::stats::ConfigMenus
  ::windows::stats::Refresh
}

proc ::windows::stats::Refresh {} {
  variable display
  if {[winfo exists .playerInfoWin]} { ::pinfo::playerInfo }
  ::windows::gamelist::Refresh
  ::maint::Refresh
  updateStatusBar
  ::tools::graphs::filter::Refresh
  #Klimmek. Update Absfilter window
  ::tools::graphs::absfilter::Refresh
  if {! [winfo exists .statsWin]} { return }

  # Set up variables for translated phrases:
  set all [::utils::string::Capital $::tr(allGames)]
  set both $::tr(OprepStatBoth)
  set since $::tr(OprepStatSince)
  set games [::utils::string::Capital $::tr(games)]
  set score [::utils::string::Capital $::tr(score)]

  # Find length of longest left-hand column:
  set alen [expr {[string length $all] + 1}]
  set blen [expr {[string length $both] + 7}]
  set slen [expr {[string length $since] + 12}]
  set len $alen
  if {$len < $blen} { set len $blen }
  if {$len < $slen} { set len $slen }

  set height 4
  set ratings 0
  set years 0
  set rlist [lsort -decreasing [array names display r*]]
  set ylist [lsort [array names display y*]]

  foreach i $rlist {
    if {$display($i)} { set ratings 1 }
  }
  foreach i $ylist {
    if {$display($i)} { set years 1 }
  }

  if {$ratings} { incr height }
  if {$years} { incr height }

  set s ""
  set sm "\n"  
  set stat ""
  append s " [::utils::string::Pad $stat [expr $len - 4]] [::utils::string::PadRight $games 10]"
  append s "     1-0     =-=     0-1 [::utils::string::PadRight $score 8]\n"
  append s "------------------------------------------------------------------------"
  append s "\n [::utils::string::Pad $all $len]" [sc_filter stats all]
#Klimmek: New Statistic: Count the games in intervalls "start elo  - end elo"
#         if elo is deselected in option menu, then enlarge the intervall to next selectet elo.
#Klimmek: New Statistic: Count the games in intervalls
  if {$ratings} {
    append s "\n"
    set j 0
    set k [lindex $rlist $j]
    while { $k!= "" && ! $display($k) } {
	incr j
	set k [lindex $ylist $j]
	if { $k == "" } { break }
    }
    set nelo [string range [lindex $rlist $j] 1 end]
    incr height
#first line searches all games greater 2600 Elo
    set stat "min. Elo $nelo-3500"
    append s "\n [::utils::string::Pad $stat $len]"   [sc_filter stats elo $nelo 9999]
    set stat "max. Elo $nelo-3500"
    append sm "\n [::utils::string::Pad $stat $len]"   [sc_filter stats elo $nelo -9999]
    set j 0
    foreach i $rlist {
      incr j  
      if {$display($i)} {
        incr height
        set elo [string range $i 1 end]
	set l $j
	set k [lindex $rlist $l]
        while { $k!= "" && ! $display($k) } {
	    incr l
	    set k [lindex $rlist $l]
	    if { $k == "" } { break }
	}
	set nelo [string range [lindex $rlist $l] 1 end]
	if { $nelo == "" } { set nelo 0 }  
#count all games where player whith lowest Elo is in the specific range      
        set stat "min. Elo $nelo-$elo"
        append s "\n [::utils::string::Pad $stat $len]"   [sc_filter stats elo $nelo $elo]
        set stat "max. Elo $nelo-$elo"
#count all games where player whith highest Elo is in the specific range      
# +10000 workaround to trigger max elo in filter function
	append sm "\n [::utils::string::Pad $stat $len]"   [sc_filter stats elo $nelo [expr {$elo + 10000}]]
      }
    }
  }
  append s $sm
#Klimmek: New Statistic: Count the games in intervalls "from year - to year"
#         if year is deselected in option menu, then enlarge the intervall to next selectet year.
  if {$years} {
    append s "\n"
    set j 0  
    foreach i $ylist {
      incr j  
      if {$display($i)} {
        incr height
        set year [string range $i 1 end]
	set l $j
	set k [lindex $ylist $l]
        while { $k!= "" && ! $display($k) } {
	    incr l
	    set k [lindex $ylist $l]
	    if { $k == "" } { break }
	}
	set nyear [string range $k 1 end]
	if { $nyear == "" } { set nyear 2099 }  
        set stat "$year - $nyear"
        append s "\n [::utils::string::Pad $stat $len]"   [sc_filter stats year $year $nyear]
      } 
    }
  }
#Old statistic: count the games from specific value to maximum value 
  set stat ""
  append s "\n\n"
  append s " [::utils::string::Pad $stat [expr $len - 4]] [::utils::string::PadRight $games 10]"
  append s "     1-0     =-=     0-1 [::utils::string::PadRight $score 8]\n"
  append s "------------------------------------------------------------------------"
  append s "\n [::utils::string::Pad $all $len]" [sc_filter stats all]

  if {$ratings} {
    append s "\n"
    foreach i $rlist {
      if {$display($i)} {
        incr height
        set elo [string range $i 1 end]
        set stat "$both $elo+"
        append s "\n [::utils::string::Pad $stat $len]"   [sc_filter stats elo $elo 0]
      }
    }
  }

  if {$years} {
    append s "\n"
    foreach i $ylist {
      if {$display($i)} {
        incr height
        set year [string range $i 1 end]
        set stat "$since $year.01.01"
        append s "\n [::utils::string::Pad $stat $len]"   [sc_filter stats year $year 0]
      }
    }
  }
  append s "\n"

  set w .statsWin.stats
  if { $height > 50  } { set height 50 }  
  $w configure -state normal
  $w delete 1.0 end
  $w insert end $s
  $w tag configure blue -foreground darkBlue
  $w tag configure red -foreground red
  $w tag add blue 1.0 2.0
  $w tag add red 2.0 3.0
  $w configure -height $height
  $w configure -state disabled
}

proc ::windows::stats::ConfigMenus {{lang ""}} {
  if {! [winfo exists .statsWin]} { return }
  if {$lang == ""} { set lang $::language }
  set m .statsWin.menu
  foreach idx {0 1} tag {File Opt} {
    configMenuText $m $idx Stats$tag $lang
  }
  foreach idx {0 2} tag {Print Close} {
    configMenuText $m.file $idx StatsFile$tag $lang
  }
}
