###
#
# ToolTips
#

namespace eval ::utils::tooltip {}

set ::utils::tooltip::showToolTips 1
set ::utils::tooltip::time 0
set ::utils::tooltip::enteredWidget {}
set ::utils::tooltip::tooltipDelay 400

array set ::utils::tooltip::message {}

# Construct tooltip window:
#
toplevel .tooltip
label .tooltip.text -relief solid -borderwidth 1 -justify left \
  -background lightYellow -padx 3 -pady 1
pack .tooltip.text -side left
wm overrideredirect .tooltip 1
if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"}  {
  ::tk::unsupported::MacWindowStyle style .tooltip help none
}
wm withdraw .tooltip


# ::utils::tooltip::Set
#
#   Set the tooltip message for <button> to be <msg>
#
proc ::utils::tooltip::Set {button msg {text_image ""} {tag ""} } {
  variable message
  set msg [string trim $msg]
  if {$msg == ""} { return }
  regsub {\\n} $msg "\n" msg
  set message($button) $msg
  if { $text_image == ""} {
    bind $button <Any-Enter> +[list ::utils::tooltip::Enter $button]
    bind $button <Any-Leave> +[list ::utils::tooltip::Leave $button]
  } else  {
    $text_image tag bind $tag <Any-Enter> +[list ::utils::tooltip::Enter $button]
    $text_image tag bind $tag <Any-Leave> +[list ::utils::tooltip::Leave $button]
  }
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
  catch {wm geometry .tooltip +$x+$y}
  wm deiconify .tooltip
  raise .tooltip
}


# ::utils::tooltip::Leave
#
#   Handles the mouse leaving a button which has a tooltip.
#
proc ::utils::tooltip::Leave {button} {
  variable showToolTips
  if {! $showToolTips} { return }
  wm withdraw .tooltip
  after cancel [list ::utils::tooltip::Check $button]
}

