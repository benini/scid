###
### search.tcl: Search routines for Scid.
###

namespace eval ::search {}

# searchType: set to Header or Material in a SearchOptions file
set searchType 0

set ::search::filter::operation 2


# TODO: Rename to ::search::filter::text
# filterText: returns text describing state of filter for specified
#   database, e.g. "no games" or "all / 400" or "1,043 / 2,057"
#
proc filterText {{base 0} {kilo 0}} {
  # Default to current base if no base specified:
  if {$base == 0} { set base [sc_base current] }
  set filterCount [sc_filter count $base]
  set gameCount [sc_base numGames $base]
  if {$gameCount == 0} { return $::tr(noGames) }
  if {$gameCount == $filterCount} {
    return "$::tr(all) / [::utils::thousands $gameCount $kilo]"
  }
  return "[::utils::thousands $filterCount $kilo] / [::utils::thousands $gameCount $kilo]"
}


# search::filter::reset
#   Resets the filter to contain all games. Calls sc_filter reset and
#   updates relevant windows.
#
proc ::search::filter::reset {} {
  global glstart
  sc_filter reset
  set glstart 1
  ::windows::gamelist::Refresh
  ::windows::stats::Refresh
  updateMenuStates
}

# ::search::filter::negate
#
#   Negates the filter, to include only excluded games.
#
proc ::search::filter::negate {} {
  global glstart
  sc_filter negate
  set glstart 1
  ::windows::gamelist::Refresh
  ::windows::stats::Refresh
  updateMenuStates
}



# ::search::addFilterOpFrame
#
#   Adds a search filter operation selection frame to the window.
#   Adds a frame of radiobuttons allowing the filter operation
#   (AND with current filter, OR with current filter, or RESET filter)
#   to be chosen.
#   The default value for the first search is RESET:
proc ::search::addFilterOpFrame {w {small 0}} {
  ttk::frame $w.filterop
  set f $w.filterop
  pack $f -side top -fill x
  
  set regular Regular.TRadiobutton
  set bold Bold.TRadiobutton
  if {$small} {
    set regular Small.TRadiobutton
    set bold SmallBold.TRadiobutton
  }
  
  ttk::label $f.title -font $bold -textvar ::tr(FilterOperation) -anchor center
  ttk::frame $f.b
  ttk::radiobutton $f.b.and -textvar ::tr(FilterAnd) -variable ::search::filter::operation -value 0 -style $regular 
  ttk::radiobutton $f.b.or -textvar ::tr(FilterOr) -variable ::search::filter::operation -value 1 -style $regular
  ttk::radiobutton $f.b.ignore -textvar ::tr(FilterIgnore) -variable ::search::filter::operation -value 2 -style $regular
  pack $f.title -side top
  pack $f.b -anchor center -side top
  pack $f.b.and $f.b.or $f.b.ignore -side left -pady 5 -padx 5
}


# ::search::Config
#
#   Sets state of Search button in Header, Board and Material windows
#
proc ::search::Config {{state ""}} {
  if {$state == ""} {
    set state disabled
    if {[sc_base inUse]} { set state normal }
  }
  catch {.sh.b.search configure -state $state }
  catch {.sb.b.search configure -state $state }
  catch {.sm.b3.search configure -state $state }
  catch {.spprep.b.search configure -state $state }
}


proc ::search::usefile {} {
  set ftype { { "Scid SearchOption files" {".sso"} } }
  set ::fName [tk_getOpenFile -initialdir $::initialDir(base) \
      -filetypes $ftype -title "Select a SearchOptions file"]
  if {$::fName == ""} { return }
  
  if {[catch {uplevel "#0" {source $::fName} } ]} {
    tk_messageBox -title "Scid: Error reading file" -type ok -icon warning \
        -message "Unable to open or read SearchOptions file: $fName"
  } else {
    switch -- $::searchType {
      "Material" { ::search::material }
      "Header"   { ::search::header }
      default    { return }
    }
  }
}

# will go to the first game found, except if the Tree of current base is opened (of there will be filter collision)
proc ::search::loadFirstGame {} {
  set w ".treeWin[sc_base current]"
  if {[winfo exists $w]} { return }
  ::game::Load [sc_filter first]
}
