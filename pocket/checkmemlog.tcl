#!/usr/bin/tclsh
###
### checkmemlog.tcl
###


###############################################################################
proc checkalloc {log {checkfree 0} } {
  set f [open $log r]
  set data [read $f]
  close $f
  set all [split $data "\n"]
  set alloc {}
  set free {}
  
  foreach line $all {
    set cmd [lindex $line 0]
    if { $cmd == "Alloc" || $cmd != "Free" } {
      lappend alloc $line
    }
    if {$cmd == "Free"} {
      lappend free [lindex $line 1]
    }
  }
  
  set free [lsort $free]
  
  puts "alloc [llength $alloc] free [llength $free]"
  set total 0
  
  foreach linealloc $alloc {
    if {[lindex $linealloc 0] != "Alloc"} {
      puts $linealloc
      continue
    }
    set ptr [lindex $linealloc 1]
    set idx [lsearch -exact -sorted $free $ptr]
    if { $idx == -1 } {
      puts "FREE MISSING: $linealloc"
      set total [expr $total + [lindex $linealloc 2] ]
    }
  }
  puts "======   memory unfreed = $total ========"
  
  if {!$checkfree} {return}
  # finds the Free called with no corresponding Alloc
  set alloc {}
  set free {}
  
  foreach line $all {
    set cmd [lindex $line 0]
    if { $cmd == "Free" || $cmd != "Alloc" } {
      lappend free $line
    }
    if {$cmd == "Alloc"} {
      lappend alloc [lindex $line 1]
    }
  }
  
  set alloc [lsort $alloc]
  
  foreach linefree $free {
    if {[lindex $linefree 0] != "Free"} {
      puts $linefree
      continue
    }
    set ptr [lindex $linefree 1]
    set idx [lsearch -exact -sorted $alloc $ptr]
    if { $idx == -1 } { puts "ALLOC MISSING: $linefree" }
  }
}
################################################################################

if {[llength $argv] == 0} { set argv "log" }

foreach logfile $argv {
  checkalloc $logfile
}

