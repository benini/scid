
######################################################################
### Crosstable window

namespace eval ::crosstab {}

set crosstab(sort) score
set crosstab(type) auto
set crosstab(ages) "+ages"
set crosstab(colors) "+colors"
set crosstab(ratings) "+ratings"
set crosstab(countries) "+countries"
set crosstab(titles) "+titles"
set crosstab(groups) "-groups"
set crosstab(breaks) "-breaks"
set crosstab(deleted) "-deleted"
set crosstab(cnumbers) "-numcolumns"
set crosstab(text) hypertext

proc ::crosstab::ConfigMenus {{lang ""}} {
  if {! [winfo exists .crosstabWin]} { return }
  if {$lang == ""} { set lang $::language }
  set m .crosstabWin.menu
  foreach idx {0 1 2 3 4 5} tag {File Edit Opt Sort Color Help} {
    configMenuText $m $idx Crosstab$tag $lang
  }
  foreach idx {0 1 2 4} tag {Text Html LaTeX Close} {
    configMenuText $m.file $idx CrosstabFile$tag $lang
  }
  foreach idx {0 1 2} tag {Event Site Date} {
    configMenuText $m.edit $idx CrosstabEdit$tag $lang
  }
  foreach idx {0 1 2 3 5 6 7 8 9 10 12 13 15} tag {All Swiss Knockout Auto Ages Nats Ratings Titles Breaks Deleted Colors ColumnNumbers Group} {
    configMenuText $m.opt $idx CrosstabOpt$tag $lang
  }
  foreach idx {0 1 2} tag {Name Rating Score} {
    configMenuText $m.sort $idx CrosstabSort$tag $lang
  }
  foreach idx {0 1} tag {Plain Hyper} {
    configMenuText $m.color $idx CrosstabColor$tag $lang
  }
  foreach idx {0 1} tag {Cross Index} {
    configMenuText $m.helpmenu $idx CrosstabHelp$tag $lang
  }
}

proc toggleCrosstabWin {} {
  set w .crosstabWin
  if {[winfo exists $w]} {
    destroy $w
  } else {
    crosstabWin
  }
}

proc ::crosstab::RefreshIfOpen {} {
  set w .crosstabWin
  if {[winfo exists $w]} { crosstabWin }
}

proc ::crosstab::Open {} {
  global crosstab
  set w .crosstabWin
  if {[winfo exists $w]} {
    ::crosstab::Refresh
    return
  }
  
  toplevel $w
  wm title $w "Scid: [tr ToolsCross]"
  wm minsize $w 50 5
  setWinLocation $w
  
  menu $w.menu
  $w configure -menu $w.menu
  $w.menu add cascade -label CrosstabFile -menu $w.menu.file
  $w.menu add cascade -label CrosstabEdit -menu $w.menu.edit
  $w.menu add cascade -label CrosstabOpt -menu $w.menu.opt
  $w.menu add cascade -label CrosstabSort -menu $w.menu.sort
  $w.menu add cascade -label CrosstabText -menu $w.menu.color
  $w.menu add cascade -label CrosstabHelp -menu $w.menu.helpmenu
  foreach i {file edit opt sort color helpmenu} {
    menu $w.menu.$i -tearoff 0
  }
  
  $w.menu.file add command -label CrosstabFileText -command {
    set ftype {
      { "Text files" {".txt"} }
      { "All files"  {"*"}    }
    }
    set fname [tk_getSaveFile -initialdir [pwd] -filetypes $ftype  -title "Save Crosstable"]
    if {$fname != ""} {
      if {[catch {set tempfile [open $fname w]}]} {
        tk_messageBox -title "Scid: Error saving file" -type ok -icon warning -message "Unable to save the file: $fname\n\n"
      } else {
        puts -nonewline $tempfile [.crosstabWin.f.text get 1.0 end]
        close $tempfile
      }
    }
  }
  $w.menu.file add command -label CrosstabFileHtml -command {
    set ftype {
      { "HTML files" {".html" ".htm"} }
      { "All files"  {"*"}    }
    }
    set fname [tk_getSaveFile -initialdir $::initialDir(html) -filetypes $ftype  -title "Save Crosstable as HTML"]
    if {$fname != ""} {
      if {[file extension $fname] != ".html" && [file extension $fname] != ".htm" } {
        append fname ".html"
      }
      if {[catch {set tempfile [open $fname w]}]} {
        tk_messageBox -title "Scid: Error saving file" -type ok -icon warning -message "Unable to save the file: $fname\n\n"
      } else {
        catch {sc_game crosstable html $crosstab(sort) $crosstab(type) \
              $crosstab(ratings) $crosstab(countries) $crosstab(titles) \
              $crosstab(colors) $crosstab(groups) $crosstab(ages) \
              $crosstab(breaks) $crosstab(cnumbers) $crosstab(deleted)} \
            result
        puts $tempfile $result
        close $tempfile
      }
    }
  }
  $w.menu.file add command -label CrosstabFileLaTeX -command {
    set ftype {
      { "LaTeX files" {".tex" ".ltx"} }
      { "All files"  {"*"}    }
    }
    set fname [tk_getSaveFile -initialdir $::initialDir(tex) -filetypes $ftype  -title "Save Crosstable as LaTeX"]
    if {$fname != ""} {
      if {[file extension $fname] != ".tex" && [file extension $fname] != ".ltx" } {
        append fname ".tex"
      }
      if {[catch {set tempfile [open $fname w]}]} {
        tk_messageBox -title "Scid: Error saving file" \
            -type ok -icon warning \
            -message "Unable to save the file: $fname\n\n"
      } else {
        catch {sc_game crosstable latex $crosstab(sort) $crosstab(type) \
              $crosstab(ratings) $crosstab(countries) $crosstab(titles) \
              $crosstab(colors) $crosstab(groups) $crosstab(ages) \
              $crosstab(breaks) $crosstab(cnumbers) $crosstab(deleted)} \
            result
        puts $tempfile $result
        close $tempfile
      }
    }
  }
  $w.menu.file add separator
  $w.menu.file add command -label CrosstabFileClose \
      -command { .crosstabWin.b.cancel invoke } -accelerator Esc
  
  $w.menu.edit add command -label CrosstabEditEvent -command {
    makeNameEditor
    setNameEditorType event
    set editName [sc_game info event]
    set editNameNew ""
    set editNameSelect crosstable
  }
  $w.menu.edit add command -label CrosstabEditSite -command {
    makeNameEditor
    setNameEditorType site
    set editName [sc_game info site]
    set editNameNew ""
    set editNameSelect crosstable
  }
  $w.menu.edit add command -label CrosstabEditDate -command {
    makeNameEditor
    setNameEditorType date
    set editNameNew " "
    set editDate [sc_game info date]
    set editDateNew [sc_game info date]
    set editNameSelect crosstable
  }
  
  $w.menu.opt add radiobutton -label CrosstabOptAll \
      -variable crosstab(type) -value allplay -command crosstabWin
  $w.menu.opt add radiobutton -label CrosstabOptSwiss \
      -variable crosstab(type) -value swiss -command crosstabWin
  $w.menu.opt add radiobutton -label CrosstabOptKnockout \
      -variable crosstab(type) -value knockout -command crosstabWin
  $w.menu.opt add radiobutton -label CrosstabOptAuto \
      -variable crosstab(type) -value auto -command crosstabWin
  $w.menu.opt add separator
  $w.menu.opt add checkbutton -label CrosstabOptAges \
      -variable crosstab(ages) -onvalue "+ages" \
      -offvalue "-ages" -command crosstabWin
  $w.menu.opt add checkbutton -label CrosstabOptNats \
      -variable crosstab(countries) -onvalue "+countries" \
      -offvalue "-countries" -command crosstabWin
  $w.menu.opt add checkbutton -label CrosstabOptRatings \
      -variable crosstab(ratings) -onvalue "+ratings" -offvalue "-ratings" \
      -command crosstabWin
  $w.menu.opt add checkbutton -label CrosstabOptTitles \
      -variable crosstab(titles) -onvalue "+titles" -offvalue "-titles" \
      -command crosstabWin
  $w.menu.opt add checkbutton -label CrosstabOptBreaks \
      -variable crosstab(breaks) -onvalue "+breaks" \
      -offvalue "-breaks" -command crosstabWin
  $w.menu.opt add checkbutton -label CrosstabOptDeleted \
      -variable crosstab(deleted) -onvalue "+deleted" \
      -offvalue "-deleted" -command crosstabWin
  $w.menu.opt add separator
  $w.menu.opt add checkbutton -label CrosstabOptColors \
      -underline 0 -variable crosstab(colors) \
      -onvalue "+colors" -offvalue "-colors" -command crosstabWin
  $w.menu.opt add checkbutton -label CrosstabOptColumnNumbers \
      -underline 0 -variable crosstab(cnumbers) \
      -onvalue "+numcolumns" -offvalue "-numcolumns" -command crosstabWin
  $w.menu.opt add separator
  $w.menu.opt add checkbutton -label CrosstabOptGroup \
      -underline 0 -variable crosstab(groups) \
      -onvalue "+groups" -offvalue "-groups" -command crosstabWin
  
  $w.menu.sort add radiobutton -label CrosstabSortName \
      -variable crosstab(sort) -value name -command crosstabWin
  $w.menu.sort add radiobutton -label CrosstabSortRating \
      -variable crosstab(sort) -value rating -command crosstabWin
  $w.menu.sort add radiobutton -label CrosstabSortScore \
      -variable crosstab(sort) -value score -command crosstabWin
  
  $w.menu.color add radiobutton -label CrosstabColorPlain \
      -variable crosstab(text) -value plain -command crosstabWin
  $w.menu.color add radiobutton -label CrosstabColorHyper \
      -variable crosstab(text) -value hypertext -command crosstabWin
  
  $w.menu.helpmenu add command -label CrosstabHelpCross \
      -accelerator F1 -command {helpWindow Crosstable}
  $w.menu.helpmenu add command -label CrosstabHelpIndex \
      -command {helpWindow Index}
  
  ::crosstab::ConfigMenus
  
  frame $w.b
  pack $w.b -side bottom -fill x
  frame $w.f
  pack $w.f -side top -fill both -expand true
  text $w.f.text -width $::winWidth($w) -height $::winHeight($w) \
      -wrap none -font font_Fixed \
      -background white -yscroll "$w.f.ybar set" \
      -xscroll "$w.f.xbar set" -setgrid 1 -cursor top_left_arrow
  ::htext::init $w.f.text
  $w.f.text tag configure bgGray -background gray95
  scrollbar $w.f.ybar -command "$w.f.text yview"
  scrollbar $w.f.xbar -orient horizontal -command "$w.f.text xview"
  grid $w.f.text -row 0 -column 0 -sticky nesw
  grid $w.f.ybar -row 0 -column 1 -sticky nesw
  grid $w.f.xbar -row 1 -column 0 -sticky nesw
  grid rowconfig $w.f 0 -weight 1 -minsize 0
  grid columnconfig $w.f 0 -weight 1 -minsize 0
  button $w.b.stop -textvar ::tr(Stop) -state disabled \
      -command { set ::htext::interrupt 1 }
  menubutton $w.b.type -text "" -menu $w.b.type.menu \
      -relief raised -bd 2 -indicatoron 1
  menu $w.b.type.menu
  $w.b.type.menu add radiobutton -label [tr CrosstabOptAll] \
      -variable crosstab(type) -value allplay -command crosstabWin
  $w.b.type.menu add radiobutton -label [tr CrosstabOptSwiss] \
      -variable crosstab(type) -value swiss -command crosstabWin
  $w.b.type.menu add radiobutton -label [tr CrosstabOptKnockout] \
      -variable crosstab(type) -value knockout -command crosstabWin
  $w.b.type.menu add radiobutton -label [tr CrosstabOptAuto] \
      -variable crosstab(type) -value auto -command crosstabWin
  button $w.b.update -textvar ::tr(Update) -command crosstabWin
  button $w.b.cancel -textvar ::tr(Close) -command {
    focus .
    destroy .crosstabWin
  }
  button $w.b.setfilter -textvar ::tr(SetFilter) -command {
    ::search::filter::reset
    ::search::filter::negate
    sc_game crosstable filter
    ::windows::gamelist::Refresh
  }
  button $w.b.addfilter -textvar ::tr(AddToFilter) -command {
    sc_game crosstable filter
    ::windows::gamelist::Refresh
  }
  pack $w.b.cancel $w.b.update $w.b.type \
      -side right -pady 3 -padx 5
  pack $w.b.setfilter $w.b.addfilter -side left -pady 3 -padx 5
  
  bind $w <Configure> "recordWinSize $w"
  bind $w <F1> { helpWindow Crosstable }
  bind $w <Return> { .crosstabWin.b.update invoke }
  bind $w <Escape> { .crosstabWin.b.cancel invoke }
  bind $w <Up> { .crosstabWin.f.text yview scroll -1 units }
  bind $w <Down> { .crosstabWin.f.text yview scroll 1 units }
  bind $w <Prior> { .crosstabWin.f.text yview scroll -1 pages }
  bind $w <Next> { .crosstabWin.f.text yview scroll 1 pages }
  bind $w <Left> { .crosstabWin.f.text xview scroll -1 units }
  bind $w <Right> { .crosstabWin.f.text xview scroll 1 units }
  bind $w <Key-Home> {
    .crosstabWin.f.text xview moveto 0
  }
  bind $w <Key-End> {
    .crosstabWin.f.text xview moveto 0.99
  }
  standardShortcuts $w
  
  # MouseWheel Bindings:
  bind $w <MouseWheel> { .crosstabWin.f.text yview scroll [expr {- (%D / 120)}] units}
  if {! $::windowsOS} {
    bind $w <Button-4> { .crosstabWin.f.text yview scroll -1 units }
    bind $w <Button-5> { .crosstabWin.f.text yview scroll  1 units }
  }
  
  ::crosstab::Refresh
}

proc crosstabWin {} {
  ::crosstab::Open
}

proc ::crosstab::Refresh {} {
  global crosstab
  set w .crosstabWin
  if {! [winfo exists $w]} { return }
  
  switch $crosstab(type) {
    allplay  { $w.b.type configure -text [tr CrosstabOptAll] }
    swiss    { $w.b.type configure -text [tr CrosstabOptSwiss] }
    knockout { $w.b.type configure -text [tr CrosstabOptKnockout] }
    auto     { $w.b.type configure -text [tr CrosstabOptAuto] }
  }
  $w.f.text configure -state normal
  $w.f.text delete 1.0 end
  busyCursor .
  $w.f.text configure -state disabled
  update idle
  $w.b.stop configure -state normal
  foreach button {update cancel setfilter addfilter type} {
    $w.b.$button configure -state disabled
  }
  pack $w.b.stop -side right -padx 5 -pady 3
  catch {grab $w.b.stop}
  update
  catch {sc_game crosstable $crosstab(text) $crosstab(sort) $crosstab(type) \
        $crosstab(ratings) $crosstab(countries) $crosstab(titles) \
        $crosstab(colors) $crosstab(groups) $crosstab(ages) \
        $crosstab(breaks) $crosstab(cnumbers) $crosstab(deleted)} result
  $w.f.text configure -state normal
  if {$crosstab(text) == "plain"} {
    $w.f.text insert end $result
  } else {
    ::htext::display $w.f.text $result
  }
  # Shade every second line to help readability:
  set lastLineNum [expr {int([$w.f.text index end])}]
  for {set i 2} {$i <= $lastLineNum} {incr i 2} {
    $w.f.text tag add bgGray $i.0 "$i.0 lineend +1c"
  }
  unbusyCursor .
  catch {grab release $w.b.stop}
  $w.b.stop configure -state disabled
  pack forget $w.b.stop
  foreach button {update cancel setfilter addfilter type} {
    $w.b.$button configure -state normal
  }
  $w.f.text configure -state disabled
  raiseWin $w
}

