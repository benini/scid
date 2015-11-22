###
#
# Tooltips
#

package require tooltip

namespace eval ::utils::tooltip {
  variable font

  if {![info exists font]} {
    set font TkDefaultFont
  }

  # Undocumented tooltip variable that allows users to extend / override
  # label creation options.
  set tooltip::labelOpts [list -highlightthickness 0 -relief solid -bd 1 \
      -background lightyellow -fg black -font $font]

  proc Set {button msg} {
    tooltip::tooltip $button $msg
  }

  proc SetTag {text_widget msg tag} {
    tooltip::tooltip $text_widget -tag $tag $msg
  }
}
