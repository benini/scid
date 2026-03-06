
namespace eval ::validate {

    # -------------------------------------------------------------------------
    # ::validate::integer --
    #   Validates integer input.
    #   Arguments:
    #     P   : The proposed text content.
    #     min : (Optional) If >= 0, prevents typing '-'.
    #     max : (Optional) If set, prevents typing values larger than this.
    # -------------------------------------------------------------------------
    proc integer {P {min ""} {max ""}} {
        if {$P eq ""} { return 1 }
        if {$P eq "-" && $min < 0} { return 1 }
        # Prevent octal (https://wiki.tcl-lang.org/page/Tcl+and+octal+numbers)
        if {[scan $P %d] ne $P} { return 0 }
        # Enforce min only if P is negative.
        #   If Min=10 and P=1, P is invalid but P is "on the way" to 10. We must allow it.
        #   If Min=-10 and P=-20, P is invalid and adding digits (e.g. -200) makes it worse. Block it.
        if {$min ne "" && $P < $min && $P < 0} { return 0 }
        if {$max ne "" && $P > $max} { return 0 }
        return 1
    }

    # -------------------------------------------------------------------------
    # ::validate::date --
    #   Validates date input keystroke-by-keystroke.
    #   Accepts format: YYYY.MM.DD (with "?" as placeholder).
    #   Each segment can contain only digits or only "?" marks, not both.
    #   Digit segments are checked against their maximum value.
    #   Arguments:
    #     P   : The proposed text content.
    #     sep : (Optional) Separator character. Default ".".
    # -------------------------------------------------------------------------
    proc date {P {sep "."}} {
        set max_values [list 2047 12 31]
        set i 0
        foreach seg [split $P $sep] {
            # Max 3 segments (year, month, day).
            if {$i >= 3} { return 0 }

            set max_v [lindex $max_values $i]
            if {[string length $seg] > [string length $max_v]} { return 0 }

            # Must be only digits or only "?", not both, not other chars.
            if {[regexp {^\d+$} $seg]} {
                if {[scan $seg %d] > $max_v} { return 0 }
            } else {
                if {[string trim $seg "?"] ne ""} { return 0 }
            }
            incr i
        }
        return 1
    }
}

# ::utils::validate::roundScale
# will round var to the next integer which is a multiple of tickinterval
# given its current value
proc ::utils::validate::roundScale { var tickinterval value } {
  set $var [expr int($value/$tickinterval ) * $tickinterval]
}

# ::utils::validate::floatScale
# returns a float value with 1 decimal
proc ::utils::validate::floatScale { var tickinterval value } {
  set $var [format "%.1f" [expr ($value/$tickinterval ) * $tickinterval] ]
}
