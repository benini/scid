###
#
# ToolTips
#

namespace eval ::utils::tooltip {}

set ::utils::tooltip::showToolTips 1
set ::utils::tooltip::time 0
set ::utils::tooltip::enteredWidget {}
set ::utils::tooltip::tooltipDelay 400
set ::utils::tooltip::tooltipWidth 30

array set ::utils::tooltip::message {}

# Construct tooltip window:
#
toplevel .tooltip
label .tooltip.text -relief solid -borderwidth 1 -justify left \
    -background #f5f5f5 -padx 3 -pady 1 -font font_Tiny
pack .tooltip.text -side left
wm overrideredirect .tooltip 1
if { $macOS }  {
  ::tk::unsupported::MacWindowStyle style .tooltip help none
}
bind .tooltip <Button-1> { wm withdraw .tooltip }
wm withdraw .tooltip


# ::utils::tooltip::Set
#
#   Set the tooltip message for <button> to be <msg>
#
proc ::utils::tooltip::Set { button msg } {
  variable message
  set msg [string trim $msg]
  if {$msg == ""} { return }
  regsub {\\n} $msg "\n" msg
  set msg [::utils::tooltip::trimWidth $msg]
  set message($button) $msg
  bind $button <Any-Enter> +[list ::utils::tooltip::Enter $button]
  bind $button <Any-Leave> +[list ::utils::tooltip::Leave $button]
}

# ::utils::tooltip::SetTag
#
#   remove a tooltip message for a given button
#
proc ::utils::tooltip::UnSet { button } {
  variable message
  if { [info exists ::utils::tooltip::message($button)] } {
	  unset message($button)
	  bind $button <Any-Enter> ""
	  bind $button <Any-Leave> ""
  }
}

# ::utils::tooltip::SetTag
#
#   Set the tooltip message for a text with tag <tag> to be <msg>
#
proc ::utils::tooltip::SetTag { text_widget msg tag } {
  variable message
  set msg [string trim $msg]
  if {$msg == ""} { return }
  regsub {\\n} $msg "\n" msg
  set msg [::utils::tooltip::trimWidth $msg]
  set message(${tag}_$text_widget) $msg
  $text_widget tag bind $tag <Any-Enter> +[list ::utils::tooltip::Enter ${tag}_$text_widget]
  $text_widget tag bind $tag <Any-Leave> +[list ::utils::tooltip::Leave ${tag}_$text_widget]
}

# ::utils::tooltip::Enter
#
#   Handles the mouse entering a button which has a tooltip.
#
proc ::utils::tooltip::Enter {button} {
  variable showToolTips
  variable enteredWidget
  variable tooltipDelay
  
  if {! $showToolTips} { return }
  set enteredWidget $button
  after $tooltipDelay [list ::utils::tooltip::Check $button]
}


# ::utils::tooltip::Check
#
#   Called a set time after the mouse has entered a button with a
#   tooltip, to check if it is still there. If so, the tooltip
#   message is displayed.
#
proc ::utils::tooltip::Check {button} {
  variable enteredWidget
  
  if {$enteredWidget != $button} {
    # The mouse cursor has moved somewhere else; display no tooltip
    return
  }
  
  if {! [info exists ::utils::tooltip::message($button)]} { return }
  
  .tooltip.text configure -text [tr $::utils::tooltip::message($button)]
  set x [winfo pointerx .]
  set y [winfo pointery .]
  incr x 10
  incr y 4
  catch {wm transient .tooltip [winfo toplevel $button]}
  
  # make the tooltip visible
  set maxw [ winfo vrootwidth .]
  set maxh [ winfo vrootheight .]
  set w [winfo reqwidth .tooltip]
  set h [winfo reqheight .tooltip]
  if { [expr $x + $w] > $maxw } {
    set x [expr $maxw - $w]
  }
  if { [expr $y + $h] > $maxh } {
    set y [expr $maxh - $h]
  }
  
  catch {wm geometry .tooltip +$x+$y}
  wm deiconify .tooltip
  raise .tooltip
  
  # Automatically erase tooltip after a short delay
  after 15000 [ list ::utils::tooltip::Leave $button ]
}


# ::utils::tooltip::Leave
#
#   Handles the mouse leaving a button which has a tooltip.
#
proc ::utils::tooltip::Leave {button} {
  after cancel [ list ::utils::tooltip::Leave $button ]
  variable showToolTips
  if {! $showToolTips} { return }
  wm withdraw .tooltip
  after cancel [list ::utils::tooltip::Check $button]
}

# ::utils::tooltip::ToWidth
#
#   Returns the arg with CR every tooltipWidth chars at most
#
proc ::utils::tooltip::trimWidth { msg } {
  set ret ""
  foreach line [split $msg "\n"] {
    
    if {[string length $line] < $::utils::tooltip::tooltipWidth} {
      append ret "$line\n"
      continue
    } else  {
      # must split the line
      set words [split $line " "]
      
      while {[llength $words] > 0} {
        set tmp [lindex $words 0]
        set words [lreplace $words 0 0]
        while {[string length "$tmp [lindex $words 0]"] < $::utils::tooltip::tooltipWidth && [llength $words] > 0} {
          append tmp " " [lindex $words 0]
          set words [lreplace $words 0 0]
        }
        append ret $tmp "\n"
      }
      
    }
  }
  return [string trim $ret]
}
