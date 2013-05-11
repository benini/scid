# bitmaps.tcl:
# Chess piece bitmaps used by Scid.

# The piece images used here were generated from freeware chess
# fonts available in TrueType format at the En Passant website
# "Chess Fonts" page, http://www.enpassant.dk/chess/fonteng.htm

### chess set Fantasy. Dark pieces are in brown
# original Fantasy: based by Maurizio Monge <maurizio.monge@gmail.com>
#http://linuz.sns.it/~monge/wiki/index.php/Chess_pieces





set png_image_support 1
if { [catch { package require img::png } ] } {
  set png_image_support 0
  ::splash::add "Img package not found (tkimg). Some piece sets are disabled."
}



##########
# Size 20 is only used in Material search window, not for boards.
# It has two special extra images, wm20 and bm20, which contain a
# bishop and knight, for indicating a minor piece.
#

image create photo wm20 -data {
  R0lGODlhFAAUAMIAAH9/f7+/vz8/PwAAAP///////////////yH5BAEKAAcALAAAAAAUABQA
  AANweLp8cCG02cSwNB8RSACctgBAR3iDqJDd5wlidBLCHGb1CQzzx+yPDYAWyJ1gixpSwOLM
  CClFESSRup7RImF42zxP0Vpg0EE6SGjSCqxTKYxHN4RJ6sYETHxVNa3vM2gDQyBoGkNbhIdq
  FHRBZyAaCQA7}

image create photo bm20 -data {
  R0lGODlhFAAUAMIAAH9/f7+/vwAAAD8/P////////////////yH5BAEKAAcALAAAAAAUABQA
  AANneLp8cCG02YQYgupj+5CbEgyYAAQCuJHlNYZo1wHDo7VyOjSAebQxS69R25UCvVlmMXIp
  TrmhSGgB4S5LzoVQegK+YJtWwLWEFjnzGVL7ftYQMoGQggerZ3CrLealoxomXxJIX1kNCQA7
}

image create photo p20 -data {
  R0lGODlh8AAUAMIAAH9/fz8/P7+/vwAAAP///////////////yH5BAEKAAcALAAAAADwABQA
  AAP+eLrc/jDKSau9OOvNu/8VAIBkJAhl2ohqe5xuCgTBGL/oQaMwJew30KwWhAkGA0Vv8gvk
  LALRUxJ9BTSAk40qFXWzkKZWCmQit5Uo2GdDW4ZuiFQ9koZ33mxZAjhjBidJFDNIRBgBhRQD
  Q4t9NH0NP3o1BEgEYjNTDix/SIITfQOIcROIooOFpouekV6PlQMEQ2qaK6QSsZUholGit5GA
  BJeAuMIixgDCnwrJAbKLsMPNsiY0VxeeyxGhnoZm2cTb4OMrP88C0X3NVWF+2CLaELnCUTRm
  6CfDtQuUwv7G1xb8iHUkmSV1lZy0GpErSZR9DbJVUOULCUQl3VRdPDL+rtsKRM8MxuqDjlcr
  FBIflkomK+CdLP8I2Ivg5NIOmxIe5RnygOSzhDKlLGqg01LCGjMhUHQpj1AhmfEYmHIy8JSJ
  jlZXAHIUDWRBojWcFnK1zZk/bw9oBLt09lcuMcpA7eS0CU8WVyIeMTBHD9ARdMjkjPt14BhF
  QEkddDuhSm7MqIUrrgJ0ZhSDvJIr+7o14x9dB3z9zTtCE3A+nHxiUpNXsFKgXj+mHPN3pKa/
  z5cH48LqJJwDVWoT8enYDis4W9k4cjzjliWk0p5ZBn5QcKdvOardXqqXN1nJVjFpxMTNgJw4
  4zypj3V6kRlxecYl7g0+mZtewcLQ/vYMjTb+U6lh5fXfJtmVNcpOj/xnGzL/kHaeO/AZ1xtN
  AaY3nHk9dZOHKnH0th43M1D4T2KXzebEbKKVFcoMhDEz1y8cvUjIPo3AU2MmNI0zYGEU2eiJ
  a3JUqF9PFT6nnnd5GHMdRrScQMeSC3Q23oCdxXaEapAdMI+Sisy1I0YyQslMgOi48iU34AzY
  yxlQJTfUA1hRoJMXYmJkHESOLIXIl1v+A5mAMgE2IkS9qLUGdDH9gIt0fprAaHQRxHeHeIfV
  eEc2CuV0Z6TrNVYcVrdEodp0ZY36WVVsPrPYb/HxmVFykfrYyJfLddTeCx15MZ8ovJlEVHx1
  zoNillrWICgh2zxpeluLfbZVnllK9pefNiiaSopPWLrVD0BZoqnbboOhBexxEQF7bXxuGfdg
  rlTEJxt9YDh1n0Dj7rOmjhtVmmmG6E2ArlRpapGmYsDa6+2qlwYcxAWHyrHwwxAX1h47EVds
  8cUYZ6xxBwkAADs=
}

image create photo e20 -height 20 -width 20
set x 0
foreach p {wp wn wb wr wq wk bp bn bb br bq bk} {
  image create photo ${p}20 -width 20 -height 20
  ${p}20 copy p20 -from $x 0 [expr $x + 19] 19
  incr x 20
}

# setPieceFont:
#   Given a piece font name, resets all piece images in all
#   available board sizes to that font.
#
proc setPieceFont {font} {
	foreach size $::boardSizes {
		image create photo e$size -height $size -width $size
		set fname [file join $::scidImgDir pieces $font]
		set fpng [file join $fname $font\_$size.png]
		set fgif [file join $fname $font\_$size.gif]
		if {[catch {image create photo tmpPieces -file "$fpng"}]} {
			image create photo tmpPieces -file "$fgif"
		}
		set x 0
		foreach p {wp wn wb wr wq wk bp bn bb br bq bk} {
			image create photo $p$size -width $size -height $size
			$p$size copy tmpPieces -from $x 0 [expr $x + $size - 1] [expr $size - 1]
			incr x $size
		}
		image delete tmpPieces
	}
}

proc InitImg {} {
	global scidImgDir boardStyle boardStyles

	#Search available piece sets
	set boardStyles {}
	set dname [file join $scidImgDir "pieces"]
	foreach {piecetype} [split [glob -directory $dname *] " "] {
		if {[file isdirectory $piecetype] == 1} {
			lappend boardStyles [file tail $piecetype]
		}
	}
	# Ensure the board style is valid:
	if {[lsearch -exact $boardStyles $boardStyle] == -1} {
		set boardStyle [lindex $boardStyles 0]
	}
	setPieceFont $boardStyle

	#Load all img/boards/_filename_.gif
	set textureSquare {}
	set dname [file join $::scidImgDir boards]
	foreach {fname} [split [glob -directory $dname *.gif] " "] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -file $fname
		if {[string range $iname end-1 end] == "-l"} {
			lappend textureSquare [string range $iname 0 end-2]
		}
	}

	#Load all img/buttons/_filename_.gif
	set dname [file join $::scidImgDir buttons]
	foreach {fname} [split [glob -directory $dname *.gif] " "] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -file $fname
	}

	#Load all img/flags/_filename_.gif
	set dname [file join $::scidImgDir flags]
	foreach {fname} [split [glob -directory $dname *.gif] " "] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -file $fname
	}
}

#TODO: group the start-up code into Init* funcs and move all the Init* calls to the end of end.tcl
InitImg
