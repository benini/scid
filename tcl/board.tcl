# board.tcl: part of Scid
# Copyright (C) 2001-2003 Shane Hudson. All rights reserved.

# letterToPiece
#    Array that maps piece letters to their two-character value.
#
array set ::board::letterToPiece [list \
    "R" wr "r" br "N" wn "n" bn "B" wb "b" bb \
    "Q" wq "q" bq "K" wk "k" bk "P" wp "p" bp "." e \
    ]

# List of color schemes: each sublist contains a reference name (not used),
# then lite, dark, highcolor, bestcolor, white, black, w border, b border.
#
set colorSchemes {
  { "Blue-white" "#f3f3f3" "#7389b6" "#f3f484" "#b8cbf8" "#ffffff" "#000000" "#000000" "#ffffff" }
  { "Green-Yellow" "#e0d070" "#70a070" "#b0d0e0" "#bebebe" }
  { "Brown" "#d0c0a0" "#a08050" "#b0d0e0" "#bebebe" }
  { "Blue-ish" "#d0e0d0" "#80a0a0" "#b0d0e0" "#f0f0a0" }
  { "M. Thomas" "#e0d8b8" "#047c24" "#1c80e0" "#fe0000" }
  { "KM. Skontorp" "#ffdb86" "#ffa200" "#b0d0e0" "#bebebe" }
}
array set newColors {}

proc SetBoardTextures {} {
  global boardfile_dark boardfile_lite
  # handle cases of old configuration files
  image create photo bgl20 -height 20 -width 20
  image create photo bgd20 -height 20 -width 20
  if { [ catch { bgl20 copy $boardfile_lite -from 0 0 20 20 ; bgd20 copy $boardfile_dark -from 0 0 20 20 } ] } {
    set boardfile_dark emptySquare
    set boardfile_lite emptySquare
    bgl20 copy $boardfile_lite -from 0 0 20 20
    bgd20 copy $boardfile_dark -from 0 0 20 20
  }
  
  foreach size $::boardSizes {
    # create lite and dark squares
    image create photo bgl$size -width $size -height $size
    image create photo bgd$size -width $size -height $size
    bgl$size copy $boardfile_lite -from 0 0 $size $size
    bgd$size copy $boardfile_dark -from 0 0 $size $size
  }
}

SetBoardTextures

# chooseBoardTextures:
#   Dialog for selecting board textures.
#
proc chooseBoardTextures {i} {
  global boardfile_dark boardfile_lite
  
  set prefix [lindex $::textureSquare $i]
  set boardfile_dark ${prefix}-d
  set boardfile_lite ${prefix}-l
  SetBoardTextures
  
}

# chooseBoardColors:
#   Dialog for selecting board colors.
#
proc chooseBoardColors {{choice -1}} {
  global lite dark highcolor bestcolor
  global colorSchemes newColors
  
  set colors {lite dark highcolor bestcolor}
  
  set w .boardColorDialog
  
  if {[winfo exists $w]} {
    # Just update the dialog box colors and return:
    if {$choice >= 0} {
      set list [lindex $colorSchemes $choice]
      set newColors(lite) [lindex $list 1]
      set newColors(dark) [lindex $list 2]
      set newColors(highcolor) [lindex $list 3]
      set newColors(bestcolor) [lindex $list 4]
    }
    set nlite $newColors(lite)
    set ndark $newColors(dark)
    
    foreach i {wr bn wb bq wk bp} {
      $w.bd.$i configure -background $ndark
    }
    foreach i {br wn bb wq bk wp} {
      $w.bd.$i configure -background $nlite
    }
    $w.bd.bb configure -background $newColors(highcolor)
    $w.bd.wk configure -background $newColors(bestcolor)
    foreach i $colors {
      $w.select.b$i configure -background $newColors($i)
    }
    
    foreach i {0 1 2 3} {
      set c $w.border.c$i
      $c itemconfigure dark -fill $dark -outline $dark
      $c itemconfigure lite -fill $lite -outline $lite
    }
    
    return
  }
  
  toplevel $w
  wm title $w "Scid: [tr OptionsBoardColors]"
  
  foreach i $colors { set newColors($i) [set $i] }
  set bd $w.bd
  pack [ttk::frame $bd] -side top -expand 1
  addHorizontalRule $w
  pack [ttk::frame $w.select] -side top -fill x
  addHorizontalRule $w
  pack [ttk::frame $w.preset] -side top -fill x
  pack [ttk::frame $w.texture] -side top -fill x
  addHorizontalRule $w
  pack [ttk::frame $w.border] -side top
  addHorizontalRule $w
  pack [ttk::frame $w.buttons] -side top -fill x
  
  set column 0
  foreach j {r n b q k p} {
    ttk::label $bd.w$j -image w${j}40
    ttk::label $bd.b$j -image b${j}40
    grid $bd.b$j -row 0 -column $column
    grid $bd.w$j -row 1 -column $column
    incr column
  }
  
  set f $w.select
  foreach row {0 1 0 1} column {0 0 2 2} c {
    lite dark highcolor bestcolor
  } n {
    LightSquares DarkSquares SelectedSquares SuggestedSquares
  } {
    button $f.b$c -image e20 -background [set $c] -command "
    set x \[ tk_chooseColor -initialcolor \$newColors($c) -title Scid \]
    if {\$x != \"\"} { set newColors($c) \$x; chooseBoardColors }
    "
    ttk::label $f.l$c -text "$::tr($n)  "
    grid $f.b$c -row $row -column $column
    grid $f.l$c -row $row -column [expr {$column + 1} ] -sticky w
  }
  
  # Border width option:
  set f $w.border
  foreach i {0 1 2 3} {
    if {$i != 0} { pack [ttk::frame $f.gap$i -width 20] -side left -padx 1 }
    set b $f.b$i
    ttk::radiobutton $b -text "$i:" -variable newborderwidth -value $i
    set c $f.c$i
    canvas $c -height 40 -width 40 -background black
    $c create rectangle 0 0 [expr {20 - $i}] [expr {20 - $i}] -tag dark
    $c create rectangle [expr {20 + $i}] [expr {20 + $i}] 40 40 -tag dark
    $c create rectangle 0 [expr {20 + $i}] [expr 20 - $i] 40 -tag lite
    $c create rectangle [expr {20 + $i}] 0 40 [expr {20 - $i}] -tag lite
    pack $b $c -side left -padx 1
    bind $c <Button-1> "set newborderwidth $i"
  }
  set ::newborderwidth $::borderwidth
  
  set count 0
  set psize 40
  foreach list $colorSchemes {
    set f $w.preset.p$count
    pack [ttk::frame $f] -side left -padx 5
    ttk::label $f.blite -image bp40 -background [lindex $list 1]
    ttk::label $f.bdark -image bp40 -background [lindex $list 2]
    ttk::label $f.wlite -image wp40 -background [lindex $list 1]
    ttk::label $f.wdark -image wp40 -background [lindex $list 2]
    ttk::button $f.select -text [expr {$count + 1}] -command "chooseBoardColors $count ; \
        set ::boardfile_dark emptySquare ; \
        set ::boardfile_lite emptySquare ; \
        ::SetBoardTextures "
    foreach i {blite bdark wlite wdark} {
      bind $f.$i <1> "chooseBoardColors $count ; \
          set ::boardfile_dark emptySquare ; \
          set ::boardfile_lite emptySquare ; \
          ::SetBoardTextures "
    }
    grid $f.blite -row 0 -column 0 -sticky e
    grid $f.bdark -row 0 -column 1 -sticky w
    grid $f.wlite -row 1 -column 1 -sticky w
    grid $f.wdark -row 1 -column 0 -sticky e
    grid $f.select -row 2 -column 0 -columnspan 2 ; # -sticky we
    incr count
  }
  
  #########################################################
  set f $w.texture
  set count 0
  set row 0
  set col 0
  set psize 40
  foreach tex $::textureSquare {
    set f $w.texture.p$count
    grid [ ttk::frame $f ] -row $row -column $col -padx 5
    canvas $f.c -width [expr $psize*2] -height [expr $psize*2] -background red
    $f.c create image 0 0 -image ${tex}-l -anchor nw
    $f.c create image $psize 0 -image ${tex}-d -anchor nw
    $f.c create image 0 $psize -image ${tex}-d -anchor nw
    $f.c create image $psize $psize -image ${tex}-l -anchor nw
    
    $f.c create image 0 0 -image bp40 -anchor nw
    $f.c create image $psize 0 -image wp40 -anchor nw
    $f.c create image 0 $psize -image wp40 -anchor nw
    $f.c create image $psize $psize -image bp40 -anchor nw
    ttk::button $f.select -text [expr {$count + 1}] -command "chooseBoardTextures $count"
    bind $f.c <1> "chooseBoardTextures $count"
    pack $f.c $f.select -side top
    
    incr count
    incr col
    if {$col > 4} { set col 0 ; incr row }
  }
  
  dialogbutton $w.buttons.ok -text "OK" -command "
  foreach i {lite dark highcolor bestcolor} {
    set \$i \$newColors(\$i)
  }
  set borderwidth \$newborderwidth
  ::board::border .main.board \$borderwidth
  grab release $w
  destroy $w
  "
  dialogbutton $w.buttons.cancel -text $::tr(Cancel) \
      -command "catch {grab release $w}; destroy $w"
  bind $w <Escape> "catch {grab release $w}; destroy $w"
  packbuttons right $w.buttons.cancel $w.buttons.ok
  chooseBoardColors
  wm resizable $w 0 0
  catch {grab $w}
}

############################################################
### Toolbar and game movement buttons:

image create photo tb_open -data {
  R0lGODdhEQARAMIAANnZ2QAAAKmpqf///76+vgAAAAAAAAAAACwAAAAAEQARAAADSQi63B0w
  RuFAGDjfQF/WGOd9g9RZEPlFSkC4RCwTpYVKuMtxqgoJu8FsSAAaL8ThjoJMxoCipvMlsgwE
  2KzW2Mp5T9twtkJWJAAAOw==
}

image create photo tb_new -data {
  R0lGODlhEQARAMIAANnZ2ampqf///wAAAP///////////////yH5BAEKAAAA
  LAAAAAARABEAAANECLoaLY5JAEGodSo4RHdDKI5C6QVBZ5qdurpvqQ4ozIqe
  oNhrjuq8mOMSZEUsRdkRkDwxmrRnrxddQJejrGi5QHm/ywQAOw==
}

image create photo tb_save -data {
  R0lGODdhEQARAKEAANnZ2QAAAJmZAP///ywAAAAAEQARAAACPISPecHtvkQYtNIAsAnS2hZN
  3iWFI6ll3cml7Tm0kfQwQrnd+q67d93AqWgQlY8IMs5quVQG+FBIp1RFAQA7
}

image create photo tb_close -data {
  R0lGODlhEQARAKEAANnZ2YsAAP///////yH5BAEKAAAALAAAAAARABEAAAIk
  hI+pyxeh4HqJMguenFI3o2FN+IFeGW6XJVZYi7TwqJb2jRsFADs=
}

image create photo tb_finder -data {
  R0lGODdhEQARAMIAANnZ2QAAAKmpqf///76+vrDE3gAAAAAAACwAAAAAEQARAAADUgi63B0w
  RuFAGDjfQF/WGOd9g9RZEPlFSkC4RCwTpcBJ0jvZghoWwMLNNpi9Cpggh2gMIINCAeUyc0Kj
  06LM+sS2BlIpF9vB3SYQRni9ZlUqkAQAOw==
}

image create photo tb_bkm -data {
  R0lGODdhEQARAMIAANnZ2YsAAAAAAP///6mpqbDE3gAAAAAAACwAAAAAEQARAAADTgi60ftQ
  iBakFXEMqrsgy0VdwxcWKIUWQgkqwqqirQkXVM66Z67WL0AMp9vZhLLGCniSrYzB4XPJu02p
  R+SV9QnCLheCVyEum8WQtBqQAAA7
}

image create photo tb_cut -data {
  R0lGODdhEQARAKEAANnZ2QAAAKmpqb+/vywAAAAAEQARAAACNYSPqZEhehyS0DD7Kt7aAtp9
  AhiSXYBm2piZU2qhkMNiwzUNdyvsjU5x+Bq0iAsgUBmSoVABADs=
}

image create photo tb_copy -data {
  R0lGODdhEQARAKEAANnZ2QAAAP///6mpqSwAAAAAEQARAAACPYSPecHtCoKYdIahpNsvVllR
  gaE1AndioBWK6mmilye21sucsJPSrD2TrW6GgXEw/GASHMdScYwaIdSqtQAAOw==
}

image create photo tb_paste -data {
  R0lGODdhEQARAMIAANnZ2VFR+wAAAKmpqf///76+vgAAAAAAACwAAAAAEQARAAADUggKIb4w
  MickpCE3N6IgBUUNg9AtXzGoLGlexFqKtJKuH6HvRAV8sg9N2LmFeLwXUCWk9YogHHKnjDF7
  ziqpNNW9fiIs8gvY5qZk1HBkKW/fnQQAOw==
}

image create photo tb_gprev -data {
  R0lGODlhEQARAMIAANnZ2RwyggAAAP///6mpqampqampqampqSwAAAAAEQARAAADQgi63P4w
  wrCEvViFrcT44CcAWwl4mDUIRMl5Ichq1ZquBN3Fck7WKZSPsuPhdCdbbPYr8pjEU/DicxCu
  WKxkywUkAAA7
}

image create photo tb_gnext -data {
  R0lGODlhEQARAMIAANnZ2RwyggAAAP///6mpqampqampqampqSwAAAAAEQARAAADQQi63P4w
  wrCEvXhRJYb/nqBVA2aVhLIBHfgJKbB2Jh3P7nuTNRr8P1YuRAAGaS2dLCgcwlSV2iXmIFiv
  V4l2C0gAADs=
}

image create photo tb_rfilter -data {
  R0lGODlhEQARACIAACH5BAkAAAAALAAAAAARABEAotnZ2YsAALDE3gAAAP//
  /76+vgAAAAAAAAM+CBChvu+xOKOrC9vKmpWd913dCGpj6A3sQHHBIMyCq5S3
  TBC0jeq0mkkWFI6IAp7xGBwUTIqWkwWNtKoPVgIAOw==
}

image create photo tb_bsearch -data {
  R0lGODlhEQARACIAACH5BAkAAAAALAAAAAARABEAotnZ2aCAUNDAoAAAALDE
  3v///76+vgAAAANJKBqswmGACRy0TNK7mtIT93gCCIiiiQWr2rGvO8LlYFMn
  mRE8AaIDQqHQ0wCFPd/ExmQmeSYcIMgjKqU4KtSAlTYNt26XKR4PEgA7
}

image create photo tb_hsearch -data {
  R0lGODlhEQARACIAACH5BAkAAAAALAAAAAARABEAotnZ2QAngbDE3gAAAP//
  /76+vgAAAAAAAAM+CLrcvuFJECetFwcMVY0ftHkkR5HnGXrgNbzDOA1CLQwW
  TRA2Lum22yxY8z1oNZ5w2CtYALBB4fVkwKqLVwIAOw==
}

image create photo tb_msearch -data {
  R0lGODlhEQARACIAACH5BAkAAAAALAAAAAARABEAotnZ2QAAAP///wAngbDE
  3rLA3MDAwAAAAANLCLrcDmM8F4YQcqp6b34B132U6GmhSIIqkAZNaHVBYRfw
  Zgr1Rdi5Ha8g+BEIwRntyERulJfaseh0Ra6RQDNg0L2+IUNIU8qRF6EEADs=
}

image create photo tb_switcher -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///wAAAP/tuMvFxosAAAAAACwAAAAAFAAUAAADWQi63B0w
  ykmrvZiKzbvn0DaMZPmFwkCsLDGkHqqWs9jJLVsWYCC6pdaAt8HlhEQBjjZaDXu/I6uQlDFH
  BYOh6ttQv2CtAdoRm8/KLufMHqM+ZS0Zvh73MpYEADs=
}

image create photo tb_pgn -data {
  R0lGODdhFAAUAKEAANnZ2QAngf///wAAACwAAAAAFAAUAAACSISPmcHtD6OcFIqLs8Zse90N
  IiYOl3kKYYoK5uiqQRy3J2qutfbGel/a5WZBmtBHzLR6rqHRyBzpSMGl7IO9Zj2d7abrzVQo
  BQA7
}

image create photo tb_glist -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///wAAAIsAAAAAAAAAAAAAACwAAAAAFAAUAAADQgi63B0w
  ykmrvZiKzbvnkDAMX7mFo6AJRNuqgSnDIjl3KCl17hvenxwQFEutegTaEFe0DYUTDlK5PAUc
  2Mc1y81gEgA7
}

image create photo tb_tmt -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///wAAAIsAALDE3gAAAAAAACwAAAAAFAAUAAADXgi63B0w
  ykmrvZiKzbvnkDCMokCY6HkKoTd8Xji+J52ibACXu0yqpdlr09oNCsjC0GerFTbJV/FzFCSV
  OdEPdbxip66k9aub3UTXAUAA0O02QsCo/YbN3HXXIDNZDBIAOw==
}

image create photo tb_maint -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///wAAAMvm/wAAAAAAAAAAACwAAAAAFAAUAAADUAi63B0w
  ykmrvZiKzbvn0Cd6oTCc3Tl85aCs5gKDwea+t9y1TjPzPd0G6Lj9ajHcK3a0LQcEwsrVNKFM
  UdhVUPJApbaqN8sRp8gs5BiczlgSADs=
}

image create photo tb_eco -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///wAAADZki4sAAAAAAAAAACwAAAAAFAAUAAADVgi63B0w
  ykmrvZiKzbvn0DaM4lB6oWCK3Lpu6Wi+bhe3uGoHpeujvI9QQCAIQqaiUKlEEo0fphFZKBau
  2CpBe+QloR5pVyfmiJ3i9NQra7tl46E8g0kAADs=
}

image create photo tb_tree -data {
  R0lGODdhFAAUAKEAANnZ2QAngf///6CAUCwAAAAAFAAUAAACRISPmcHtD6OcFIqLs8Zsi4GB
  WheK5kZm4BpywSXC7EC7pXlm6U3HtlwKXnafnnH08tQ8RCEquVk+lT0mlCf9ebaCCqUAADs=
}

image create photo tb_engine -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///7i4uAAAAAAAAAAAAAAAACwAAAAAFAAUAAADUwi63B0w
  ykmrvZiKzcXooAB1Q/mdnveNnLmZpSoGHGGHISvcOKjbwKCQ8BsaibSdDTYIwljHIzQ6hMKW
  JuxA1yRcvVlkDVhydsXjDm9j0/VwGUwCADs=
}

image create photo tb_crosst -data {
  R0lGODdhFAAUAMIAANnZ2QAngf///wAAAIsAAAAAAAAAAAAAACwAAAAAFAAUAAADSQi63B0w
  ykmrvZiKzbvnkDCMo1h+QoiuW1iS5qqyaDilApHvehrILJtk99MZW79g7Xc7Fnc+WssjjPCI
  0Jk0GW1edUmtFJS5JAAAOw==
}

image create photo tb_help -data {
  R0lGODdhEQARAIQAANnZ2QAAAKa/ovD07+vx6uHp4MvayfP289Lf0MPUwazDqLzPuCsrK+bt
  5CEuH2WLXoythpa0kbjMtY2tiAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
  ACwAAAAAEQARAAAFSSAgjkFZjigaCANRGEGqGsdQ3EgsB8mgmIuCgiEDBBoO0k2XgqmEzKIo
  cHtEi9QC5Lq7baWkiJbbjZB3JrB6bTx3JW6VZBJXnUMAOw==
}

image create photo b_bargraph -data {
  R0lGODdhGAAYAMIAANnZ2QAngf///wAAAIsAAAAAAAAAAAAAACwAAAAAGAAYAAADYwi63P4w
  ygmDvThnpnvnXmhxQmmeqBmQaXuuS+DOAqzIwkCjNoDrlhfuxQIOa8dS70ewEJ7NAJSgLCKF
  12qsZLwGg9ob1yv7DpdjM1llVavDPu5gTq/T4ckdXp9aikIUgYITCQA7
}

image create photo b_list -data {
  R0lGODdhGAAYAKEAANnZ2QAngf///wAAACwAAAAAGAAYAAACT4SPqcvtz4KctFZkc8a6SyyE
  4kiKATgM5RqeRyCkgjfNIIu7BizjpA7gqWgS28vHAgqRI2VsSDTumCVnj2qF0qRB6g8DUSjD
  CSVxQ06rEQUAOw==
}
#----------------------------------------------------------------------
if {$png_image_support} {
	image create photo tb_open -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
		WXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH1gkWFgcEIFayvAAAAB10RVh0Q29tbWVudABDcmVhdGVk
		IHdpdGggVGhlIEdJTVDvZCVuAAABsElEQVQ4y6WSS2sTURzFf3c6giWktRql7roLqIv5CA1FtBtd
		pC+6cVGQItFvIz6w0l1F+gG6qa0WxFUIgQhu0hJd9arptJ1mHr33uhgbcjsJFjybC//nOf97xJPK
		8q6UcoJzKBQKX188f3Wbf8CVUk5UKo9wnKFu8CTo8GZl7RYXgAsQxyG7e00wBmMMN67fBGB2vmwG
		NY6NXdl+/XKl5AKEYUQQnKQZA99/tJgp3yOKIwQOCGE1x3HCxsanyS6DXjQae/h+ANT7bh4fv4rn
		3bEl9ML3A96/Wx+oeW5hJnsDpRRJEluHbLd/9dF9DYAkSewBWmvSV3UTtVotM6BUmiK9WcceEEUh
		nU5oFXuex4W/ceiSSxwlVmJn5yNvV1dRSmWaNje/kMvlWFicWxOz82WTz+eRUlpFDx/cpVgsMjKS
		50zmqTrFGDBa8WHrM9VqPWXw7OkSxmQ9c3zs02w2EOd8ADB9f4pqtS7d1DuGVutbX42O42RiWmsO
		DnyAIxeg/fsno6MFi8XZVpuY+RsTHB76AL54vLy0tb8vJ9PJA62P44geBobh4ctHWutF/hd/AExB
		ukCW3MYjAAAAAElFTkSuQmCC
	}

	image create photo tb_new -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A
		/wD/oL2nkwAAAAlwSFlzAAALEgAACxIB0t1+/AAAAAd0SU1FB9gCARYPN9dLZuUAAAAddEVYdENv
		bW1lbnQAQ3JlYXRlZCB3aXRoIFRoZSBHSU1Q72QlbgAAAl1JREFUOMttkr2LVFkQxX9163bPOD2z
		/eH36M4oLLOw2XZgYGKggZGxYGCiYCyCkf+A/4AaLys7sAYKGxjIgmi6GwiCLRiIjs44X08Y5/Xr
		d6sM3useBQsu93KpOpxz6gjA8t/3L4hwx80PO4A7jjHV2KHbWrH57ouVbmvwcbrxOZMwtaI6+1gb
		3Wca2x8i1cDdc2fPH+12eozLyg0sf84w+1dHO/8v2ujt4mjoaOx8AT8lOrMslv8RAcqyPNppd1nf
		WKNMJWY5ml7RyC6CDwGj8+sGANuv9s+kMvutyN/emuueXYsA5o7jlKkkWQlph2BvwEvaS+8RvAaC
		ztIKDmSvFxT8TARwM3BIqSSlErGcIBng9flhCSInA4CZAVCmUcUiGeZKc/Y02eA4iEym3CEbHGNm
		rj8SiVNhLKECMFJKlNagsHk8zAMB0YN7XERAlKDtXQjrYSJhDO9g0qSweXL/HUTxtEk2WCAbLCAS
		AYUw9VIkPIvfShARJASCKM4Rcu+zb+4224MTTHcvAU72epG13cs+Y+t/akjPa4BKgqoSJICAEDEW
		yH2W+NMDkm8hQO/EFZ48eurt1u4/h3qfP9QeWA0QUVVifatOI40jJP2FUegz0j40+3zaavnT/5ZW
		4+GH+d4aBWJQTEJtulBdEWgCXv3IPpLB6mbLACYSBAhBkbpRxquTGmjskQhmjtes454EQVW/a6yy
		UrGZpEcq071efQSIGt9vbm0c6/UOfNv6w/htb28Ro64Oh8VwAlAUxdW/lu/fK4ri573EjSPsTJ44
		MTbfpVReu3H9pgN8BR0XJYkmw1fvAAAAAElFTkSuQmCC
	}

	image create photo tb_save -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlz
		AAAN1wAADdcBQiibeAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAALBSURB
		VDiNnZJNaFRXGIafc++5M3ci0URnEk1MVKRotRrswnRMLP4sVVTEVUEp+aNNjVZ01boRKqhIcfAH
		RbNpiyK6EMWAoIJSahS0tmAXhVZDJ4ljmsn8ZOZ6555zXIwksXblC2dxXs55+L73+4Qxhv9qa2/k
		uVa6capnWeKl1qbuaserYKov3/kNGG3qTu14iBTOhNf9Y/NMzSsJvA04eTqRLBaLNUqpCZioFgD8
		lGpDmRKf1fYiEPYnmW+Kh48eAsC27SDiRl5Kz/Nine1dUkqJ61bgeQX6L3z3TlVCWHzZ1U0mnSMa
		jRIEgTx77kzMCoLAkVLieR7GaDzP+7+uAMjlc+RyWcYyY2hjUEpJ+QZP4v7nPE7eBGBW5exyFkYD
		oIxPrKqO7uuLAFhS08q+1ouTISql2LhwD3+nf2Vzcwctjdv5s3gXjQLg9/FrHNhwmcH8Hxzv283a
		ue1oXYZbACoIWBBr4uuPL3Hr0RUuPzlCfWg5taEPAYhYVSTzTznet4ttCw6yZHYLfsmfBAjLolgo
		MH/OYjqXnmfwn2F6731LS2UX66v3MV03kOjrYcu8g8Q/2EAul8W27EmA44QYepEkm8/y0eIVfBU/
		Ry3LOHajk5H0MIm+HtqaTrIpvpN0ZpTBoSShcLicQWpkFDfscuv2HeLxZoaHktTXN9C2+hC/pdbR
		+8t+9rT+QNReSP+DnykUC/Tff0DrqjWkRkahZ+9u875q/6LLyL+eDZA48T2Ul4+KimlkMmOEHXdi
		ClI6uG6EfD478aYwPs7wixRi5epPi9GqSjf17xjStnDDIZyQg2PbhByJbVsESlPyAzzfx/dLeH6J
		2MwZpLPjOWkJIQFqZlUhhMCyBJYQiDcHyncnJJHSRkyLUAoUxhi01pWyobEhOfB8oNEYI6aurTYG
		S7xlAeBIGyGEKQWKpqblj14D6x5TKes4P9MAAAAASUVORK5CYII=
	}

	image create photo tb_close -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAkVJREFU
		OI3FkMtrE1EYxe/NxIJ1ZqVUbB5NH5kkQjuTdFKLNVDBihGKxVK0JY9JddGlf4d/ghtFsBhuC4rY
		jQ+ikFixNpNJMpPGhYIS0NhGJTOTdCa5LiRpm+K6Z/Vdzj2H7/sBcNSCrYFfjNyFJhhtNvArtaqF
		EUKNzr8LoZsvj3WZRyA2PXpw/+EdAAAwtW0M+Fu3Yz0MOzzdTR1Hc3NzxP5wlA/FaRc9Nj9/41QT
		44WWsVcA8ZNkMlUNBCZIlmWmyL0SyC+G4y6P+0ogcJ7c2NisQoiftmLm1uCwDy7JufxJM0Fcnrw4
		SQKApwQhsxKNhbDnrOfS+PgY9S71XikWPr3Q1PpSK9deM5FIYKfTvbpd2fHXNc12ITBBmiBhtVh6
		BznOR62vf1CkvPRaU+uz+/nsvxNIkoRppwttV3bGCbPZyjDDJ3pO93SJ2ZyS/ph+oyn1mU64JtAh
		hFATAKzq9V1s6DowDAMYuwYEGKj/vIMiOt4wEgs9pmln0Md5yXxO1srffxhuD92taqrNYrX6xEx2
		5X8FMMqHloeG+q+OnfNT6U1BEdLp5LdS6bOu62dYliFrNdVmddhZUciuHiqI8OF7fQ77db+fozKC
		qOYlKaUpetDQG8uVX5UJQzd6GXaErGk1u6O/byAjiM8OMIAQz3Ccj8qKOUWS5WRN0YMIoQZCqFFX
		d6eLW8WEKOaU0VEv1Wzi2UMbeH2MrSBvDZR/lt9+/VK6tra21qYtSRKmaXf8T/X3iJwvWAjCFBfS
		4vNOoEejvx7fDFN88/S5AAAAAElFTkSuQmCC
	}

	image create photo tb_finder -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
		WXMAAA3XAAAN1wFCKJt4AAAAB3RJTUUH1gERFQ8D2QpgNgAAAdRJREFUOMulk09IFFEcxz+zO+rs
		1LZ26A91CWlJjDCHKDDCDl46SKfAFum4bFDStYvb6kG8qmAsdFssEIo6dtKLrh5EcilhWYglQZCt
		3Z11XJ3Z9zyYs46iS/Q9PX7v+/vwe9/3nrL0rGVKFTsxjkhA4k6KNzSQsjyAvPp0GFEtuUWpqGx8
		HMNIoTQCqAeLQv6HW9RCFwBYHkCe0vvWSPHcBZT//EaKfX+pUOCM0YfarJ3YvZueicEhAM0avqqJ
		r1JAcXYQPxfZpbFUgPX3Q2iAP3QR7VIb5x/0c/b63VMb11531wHto/MA2KV1hG1RTH/h17tXrjnY
		eZ/grXsHEXPu5pPjIZYzM4DEXE1jbQcIxrOuyZqO4s9lCFy7AUdy9blXV7MRNQfzWxo9kqQ6O4GZ
		CFOdnUCPJCkufEUKBymcEwDC9mzYc+Nc7n+BPTd+6NX4j/l8AM7W5j7d2XY3mnoG2fgwSVPPYP0o
		uVVkzcbZ2vRmYBfz8Hc0vaMTazqKHkmiPXxZDzKepZwII0U3gSt5L0BRW+rG9tuwtoKZCHtGDcaz
		BKKfMZOPCXU98gKKS5/Q2zrcYqvRS6vRC0DNqmDlMh5g5fu85zNNATH+XUNGihH+V3vQLbHT+Z4D
		/QAAAABJRU5ErkJggg==
	}

	image create photo tb_bkm -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A
		/wD/oL2nkwAAAAlwSFlzAAALEgAACxIB0t1+/AAAAAd0SU1FB9gCARYOF/U+d2wAAAAddEVYdENv
		bW1lbnQAQ3JlYXRlZCB3aXRoIFRoZSBHSU1Q72QlbgAAAmNJREFUOMt1k89L1EEYxj/vzOi6a5u7
		m1Ziqf1yo04ZdOlQRNAt+nUQC4pI6tApgiDoD5AOXhLyFoSSkJRBh6AuYqegY9CKSFq7abrrLuq6
		392d6fBdd12o9zTMvD+e53mfEYDx12MXkxM3JqkLRzBsOHH2tI0ciSxEmxO/mxpyWVGBpNY7PuiG
		6LQ2LSnj57rn5y/f5eObEfpv3cfbXEN0keCuAun1adW6s6HLFue7igWHNpENcKdEh8bFbr5UAKVS
		qf34teHq7GIhByoL4bfE9qawxR9E4stE4iuUS6shLz93bCP35QmOCwbAOofDVaEX1pdojFjA0tKT
		RHDgCgBEepI4IDvTqcGdUQDOWqr1gDKCbhL8S8d/QhA5oACstfXyOXBWEQieJJvYByJ1b9lEB6Fw
		b1HEBNQWhe0RCLWhbBQh6g/SbTUsIiAapVvyoJZNlcI2ZKFwO1p5lNZyOCW4cppsotPXIJ4CNKjA
		NxE1bf5FYezFMNoo+gdu833uEEdVN03R64AjO9PFUv6mC9nlUa3KnysN3LbiZ1waTCAIo4/jhKMB
		Dp6boOwyCBDrvsOnd1OupTn/fncsl6poUENw9eksRhu01lwZnCW7kqesD1NUvRR1LzT28ifT7Ka+
		9iyaPZObNQ0E+obmsc5VRBcE6BtaqPpDEJAgZQuL6WYLUKUggFIaqSTK1urEb+Qf/XtrHa6C2tQo
		CFrrukTfKz6a6o7EF91VVm8AjDa/0pmVjlisdXvqP+23uprBGL1YKHiFagPP8wZejY+NeJ63v+a4
		2t+o+cxhTOPPcrl07+GDRw7gLy2eBHy6Hj7jAAAAAElFTkSuQmCC
	}

	image create photo tb_cut -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAzJJREFU
		OI2NkV1sU3UYxp/3f77GtnZuwJaxuAwZa1mHkhCIBgnJWtcOJARLjC4CxuiFMdFEMml2oRFsGaeF
		C+BWI2bD6QU37EaRKOIFZQXm18VG1sWuLhXadevZ6cc5PefvFQ0JMfhev7/fm/d5AACjajijxkY/
		xf+c09HwZ6dj4UUAYABARG1ut3skeibyzpPgaDTyvsfz7Efg1F4TOJ0OY9C/V3T19J5XY6de/y9Y
		jYXf9ni2qv6XAlJDQ6NZE+h6sbKqFRDwDyquzT1fRKOjBx67fCb8hqd36wWfz69o2jLK5WKlJmCM
		/ZFOp5DP3UcgsK/ume5N35yKnvTVfo5FDrl6PJ/7vAPKUjaD9EIKjNjvACACQNkwh+NTU9/5+vsb
		qv8sYm9gn1KdtCcjasQrEWtxud1jA94B+UHmb1RtG/GphF6uVo8BgAAA165eW9i958Xcg2zW29He
		IZlGGVu2eMTZ2ZkjTU81vzY4EJCW81mUKhX8fONGMZ/Pvnd8eGSyJgCAq9//cPuFXc//mUovvLxu
		7XopHr9JBw8eYqm/5lkyOQdZUazrv1zXc/lC8PjwyOWHHD2WtHpyM5OVn7hlbzh6+E1wzvHV2EUI
		gnDPKFu+UCiUenSfAGCCsXc58Ann3AlAtEVRUs6dRcXpgGXZMDUNdR8cA6pVAIBAtMKJTgzZ9lka
		Bw40NjWN7di5s7Guvh5MEJBOJvn09DTdD324gDVr5PUnRtv6QyHumJkhWBaKxSJuxeOr2vLyW/iW
		sdmlcJjf6u7WJySpdElR+EowyMcB+yKw9pLDsW6MyF4JBvm4KPKvJal0c+NGfdHr5ROMzTGT8y6W
		SGBufl40TLOXWxZMwwAj0o4CuSFNywpEmmkYAADbND3zqZRY73TC4vxpJhAtlXUdra2tBiNKdnR2
		rhY0DQJjvz4MSiC6s1Io8M6urlUwNtfW3m6UdB0iUVZ4hYhpmrbrue3bG3r7+lAny/KdREIzKpVX
		LwMZANjP+e1cLnfE7XI19m3bhpbmZvm3u3f1UqkUph8BMcOYCuCwZdstMmP3qrY9PARcebSuccAv
		MaaanPcIREsc+FKw7Y//BYhsZfiE0OfYAAAAAElFTkSuQmCC
	}

	image create photo tb_copy -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
		WXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH1gETCToqhryocwAAAK1JREFUOMutkk0KwjAQhZ+QCxXE
		AwgueiB/0IXJIhLjgVwIHkCayZHqpglSJtO0+FaBDC9fPmblvL0C0JCjT4eLYW+ct/1UnLd9qVml
		w+v9ZAd221ZEywXrZoMlyQVd/PyPIFCHQAEAQCFmV5xYloAo4rg/iy/fHzcNwLAE6dUasaKDGrGK
		a00ENWIVAD38ZxnBsKJmvJ1zCIqZ5YDLmIArFAumtlAqKIr9nQGAL0ezaR+0HlviAAAAAElFTkSu
		QmCC
	}

	image create photo tb_paste -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
		WXMAAAsRAAALEQF/ZF+RAAAAB3RJTUUH1gQFEjM27p6E1wAAAYtJREFUOMuNk79r02EQxj/33Gua
		SWqlILaCiCiIOImhsV+UdHVUtEIhIOgmdBChf4BBKnSug2vaRZTiFGjtkEJjJNEt4j9QzBIwFKv9
		MaRfTZvYfp/p7rh77u557zUO4dr1G4+B+a7Qk6/Vymv+A5ub1H1gIQ68+XyGtx9WSafTtNttHt27
		xd2rP7prHkwXdxZjR8BCvlAmXyjTPP+U3YEhdrb/8L1RR4IWw5zOzRLndDeLCQDYahRZKq2xUnrH
		9u8Wg4Mn+dnaYKX0nlfzi2w1in1XCN3OVG6UiTsPe5KmcqMcpcFuvlA+0GHp2ymamykS4GPoF21u
		pnj+bObY6pezL26HoxJq9U+YHHchOe6OTMjFxQuXejU4DA+BWq2OScgMmTAZY2PZ/iL2KBwCmUwG
		lyMXMnWmkCck8BNUq1UkYWaYOlOMj0fJJ8jezOLqaCD5vq1kBB6cynoFMyEZURT9JUm4QiCKos5L
		KN5f/QlSlyf/VX5ZBmDk7Lljb6HnNwL8ujINA0NJLnFjDzcHYFcB8qBPAAAAAElFTkSuQmCC
	}

	image create photo tb_gprev -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAAB3RJ
		TUUH1wgGEBoIdCRDswAAAZlJREFUOI3V0b9PGnEYx/H397iT48SJYF1KOISEgYRFOkisSaVQUol0
		6NCUUk20McXNn4mTi4P+GyYdZKrpf3ANUztALnTSdLCJg2mTQut5yLdLayoB16af6clreJ7k+cC/
		jmeAK0AAuPN7/tnjoz1+Iz5d182p6andbC4jgfHbXPn7ajAYHEsmk/dnMg/erVQqawCBQGBokAMI
		gHQ6PaIoiun1eefDodDrzc2toXDYFI9n8zgX7j3Nqz3r9R/tiwnLsj6o5XI55DjOZKv9fac4VzQf
		5fNas2mj+3QA/CPDB/08Go0almWhJBIJ8+u38zcvSqXY4uKS1vxkM+z3Y/gMAAZ5PB43ANRIJHI2
		Ix9WDqvVVce5vFsoFLRWu4WqaQAcVqsn/TwWixnX37Nte6xerxfXN9YPlpdfXZ5+Oe12u1cym8vI
		RqNR6ue2bT+/0Z2UUnNdN12r1bbnF15+Pjp662ZzGdnpdJYGOYD6Z4EQwgXeSylPUqnU8d7+3hPg
		qcfjuRJC9PXrGnsjpVSBFBABmkKIj7f5f55f4EnGQHaRI38AAAAASUVORK5CYII=
	}

	image create photo tb_gnext -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAAB3RJ
		TUUH1wgGEBoIdCRDswAAAc1JREFUOI3d0r9rE3EYx/H3N3cxd9f8lEBNmghCfgwOZg7BetK0iINN
		Z6Wtg10c1NE0ms7uCuriIO1oFSoIgSIitH9AbYxEqI2Nm7Qmsb07vi6JbWNwFXyWB17Dhw88D/zr
		Ubo7AEQAN/ATkF0Pdf0E0DnifwRExifGPsfjMf/OTnPDcZx9wOp6fYAfDwiHw8OR6KmbN+bmMu1O
		64rHo310HGfPMAxjkLfb7XavjQKQyWTiuqFdL83fd+dyudB2Y3tK17VgIBDc0DTPdL9HoyNfkslk
		p16v7ysA+Xz+TKv1Y8Y0TaVa26QwOaUGQyfP1T5VL4H0mebF416rXvZ6fV+z2eyuCyCdThtCCHRd
		x+8PsFn9QGGyoN6+dec0CPcg3937/iyRSKRUgGQyqb99typUVSU2EmNoyMvK6xV7cfH5NyHEsKqq
		ar+PnjcfpFKphtprgACfz8+BZbGwULZcwvWqeLe0XCoXn/b7fPHekmEY79PpdAMA27anxyfG5PLL
		F/bM7NVmpVIpSylHbduePfRrzUqlUrYs64KU0tM7owqgKIoDsL62/ubRwydLmqatCiG2pJTxQ3/8
		24/+gQCQUp4FMsAWsCaEOPib/2fzCyhU1vTKsQR1AAAAAElFTkSuQmCC
	}

	image create photo tb_hsearch -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAkRJREFU
		OI2lktFL01EUxz/3d3/bNKUJaU6dOkmhfJBMMdFkJbJIfKiHIiPoIemxB0GEIh8qSOqpN/+OHnoo
		iIooE6HSStPEbKuZbupmY+63/e7tIZxWth76woF7D5/7veccDvynxPZLc9uRx5Zl+QEMw3jyemz0
		aK48gLHdwLIs/6meAAfqqlFK+f+V/6OCptZ2nbEzaK1/ugsxIKW0bKXuKqUAkKbk1eiL7Du5eWg4
		dLi1ory073zvaXyVFZjSYHEp0qm1Dpw43iWvDPbT0tzI23dT5Be5Hy59/RoEEE2tbZdtpe44XS59
		8cI5VygYZHp6ig9zQer315FMJplfCHH71hDh8CILn0Lcu//Asm0bAzFgKq2Hrw72O2tqqpmZmSUe
		j2VbOthQTyQSYX4hBEAikcAwINDZ4UylLB49fT5s2Ladn5fnIhJdZnV1Jdv/37QcWWZu7iMCjdY6
		3wSwbRvH1jiyej89SyKR2NEonUkDYBrCSCWTGy6PZy/FxSXEYutorUmlFW8mp2wBdHX6ZZG7iJLi
		EuKxddCQ2kghICUa29uvKStzfYfSlWEYN6SUqXQ6fZPfdgZACDEkS8vK9uzz+Xp6z5x0OiTscjlY
		i8W/K8XZifGXI+FQ8JnHWzFZuwNjK0YMh3Re6u4OFFT5qvBWetntduMt9xRKKfo2f8rFmBrl93f4
		ia+vUVtbRyZtU1hQQPDLt2ObBrkYU2t0MPgZITQr0RXC4TDRaBTE1pbnYkRDc4s2TROt9S8BMDE+
		JgByMT8Azog6tOCy8AIAAAAASUVORK5CYII=
	}
}

#----------------------------------------------------------------------

set tb .main.tb
ttk::frame $tb -relief raised -border 1
button $tb.new -image tb_new -command ::file::New
button .main.tb.open -image tb_open -command ::file::Open
button .main.tb.save -image tb_save -command {
  if {[sc_game number] != 0} {
    #busyCursor .
    gameReplace
    # catch {.save.buttons.save invoke}
    #unbusyCursor .
  } else {
    gameAdd
  }
}
button .main.tb.close -image tb_close -command ::file::Close
button .main.tb.finder -image tb_finder -command ::file::finder::Open
menubutton .main.tb.bkm -image tb_bkm -menu .main.tb.bkm.menu
menu .main.tb.bkm.menu
bind $dot_w <Control-b> ::bookmarks::PostMenu
bind .main.tb.bkm <ButtonPress-1> "+.main.tb.bkm configure -relief flat"


ttk::frame .main.tb.space1 -width 12
button .main.tb.cut -image tb_cut -command ::game::Clear
button .main.tb.copy -image tb_copy \
    -command {catch {sc_clipbase copy}; updateBoard}
button .main.tb.paste -image tb_paste \
    -command {catch {sc_clipbase paste}; updateBoard -pgn}
ttk::frame .main.tb.space2 -width 12
button .main.tb.gprev -image tb_gprev -command {::game::LoadNextPrev previous}
button .main.tb.gnext -image tb_gnext -command {::game::LoadNextPrev next}
ttk::frame .main.tb.space3 -width 12
button .main.tb.rfilter -image tb_rfilter -command ::search::filter::reset
button .main.tb.bsearch -image tb_bsearch -command ::search::board
button .main.tb.hsearch -image tb_hsearch -command ::search::header
button .main.tb.msearch -image tb_msearch -command ::search::material
ttk::frame .main.tb.space4 -width 12
button .main.tb.switcher -image tb_switcher -command ::windows::switcher::Open
button .main.tb.glist -image tb_glist -command ::windows::gamelist::Open
button .main.tb.pgn -image tb_pgn -command ::pgn::OpenClose
button .main.tb.tmt -image tb_tmt -command ::tourney::toggle
button .main.tb.maint -image tb_maint -command ::maint::OpenClose
button .main.tb.eco -image tb_eco -command ::windows::eco::OpenClose
button .main.tb.tree -image tb_tree -command ::tree::make
button .main.tb.crosst -image tb_crosst -command toggleCrosstabWin
button .main.tb.engine -image tb_engine -command makeAnalysisWin
button .main.tb.help -image tb_help -command {helpWindow Index}

foreach i {new open save close finder bkm cut copy paste gprev gnext \
      rfilter bsearch hsearch msearch \
      switcher glist pgn tmt maint eco tree crosst engine help} {
  .main.tb.$i configure -takefocus 0 -relief flat -border 1 -anchor n -highlightthickness 0
  bind .main.tb.$i <Any-Enter> "+.main.tb.$i configure -relief groove"
  bind .main.tb.$i <Any-Leave> "+.main.tb.$i configure -relief flat; statusBarRestore %W; break"
}

#pack .main.tb -side top -fill x -before .button

proc configToolbar {} {
  set w .tbconfig
  toplevel $w
  wm title $w "Scid: [tr OptionsToolbar]"
  
  array set ::toolbar_temp [array get ::toolbar]
  pack [ttk::frame $w.f1] -side top -fill x
  foreach i {new open save close finder bkm} {
    checkbutton $w.f1.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f1.$i -side left -ipadx 2 -ipady 2
  }
  pack [ttk::frame $w.f2] -side top -fill x
  foreach i {gprev gnext} {
    checkbutton $w.f2.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f2.$i -side left -ipadx 1 -ipady 1
  }
  pack [ttk::frame $w.f3] -side top -fill x
  foreach i {cut copy paste} {
    checkbutton $w.f3.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f3.$i -side left -ipadx 1 -ipady 1
  }
  pack [ttk::frame $w.f4] -side top -fill x
  foreach i {rfilter bsearch hsearch msearch} {
    checkbutton $w.f4.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f4.$i -side left -ipadx 1 -ipady 1
  }
  pack [ttk::frame $w.f5] -side top -fill x
  foreach i {switcher glist pgn tmt maint eco tree crosst engine} {
    checkbutton $w.f5.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
        -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f5.$i -side left -ipadx 1 -ipady 1
  }
  
  addHorizontalRule $w
  pack [ttk::frame $w.b] -side bottom -fill x
  button $w.on -text "+ [::utils::string::Capital $::tr(all)]" -command {
    foreach i [array names toolbar_temp] { set toolbar_temp($i) 1 }
  }
  button $w.off -text "- [::utils::string::Capital $::tr(all)]" -command {
    foreach i [array names toolbar_temp] { set toolbar_temp($i) 0 }
  }
  ttk::button $w.ok -text "OK" -command {
    array set toolbar [array get toolbar_temp]
    catch {grab release .tbconfig}
    destroy .tbconfig
    redrawToolbar
  }
  ttk::button $w.cancel -text $::tr(Cancel) \
      -command "catch {grab release $w}; destroy $w"
  pack $w.cancel $w.ok -side right -padx 2
  pack $w.on $w.off -side left -padx 2
  catch {grab $w}
}

proc redrawToolbar {} {
  global toolbar
  foreach i [winfo children .main.tb] { pack forget $i }
  set seenAny 0
  set seen 0
  foreach i {new open save close finder bkm} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .main.tb.space1 -side left }
  set seen 0
  foreach i {gprev gnext} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .main.tb.space2 -side left }
  set seen 0
  foreach i {cut copy paste} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .main.tb.space3 -side left }
  set seen 0
  foreach i {rfilter bsearch hsearch msearch} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .main.tb.space4 -side left }
  set seen 0
  foreach i {switcher glist pgn tmt maint eco tree crosst engine} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .main.tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seenAny} {
    grid .main.tb -row 0 -column 0 -columnspan 3 -sticky we
  } else {
    grid forget .main.tb
  }
}

proc setToolbar {x} {
  if {$x} {
    grid .main.tb -row 0 -column 0 -columnspan 3 -sticky we
  } else {
    grid forget .main.tb
  }
}

# Set toolbar help status messages:
foreach {b m} {
  new FileNew open FileOpen finder FileFinder
  save GameReplace close FileClose bkm FileBookmarks
  gprev GamePrev gnext GameNext
  cut GameNew copy EditCopy paste EditPaste
  rfilter SearchReset bsearch SearchCurrent
  hsearch SearchHeader msearch SearchMaterial
  switcher WindowsSwitcher glist WindowsGList pgn WindowsPGN tmt WindowsTmt
  maint WindowsMaint eco WindowsECO tree WindowsTree crosst ToolsCross
  engine ToolsAnalysis
} {
  set helpMessage(.main.tb.$b) $m
  # ::utils::tooltip::Set $tb.$b $m
}
set helpMessage(.main.fbutton.button.addVar) EditAdd
set helpMessage(.main.fbutton.button.trial) EditTrial


image create photo tb_start -data {
  R0lGODdhFAAUAPAAANnZ2VFR+ywAAAAAFAAUAAACPoSPqQGsf5iDT1JoU5hm96Z5kZh123Q6
  ZaqmX+uyKijXs2Szrxnr9HjikUBAVPCHOPJ2oSbyoiFCk9KpFVIAADs=
}

image create photo tb_prev -data {
  R0lGODdhFAAUAPAAANnZ2VFR+ywAAAAAFAAUAAACI4SPqcvtD6MJVAKKI95v++aFS0iO5Mec
  maNqooRaq0XXNl0AADs=
}

image create photo tb_next -data {
  R0lGODdhFAAUAIAAANnZ2VFR+ywAAAAAFAAUAAACI4SPqcvtD1WYEc1bwd1x++eFTUgupCid
  FKOCqItVcUbX9q0UADs=
}

image create photo tb_end -data {
  R0lGODdhFAAUAIAAANnZ2VFR+ywAAAAAFAAUAAACPoSPqcsBztqLEgZ4rnJWZ59Nz4WR2NSR
  hlmKLMeu7kujK/3ao7mretxrpUo+WQpRNN4SoNCJ4oRuRNJodVEAADs=
}

image create photo tb_invar -data {
  R0lGODdhFAAUAKEAANnZ2QAngVFR+wAAACwAAAAAFAAUAAACO4SPqcvtf0JQ0ghBZ6rgYsSB
  mvdFmhGSJRCyp1q2KWyiZ0fb+pHvrZpp4S4LidDDMN5wDiHE9YxKp4sCADs=
}

image create photo tb_outvar -data {
  R0lGODdhFAAUAKEAANnZ2QAngVFR+wAAACwAAAAAFAAUAAACO4SPqcvtf0JQcgkBatLoYh5N
  nWeAIOBdpbiOaRseKQmDs1qzxh1n+v4KnWS01ZCIEf4SuB4EcXxKp9QCADs=
}

image create photo tb_addvar -data {
  R0lGODdhFAAUAKEAANnZ2QAngc4PNAAAACwAAAAAFAAUAAACNoSPqcvtf0JQ0tV0jxBxYq9x
  HZKFJAhk27qmqMq2rlGaJ43a46xslJR7AIMWIORzRCaXzKahAAA7
}

#----------------------------------------------------------------------
if {$png_image_support} {
	image create photo tb_start -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABl0RVh0
		U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAHaSURBVDiNfVNNaxNRFD3vYzJmkkybBIxf
		qRmtWoooSGkXgiDiQmdR0B/hX5h/0PEfdOfCvdDF4KIUcSEUQZAuVChxNNVWbTJdTMBkMjPXxURs
		58MLDx73nnvuPe/dyzoP1wIAChIru441QsoM034C4JnrWEE6xhkDW310H4yxKB1Mkp+uAVgHwPPi
		Ms85rSqEIp836pVV72gYF+FyWQ3T1oSUm1cvtx/fWVnUGAMVEWQ6MEy7KaR4tbjQWbjYbilRPIFa
		kmw0Dn3DtNNwShPMcSm2blyfP9M63ZC9Xz5qZQX37q5wsH/dMgBRMMLLrXcnO+CCb9+6eW1mdrbG
		vx0OEcUEzx/D88dg7GSlCw01I0FcMs7Xa1UNn/ePEId0TPjfG0PiZQj1UoYg7nb3RiVF0XRVxXd/
		CCp8OiCMtAwBEeHBh4+uc2W+XTnXrLL9wRB6RUWzdiqRcEzHJIwzBADwFqDbu9291525s3qrrnNF
		crzf+RQFQZjXiMjMgetYOyBa/tI7GAz6XhjHhGlyE0A1dcq5k+g61q5h2ksHPw7fTMKohWTgxnl7
		kjuJU5IeiJb6fe8rAFGE40SgjRebIKIMyHWsnyBaBrBdRMDof381NcO0KwB+u46VWao/JyCsQtBj
		QHUAAAAASUVORK5CYII=
	}

	image create photo tb_prev -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABl0RVh0
		U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAHUSURBVDiNnVPbatRQFF07SZlMNZ1kpjXj
		TMdOphSkFH0QfFDwAxrwC0R/I3/Q+AN+gJ8g5EEqShUV0UdFQTBCpWPbcTpjk5ALyfYl09sk8+CB
		xTmw915r7X3OATNjFrqbWw+6m1tKWVzAjGWYjy0ATwGIZTlScaFNRPREUy89HP/10yzjUpEpB4Zp
		V4jo2ZXF2qN7d2/OS6KQznJJzKfshmnXiOjFcquxcWNjTRYlEa92PqXHXljWgnZCYJh2m4he97pX
		O6ur1+YOjgLIsoTGQhUCTeni+fb7KE7SppQXr4No5/paR2u1dXHvj480Y0RejLEXT8mu6AomwpJh
		2hUA253WYkPXl+hnf4w0H9ppd5MDgcGIYxlZHhRcx4oA3N/dGxz/3h9wrSrBD0J4fgg/mCDKESII
		IkRhfEJ+dgbrIHrT67ZVpaYI/YEPZX4O9QUZAuVDyHeBgA8fP0dZxs2Lt9AD0bvOst5QNVWSRAFf
		v3xPwjgpenAiAO1cwHWsH2C+tftrv394MEiyjBElSQagDeDyBVRdxxqdc3DGyRIRva3X1ZXh8IiZ
		0XQda1TgovgvuI51yMy3h8PRN2ZUinJmEuQkI2a+A+DlfxHkJD4AE4BXlvMPGdb3LcL6lQ4AAAAA
		SUVORK5CYII=
	}


	image create photo tb_next -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABl0RVh0
		U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAHDSURBVDiNnVNNaxNRFD1vkmiooV0kjQQV
		O4KuKogLIYoKCoqZpXv3+gveP3D+iH9AeOBacSFUQaj1a+JTk1RrWpOQmc5MPt5x0XYaYycBL7x3
		F/ecc++7716QRNpZqT1+NCtOEoIk0sx2XF8I8YTkQ62kOQpjpbL3LFMqLj4QQjy1Hff4/wjg6pXV
		/MqZk7eFEC9tx12ajguSsB23D6AwHcxlLdy7U8XYEHWvMfxYbzZJXtdKtqYFwtrdat6yDgsSAiCB
		nh+j68eoFBewubk1Xn//rQPyplZyAwCyB4SRIVpbPZiUnra2A5TLy5lLmWzx7bv6K9txa1rJF4nA
		IB5gN4xhDAAcqIjDWwA6jHC2vCTOnztd+OQ1ntmOaycCUTRAEMQwM771VKmATrcHT7d2AdzXSv5K
		BIYjA7uy+BeBBLp+jN/9CJXiCQyiCB8+f/Vp6Ggln0/2YPT6zcZ4OmM2Y4nVixesXG4BYRDQ+9L0
		Qd7SSq4lmH1fSh48YaOx6QyGJu/3++Z742cP5A2t5PokZt4oh8vl0rF2e2cb5DWtpPdPlans/Ta0
		2zs/QFa1ko2jAPNGeQ3k5TTyXorZ61yYt85/ANR7LcV/o6ZXAAAAAElFTkSuQmCC
	}

	image create photo tb_end -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABl0RVh0
		U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAHGSURBVDiNhZJPSxtBGMaf2cxqhCQWa/EP
		Jc1YUFpowVYotCiFghSnJ8Gz38DzfgNH6KmXfgihh8JCr4WeqigtirW2HdEGlSyJMWu20d19PYhh
		N93VB95h4Hmf38zLDCMiJElItaBt612K1w4ZielLvRVvlt4LqViSOTv3+kYA67+Vmzc5/yik6kpr
		ug6AF88e9oyOFqc551+EVIWkHi6kagDIdhomN3gYEkrFwS5umuMbm7/XhFST2rYOYgAA2emXT7jZ
		nQVYZFwGHLst1Jsuhgf6OM8YpfXvP78JqSY7AQgIKB+egCL56OP8rbgY7CtkJsYf9K+ub62EfhAH
		+H6ARtMDwMDAAFylWXv947Vwb6DAxu4X81vbOg4490N43hlSvgQA4O6dHBynih87ux6AnvgNghAj
		Q72xABFQc//h2G1h+HYOXrOJ7Z29UxDNAPgcBdDX1c0AHeIZgz16PGZ0mxwn9Qbp3bIL0CttWytC
		qtgI+fawEflB2Dj3Q6NWq4fl8lEdoCltWxv/HaRtq5U0s5AKh0dO4FSqVRA917b1K6nv2p/oVKoH
		IHqaFr4JsAaiCW1b+0nmh+VPlxsiSqzSzGI+zYvWBT6H38bSaD3bAAAAAElFTkSuQmCC
	}

	image create photo tb_invar -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAAB3RJ
		TUUH1wYaCjgBHgTN1wAAAlJJREFUOI3FkT1ME2EYx//3vndtLdCWmkIRCFekGAJiIhJTI0knjcYV
		jZuDRldJjF9LJwcS3XF07KTGEBTRxEQTEBJ0QaDlaiu0NS13vdLvu/d1glRb4+hvevI8eX55PoD/
		jXAQTYapXIheJoRe59w8BQGtnAtlgQhRcPbUnXTPrKzcrDUVDFx45DEpmfccdvpHh/vtrrYWSBJF
		pWogq+axvpkopbKqQko4s/X2Xq5eQDEZpi5D+zRxemh47ITfarOIqBkGVL2M7YwOk1MMDfZIjAlO
		NZ8PqBvzz34THPWN3/D5vFeP+Y5YP69uFD8urplrkYSR0wvl7o52i5ovI6tX4Jc7aOqn5rb1Tizl
		IgvKvoAwgU/pRdP+Yn5Rjyg7tyihvRKRenfVXGh5dWPP47Qht1eCXqjCJ3c5KSW36ycQGWf+bCZb
		ZIZxJTb7YK6u9rj/0vQ1TS+MHLIQ6IUK2l1tYECgXkCoQJY5Y+9is/frmwEAHHy7WquBCAKKlRos
		FhFgzN38jQDki9NewPwKwLOfGz0+CK1oQLJIkL1OLLxfanxjPT3nn7hFsfqhq9M9IPd1WznniO5o
		cDntkL0ucA4o8ZS5FU3swsQE+VPw4/XUrpUKgVRa/bIZ+V6q1hiskgjOgKrJEI1tG1vReBK8Nq7M
		3V1vmOBgnWDIJrTaXjkcrQG5r8fuaLMjnkhW4/FkHNQ8q7x8mG66Qj1jYzOS2qmFbXbbOYezhaZT
		mW9cKgdjz0PaX2/QwGSYykUlDM5OlgxxJP3mTuGfPY1wIRgMic0qvwAa9wLWla9eZgAAAABJRU5E
		rkJggg==
	}

	image create photo tb_outvar -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A
		/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9oCHAw7EDdhKJYAAAI+SURBVDjL
		xVNLaxNhFD3fI5PJJGmiNi1Vq60xECm+wI1aLFhELVkIQn9BUZFu2oUgQZGWFgTrXhBB3AVciBhF
		SVARXVhciBZsO76wYkxiOs10JjOZmc9VIdGKdeVdnnvOuZfLucD/LrIaeOjqRd+COX0alJyCJ+IA
		ZAA6OJ2G413X1u3IlM5OuasabJ88ERHCfi56lG7lQCDQGmqDxCXYXh0VU8NSvmzQWWuOejgyl75X
		/M0gfjmVqx2L9HYnYtJCtQZL1NHulxH2UcicgXMZall1nRvGjBZJ7mVN4vHUYa8zMNJxsCM4v0gh
		qjbCsoXlXFnX7xe9ysuKU/At2lu7NvpLfiusqMXvtGm8hBGzPxSpWjakzzaiLRaczJJO561LUHgn
		JNrJ87Uzn66pS1iUFDjOKG/UC0H2xwJ+lOsUImRAqwrIhvNRTWenGmi34hMDRT6j34bjJZo2IK67
		XuIS3KoHcAqyXAM8sfDrndR09gGpO3lIbJrEJwZEYzM0nEChAFDdhNcmELzZpC+Csl3q+bvfVgAK
		ypKgpGgdj7ktwz3gYBDMAdE8BH110KHNcHf7LQBvPa4kG8UAwCq52fKGvm0Z9qE2qCuW4muVqaEz
		UBdwIwB5UjLZO/s1kUjf+3N3tD8mMT5+tB2cP7N7o1vCPVHph20g8Egz6BfrBauK1OxktvbXKMcv
		9EWhhB67O8NJ+tV1ScV6uMm3Z/Dp6Fh9zb/QNXYyyJj5BpS80iLJwZXM/1Ptu9LP/USQtXB/AkJk
		7Ms2MTbJAAAAAElFTkSuQmCC
	}
}
#----------------------------------------------------------------------

################################################################################
#  Image data for "find best move" training
################################################################################
image create photo tb_lightbulb -data {
  R0lGODlhFAAUAOf7AJB+DJKAD5WCEpGFHpaJGZ2PFZ+QBm2UlaCSJKGTJaaWEnOam6ubGqed
  GaScLHeen6ieG3mgoauhH3yjpKSmE4CkoIGloaaoI6+lLomlooamqbCmL4qmo6qrHLSpKYqp
  rI2pprWqKouqraOvQo+rqLSrRIaur6GsdYuuqq+wLYevsJ6tgrGxJJGtqpitrJOwoZOvra2y
  R5SwrpqvrrO1MpaysJmznp6ysbe4NZm1s723N6ays6C0s7m6OJe3uqi3i6K2tb66Qbu8Opm5
  vJ25tp66t8C/Kp+7uMLAIL2+RMa7TJy8v7+/PaC8uae7uqG9uq26u56+waK+u8DCR6O/vKa+
  wqm+vcbEMaTAvqe/xLC9vsPEQqq/vqjAxcTFQ8vEPMPFSqnBxqzBwMTGTK3Cwa7Dws/HP8fI
  TqzEycnJR7HFxLLGxcnLWLPHxrXJyLvIyb7Iw9PNVLPLz7zJyrbLyr3Ky77LzLjNzNDSXr/M
  zbnOzbrPztLUYLvQz9HUZ7zR0MPP0L3S0b/T0sLS2MXS0sDU08bT08nTzcfU1d/bSdzeOMjV
  1sLX1tjbbtzcWd/aaMnW1+PbW8PY19ncb8rX2M3X0svY2cXa2czZ2uLgVtLY2s3a2+PhV8fc
  29jkXtbkZeHfeuPiYNfbys/c3OPlSMne3ebjWdDd3efkWtHe3+XifePig93ex9Lf4NPg4dTh
  4ubnctfh3NXi4+Xoetji3dvi19bj5OjpdNfk5drk3+zpg97l2tjm5t3m4drn59rp3OHn3O/s
  huDp0Nvo6eTm49zp6uDr2N3q6+Dq5ePq3+Tp7OHs2d7r7OHr5uTr4OTt1N/s7eXs4eDt7ubs
  7uHu7+ft7/HzoOnu8Onw5efw6+rv8uvw8+7y4ezx9Ov02+zz5/Dz4u3y9e7z9vHz8Pv3rPT1
  3u/19/j22fL42fD37PD2+Pb34PL3+fP4+/b49PT5/Pf59vX6/fj69/b7/vn7+Pr8+ff9//v9
  +vj+//z/+/7//P///////////////////yH5BAEKAP8ALAAAAAAUABQAAAimAP8JHEiwoMGD
  RBISOcjQkr6H+sIxJEhEHkSI7/RM/Afp4kVfCxnyuufxYbc9DInIajfPY71jp1Ke2sau3sN7
  9MzJsjTRki1k4NClw6bs16kmE4m44gXJl69DxlwJ2vjP0M5Rp1zJgkRVIKFTZaoYGtVVoAxX
  ZFrswVJW4AMNHw6saPuPTSNVfBrQDRWM3C29bRVlQkUKcNkpY7YkUUD3HwMGjcsGBAA7
}
image create photo tb_backward -data {
  R0lGODlhFAAUAOevAAAfTQAgUAAjWAAmXQA4dQpFfQBQlA9NhwBVmwBgpwVnrgBrrw5rrgBx
  twBxuBZsrx9sqwB4vgB4wAB5wAB7zwB8zwB9zwV+zwSA0Cx5twCE0QCFzgCF1ACG0gCHygCH
  zgCHzwCJzQuG0gCJ1QCK1h+DxACL1wCM1yuCwQCO2ACP0geN1QCP1xeJ0wCR1BaL1ACT2gWS
  2QCV2wCW2wiU2SKN1AGX3AOX2wCa3g2Y2QCc3gOd3hWZ2jmTwwCh4hya2hWc3AOi4hOf4A2h
  4ACl5Q+i4ASm5ACn5gCn6Aml4hqh2CSe3Bmi2imd3Q6l4wCp6TGc2gWo5gGp6AOp6ACq6gmo
  5QCs7ACs7RWn5Aar6gCt7jue20Oc2ACu8FCa0wCv7yql4ACx8z6j0EGh3ACy9Cuo4VWf1h2u
  5w+y7guz8E+i2Taq4iKw6HOduxq07lil2imz6kat3lyn2xy48Si27WOp3UKz5hu9+CC89S25
  71qu2YCnxEq05ku14yO/+GKw12uv4lS352K13DXA9k+87UfH+WXB7GTD71jJ9lfK+aK5yqy3
  yGXJ9HjQ+pbN64TT+ozV+rLO35zZ+6Da+afc+6jd+8PY5bza79TV3K/f+8fe6rzj/crl9s3l
  8dDl9Mfo/+Hj6ebi5tXn8ubn6+zo6u/p6vDt7vDu7u/u8fHu7+/v8vbx8Pfy8fb09fz39///
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  /////////////////////////////////yH5BAEKAP8ALAAAAAAUABQAAAj+AP8JHEiwoMGD
  CBMO1NChgwaFBJcYqvRp0yQ+PxRuOJQJUqE7fhJJomQnIaFGeMKEIUNm5aBHZQ7mYJTmi82b
  Nucg+lBQghs0V65okVIlaBcmVvJEKRiCzhMqScQs6oNEyZ5IU7LAmUDQxZkjPRShcvWnDahW
  nYwQYROBoAonekKtOpUKE6tTpjQF8YGlAUEPQ3AE8jSqlCBOqkhZ2qGjyAKCDoTMkHFjzaU4
  MMA4EnXDBpAEBA3QiJGiNAkWpU2cSMEDhEEFUEZwmE179oomCA6W2CKCAoUKFShYeDGGAUIC
  KORwaXEBQw01bx5APJDBDKA6XiAUgDgwwAABALgEix8YEAA7
}
image create photo tb_forward -data {
  R0lGODlhFAAUAOerAAAfTQAgUAAjWAAmXQA4dQpFfQBQlA9NhwBVmwBgpwVnrgBrrw5rrgBx
  twBxuBZsrx9sqwB4vgB4wAB5wAB7zwB8zwB9zwV+zwSA0Cx5twCE0QCFzgCF1ACG0gCHygCH
  zgCHzwCJzQuG0gCJ1QCK1gCK1x+DxCuCwQCN1wCO2ACP0geN1QCP2BeJ0wCR1BaL1AWS2QCU
  2wCV2wCW2wiU2SKN1AGX3ACb3giZ3A2Y2QCc3hWZ2kKPvACg4gCg4xya2hWc3BOf4A2h4ACl
  5ACl5Q+i4ACm5Qqk4QKn5iSe3Cmd3ROk3gum4wCp6TGc2gWo5iWh1gCq6xGm4waq5wCs7QCs
  7hWn5Aar6gCt7zue20Oc2FCa0wCv7y2k2wCx80Gh3ACy9Cuo4TGo4VWf1h2u5w+y7kykzk+i
  2Qu08CKw6FGl0Rq07lil2imz6j+u4zWx5Vyn2xy48Si27WOp3UKz5hu9+CC89S2570q05oOn
  wCO/+Fqy3Guv4o2pwzXA9nC02U+87UfH+Wy/6mXB7GTD71jJ9lfK+WXJ9JLH4LHC0HjQ+r7B
  zp7L4oTT+qHP5ozV+qnU7KbV66rU7ZzZ+6Da+afc+6jd+9TV3K/f+7zj/dLi8cfo/9bn9Ojn
  7Ovn6ujo6+zo6trs+fPr6vDt7u/u8PLv8PHw8vXx8Pbx8fb09v/6+P//////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  /////////////////////////////////yH5BAEKAP8ALAAAAAAUABQAAAj+AP8JHEiwoMGD
  CBMO1NChgwaFBJMMsrQpEyU8PxRuIITpUaA6egxNqkQnISBFdrx4AQNmpZ9GYQ7mOISGi82b
  NuMU+lBQwpoyS7BUoTKFCRYqSO88KRhCThNEfaAgebPIzJEoTa60mUDQBRkikVJ1yqNGlalE
  PIwMSROBoAopPRyNGoXqUqlRpzz98WGlAUEPQm4wAkUq1B5RnzgJuqGjyAKCDoLIgCRJTIwu
  mtzgiDHDBpAEBA3QgIGiRIoULEicPr0DhEEFTkZwmE179golCA6ayCKCAoUKFShYePGFAUIC
  J+BoaXEBQ40zbB5APJBhDJ85WyAUgDgwwAABALgEix8YEAA7
}
image create photo tb_stop -data {
  R0lGODlhFAAUAOedAF0AAGAAAGgAAGwAADYSBD0UBEMVA38IAI4NAKMJAKQJAKMKAKQKAJkP
  AIgUC54SAKMSAKMVAKQVAJEaESk2NagXADA2MzU1MasXAKoZALIXAKsaBrYcADNAPzpAPcwb
  AD8/O8wcAL8gAMMgAK4lENAeANAfAMsiANwgAMwlANQjAMwmAMwmBNElBD1KSssmDc0nA0hI
  RERJR7AuGdImCdcmANInCbouEcwpEdgoAOMlAM8qD8gtCNYqBtEsA9IrC9sqAK01ItYtCOcp
  AL40GNcvBOEtAF9NSFtOS0lTVVZQTlNRT09SUuwsANAzG+UwAMI3JNszBeUxAPAuAN00Bdg1
  D901Btg1Fdw2DeE2A884JuM3AOI4A/QzAOo2AOQ4AOE5BrlBMuo5AMFBMO45ANE+LtBCFuc+
  CvI9APM9AGJfXl5gYfU9APY9APs8AFliZedBDPU/APY/ANpDLe9DB/NDBNdHNO9HC+pIFdRO
  Ie5JEvNKDdhQQdJVLPBRG9pVRvZSE9ZWS/lUCflXEOVeL9FhV/ZcI9dgV9RlXd1nQNhnYNlq
  ZOVqQfpoMPlsOtpybPVwRPpwPN55dfuBVvyIYPqNZfWXdfuWdPidffudf/uhhf6qjv+zl///
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////
  /////////////////////////////////yH5BAEKAP8ALAAAAAAUABQAAAj+AP8JHEiwoMGD
  CBMOXKCAQQKFBIkkwsRpk6U+NxRCYKSpUiNBgyJdypQnIaFJgNqwiROHjRxDlMwc5AGpDpo0
  OHOi2eOIQ0EJd+iQ2VLAgFEDBNyQ8fOloAg9XryAWaOmqpo3XbyIwYOB4IozUqREYbKk7JIk
  U6Q8gZOBYIosRowUkRGjbgwXTeJyqUBwBBUgQHx4AEEYRIchgK1EIKgBS40aMCxcmHyBgo4a
  Oao8IIhASA8VLJAcGX1ECQoVV04Y3GCnhQkbNGLTsFHix5wGB6Hw2fHhQ4gQvp38IYHwwJhF
  gbS8wFHmkKIZECeEQSTpUaEgDiAODDBAAADt4AcCBgQAOw==
}

ttk::frame .main.fbutton
ttk::frame .main.fbutton.button -relief raised -border 1
button .main.fbutton.button.start -image tb_start -command ::move::Start
button .main.fbutton.button.back -image tb_prev -command ::move::Back
button .main.fbutton.button.forward -image tb_next -command ::move::Forward
button .main.fbutton.button.end -image tb_end -command ::move::End
bind .main.fbutton.button.end <Button-$::MB3> ::tactics::findBestMove
ttk::frame .main.fbutton.button.space -width 15

# The go-into-variation button is a menubutton:
menubutton .main.fbutton.button.intoVar -image tb_invar -menu .main.fbutton.button.intoVar.menu -relief raised
menu .main.fbutton.button.intoVar.menu -tearoff 0 -font font_Regular

button .main.fbutton.button.exitVar -image tb_outvar \
    -command {::move::ExitVar }
button .main.fbutton.button.addVar -image tb_addvar \
    -command {sc_var create; updateBoard -pgn -animate}
ttk::frame .main.fbutton.button.space2 -width 15

image create photo tb_flip -data {
  R0lGODdhFAAUAKEAAAAAANDAoKCAUIsAACwAAAAAFAAUAAACXoSPqcHiHJyA0tDXcHS2jT9s
  UyYYEgheY2AKXxaSUPuK6gww3/S66MDJBVK9H7AkHKIiywpAotxFa6ynD8ULpaoOY5YZ69hk
  yuBNh9khz1M1EirD4uDjemtFpyv2/AIAOw==
}

image create photo tb_coords -data {
  R0lGODdhFAAUAKEAANnZ2QAAANDAoKCAUCwAAAAAFAAUAAACR4QRFsItA+FJyrUoUdjIMjwc
  4uKB4gRC1oSmq9aCLxJjM4Wkw11H70YJ6GYjoPF4SiqXTEVTwWE9nZPoEjh6BrPaBA47VRYA
  ADs=
}

image create photo tb_stm -data {
  R0lGODlhFAAUAMIAANDAoKCAUAAAAP///////////////////yH5BAEKAAQALAAAAAAUABQA
  AANHSLHMQjDKRp+8tNkbs+OTF2ygOIKdSHJA67qPIM/Wa8dDntc2TAi6HaTnAwZ5RNxxSAQo
  dchejCZjJlFWKfZHpW2/4LAYmwAAOw==
}

image create photo tb_trial -data {
  R0lGODlhFAAUABEAACH5BAkAAAAALAAAAAAUABQAodnZ2QAAAKCAUIsAAAI8
  hI+pMD0LnYOqGUvjy3WDAAYZZoQiRZYn6n0hl5gyeKSmgOdC3c4yZYLFVkIX
  rWgkUnAK5lIHzUCjSEgBADs=
}

image create photo tb_trial_on -data {
  R0lGODdhFAAUAKEAAP//4IsAAAAAAKCAUCwAAAAAFAAUAAACPISPqRAdC52DqhlL48t1AwEK
  GWaEIkWWJ+p9IZeYMnik5oDnQ93OMmWCxVZCF61oJFJwCuZSB81Ao0hIAQA7
}

#----------------------------------------------------------------------
if {$png_image_support} {
	image create photo tb_flip -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAABl0RVh0
		U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAMLSURBVDiNbZJNaFRXFMf/5777Ms5XJqOT
		z8aYEUFF0xY1ptCQtlDoYkRKFRRBLMWGgjuh+nQj2M1YQVcllFaEkrSlUiklr7OorbZqoTEimmDU
		NvOamGSaaWImmY83mXlzTxfOg1l44O7O+fE/v3OJmeFWNBZfT0RnAbzBzC1EtATQBLMaAPCjZRrl
		mt5TAAbIBURj8XdB9LU3EJRrw0G9OVIPr67BtleR+nchl/ovUwHzR5ZpfBuNxfsBfA6ggZgZ0Vh8
		K4hGQ5FGn8fjQcivozUSRCTkRSTkQ8CrI5Mt4EpitJDNF+/41ui77WKpjhlrnwP2nPvC6w98IDRN
		2LkslFKQgiqN64KF7Zs7Aju2tFOdrkFqhMTtCdXTtUF8Nni95FRURFRXOrhq24KdMq9rbi5E2tpP
		OBW1PpVe3nft1vi9b8yRQs4uQpca9r/9suhobgAAAqCeA5j9QpDT17vrstDkMoCrlmmkLNP4OTl8
		cuf03OKxi5evYX5xBVZqBY5Srkt2E6iXWps+qQ94L3S2N3UBsGpsSyI6+mbP5lJHSxhNYR+kEG4C
		ltW+8I2Bw1m8uL5k5tfvjv9TvD8xXSQQQIBTUWsAsHuFVQC6G6vm/QrgKIDyC8DSMo0ZF+Cc//g9
		DQCUYtwYnVSJ38eegvlVyzQytVNnhh62razkN/ww/MtNAA3uCiACJmeX4ZFA4rcHBODT2uHu/iE/
		ESV7Xtk0ODU91w1AA7AqAEAIIgDobK1Ha2M9PjzQR6Gg7/zGPedGorH47irjiEeX0ppKHX/0ONlL
		RGXLNMrS1ZnNl3DzXpLf6t5EbY0hHNr7mm9kfHrXX5Oz16OxeJ0mpQQRzykFITQioqsAIKvW6NL3
		t+2Z+Uzy7thU5zt9Xf5Q0IuOtgj5/H5feimP9LMsKo4iIQQyC+kCmM8CgKiKo5n5zCVr+OT25Wz+
		/e9++nPpSuJObuzJLOYXc8jZZTATnHKpkllI22Dut0zjIQC4V/gKwBHLNLj6eXQAe4nEMYC3MXOY
		iNIA/mDm05Zp/O3K/R/qul6uO089wQAAAABJRU5ErkJggg==
	}
}
#----------------------------------------------------------------------

##############################

namespace eval ::board {
  
  namespace export sq
  
  # List of square names in order; used by sq procedure.
  variable squareIndex [list a1 b1 c1 d1 e1 f1 g1 h1 a2 b2 c2 d2 e2 f2 g2 h2 \
      a3 b3 c3 d3 e3 f3 g3 h3 a4 b4 c4 d4 e4 f4 g4 h4 \
      a5 b5 c5 d5 e5 f5 g5 h5 a6 b6 c6 d6 e6 f6 g6 h6 \
      a7 b7 c7 d7 e7 f7 g7 h7 a8 b8 c8 d8 e8 f8 g8 h8]
}

# ::board::sq:
#    Given a square name, returns its index as used in board
#    representations, or -1 if the square name is invalid.
#    Examples: [sq h8] == 63; [sq a1] = 0; [sq notASquare] = -1.
#
proc ::board::sq {sqname} {
  variable squareIndex
  return [lsearch -exact $squareIndex $sqname]
}

# ::board::san --
#
#	Convert a square number (0-63) used in board representations
#	to the SAN square name (a1, a2, ..., h8).
#
# Arguments:
#	sqno	square number 0-63.
# Results:
#	Returns square name "a1"-"h8".
#
proc ::board::san {sqno} {
  if {($sqno < 0) || ($sqno > 63)} { return }
  return [format %c%c \
      [expr {($sqno % 8) + [scan a %c]}] \
      [expr {($sqno / 8) + [scan 1 %c]}]]
  
}

# ::board::new
#   Creates a new board in the specified frame.
#   The psize option should be a piece bitmap size supported
#   in Scid (see the boardSizes variable in start.tcl).
#   The showmat parameter adds a frame to display material balance
#
proc ::board::new {w {psize 40} {showmat "nomat"} } {
  if {[winfo exists $w]} { return }
  
  set ::board::_size($w) $psize
  set ::board::_border($w) $::borderwidth
  set ::board::_coords($w) 0
  set ::board::_flip($w) 0
  set ::board::_data($w) [sc_pos board]
  set ::board::_stm($w) 1
  set ::board::_showMarks($w) 0
  set ::board::_mark($w) {}
  set ::board::_drag($w) -1
  set ::board::_showmat($w) 0
  
  if { $showmat != "nomat"} { set ::board::_showmat($w) 1 }
  
  set border $::board::_border($w)
  set bsize [expr {$psize * 8 + $border * 9} ]
  
  
  ttk::frame $w -class Board
  canvas $w.bd -width $bsize -height $bsize -cursor crosshair -background black -borderwidth 0 -highlightthickness 0
  if {[info tclversion] == 8.5} {
    grid anchor $w center
  }
  
  grid $w.bd -row 1 -column 3 -rowspan 8 -columnspan 8
  set bd $w.bd
  
  
  # Create empty board:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8} ]
    set yi [expr {int($i/8)} ]
    set x1 [expr {$xi * ($psize + $border) + $border +1 } ]
    set y1 [expr {(7 - $yi) * ($psize + $border) + $border +1 } ]
    set x2 [expr {$x1 + $psize }]
    set y2 [expr {$y1 + $psize }]
    
    $bd create rectangle $x1 $y1 $x2 $y2 -tag sq$i -outline ""
  }
  
  # Set up coordinate labels:
  for {set i 1} {$i <= 8} {incr i} {
    ttk::label $w.lrank$i -text [expr {9 - $i}]
    grid $w.lrank$i -row $i -column 2 -sticky e
    ttk::label $w.rrank$i -text [expr {9 - $i}]
    grid $w.rrank$i -row $i -column 11 -sticky w
  }
  foreach i {1 2 3 4 5 6 7 8} file {a b c d e f g h} {
    ttk::label $w.tfile$file -text $file
    grid $w.tfile$file -row 0 -column [expr $i + 2] -sticky s
    ttk::label $w.bfile$file -text $file
    grid $w.bfile$file -row 9 -column [expr $i + 2] -sticky n
  }
  
  # Set up side-to-move icons:
  ttk::frame $w.stmgap -width 3
  ttk::frame $w.stm
  frame $w.wtm -relief solid -borderwidth 1 -background white
  frame $w.btm -relief solid -borderwidth 1 -background black
  grid $w.stmgap -row 1 -column 1
  grid $w.stm -row 2 -column 0 -rowspan 5 -padx 2
  if {$::board::_showmat($w)} {
    canvas $w.mat -width 20 -highlightthickness 0
  }
  
  grid $w.wtm -row 8 -column 0
  grid $w.btm -row 1 -column 0
  if {$::board::_showmat($w)} {
    grid $w.mat -row 1 -column 12 -rowspan 8 -pady 5
  }
  
  ::board::stm $w
  ::board::coords $w
  ::board::resize $w redraw
  if {$::board::_showmat($w)} {
    ::board::material $w
  }
  ::board::update $w
  return $w
}

# ::board::defaultColor
#   Returns the color (the value of the global
#   variable "lite" or "dark") depending on whether the
#   specified square number (0=a1, 1=b1, ..., 63=h8) is
#   a light or dark square.
#
proc ::board::defaultColor {sq} {
  return [expr {($sq + ($sq / 8)) % 2 ? "$::lite" : "$::dark"}]
}

# ::board::size
#   Returns the current board size.
#
proc ::board::size {w} {
  return $::board::_size($w)
}

################################################################################
# Pascal Georges :
# an alias resize function to handle the bug (flip + resize) : when the board was flipped, and the board resized
# its state was incoherent. As this did not occur when the board is not flipped, unflip the board before the
# resizing : should be fixed !
################################################################################
proc ::board::resize2 {w psize} {
  if {$psize == $::board::_size($w)} { return $psize }
  if { ! [ ::board::isFlipped $w ] } {
    ::board::resize $w $psize
  }  else {
    ::board::flip $w
    ::board::resize $w $psize
    ::board::flip $w
  }
}

# ::board::resize
#   Resizes the board. Takes a numeric piece size (which should
#   be in the global boardSizes list variable), or "-1" or "+1".
#   If the size argument is "redraw", the board is redrawn.
#   Returns the new size of the board.
#
proc ::board::resize {w psize} {
  global boardSizes
  
  set oldsize $::board::_size($w)
  if {$psize == $oldsize} { return $oldsize }
  if {$psize == "redraw"} { set psize $oldsize }
  if {$psize == "-1"} {
    set index [lsearch -exact $boardSizes $oldsize]
    if {$index == 0} { return $oldsize }
    incr index -1
    set psize [lindex $boardSizes $index]
  } elseif {$psize == "+1"} {
    set index [lsearch -exact $boardSizes $oldsize]
    incr index
    if {$index == [llength $boardSizes]} { return $oldsize }
    set psize [lindex $boardSizes $index]
  }
  
  # Verify that we have a valid size:
  if {[lsearch -exact $boardSizes $psize] < 0} { return $oldsize }
  
  set border $::board::_border($w)
  set bsize [expr {$psize * 8 + $border * 9} ]
  
  $w.bd configure -width $bsize -height $bsize
  set ::board::_size($w) $psize
  
  # Resize each square:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8}]
    set yi [expr {int($i/8)}]
    set x1 [expr {$xi * ($psize + $border) + $border }]
    set y1 [expr {(7 - $yi) * ($psize + $border) + $border }]
    set x2 [expr {$x1 + $psize }]
    set y2 [expr {$y1 + $psize }]
    $w.bd coords sq$i $x1 $y1 $x2 $y2
  }
  
  # Resize the side-to-move icons:
  set stmsize [expr {round($psize / 4) + 5}]
  $w.stm configure -width $stmsize
  $w.wtm configure -height $stmsize -width $stmsize
  $w.btm configure -height $stmsize -width $stmsize
  
  # resize the material canvas
  if {$::board::_showmat($w)} {
    $w.mat configure -height [expr $psize * 8]
    $w.mat configure -width 20
    ::board::material $w
  }
  
  ::board::update $w
  
  return $psize
}

# ::board::border
#   Get or set the border width.
#   If the optional argument is missing or the empty string, returns
#   the width of the board.
#   Otherwise, the board sqyare borders are set to the specified width.
#
proc ::board::border {w {border ""}} {
  if {$border == ""} {
    return $::board::_border($w)
  } else {
    set ::board::_border($w) $border
    ::board::resize2 $w redraw
  }
}

# ::board::getSquare
#   Given a board frame and root-window X and Y screen coordinates,
#   returns the square number (0-63) containing that screen location,
#   or -1 if the location is outside the board.
#
proc ::board::getSquare {w x y} {
  if {[winfo containing $x $y] != "$w.bd"} {
    return -1
  }
  set x [expr {$x - [winfo rootx $w.bd]}]
  set y [expr {$y - [winfo rooty $w.bd]}]
  set psize $::board::_size($w)
  set border $::board::_border($w)
  set x [expr {int($x / ($psize+$border))}]
  set y [expr {int($y / ($psize+$border))}]
  
  if {$x < 0  ||  $y < 0  ||  $x > 7  ||  $y > 7} {
    set sq -1
  } else {
    set sq [expr {(7-$y)*8 + $x}]
    if {$::board::_flip($w)} { set sq [expr {63 - $sq}] }
  }
  return $sq
}

# ::board::showMarks
#   Turns on/off the showing of marks (colored squares).
#
proc ::board::showMarks {w value} {
  set ::board::_showMarks($w) $value
}

# ::board::colorSquare
#   Colors the specified square (0-63) of the board.
#   If the color is the empty string, the appropriate
#   color for the square (light or dark) is used.
#
proc ::board::colorSquare {w i {color ""}} {
  if {$i < 0  ||  $i > 63} { return }
  if {$color != ""} {
    $w.bd itemconfigure br$i -state hidden
  } else {
    set color [::board::defaultColor $i]
    set brstate "normal"
    foreach mark $::board::_mark($w) {
      if {[lindex $mark 1] == $i && [lindex $mark 0] == "full"} {
        set color [lindex $mark 3]
        set brstate "hidden"        
      }
    }
    $w.bd itemconfigure br$i -state $brstate
  }
  $w.bd itemconfigure sq$i -fill $color -outline ""  
}

# ::board::midSquare
#   Given a board and square number, returns the canvas X/Y
#   coordinates of the midpoint of that square.
#
proc ::board::midSquare {w sq} {
  set c [$w.bd coords sq$sq]
  #Klimmek: calculation change, because some sizes are odd and then some squares are shifted by 1 pixel
  # set x [expr {([lindex $c 0] + [lindex $c 2]) / 2} ]
  # set y [expr {([lindex $c 1] + [lindex $c 3]) / 2} ]
  set psize $::board::_size($w)
  if { $psize % 2 } { set psize [expr {$psize - 1}] }
  set x [expr {[lindex $c 0] + $psize/2} ]
  set y [expr {[lindex $c 1] + $psize/2} ]
  return [list $x $y]
}


# ::board::setmarks --
#
#	Set the marks for the board:
#	colored squares, arrows, circles, etc.
#
# Arguments:
#	w	A frame containing a board '$win.bd'.
#       cmds    Commands to draw the marks
# Results:
#	Sets ::board::_mark($w) with all the right formatted commands.
#       Marks will be drawn by ::board::update
#	Returns nothing.
#
proc ::board::setmarks {w cmds} {
  set ::board::_mark($w) {}
  foreach {cmd discard} [mark::getEmbeddedCmds $cmds] {
    lset cmd 1 [::board::sq [lindex $cmd 1]]
    set dest [::board::sq [lindex $cmd 2]]
    if {$dest != -1} {lset cmd 2 $dest}
    lappend ::board::_mark($w) $cmd
  }
}

### Namespace ::board::mark

namespace eval ::board::mark {
  namespace import [namespace parent]::sq
  
  # Regular expression constants for
  # matching Scid's embedded commands in PGN files.
  
  variable StartTag {\[%}
  variable ScidKey  {mark|arrow}
  variable Command  {draw}
  variable Type     {full|square|arrow|circle|disk|tux}
  variable Text     {[-+=?!A-Za-z0-9]}
  variable Square   {[a-h][1-8]\M}
  variable Color    {[\w#][^]]*\M}	;# FIXME: too lax for #nnnnnn!
  variable EndTag   {\]}
  
  # Current (non-standard) version:
  variable ScidCmdRegex \
      "$StartTag              # leading tag
  ($ScidKey)\\\ +        # (old) command name + space chars
  ($Square)              # mandatory square (e.g. 'a4')
  (?:\\ +($Square))?     # optional: another (destination) square
  (?:\\ *($Color))?      # optional: color name
  $EndTag                # closing tag
  "
  # Proposed new version, according to the
  # PGN Specification and Implementation Guide (Supplement):
  variable StdCmdRegex \
      "${StartTag}            # leading tag
  ${Command}             # command name
  \\                     # a space character
  (?:(${Type}|$Text),)?  # keyword, e.g. 'arrow' (may be omitted)
  # or single char (indicating type 'text')
  ($Square)              # mandatory square (e.g. 'a4')
  (?:,($Square))?        # optional: (destination) square
  (?:,($Color))?         # optional: color name
  $EndTag                # closing tag
  "

  # ChessBase' syntax for markers and arrows
  variable CBSquare    {csl}
  variable CBarrow     {cal}
  variable CBColor     {[GRY]}
  variable Square      {[a-h][1-8]\M}
  variable sqintern    {[a-h][1-8]}

  variable CBSquareRegex \
     "$StartTag
     ($CBSquare)\\\ +
     ($CBColor)
     ($Square)
     (?:,($CBColor)($Square))?
     $EndTag
     "

  variable CBArrowRegex \
     "$StartTag
     ($CBarrow)\\\ +
     ($CBColor)
     ($sqintern)
     ($sqintern)
     $EndTag
     "
}

# ::board::mark::getEmbeddedCmds --
#
#	Scans a game comment string and extracts embedded commands
#	used by Scid to mark squares or draw arrows.
#
# Arguments:
#	comment     The game comment string, containing
#	            embedded commands, e.g.:
#	            	[%mark e4 green],
#	            	[%arrow c4 f7],
#	            	[%draw e4],
#	            	[%draw circle,f7,blue].
# Results:
#	Returns a list of embedded Scid commands,
#		{command indices ?command indices...?},
#	where 'command' is a list representing the embedded command:
#		'{type square ?arg? color}',
#		e.g. '{circle f7 red}' or '{arrow c4 f7 green}',
#	and 'indices' is a list containing start and end position
#	of the command string within the comment.
#
proc ::board::mark::getEmbeddedCmds {comment} {
  if {$comment == ""} {return}
  variable ScidCmdRegex
  variable StdCmdRegex
  variable CBSquareRegex
  variable CBArrowRegex
  set result {}
  
  # Build regex and search script for embedded commands:
  set regex  ""
  foreach r [list $ScidCmdRegex $StdCmdRegex $CBSquareRegex $CBArrowRegex] {
    if {[string equal $regex ""]} {set regex $r} else {append regex "|$r"}
  }
  set locateScript  {regexp -expanded -indices -start $start \
        $regex $comment indices}
  
  # Loop over all embedded commands contained in comment string:
  
  for {set start 0} {[eval $locateScript]} {incr start} {
    foreach {first last} $indices {}	;# just a multi-assign
    foreach re [list $ScidCmdRegex $StdCmdRegex $CBSquareRegex $CBArrowRegex] {
      # Assing matching subexpressions to variables:
      if {![regexp -expanded $re [string range $comment $first $last] \
            match type arg1 arg2 color]} {
        continue
      }
      # CB uses rotated arguments. Bring them in order
      if {[string equal $type "csl"] || [string equal $type "cal"]} {
         set dummy1 $arg1
         set dummy2 $arg2
         set dummy3 $color
         set color $dummy1
         set arg1  $dummy2
         set arg2  $dummy3
         if {[string equal $type "csl"]} {set type  "full"  }
         if {[string equal $type "cal"]} {set type  "arrow" }
         if {[string equal $color "R"]}  {set color "red"   }
         if {[string equal $color "G"]}  {set color "green" }
         if {[string equal $color "Y"]}  {set color "yellow"}
      }
      # Settings of (default) type and arguments:
      if {[string equal $color ""]}   { set color "red" }
      switch -glob -- $type {
        ""   {set type [expr {[string length $arg2] ? "arrow" : "full"}]}
        mark {set type "fu"	;# new syntax}
        ?    {if {[string length $arg2]} break else {
            set arg2 $type; set type "text"}
        }
      }
      # Construct result list:
      lappend result [list $type $arg1 $arg2 $color]
      lappend result $indices
      set start $last	;# +1 by for-loop
    }
  }
  return $result
}

# ::board::mark::remove --
#
#	Removes a specified mark.
#
# Arguments:
#	win	A frame containing a board '$win.bd'.
#	args	List of one or two squares.
# Results:
#	Appends a dummy mark to the bord's list of marks
#	which causes the add routine to delete all marks for
#	the specified square(s).
#
proc ::board::mark::remove {win args} {
  if {[llength $args] == 2} {
    eval add $win arrow $args nocolor 1
  } else {
    add $win DEL [lindex $args 0] "" nocolor 1
  }
}

# ::board::mark::add --
#
#	Draws arrow or mark on the specified square(s).
#
# Arguments:
#	win		A frame containing a board 'win.bd'.
#	args		What kind of mark:
#	  type  	  Either type id (e.g., square, circle) or
#			    a single character, which is of type 'text'.
#	  square	  Square number 0-63 (0=a1, 1=a2, ...).
#	  ?arg2?	  Optional: additional type-specific parameter.
#	  color 	  Color to use for marking the square (mandatory).
#	  ?new? 	  Optional: whether or not this mark should be
#			    added to the list of marks; defaults to 'true'.
# Results:
#	For a given square, mark type, color, and optional (type-specific)
#	destination arguments, creates the proper canvas object.
#
proc ::board::mark::add {win args} {
  # Rearrange list if "type" is simple character:
  if {[string length [lindex $args 0]] == 1} {
    # ... e.g.,  {c e4 red} --> {text e4 c red}
    set args [linsert $args 1 "text"]
    set args [linsert [lrange $args 1 end] 2 [lindex $args 0]]
  }
  # Add default arguments:
  if {![regexp true|false|1|0 [lindex $args end]]} {
    lappend args "true"
  }
  if {[llength $args] == 4} { set args [linsert $args 2 ""]}
  
  # Here we (should) have: args == <type> <square> ?<arg>? <color> <new>
  foreach {type square dest color new} $args {break}	;# assign
  if {[llength $args] != 5 } { return }
  
  set board $win.bd
  set type  [lindex $args 0]
  
  # Remove existing marks:
  if {$type == "arrow"} {
    $board delete "mark${square}:${dest}" "mark${dest}:${square}"
    if {[string equal $color "nocolor"]} { set type DEL }
  } else {
    $board delete "mark${square}"
    #not needed anymore
    #    ::board::colorSquare $win $square [::board::defaultColor $square]
  }
  
  switch -- $type {
    full    { ::board::colorSquare $win $square $color }
    DEL     { set new 1 }
    default {
      # Find a subroutine to draw the canvas object:
      set drawingScript "Draw[string totitle $type]"
      if {![llength [info procs $drawingScript]]} { return }
      
      # ... and try it:
      if {[catch {eval $drawingScript $board $square $dest $color}]} {
        return
      }
    }
  }
  if {$new} { lappend ::board::_mark($win) [lrange $args 0 end-1] }
}

# ::board::mark::DrawXxxxx --
#
#	Draws specified canvas object,
#	where "Xxxxx" is some required type, e.g. "Circle".
#
# Arguments:
#	pathName	Name of the canvas widget.
#	args		Type-specific arguments, e.g.
#				<square> <color>,
#				<square> <square> <color>,
#				<square> <char> <color>.
# Results:
#	Constructs and evaluates the proper canvas command
#	    "pathName create type coordinates options"
#	for the specified object.
#

# ::board::mark::DrawCircle --
#
proc ::board::mark::DrawCircle {pathName square color} {
  # Some "constants":
  set size 0.6	;# inner (enclosing) box size, 0.0 <  $size < 1.0
  set width 0.1	;# outline around circle, 0.0 < $width < 1.0
  
  set box [GetBox $pathName $square $size]
  lappend pathName create oval [lrange $box 0 3] \
      -tag [list mark circle mark$square p$square]
  if {$width > 0.5} {
    ;# too thick, draw a disk instead
    lappend pathName -fill $color
  } else {
    set width [expr {[lindex $box 4] * $width}]
    if {$width <= 0.0} {set width 1.0}
    lappend pathName -fill "" -outline $color -width $width
  }
  eval $pathName
}

# ::board::mark::DrawDisk --
#
proc ::board::mark::DrawDisk {pathName square color} {
  # Size of the inner (enclosing) box within the square:
  set size 0.6	;# 0.0 <  $size < 1.0 = size of rectangle

  set box [GetBox $pathName $square $size]
  eval $pathName \
      {create oval [lrange $box 0 3]} \
      -fill $color \
      {-tag [list mark disk mark$square p$square]}
}

# ::board::mark::DrawText --
# Pascal Georges : if shadow!="", try to make the text visible even if fg and bg colors are close
proc ::board::mark::DrawText {pathName square char color {size 0} {shadowColor ""}} {
  set box [GetBox $pathName $square 0.8]
  set len [expr {($size > 0) ? $size : int([lindex $box 4])}]
  set x   [lindex $box 5]
  set y   [lindex $box 6]
  $pathName delete text$square mark$square
  if {$shadowColor!=""} {
    eval $pathName \
        create text [expr $x+1] [expr $y+1] -fill $shadowColor \
        {-font [list helvetica $len bold]} \
        {-text [string index $char 0]}     \
        {-anchor c} \
        {-tag  [list mark text text$square mark$square p$square]}
    
  }
  eval $pathName \
      create text $x $y -fill $color     \
      {-font [list helvetica $len bold]} \
      {-text [string index $char 0]}     \
      {-anchor c} \
      {-tag  [list mark text text$square mark$square p$square]}
}

# ::board::mark::DrawArrow --
#
proc ::board::mark::DrawArrow {pathName from to color} {
  if {$from < 0  ||  $from > 63} { return }
  if {$to   < 0  ||  $to   > 63} { return }
  set coord [GetArrowCoords $pathName $from $to]
  eval $pathName \
      {create line $coord} \
      -fill $color -arrow last -width 2 \
      {-tag [list mark arrows "mark${from}:${to}"]}
}

# ::board::mark::DrawRectangle --
# Draws a rectangle surrounding the square
proc ::board::mark::DrawRectangle { pathName square color pattern } {
  if {$square < 0  ||  $square > 63} { puts "error square = $square" ; return }
  set box [::board::mark::GetBox $pathName $square]
  $pathName create rectangle [lindex $box 0] [lindex $box 1] [lindex $box 2] [lindex $box 3] \
      -outline $color -width $::highlightLastMoveWidth -dash $pattern -tag highlightLastMove
}

# ::board::mark::DrawTux --
#
image create photo tux16x16 -data \
    {R0lGODlhEAAQAPUyAAAAABQVFiIcBi0tLTc0Kj4+PkQ3CU9ADVVFD1hJFV1X
      P2pXFWJUKHttLnttOERERVVWWWRjYWlqcYNsGJR5GrSUIK6fXsKdGMCdI8er
      ItCuNtm2KuS6KebAKufBOvjJIfnNM/3TLP/aMP/lM+/We//lQ//jfoGAgJaU
      jpiYmqKipczBmv/wk97e3v//3Ojo6f/96P7+/v///wAAAAAAAAAAAAAAAAAA
      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEBADIALAAAAAAQABAAAAbm
      QJlMJpMBAAAAQCaTyWQymUwmAwQAAQAAIJPJZDKZTCYDQCInCQAgk8lkMplM
      JgMwOBoHACCTyYAymUwmkwEao5IFAADIZDKZTCaTAVQu2GsAAMhkMplMJgMU
      YrFY7AQAAGQymUwmA6RisVjsFQAAATKZTCYDBF6xWCwWewAAAJlMJjMoYrFY
      LBaDAAAAmUwW+oBWsVgsxlokFgCZTBYChS6oWCxmAn5CHYNMJhOJQiFS7JXS
      iEQjCkAmw3BCow0hAMiMNggAQCYDAAyTAwAASEwEAABAJpPJAAAAAACUAQAA
      gEwmCwIAOw==}
set ::board::mark::tux16x16 tux16x16

image create photo tux32x32 -data \
    {R0lGODlhIAAgAPU0AAAAABANAxERESAaBiwkCDAnCSQkJEM2DEA3GVBBDllJ
      EFNKLG5aFHBbFHpkFnZoMkBAQFBQUGBgYHBwcIBpF4xyGZ+DHZ+GKqmKHq+T
      Lb+hNsynJNSuJtu0J9+6NeW8Kc+wQPnMLPTJMP7QLv/UO//aVf/dYv/ifIiI
      hp+fn6+vr7+/v//lif/ol//rpM/Pz9/f3//22O/u6v/55f///////wAAAAAA
      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEBADUALAAAAAAgACAAAAb+
      wFqtVqvVarVarQYAAAAAAABQq9VqtVqtVqvVarVarVar1Wq1Wg0AAAAAAAAA
      AKjVarVarVar1YC1Wq1Wq9VqtVqtBgAAAAAAAAAAAGq1Wq1Wq9VqtVqtVqvV
      arVaDQAAAAAAAAAAAABqtVqtVqsBa7VarVar1Wq1Wq0GMMgighdtAgAAALVa
      rVar1Wq1Wq1Wq9VqtVqtBphEUpCUQQUAAAC1Wq1WA9ZqtVqtVqvVarVarVYD
      RBYejwahAgAAgFqtVqvVarVarVar1Wq1Wq1WAxRIIdFolAEAAABArQas1Wq1
      Wq1Wq9VqtVqtVqvVGqPRaDTSAAAAAKBWq9VqtVr+rVar1Wq1Wq1Wq9UMp9Fo
      xJIJAAAAAFir1Wq1Wq1Wq9VqtVqtVqvVABGaqzWj0SYAAAAAqNVqtVqtVqvV
      arVarVarAQQyGo1Go9FgAAAQAAAAarVarVar1Wq1Wq1WqwEAExqNRqPRaDSD
      AAAAAGq1Wq1Wq9VqtVqtVqsBAC8ajUaj0Wg0oAoAAAAAgFqtVqvVarVarVar
      AQACGo1Go9FoNBpNAAAAAIBarVar1Wq1Wq1WqwEAKhqNRqPRaEAajYYCAAAA
      AKBWq9VqtVqtVqvVAAIajUaj0Wg0Go22AgAAAACgVqvVarVarVarAQARGo1G
      o9GANBqNRpMBAAAAAAD+qNVqtVqtVqvVAAAUjUaj0Wg0Go1GowkAAAAAAKjV
      arVarVar1QgUFI1GowFpNBqNRqPRDAZDAAAA1Gq1Wq1Wq9VGo1HpRaPRaDQa
      jUY7iQAAwUMBANRqtVqtVhuFRqPR6LIC0mg0Go1Go5lGiYBlVAEAarVarVar
      jUaj0Wg0KqRoNBqNRqOZRqPRaPQBAGq1Wq1Wq41Go9FoBBxtADIajUaj0Uyj
      0Wg0Gn0YgFqtVqvVRqPRaDQajVw0Go1Go6VGo9FoNBqNOABArVar1Uaj0Qg4
      Go1GoxiNRntFBqPRaDQajT4KAKBWq9Vqo9FoNBqNRiOHASIAAAqj0Wg0CmGW
      AAAAoFar1WoYDlAUGo1Go1FFAAAAAInRaDT6EAAAAABQq9VqNQAAAHB0QqNO
      AQAAAACA0Gi0AQAAAECtVqvVajUgAAAAAAAAAAAAAAAAAAAAAAAAAIBarVar
      1Wq1Wq1WqwEAAAAAAKjVarUaAAAAAAC1Wq1Wq9VqwFqtVqvVarVarVar1Wq1
      Wq1Wq9VqtVqtVqvVarUgADs=
    }
set ::board::mark::tux32x32 tux32x32

proc ::board::mark::DrawTux {pathName square discard} {
  variable tux16x16
  variable tux32x32
  set box [::board::mark::GetBox $pathName $square]
  for {set len [expr {int([lindex $box 4])}]} {$len > 0} {incr len -1} {
    if {[info exists tux${len}x${len}]} break
  }
  if {!$len} return
  $pathName create image [lrange $box 5 6] \
      -image tux${len}x${len} \
      -tag [list mark "mark$square" tux]
}

# ::board::mark::GetArrowCoords --
#
#	Auxiliary function:
#	Similar to '::board::midSquare', but this function returns
#	coordinates of two (optional adjusted) squares.
#
# Arguments:
#	board	A board canvas ('win.bd' for a frame 'win').
#	from	Source square number (0-63).
#	to	Destination square number (0-63).
#	shrink	Optional shrink factor (0.0 - 1.0):
#		  0.0 = no shrink, i.e. just return midpoint coordinates,
#		  1.0 = start and end at edge (unless adjacent squares).
# Results:
#	Returns a list of coodinates {x1 y1 x2 y2} for drawing
#	an arrow "from" --> "to".
#
proc ::board::mark::GetArrowCoords {board from to {shrink 0.6}} {
  if {$shrink < 0.0} {set shrink 0.0}
  if {$shrink > 1.0} {set shrink 1.0}
  
  # Get left, top, right, bottom, length, midpoint_x, midpoint_y:
  set fromXY [GetBox $board $from]
  set toXY   [GetBox $board $to]
  # Get vector (dX,dY) = to(x,y) - from(x,y)
  # (yes, misusing the foreach multiple features)
  foreach {x0 y0} [lrange $fromXY 5 6] {x1 y1} [lrange $toXY 5 6] {break}
  set dX [expr {$x1 - $x0}]
  set dY [expr {$y1 - $y0}]
  
  # Check if we have good coordinates and shrink factor:
  if {($shrink == 0.0) || ($dX == 0.0 && $dY == 0.0)} {
    return [list $x0 $y0 $x1 $y1]
  }
  
  # Solve equation: "midpoint + (lamda * vector) = edge point":
  if {abs($dX) > abs($dY)} {
    set edge [expr {($dX > 0) ? [lindex $fromXY 2] : [lindex $fromXY 0]}]
    set lambda [expr {($edge - $x0) / $dX}]
  } else {
    set edge [expr {($dY > 0) ? [lindex $fromXY 3] : [lindex $fromXY 1]}]
    set lambda [expr {($edge - $y0) / $dY}]
  }
  
  # Check and adjust shrink factor for adjacent squares
  # (i.e. don't make arrows too short):
  set maxShrinkForAdjacent 0.667
  if {$shrink > $maxShrinkForAdjacent} {
    set dFile [expr {($to % 8) - ($from % 8)}]
    set dRank [expr {($from / 8) - ($to / 8)}]
    if {(abs($dFile) <= 1) && (abs($dRank) <= 1)} {
      set shrink $maxShrinkForAdjacent
    }
  }
  
  # Return shrinked line coordinates {x0', y0', x1', y1'}:
  set shrink [expr {$shrink * $lambda}]
  return [list [expr {$x0 + $shrink * $dX}] [expr {$y0 + $shrink * $dY}]\
      [expr {$x1 - $shrink * $dX}] [expr {$y1 - $shrink * $dY}]]
}

# ::board::mark::GetBox --
#
#	Auxiliary function:
#	Get coordinates of an inner box for a specified square.
#
# Arguments:
#	pathName	Name of a canvas widget containing squares.
#	square		Square number (0..63).
#	portion		Portion (length inner box) / (length square)
#			(1.0 means: box == square).
# Results:
#	Returns a list whose elements are upper left and lower right
#	corners, length, and midpoint (x,y) of the inner box.
#
proc ::board::mark::GetBox {pathName square {portion 1.0}} {
  set coord [$pathName coords sq$square]
  set len [expr {[lindex $coord 2] - [lindex $coord 0]}]
  if {$portion < 1.0} {
    set dif [expr {$len * (1.0 -$portion) * 0.5}]
    foreach i {0 1} { lappend box [expr {[lindex $coord $i] + $dif}] }
    foreach i {2 3} { lappend box [expr {[lindex $coord $i] - $dif}] }
  } else {
    set box $coord
  }
  lappend box [expr { [lindex $box 2] - [lindex $box 0]     }]
  lappend box [expr {([lindex $box 0] + [lindex $box 2]) / 2}]
  lappend box [expr {([lindex $box 1] + [lindex $box 3]) / 2}]
  return $box
}

### End of namespace ::board::mark

# ::board::piece {w sq}
#   Given a board and square number, returns the piece type
#   (e for empty, wp for White Pawn, etc) of the square.
proc ::board::piece {w sq} {
  set p [string index $::board::_data($w) $sq]
  return $::board::letterToPiece($p)
}

# ::board::setDragSquare
#   Sets the square from whose piece should be dragged.
#   To drag nothing, the square value should be -1.
#   If the previous value is a valid square (0-63), the
#   piece being dragged is returned to its home square first.
#
proc ::board::setDragSquare {w sq} {
  set oldSq $::board::_drag($w)
  if {$oldSq >= 0  &&  $oldSq <= 63} {
    ::board::drawPiece $w $oldSq [string index $::board::_data($w) $oldSq]
    $w.bd raise arrows
  }
  set ::board::_drag($w) $sq
}

# ::board::dragPiece
#   Drags the piece of the drag-square (as set above) to
#   the specified global (root-window) screen cooordinates.
#
proc ::board::dragPiece {w x y} {
  set sq $::board::_drag($w)
  if {$sq < 0} { return }
  set x [expr {$x - [winfo rootx $w.bd]} ]
  set y [expr {$y - [winfo rooty $w.bd]} ]
  $w.bd coords p$sq $x $y
  $w.bd raise p$sq
}

# ::board::bind
#   Binds the given event on the given square number to
#   the specified action.
#
proc ::board::bind {w sq event action} {
  if {$sq == "all"} {
    for {set i 0} {$i < 64} {incr i} {
      $w.bd bind p$i $event $action
    }
  } else {
    $w.bd bind p$sq $event $action
  }
}

# ::board::drawPiece
#   Draws a piece on a specified square.
#
proc ::board::drawPiece {w sq piece} {
  set psize $::board::_size($w)
  set flip $::board::_flip($w)
  # Compute the XY coordinates for the centre of the square:
  set midpoint [::board::midSquare $w $sq]
  set xc [lindex $midpoint 0]
  set yc [lindex $midpoint 1]
  # Delete any old image for this square, and add the new one:
  $w.bd delete p$sq
  $w.bd create image $xc $yc -image $::board::letterToPiece($piece)$psize -tag p$sq
}

# ::board::clearText
#   Remove all text annotations from the board.
#
proc ::board::clearText {w} {
  $w.bd delete texts
}

# ::board::drawText
#   Draws the specified text on the specified square.
#   Additional arguments are treated as canvas text parameters.
#
proc ::board::drawText {w sq text color args {shadow ""} } {
  mark::DrawText ${w}.bd $sq $text $color \
      [expr {[catch {font actual font_Bold -size} size] ? 11 : $size}] \
      $shadow
  #if {[llength $args] > 0} {
  #  catch {eval $w.bd itemconfigure text$sq $args}
  #}
}

# Highlight last move played by drawing a red rectangle around the two squares
proc  ::board::lastMoveHighlight {w} {
  $w.bd delete highlightLastMove
  if { ! $::highlightLastMove } {return}
  set moveuci [ sc_game info previousMoveUCI ]
  if {[string length $moveuci] >= 4} {
    set moveuci [ string range $moveuci 0 3 ]
    set square1 [ ::board::sq [string range $moveuci 0 1 ] ]
    set square2 [ ::board::sq [string range $moveuci 2 3 ] ]
    ::board::mark::DrawRectangle $w.bd $square1 $::highlightLastMoveColor $::highlightLastMovePattern
    ::board::mark::DrawRectangle $w.bd $square2 $::highlightLastMoveColor $::highlightLastMovePattern
  }
}

# ::board::update
#   Update the board given a 64-character board string as returned
#   by the "sc_pos board" command. If the board string is empty, it
#   defaults to the previous value for this board.
#   If the optional paramater "animate" is 1 and the changes from
#   the previous board state appear to be a valid chess move, the
#   move is animated.
#
proc ::board::update {w {board ""} {animate 0}} {  
  set oldboard $::board::_data($w)
  if {$board == ""} {
    set board $::board::_data($w)
  } else {
    set ::board::_data($w) $board
  }
  set psize $::board::_size($w)
  set flip $::board::_flip($w)
  
  # Cancel any current animation:
  after cancel "::board::_animate $w"
  
  # Remove all marks (incl. arrows) from the board:
  $w.bd delete mark
  
  # Draw each square:
  for {set sq 0} { $sq < 64 } { incr sq } {
    set piece [string index $board $sq]
    # Compute the XY coordinates for the centre of the square:
    set midpoint [::board::midSquare $w $sq]
    set xc [lindex $midpoint 0]
    set yc [lindex $midpoint 1]
    #update every square with color and texture
    set color [::board::defaultColor $sq]
    $w.bd itemconfigure sq$sq -fill $color -outline "" ; #-outline $color
    
    set boc bgd$psize
    if { ($sq + ($sq / 8)) % 2 } { set boc bgl$psize }
    $w.bd delete br$sq
    $w.bd create image $xc $yc -image $boc -tag br$sq
    
    # Delete any old image for this square, and add the new one:
    $w.bd delete p$sq
    $w.bd create image $xc $yc -image $::board::letterToPiece($piece)$psize -tag p$sq
  }
  
  # Update side-to-move icon:
  grid remove $w.wtm $w.btm
  if {$::board::_stm($w)} {
    set side [string index $::board::_data($w) 65]
    if {$side == "w"} { grid configure $w.wtm }
    if {$side == "b"} { grid configure $w.btm }
  }
  
  # Redraw marks and arrows if required:
  if {$::board::_showMarks($w)} {
    foreach mark $::board::_mark($w) {
      set type  [lindex $mark 0]
      if {$type == "full"}    { 
        ::board::colorSquare $w [lindex $mark 1] [lindex $mark 3]
      } else {
        # Find a subroutine to draw the canvas object:
        set drawingScript "mark::Draw[string totitle $type]"
        if {[llength [info procs $drawingScript]]} {
          catch {eval $drawingScript $w.bd [join [lrange $mark 1 3]]}  
        }
      }
    } 
  }
  
  # Redraw last move highlight if mainboard
  if { $w == ".main.board"} {
    ::board::lastMoveHighlight $w
  }
  
  # Redraw material values
  if {$::board::_showmat($w)} {
    # grid remove $w.mat
    if {$::gameInfo(showMaterial)} {
      # grid configure $w.mat
      ::board::material $w
    }
  }
  
  # Animate board changes if requested:
  if {$animate  &&  $board != $oldboard} {
    ::board::animate $w $oldboard $board
  }
}

proc ::board::isFlipped {w} {
  return $::board::_flip($w)
}

# ::board::flip
#   Rotate the board 180 degrees.
#
proc ::board::flip {w {newstate -1}} {
  if {! [info exists ::board::_flip($w)]} { return }
  if {$newstate == $::board::_flip($w)} { return }
  set flip [expr {1 - $::board::_flip($w)} ]
  set ::board::_flip($w) $flip
  
  # Swap squares:
  for {set i 0} {$i < 32} {incr i} {
    set swap [expr {63 - $i}]
    set coords(South) [$w.bd coords sq$i]
    set coords(North) [$w.bd coords sq$swap]
    $w.bd coords sq$i    $coords(North)
    $w.bd coords sq$swap $coords(South)
  }
  
  # Change coordinate labels:
  for {set i 1} {$i <= 8} {incr i} {
    set value [expr {9 - [$w.lrank$i cget -text]} ]
    $w.lrank$i configure -text $value
    $w.rrank$i configure -text $value
  }
  if {$flip} {
    foreach file {a b c d e f g h} newvalue {h g f e d c b a} {
      $w.tfile$file configure -text $newvalue
      $w.bfile$file configure -text $newvalue
      grid configure $w.wtm -row 1
      grid configure $w.btm -row 8
    }
  } else {
    foreach file {a b c d e f g h} {
      $w.tfile$file configure -text $file
      $w.bfile$file configure -text $file
      grid configure $w.wtm -row 8
      grid configure $w.btm -row 1
    }
  }
  ::board::update $w
  return $w
}
################################################################################
# ::board::material
# displays material balance
################################################################################
proc ::board::material {w} {
  set f $w.mat
  
  $f delete material
  
  if {! $::gameInfo(showMaterial)} { return }
  set fen [lindex [sc_pos fen] 0]
  set p 0
  set n 0
  set b 0
  set r 0
  set q 0
  for {set i 0} {$i < [string length $fen]} {incr i} {
    set ch [string index $fen $i]
    switch -- $ch {
      p {incr p -1}
      P {incr p}
      n {incr n -1}
      N {incr n}
      b {incr b -1}
      B {incr b}
      r {incr r -1}
      R {incr r}
      q {incr q -1}
      Q {incr q}
    }
  }
  set sum [expr abs($p) + abs($n) +abs($b) +abs($r) +abs($q) ]
  set rank 0
  addMaterial $q "q" $f $rank $sum
  incr rank [expr abs($q) ]
  addMaterial $r "r" $f $rank $sum
  incr rank [expr abs($r) ]
  addMaterial $b "b" $f $rank $sum
  incr rank [expr abs($b) ]
  addMaterial $n "n" $f $rank $sum
  incr rank [expr abs($n) ]
  addMaterial $p "p" $f $rank $sum
}
################################################################################
#
################################################################################
proc ::board::addMaterial {count piece parent rank sum} {
  if {$count == 0} {return}
  if {$count <0} {
    set col "b"
    set count [expr 0 - $count ]
  } else  {
    set col "w"
  }
  set w [$parent cget -width]
  set h [$parent cget -height]
  set offset [expr ($h - ($sum * 20)) / 2]
  if {$offset <0} { set offset 0 }
  set x [expr $w / 2]
  for {set i 0} {$i<$count} {incr i} {
    set y [expr $rank * 20 +10 + $offset + $i * 20]
    $parent create image $x $y -image $col${piece}20 -tag material
  }
}

################################################################################
#
################################################################################

# ::board::stm
#   Add or remove the side-to-move icon.
#
proc ::board::stm {w} {
  set stm [expr {1 - $::board::_stm($w)} ]
  set ::board::_stm($w) $stm
  if {$stm} {
    grid configure $w.stmgap
    grid configure $w.stm
  } else {
    grid remove $w.stmgap $w.stm $w.wtm $w.btm
  }
  ::board::update $w
}

# ::board::coords
#   Add or remove coordinates around the edge of the board.
# Toggle between 0,1,2.
proc ::board::coords {w} {
  set coords [expr {1 + $::board::_coords($w)} ]
  if { $coords > 2 } { set coords 0 }
  set ::board::_coords($w) $coords
  
  if {$coords == 0 } {
    for {set i 1} {$i <= 8} {incr i} {
      grid configure $w.lrank$i
      grid configure $w.rrank$i
    }
    foreach i {a b c d e f g h} {
      grid configure $w.tfile$i
      grid configure $w.bfile$i
    }
  } elseif {$coords == 1 } {
    for {set i 1} {$i <= 8} {incr i} {
      grid remove $w.lrank$i
      grid remove $w.rrank$i
    }
    foreach i {a b c d e f g h} {
      grid remove $w.tfile$i
      grid remove $w.bfile$i
    }
  } else { #Klimmek: coords == 2 then show left and bottom
    for {set i 1} {$i <= 8} {incr i} {
      grid configure $w.lrank$i
      grid remove $w.rrank$i
    }
    foreach i {a b c d e f g h} {
      grid remove $w.tfile$i
      grid configure $w.bfile$i
    }
  }
}

# ::board::animate
#   Check for board changes that appear to be a valid chess move,
#   and start animating the move if applicable.
#
proc ::board::animate {w oldboard newboard} {
  global animateDelay
  if {$animateDelay <= 0} { return }
  
  # Find which squares differ between the old and new boards:
  set diffcount 0
  set difflist [list]
  for {set i 0} {$i < 64} {incr i} {
    if {[string index $oldboard $i] != [string index $newboard $i]} {
      incr diffcount
      lappend difflist $i
    }
  }
  
  # Check the number of differences could mean a valid move:
  if {$diffcount < 2  ||  $diffcount > 4} { return }
  
  for {set i 0} {$i < $diffcount} {incr i} {
    set sq($i) [lindex $difflist $i]
    set old($i) [string index $oldboard $sq($i)]
    set new($i) [string index $newboard $sq($i)]
  }
  
  set from -1
  set to -1
  set captured -1
  set capturedPiece "."
  
  if {$diffcount == 4} {
    # Check for making/unmaking a castling move:
    set castlingList [list [sq e1] [sq g1] [sq h1] [sq f1] \
        [sq e8] [sq g8] [sq h8] [sq f8] \
        [sq e1] [sq c1] [sq a1] [sq d1] \
        [sq e8] [sq c8] [sq a8] [sq d8]]
    
    foreach {kfrom kto rfrom rto} $castlingList {
      if {[lsort $difflist] == [lsort [list $kfrom $kto $rfrom $rto]]} {
        if {[string tolower [string index $oldboard $kfrom]] == "k"  &&
          [string tolower [string index $oldboard $rfrom]] == "r"  &&
          [string tolower [string index $newboard $kto]] == "k"  &&
          [string tolower [string index $newboard $rto]] == "r"} {
          # A castling move animation.
          # Move the rook back to initial square until animation is complete:
          # TODO: It may look nicer if the rook was animated as well...
          eval $w.bd coords p$rto [::board::midSquare $w $rfrom]
          set from $kfrom
          set to $kto
        } elseif {[string tolower [string index $newboard $kfrom]] == "k"  &&
          [string tolower [string index $newboard $rfrom]] == "r"  &&
          [string tolower [string index $oldboard $kto]] == "k"  &&
          [string tolower [string index $oldboard $rto]] == "r"} {
          # An undo-castling animation. No need to move the rook.
          set from $kto
          set to $kfrom
        }
      }
    }
  }
  
  if {$diffcount == 3} {
    # Three squares are different, so check for an En Passant capture:
    foreach i {0 1 2} {
      foreach j {0 1 2} {
        foreach k {0 1 2} {
          if {$i == $j  ||  $i == $k  ||  $j == $k} { continue }
          # Check for an en passant capture from i to j with the enemy
          # pawn on k:
          if {$old($i) == $new($j) && $old($j) == "." && $new($k) == "."  &&
            (($old($i) == "p" && $old($k) == "P") ||
            ($old($i) == "P" && $old($k) == "p"))} {
            set from $sq($i)
            set to $sq($j)
          }
          # Check for undoing an en-passant capture from j to i with
          # the enemy pawn on k:
          if {$old($i) == $new($j) && $old($k) == "." && $new($i) == "."  &&
            (($old($i) == "p" && $new($k) == "P") ||
            ($old($i) == "P" && $new($k) == "p"))} {
            set from $sq($i)
            set to $sq($j)
            set captured $sq($k)
            set capturedPiece $new($k)
          }
        }
      }
    }
  }
  
  if {$diffcount == 2} {
    # Check for a regular move or capture: one old square should have the
    # same (non-empty) piece as the other new square, and at least one
    # of the old or new squares should be empty.
    
    if {$old(0) != "." && $old(1) != "." && $new(0) != "." && $new(1) != "."} {
      return
    }
    
    foreach i {0 1} {
      foreach j {0 1} {
        if {$i == $j} { continue }
        if {$old($i) == $new($j)  &&  $old($i) != "."} {
          set from $sq($i)
          set to $sq($j)
          set captured $sq($j)
          set capturedPiece $old($j)
        }
        
        # Check for a (white or black) pawn promotion from i to j:
        if {($old($i) == "P"  &&  [string is upper $new($j)]  &&
          $sq($j) >= [sq a8]  &&  $sq($j) <= [sq h8])  ||
          ($old($i) == "p"  &&  [string is lower $new($j)]  &&
          $sq($j) >= [sq a1]  &&  $sq($j) <= [sq h1])} {
          set from $sq($i)
          set to $sq($j)
        }
        
        # Check for undoing a pawn promotion from j to i:
        if {($new($j) == "P"  &&  [string is upper $old($i)]  &&
          $sq($i) >= [sq a8]  &&  $sq($i) <= [sq h8])  ||
          ($new($j) == "p"  &&  [string is lower $old($i)]  &&
          $sq($i) >= [sq a1]  &&  $sq($i) <= [sq h1])} {
          set from $sq($i)
          set to $sq($j)
          set captured $sq($j)
          set capturedPiece $old($j)
        }
      }
    }
  }
  
  # Check that we found a valid-looking move to animate:
  if {$from < 0  ||  $to < 0} { return }
  
  # Redraw the captured piece during the animation if necessary:
  if {$capturedPiece != "."  &&  $captured >= 0} {
    ::board::drawPiece $w $from $capturedPiece
    eval $w.bd coords p$from [::board::midSquare $w $captured]
  }
  
  # Move the animated piece back to its starting point:
  eval $w.bd coords p$to [::board::midSquare $w $from]
  $w.bd raise p$to
  
  # Remove side-to-move icon while animating:
  grid remove $w.wtm $w.btm
  
  # Start the animation:
  set start [clock clicks -milli]
  set ::board::_animate($w,start) $start
  set ::board::_animate($w,end) [expr {$start + $::animateDelay} ]
  set ::board::_animate($w,from) $from
  set ::board::_animate($w,to) $to
  ::board::_animate $w
}

# ::board::_animate
#   Internal procedure for updating a board move animation.
#
proc ::board::_animate {w} {
  if {! [winfo exists $w]} { return }
  set from $::board::_animate($w,from)
  set to $::board::_animate($w,to)
  set start $::board::_animate($w,start)
  set end $::board::_animate($w,end)
  set now [clock clicks -milli]
  if {$now > $end} {
    ::board::update $w
    return
  }
  
  # Compute where the moving piece should be displayed and move it:
  set ratio [expr {double($now - $start) / double($end - $start)} ]
  set fromMid [::board::midSquare $w $from]
  set toMid [::board::midSquare $w $to]
  set fromX [lindex $fromMid 0]
  set fromY [lindex $fromMid 1]
  set toX [lindex $toMid 0]
  set toY [lindex $toMid 1]
  set x [expr {$fromX + round(($toX - $fromX) * $ratio)} ]
  set y [expr {$fromY + round(($toY - $fromY) * $ratio)} ]
  $w.bd coords p$to $x $y
  $w.bd raise p$to
  
  # Schedule another animation update in a few milliseconds:
  after 5 "::board::_animate $w"
}

# Capture board screenshot.
# Based on code from David Easton:
# http://wiki.tcl.tk/9127

set window_image_support 1
if { [catch {package require img::window}] } {
  set window_image_support 0
}

if {!$png_image_support || !$window_image_support} {
  .menu.tools entryconfig [tr ToolsCaptureBoard] -state disabled
  ::splash::add "Capture Current Board is disabled."
}

proc captureWidget { widget image px py } {

  if {![winfo ismapped $widget]} {
    return
  }

  regexp {([0-9]*)x([0-9]*)\+([0-9]*)\+([0-9]*)} [winfo geometry $widget] - w h x y

  incr px $x
  incr py $y

  # Make an image from this widget
  set tempImage [image create photo -format window -data $widget]

  # Copy this image into place on the main image
  $image copy $tempImage -to $px $py
  image delete $tempImage

  foreach child [winfo children $widget] {
    captureWidget $child $image $px $py
  }
}

proc boardToFile { format filepath } {

  set w .main.board
  set board $w.bd

  if { $format == "" } {
    set format png
  }
  set filename $filepath

  # Make the base image based on the board
  ::board::update $w
  update idletask
  set image [image create photo -format window -data $board]

  if { $filename == "" } {
    # set types {{"Image Files" {.$format}}}
    set types {{"All Files" {*}}}
    set filename [tk_getSaveFile -filetypes $types \
                                 -initialfile current_board.$format \
                                 -defaultextension .$format \
                                 -title "Scid: Save Current Board:"]
  }

  if {[llength $filename]} {
    if {[catch {$image write -format $format $filename} result ]} {
      tk_messageBox -type ok -icon error -title "Scid" -message $result
    }
  }
  image delete $image
}


###
### End of file: board.tcl
###
