
####################
# File finder window

set ::file::finder::data(dir) [pwd]
set ::file::finder::data(sort) name
set ::file::finder::data(recurse) 0
set ::file::finder::data(stop) 0
set ::file::finder::data(Scid) 1
set ::file::finder::data(PGN) 1
set ::file::finder::data(Rep) 1
set ::file::finder::data(EPD) 1
set ::file::finder::data(Old) 1

image create photo ::file::finder::updir -data {
  R0lGODdhGQAUAKEAANnZ2QAAAPD/gAAngSwAAAAAGQAUAAACToSPqcvtEGJ8LIh7A00WY71B
  0kiWnIemHmh06pshrjAM8CpjdX3HR7fboXifnM6WIvpaHmUTuYQ8g1Tcb0gVWpk9FUvaTX1F
  pfIohE4zCgA7
}

proc ::file::finder::Open {} {
  set w .finder
  if {[winfo exists $w]} { return }
  
  toplevel $w
  wm title $w "Scid: $::tr(FileFinder)"
  bind $w <F1> {helpWindow Finder}
  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"
  
  menu $w.menu
  $w configure -menu $w.menu
  
  $w.menu add cascade -label FinderFile -menu $w.menu.file
  menu $w.menu.file
  $w.menu.file add checkbutton -label FinderFileSubdirs \
      -variable ::file::finder::data(recurse) -onvalue 1 -offvalue 0 \
      -command ::file::finder::Refresh
  $w.menu.file add separator
  $w.menu.file add command -label FinderFileClose -command "destroy $w"
  
  $w.menu add cascade -label FinderSort -menu $w.menu.sort
  menu $w.menu.sort
  foreach {name value} {Type type Size size Mod mod Filename name Path path} {
    $w.menu.sort add radiobutton -label FinderSort$name \
        -variable ::file::finder::data(sort) -value $value \
        -command {::file::finder::Refresh -fast}
  }
  
  $w.menu add cascade -label FinderTypes -menu $w.menu.types
  menu $w.menu.types
  foreach type {Scid Old PGN Rep EPD} {
    $w.menu.types add checkbutton -label FinderTypes$type \
        -variable ::file::finder::data($type) -onvalue 1 -offvalue 0 \
        -command ::file::finder::Refresh
  }
  
  $w.menu add cascade -label FinderHelp -menu $w.menu.helpmenu
  menu $w.menu.helpmenu
  $w.menu.helpmenu add command -label FinderHelpFinder \
      -accelerator F1 -command {helpWindow Finder}
  $w.menu.helpmenu add command -label FinderHelpIndex -command {helpWindow Index}
  
  pack [frame $w.d] -side top -fill x
  label $w.d.label -text "$::tr(FinderDir):" -font font_Small
  set ::file::finder::data(menu) [tk_optionMenu $w.d.mb ::file::finder::data(dir) ""]
  $w.d.mb configure -font font_Small -width 1 -anchor e
  $::file::finder::data(menu) configure -font font_Small
  button $w.d.up -image ::file::finder::updir -command {::file::finder::Refresh ..}
  pack $w.d.label -side left -padx 5
  pack $w.d.up -side right -padx 5
  pack $w.d.mb -side left -fill x -expand yes
  
  frame $w.t
  frame $w.b
  text $w.t.text -width 65 -height 25 -font font_Small -wrap none \
      -fg black -bg white -yscrollcommand "$w.t.ybar set" -setgrid 1 \
      -cursor top_left_arrow
  scrollbar $w.t.ybar -command "$w.t.text yview" -width 12
  $w.t.text tag configure Dir -foreground brown
  $w.t.text tag configure Vol -foreground gray25
  $w.t.text tag configure PGN -foreground blue
  $w.t.text tag configure Scid -foreground red
  $w.t.text tag configure Old -foreground black
  $w.t.text tag configure Rep -foreground darkGreen
  $w.t.text tag configure EPD -foreground orange
  $w.t.text tag configure bold -font font_SmallBold
  $w.t.text tag configure center -justify center
  set xwidth [font measure [$w.t.text cget -font] "x"]
  set tablist {}
  foreach {tab justify} {15 r 30 r 32 l 50 l} {
    set tabwidth [expr {$xwidth * $tab} ]
    lappend tablist $tabwidth $justify
  }
  $w.t.text configure -tabs $tablist
  bindMouseWheel $w $w.t.text
  
  checkbutton $w.b.sub -text [tr FinderFileSubdirs] \
      -variable ::file::finder::data(recurse) -onvalue 1 -offvalue 0 \
      -command ::file::finder::Refresh
  dialogbutton $w.b.stop -textvar ::tr(Stop) -command {set finder(stop) 1 }
  dialogbutton $w.b.help -textvar ::tr(Help) -command {helpWindow Finder}
  dialogbutton $w.b.close -textvar ::tr(Close) -command "destroy $w"
  bind $w <Escape> "$w.b.stop invoke"
  
  pack $w.b -side bottom -fill x
  packbuttons right $w.b.close $w.b.help $w.b.stop
  packbuttons left $w.b.sub
  pack $w.t -side top -fill both -expand yes
  pack $w.t.ybar -side right -fill y
  pack $w.t.text -side left -fill both -expand yes
  ::file::finder::ConfigMenus
  ::file::finder::Refresh
}

proc ::file::finder::Refresh {{newdir ""}} {
  variable data
  set w .finder
  if {! [winfo exists $w]} { return }
  set t $w.t.text
  
  # When parameter is "-fast", just re-sort the existing data:
  set fastmode 0
  if {$newdir == "-fast"} {
    set fastmode 1
    set newdir ""
  }
  if {$newdir == ".."} { set newdir [file dirname $data(dir)] }
  if {$newdir != ""} { set data(dir) $newdir }
  
  busyCursor .
  set data(stop) 0
  $w.b.close configure -state disabled
  $w.b.help configure -state disabled
  $w.b.sub configure -state disabled
  $w.b.stop configure -state normal
  catch {grab $w.b.stop}
  $t configure -state normal
  update
  
  if {$fastmode} {
    set flist $data(flist)
  } else {
    set flist [::file::finder::GetFiles $data(dir)]
    set data(flist) $flist
  }
  
  switch $data(sort) {
    "none" {}
    "type" { set flist [lsort -decreasing -index 1 $flist] }
    "size" { set flist [lsort -integer -decreasing -index 0 $flist] }
    "name" { set flist [lsort -dict -index 2 $flist] }
    "path" { set flist [lsort -dict -index 3 $flist] }
    "mod"  { set flist [lsort -integer -decreasing -index 4 $flist] }
  }
  
  set hc yellow
  $t delete 1.0 end
  set dcount 0
  $t insert end "$::tr(FinderDirs)\n" {center bold}
  set dlist {}
  
  # Insert drive letters, on Windows:
  if {$::windowsOS} {
    foreach drive [lsort -dictionary [file volume]] {
      $t insert end " $drive " [list Vol v$drive]
      $t insert end "    "
      $t tag bind v$drive <1> [list ::file::finder::Refresh $drive]
      $t tag bind v$drive <Any-Enter> \
          "$t tag configure [list v$drive] -background $hc"
      $t tag bind v$drive <Any-Leave> \
          "$t tag configure [list v$drive] -background {}"
    }
    $t insert end "\n"
  }
  
  # Insert parent directory entry:
  lappend dlist ..
  
  # Generate other directory entries:
  set dirlist [lsort -dictionary [glob -nocomplain [file join $data(dir) *]]]
  foreach dir $dirlist {
    if {[file isdir $dir]} {
      lappend dlist $dir
    }
  }
  foreach dir $dlist {
    if {$dcount != 0} {
      set sep "\n"
      if {$dcount % 2 != 0} { set sep "\t\t\t" }
      $t insert end $sep
    }
    incr dcount
    if {$dir == ".."} {
      set d ..
      $t insert end " .. ($::tr(FinderUpDir)) " [list Dir d..]
    } else {
      set d [file tail $dir]
      $t insert end " $d " [list Dir d$d]
    }
    $t tag bind d$d <1> [list ::file::finder::Refresh $dir]
    $t tag bind d$d <Any-Enter> \
        "$t tag configure [list d$d] -background $hc"
    $t tag bind d$d <Any-Leave> \
        "$t tag configure [list d$d] -background {}"
  }
  
  # Add File section headings:
  $t insert end "\n\n"
  if {[llength $flist] != 0} {
    foreach i {Type Size Mod Name Path} v {type size mod name path} {
      $t tag configure s$i -font font_SmallBold
      $t tag bind s$i <1> "set ::file::finder::data(sort) $v; ::file::finder::Refresh -fast"
      $t tag bind s$i <Any-Enter> "$t tag config s$i -foreground red"
      $t tag bind s$i <Any-Leave> "$t tag config s$i -foreground {}"
    }
    $t insert end "$::tr(FinderFiles)\n" {center bold}
    $t insert end " "
    $t insert end "[tr FinderSortType]" sType
    $t insert end "\t"
    $t insert end "[tr FinderSortSize]" sSize
    $t insert end "\t"
    $t insert end "[tr FinderSortMod]" sMod
    $t insert end "\t"
    $t insert end "[tr FinderSortName]" sName
    $t insert end "\t"
    $t insert end "[tr FinderSortPath]" sPath
    $t insert end "\n"
  }
  
  # Add each file:
  foreach i $flist {
    set size [lindex $i 0]
    set type [lindex $i 1]
    set fname [lindex $i 2]
    set path [lindex $i 3]
    set mtime [lindex $i 4]
    set est [lindex $i 5]
    $t insert end "\n "
    $t insert end $type [list $type f$path]
    set esize ""
    if {$est} { set esize "~" }
    append esize [::utils::thousands $size]
    $t insert end "\t$esize" f$path
    $t insert end "\t[clock format $mtime -format {%b %d %Y}]" f$path
    $t insert end "\t$fname\t" f$path
    set dir [file dirname $path]
    set tail [file tail $path]
    if {$dir == "."} {
      set fullpath $data(dir)/$tail
    } else  {
      set fullpath $data(dir)/$dir/$tail
    }
    $t tag bind f$path <ButtonPress-1> "::file::Open [list $fullpath]"
    $t tag bind f$path <Any-Enter> \
        "$t tag configure [list f$path] -background $hc"
    $t tag bind f$path <Any-Leave> \
        "$t tag configure [list f$path] -background {}"
    if {$dir == "."} {
      set fullpath "$data(dir)/$tail"
    } else {
      $t tag configure p$path -foreground darkblue
      $t insert end "$dir/" [list p$path f$path]
    }
    $t tag configure t$path -foreground blue
    $t insert end $tail [list t$path f$path]
  }
  $t configure -state disabled
  
  # Update directory menubutton:
  $data(menu) delete 0 end
  set mlist {}
  set d {}
  foreach subdir [file split $data(dir)] {
    set d [file join $d $subdir]
    lappend mlist $d
  }
  foreach m $mlist {
    $data(menu) add command -label $m -command "::file::finder::Refresh [list $m]"
  }
  
  catch {grab release $w.b.stop}
  $w.b.stop configure -state disabled
  $w.b.help configure -state normal
  $w.b.close configure -state normal
  $w.b.sub configure -state normal
  unbusyCursor .
}

proc ::file::finder::ConfigMenus {{lang ""}} {
  if {! [winfo exists .finder]} { return }
  if {$lang == ""} { set lang $::language }
  set m .finder.menu
  foreach idx {0 1 2 3} tag {File Sort Types Help} {
    configMenuText $m $idx Finder$tag $lang
  }
  foreach idx {0 2} tag {Subdirs Close} {
    configMenuText $m.file $idx FinderFile$tag $lang
  }
  foreach idx {0 1 2 3 4} tag {Type Size Mod Name Path} {
    configMenuText $m.sort $idx FinderSort$tag $lang
  }
  foreach idx {0 1 2 3 4} tag {Scid Old PGN Rep EPD} {
    configMenuText $m.types $idx FinderTypes$tag $lang
  }
  foreach idx {0 1} tag {Finder Index} {
    configMenuText $m.helpmenu $idx FinderHelp$tag $lang
  }
}

proc ::file::finder::GetFiles {dir {len -1}} {
  variable data
  set dlist {}
  set flist {}
  if {$len < 0} {
    set len [expr {[string length $dir] + 1} ]
  }
  
  foreach f [glob -nocomplain [file join $dir *]] {
    if {[file isdir $f]} {
      lappend dlist $f
    } elseif {[file isfile $f]} {
      set ext [string tolower [file extension $f]]
      if {[catch {set mtime [file mtime $f]}]} { set mtime 0 }
      set showFile 0
      set rootname [file rootname $f]
      set type PGN
      if {$ext == ".si3"} {
        set showFile 1
        set type Scid
      } elseif {$ext == ".si"} {
        set showFile 1
        set type Old
      } elseif {$ext == ".sor"} {
        set showFile 1
        set type Rep
      } elseif {$ext == ".epd"} {
        set type EPD
        set showFile 1
      } elseif {$ext == ".pgn"} {
        set showFile 1
      } elseif {$ext == ".gz"} {
        set rootname [file rootname $rootname]
        if {[regexp {\.epd\.gz} $f]} { set showFile 1; set type EPD }
        if {[regexp {\.pgn\.gz} $f]} { set showFile 1 }
      }
      if {$showFile  &&  [info exists data($type)]  &&  $data($type)} {
        set path [string range $f $len end]
        set est 0
        if {[catch {set size [sc_info fsize $f]}]} {
          # Could not determine file size, probably a PGN or EPD file
          # that the user does not have permission to read.
          set est 1
          set size 0
        }
        if {$size < 0} {
          set est 1
          set size [expr {0 - $size}]
        }
        if {[file dirname $path] == "."} { set path "./$path" }
        lappend flist [list $size $type [file tail $rootname] $path $mtime $est]
      }
    }
    update
    if {$data(stop)} { break }
  }
  if {$data(recurse)} {
    foreach f $dlist {
      foreach i [::file::finder::GetFiles $f $len] {
        lappend flist $i
        update
        if {$data(stop)} { break }
      }
    }
  }
  return $flist
}

