#
# Copyright (C) 2020 Uwe Klimmek
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Implements a "dark" theme.

namespace eval ttk::theme::dark {
    array set colors {
        background     "#323232"
        foreground     "#e0e0e0"
        disabledfg     "#a0a0a0"
        buttonbg       "#3b3b3e"
        buttonbgdark   "#2b2b2e"
        buttonbglight  "#4b4b4e"
        labelframe     "#a5a6a9"
        fieldbg        "#1e1e1e"
        fieldborder    "#292929"
        darkcolor      "#222222"
        lightcolor     "#656669"
        notebookborder "#555659"
        selectbg       "#555659"
        selectfg       "#ffffff"
        through        "#353639"
    }

    ttk::style theme create dark -parent clam -settings {
        set basecol DodgerBlue3 ;# Alternative: #3b6dce Basecolor, change here to have new topic for the theme
        # -----------------------------------------------------------------------------
        # Theme defaults
        ttk::style configure "." \
            -foreground $colors(foreground) \
            -background $colors(background) \
            -darkcolor $colors(darkcolor) \
            -lightcolor $colors(lightcolor) \
            -troughcolor $colors(through) \
            -selectbackground $basecol \
            -selectforeground $colors(selectfg) \
            -activebackground $basecol \
            -activeforeground $colors(selectfg) \
            -indicatorbackground $colors(fieldbg) \
            -indicatorforeground $basecol \
            -fieldbackground $colors(fieldbg) \
            -bordercolor $colors(fieldborder) -selectborderwidth 0 \
            -arrowcolor $basecol \
            ;

        ttk::style map "." \
            -foreground [list disabled $colors(disabledfg)] \
            -background [list active $colors(buttonbglight)] \
            -fieldbackground [list disabled $colors(background)] \
            -indicatorbackground [list \
                pressed $colors(background) \
                alternate $colors(disabledfg) \
                disabled $colors(background)] \
            -indicatorforeground [list disabled $colors(disabledfg)] \
            -arrowcolor [list disabled $colors(disabledfg)] \
        ;

        set borders [list disabled $colors(fieldborder) {active pressed} $basecol \
                    {disabled selected} $colors(fieldborder) {pressed selected} $basecol pressed $basecol \
                    {active selected} $basecol active $basecol selected $basecol) focus $basecol ]
        set buttonborder [list disabled $colors(fieldborder) {active pressed} $basecol \
                    {disabled selected} $colors(fieldborder) {pressed selected} $basecol pressed $basecol \
                    {active selected} $basecol active $basecol selected $basecol) ]
        set buttonsbg [list disabled $colors(through) pressed $colors(buttonbgdark) \
                    active $colors(buttonbglight) ]
        set scrollbars [list pressed $colors(buttonbglight) active $colors(buttonbglight) \
                    disabled $colors(through) !pressed $colors(buttonbg) ]
        set scrollbarsl [list pressed $colors(darkcolor) active $colors(lightcolor) disabled $colors(through) ]
        set scrollbarsd [list pressed $colors(lightcolor) active $colors(darkcolor) disabled $colors(through) ]
        ttk::style configure TButton -anchor center -relief raised -padding 4 -background $colors(buttonbg)
        ttk::style map TButton -bordercolor $buttonborder -background $buttonsbg
        ttk::style map TMenubutton -bordercolor $borders -background $buttonsbg
        ttk::style map Toolbutton -relief [list active raised] -bordercolor $borders -foreground [list disabled $colors(disabledfg)]
        ttk::style map TSpinbox -bordercolor $borders -background $buttonsbg
        ttk::style map TCombobox -bordercolor $borders -background $buttonsbg -lightcolor $borders
        ttk::style map TEntry -bordercolor $borders -lightcolor $borders
        ttk::style map TScale -bordercolor [list active $basecol ]

        ttk::style configure Toolbutton -padding 0
        ttk::style configure TMenubutton -anchor center -padding 4 -relief raised -background $colors(buttonbg)
        ttk::style configure TScale -troughcolor $colors(through)
        ttk::style configure TEntry -foreground $colors(selectfg) \
            -padding {2 0} -lightcolor $colors(fieldbg)
        ttk::style configure TCombobox -anchor center -padding {5 1} -relief raised -borderwidth 1 \
            -lightcolor $colors(fieldbg)
        ttk::style configure TSpinbox -lightcolor $colors(fieldbg) -arrowsize 12

        ttk::style configure TNotebook.Tab -bordercolor $colors(notebookborder) -border {4 2 4 2} -padding {3 2 3 2} -lightcolor $colors(background)
        ttk::style map TNotebook.Tab -background [list active $colors(background) selected $colors(background) \
             !selected $colors(buttonbgdark)] -bordercolor [list active $basecol ] -lightcolor [list active $basecol ]
        ttk::style configure TPanedwindow -sashrelief raised

        ttk::style configure TLabelframe -bordercolor $colors(labelframe) -relief raised -padding 4
        ttk::style configure TProgressbar -background $basecol

        ttk::style configure TScrollbar -troughcolor $colors(through) -bordercolor $colors(buttonbg) \
			-background $colors(through) -arrowcolor $colors(lightcolor)
        ttk::style map TScrollbar -background $scrollbars -lightcolor $scrollbarsl -darkcolor $scrollbarsd
        ttk::style configure Heading -relief raised
        ttk::style map Heading -bordercolor $buttonborder -background $buttonsbg
        ttk::style configure Treeview -background $colors(fieldbg)
        ttk::style map Treeview -background [list selected $basecol disabled $colors(darkcolor)] \
            -foreground [list selected $colors(selectfg)]
    }
}
