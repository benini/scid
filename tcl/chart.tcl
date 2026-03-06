########################################################################
# Copyright (C) 2026 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

# ==============================================================================
# Draws an evaluation chart on a Tk canvas:
# - Line chart of evaluation
# - Filled areas above/below 0 (positive/negative)
#
# Public API:
#   - ::chart::init w ?options?
#         Initialize the canvas 'w'. Options override defaults.
#   - ::chart::setDataPoint w xIndex score ?callback?
#         Add or update a datapoint. callback receives {xIndex score}.
#   - ::chart::clear w
#         Clear all data and reset the chart.
#   - ::chart::moveCursorLine w xIndex
#         Move the vertical cursor line at a specific data point.
#
# Options (passed to init):
#   COLOR_AREA_POS, COLOR_AREA_NEG, COLOR_AXIS, COLOR_LINE, COLOR_CURSOR,
#   COLOR_DOT, FONT, MAX_ABS (y-scale), PADX, PADY
#
# Usage Example:
#   canvas .c
#   pack .c -fill both -expand 1
#   ::chart::init .c {MAX_ABS 500}
#
#   proc fn_callback {xIndex score} {
#       if {$score eq ""} {
#           puts "User clicked on move $xIndex"
#           return ""
#       }
#       return "1. e4\n[expr {$score/100.0}]"
#   }
#   ::chart::setDataPoint .c 1 30 fn_callback
#   ::chart::moveCursorLine .c 1   ;# Show line at x position 1
#   ::chart::moveCursorLine .c     ;# Hide line
#
# ==============================================================================

namespace eval ::chart {
    variable DEFAULTS {
        COLOR_AREA_POS "#605a54"
        COLOR_AREA_NEG "#000000"
        COLOR_AXIS     "#66625f"
        COLOR_LINE     "#FF5E0E"
        COLOR_CURSOR   "#d68f30"
        COLOR_DOT      "#d68f30"
        FONT           "TkDefaultFont"
        MAX_ABS        400.0
        PADX           2
        PADY           2
    }

    # Widget state array:
    #   m_($w,config)       - Configuration dict
    #   m_($w,data)         - Dict: xIndex -> {score callback}
    #   m_($w,xMax)         - Current maximum x index
    #   m_($w,currentX)     - Currently highlighted x index (for cache)
    #   m_($w,cursorLineX)  - Current cursor line x index (for resize)
    # Cached / derived data:
    #   m_($w,sortedPoints) - Sorted list of x indices (cached)
    #   m_($w,segments)     - List of connected segments
    #   m_($w,geometry)     - List: {usableW usableH midY padX padY rightLimit}
    variable m_
}

# Initialize widget state and bindings.
proc ::chart::init {w {options {}}} {
    variable m_
    variable DEFAULTS

    set m_($w,config) [dict merge $DEFAULTS $options]

    set m_($w,data)         [dict create]
    set m_($w,sortedPoints) {}
    set m_($w,xMax)         1
    set m_($w,segments)     {}
    set m_($w,geometry)     [list 0 0 0 0 0 0]
    set m_($w,currentX)     -1
    set m_($w,cursorLineX)  ""

    $w delete all

    $w create line 0 0 0 0 -fill [dict get $m_($w,config) COLOR_AXIS] \
        -width 1 -tags "axis"

    $w create line 0 0 0 0 -fill [dict get $m_($w,config) COLOR_CURSOR] \
        -dash . -tags "cursor_line" -state hidden
    $w create oval 0 0 0 0 -fill [dict get $m_($w,config) COLOR_DOT] \
        -outline [dict get $m_($w,config) COLOR_CURSOR] -width 2 \
        -tags "cursor_dot" -state hidden

    if {![winfo exists $w.tip]} {
        ttk::label $w.tip -font [dict get $m_($w,config) FONT]
    }
    bind $w.tip <Motion>   [format {::chart::_onMotion %s [expr {%%X-[winfo rootx %s]}]} $w $w]
    bind $w.tip <Button-1> [format {::chart::_onClick %s [expr {%%X-[winfo rootx %s]}]} $w $w]
    bind $w.tip <Destroy>  [list apply {{w} {
        after cancel [list ::chart::_render $w]
        array unset ::chart::m_ "$w,*"
    }} $w]

    bind $w <Configure> [list ::chart::_onConfigure %W]
    bind $w <Motion>    [list ::chart::_onMotion %W %x]
    bind $w <Leave>     [list ::chart::_onLeave %W %d]
    bind $w <Button-1>  [list ::chart::_onClick %W %x]
}

# Reset all data and redraw.
proc ::chart::clear {w {xMax 1}} {
    variable m_
    set m_($w,data)         [dict create]
    set m_($w,sortedPoints) {}
    set m_($w,xMax)         [expr {max(1, $xMax)}]
    set m_($w,segments)     {}
    set m_($w,currentX)     -1
    set m_($w,cursorLineX)  ""
    _render $w
}

# Show or hide the vertical cursor line at a specific x position.
# Call without xIndex argument to hide the line.
proc ::chart::moveCursorLine {w {xIndex ""}} {
    variable m_
    set m_($w,cursorLineX) $xIndex

    if {$xIndex eq "" || $xIndex > $m_($w,xMax)} {
        $w itemconfigure "cursor_line" -state hidden
        return
    }

    lassign $m_($w,geometry) usableW usableH midY padX padY rightLimit
    if {$usableW <= 0} { return }

    set px [expr {$padX + (double($xIndex) / $m_($w,xMax) * $usableW)}]
    $w coords "cursor_line" $px $padY $px [expr {$padY + $usableH}]
    $w itemconfigure "cursor_line" -state normal
}

# Add or update a data point. Callback receives {xIndex score} and returns the label text.
proc ::chart::setDataPoint {w xIndex score callback} {
    variable m_
    if {![dict exists $m_($w,data) $xIndex]} {
        tailcall ::chart::newDataPoint $w $xIndex $score $callback
    }

    dict set m_($w,data) $xIndex [list $score $callback]
    _render $w $xIndex

    # If this point is currently displayed, update the label
    if {$m_($w,currentX) == $xIndex} {
        set m_($w,currentX) -1  ;# Reset cache to force the update
        _onMotion $w [expr {[winfo pointerx $w] - [winfo rootx $w]}]
    }
}

proc ::chart::newDataPoint {w xIndex score callback} {
    variable m_
    dict set m_($w,data) $xIndex [list $score $callback]

    lappend m_($w,sortedPoints) $xIndex
    if {$xIndex > $m_($w,xMax)} {
        set m_($w,xMax) $xIndex
    } else {
        set m_($w,sortedPoints) [lsort -integer $m_($w,sortedPoints)]
    }

    # Rebuild segments (groups of consecutive x indices)
    set xPrevious [lindex $m_($w,sortedPoints) 0]
    set currentSegment {}
    set segments [list]
    foreach xIdx $m_($w,sortedPoints) {
        if {$xIdx - $xPrevious > 1} {
            lappend segments $currentSegment
            set currentSegment {}
        }
        lappend currentSegment $xIdx
        set xPrevious $xIdx
    }
    if {[llength $currentSegment] > 0} {
        lappend segments $currentSegment
    }

    set m_($w,segments) $segments
    _render $w
}

# Handle resize with debounced rendering.
proc ::chart::_onConfigure {w} {
    variable m_
    set config $m_($w,config)
    set padX [dict get $config PADX]
    set padY [dict get $config PADY]

    set newW [winfo width $w]
    set newH [winfo height $w]

    set usableW [expr {$newW - (2 * $padX)}]
    set usableH [expr {$newH - (2 * $padY)}]
    set midY       [expr {$padY + ($usableH / 2)}]
    set rightLimit [expr {$padX + $usableW}]

    lassign $m_($w,geometry) oldW oldH
    if {$usableW == $oldW && $usableH == $oldH} {
        return
    }

    set m_($w,geometry) [list $usableW $usableH $midY $padX $padY $rightLimit]
    set m_($w,currentX) -1

    $w coords "axis" $padX $midY $rightLimit $midY
    after cancel [list ::chart::_render $w]
    after 10     [list ::chart::_render $w]
}

# Render the chart. If dataPoint is specified, only re-render the affected segment.
proc ::chart::_render {w {dataPoint ""}} {
    variable m_

    set data $m_($w,data)
    if {[dict size $data] == 0} return

    lassign $m_($w,geometry) usableW usableH midY padX padY rightLimit
    if {$usableW < 1} return

    set config    $m_($w,config)
    set maxAbs    [dict get $config MAX_ABS]

    set xMax      $m_($w,xMax)
    set xFactor   [expr {double($usableW) / $xMax}]
    set yFactor   [expr {($usableH / 2.0) / $maxAbs}]
    set negMaxAbs [expr {-$maxAbs}]

    if {$dataPoint eq ""} {
        $w delete "segment"
        moveCursorLine $w $m_($w,cursorLineX)
    }

    set idx -1
    foreach segment $m_($w,segments) {
        incr idx

        if {$dataPoint ne ""} {
            if {$dataPoint ni $segment} { continue }
            $w delete "segment_$idx"
        }

        set tags [list "segment" "segment_$idx"]

        # Single point: draw as dot
        if {[llength $segment] == 1} {
            set xIndex [lindex $segment 0]
            set score [lindex [dict get $data $xIndex] 0]

            set x [expr {$padX + $xIndex * $xFactor}]
            if {$score > $maxAbs} { set score $maxAbs }
            if {$score < $negMaxAbs} { set score $negMaxAbs }
            set y [expr {$midY - $score * $yFactor}]

            $w create oval [expr {$x-2}] [expr {$y-2}] [expr {$x+2}] [expr {$y+2}] \
                -fill [dict get $config COLOR_LINE] -outline "" -tags $tags
            continue
        }

        set lineCoords {}
        set posArea    {}
        set negArea    {}

        set prevX ""; set prevY ""
        set startX ""; set endX ""

        foreach xIndex $segment {
            set score [lindex [dict get $data $xIndex] 0]

            set x [expr {$padX + $xIndex * $xFactor}]
            if {$score > $maxAbs} { set score $maxAbs }
            if {$score < $negMaxAbs} { set score $negMaxAbs }
            set y [expr {$midY - $score * $yFactor}]

            if {$startX eq ""} { set startX $x }
            set endX $x

            # Interpolate zero-crossing point
            if {$prevY ne ""} {
                if {($prevY < $midY && $y > $midY) || ($prevY > $midY && $y < $midY)} {
                    set ratio  [expr {($midY - $prevY) / ($y - $prevY)}]
                    set crossX [expr {$prevX + ($x - $prevX) * $ratio}]
                    lappend posArea $crossX $midY
                    lappend negArea $crossX $midY
                }
            }

            lappend lineCoords $x $y

            if {$y < $midY} {
                lappend posArea $x $y
                lappend negArea $x $midY
            } else {
                lappend posArea $x $midY
                lappend negArea $x $y
            }

            set prevX $x
            set prevY $y
        }

        # Close polygons
        set posArea [concat [list $startX $midY] $posArea [list $endX $midY]]
        set negArea [concat [list $startX $midY] $negArea [list $endX $midY]]

        $w create polygon $negArea -fill [dict get $config COLOR_AREA_NEG] \
            -outline "" -tags $tags
        $w create polygon $posArea -fill [dict get $config COLOR_AREA_POS] \
            -outline "" -tags $tags
        $w create line $lineCoords -fill [dict get $config COLOR_LINE] \
            -width 2 -capstyle round -joinstyle round -tags [concat $tags eval_line]
    }

    $w raise "axis"
    $w raise "eval_line"
    $w raise "cursor_line"
    $w raise "cursor_dot"
}

# HELPER: Map mouse X coordinate to data index.
proc ::chart::_getDataAtX {w mouseX} {
    variable m_
    if {[dict size $m_($w,data)] == 0} { return {} }

    lassign $m_($w,geometry) usableW usableH midY padX padY rightLimit
    if {$usableW <= 0} { return {} }

    set xMax   $m_($w,xMax)
    set xIndex [expr {round(double($mouseX - $padX) / $usableW * $xMax)}]
    if {$xIndex < 0} { set xIndex 0 }
    if {$xIndex > $xMax} { set xIndex $xMax }
    if {![dict exists $m_($w,data) $xIndex]} { return {} }

    set pointX [expr {$padX + (double($xIndex) / $xMax * $usableW)}]
    return [concat [dict get $m_($w,data) $xIndex] $xIndex $pointX]
}

# Handle mouse click: trigger callback with empty score to signal action.
proc ::chart::_onClick {w mouseX} {
    lassign [::chart::_getDataAtX $w $mouseX] -> callback xIndex
    if {$xIndex ne ""} {
        {*}$callback $xIndex ""
    }
}

# Handle mouse movement: show the data label.
proc ::chart::_onMotion {w mouseX} {
    lassign [::chart::_getDataAtX $w $mouseX] score callback xIndex px
    if {$xIndex eq ""} {
        ::chart::_onLeave $w
        return
    }

    variable m_
    if {$m_($w,currentX) == $xIndex} {
        return
    }
    set m_($w,currentX) $xIndex

    lassign $m_($w,geometry) usableW usableH midY padX padY rightLimit

    set maxAbs [dict get $m_($w,config) MAX_ABS]
    set s $score
    if {$s > $maxAbs} {set s $maxAbs} elseif {$s < -$maxAbs} {set s -$maxAbs}
    set py [expr {$midY - int($s / $maxAbs * ($usableH / 2.0))}]

    $w coords "cursor_dot" [expr {$px-4}] [expr {$py-4}] [expr {$px+4}] [expr {$py+4}]
    $w itemconfigure "cursor_dot" -state normal

    $w.tip configure -text [{*}$callback $xIndex $score]

    set tipW [winfo reqwidth $w.tip]
    set tipX [expr {int($px) + 15}]
    if {$tipX + $tipW > $rightLimit} {
        set tipX [expr {int($px) - $tipW - 10}]
    }
    set tipH [winfo reqheight $w.tip]
    set maxY [expr {$padY + $usableH - $tipH}]
    set tipY [expr {max($padY, min($maxY, $py - 30))}]

    place $w.tip -x $tipX -y $tipY
    raise $w.tip
}

# Hide cursor elements when mouse leaves the widget.
proc ::chart::_onLeave {w {detail ""}} {
    if {$detail ne "NotifyInferior"} {
        set ::chart::m_($w,currentX) -1
        $w itemconfigure "cursor_dot" -state hidden
        place forget $w.tip
    }
}
