
####################
# Player Info window

namespace eval pinfo {
set playerInfoName ""

image create photo wikiplnk -data {
	R0lGODlhEAAQAIQQAAQCBBkYGSgoKDw6PEhHSFdYV2lqaXp7eoSDhJiYmKmoqbm6ucjHyNjZ2Ono
	6fz9/P///////////////////////////////////////////////////////////////yH+EUNy
	ZWF0ZWQgd2l0aCBHSU1QACH5BAEKABAALAAAAAAQABAAAAV24COOZGmeaDouBbE8CnE0z1E0jVE8
	iPA+BEHDgUg8HAZjI2BwPBIBBcMgQo4KAcajEUQoRIsvOIAQJQC7I+InIhBojQFB1DiUEIBv3Pc0
	lgQFDgoGA1QITncDBwp1AgllJgoCAl8Lk1onbjQPBgIpC5hbbConIQA7
}
image create photo fidelnk -data {
	R0lGODlhEAAQAOecACIxWSY0XSc2XSg2YCc3Xig3Xik3Xyk4Xyo4Xyo4YCo5Xyo5YCs5Xyo6Xys6
	YCs6YSw6YCw6YSw7YSw7Yi07Yi48Yi48Yy88Yi89YzA+ZDE/ZDE/ZTI/ZTJAZTJBZjNBZTNBZjRB
	ZjNCZTRCZjZEaDdEaThEaThGaTlGaTpIazxKbT1KbT9MbkBNb0NQc0VRc0ZScUZUdEhUdEdVdkhV
	dElVdEpXdk1ZeE5ZeFRef1NgfVRgf1dgf1hhf11nhGFsh2JsiGFtiGJtiGNtiGZyi2lzjWt3kHB4
	kHN+lnqEm36GnYCJnYmSo4qTpZWbrpWcq5eerZeer5qgrp6ltaGns6asuKesuqetvK60wrC1wLa6
	xra8x7i9xLu/x7vAyb3CyMvO1MzP09DS2tDT2dHU2dHV2tLV2dPV29PX29fZ3tna3dna3tra3tzd
	4d3d4dze4Nze4d3e4d3e4tzf4d3f4d3f497f4d7f5N/g4d7h497h5t/h5ODi5OHi5eHj5eLj5eLk
	5uPl6OTm6efn6eXo6ejq6+rq6+rq7Orr7Ors6+vs7ezt7+3u7+/w8vDw8O/x8fDx8vHx8vHy9PHz
	9PX19fb29vf39/j4+fr6+/v6+/z9/f39/v//////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////yH+EUNyZWF0ZWQgd2l0aCBH
	SU1QACH5BAEKAP8ALAAAAAAQABAAAAjbAEEIHEiwoMGDBz1IGGDhhIkKBhx0IBhiAgUjWMSYiXRH
	C5IPC0YIfLBji51KV1wESWPpT5chCUBggDGH06UsACYE0DFIEqdGPSBsKIMojxwgRFg84MGmzh5B
	elbccATp0SNGVjgIWBKpUCJFjH7gcPOGDh8yFzAISGLID6A+f4SQCMQIzhovJVqouDFGTZtDk15Q
	8EEI0yZKVGrIgCJJU6ZFRxiAQFAEDR4wVXLYkBImzhklCgY2ENEkChMuX55McYLiQMEOBSCkiEFj
	RgQCGhCC6JCht+7fAwMCADs=
}
image create photo iccflnk -data {
	R0lGODlhEAAQAMZqAAAA/wEB/wMD/wQE/wUF/wYG/wcH/wgI/woK/wsL/wwM/xAQ/xER/xIS/xMT
	/xQU/xYW/xcX/xgY/xkZ/xoa/xsb/x4e/yEh/yIi/yUl/yYm/ycn/ykp/zIy/zQ0/zY2/zc3/zo6
	/zs7/zw8/z09/0ZG/0lJ/01N/1hY/1lZ/1pa/1tb/1xc/2Nj/2Vl/2lp/2pq/3R0/3V1/3Z2/3d3
	/3h4/3t7/3x8/39//4SE/4WF/4uL/42N/4+P/5CQ/5KS/5OT/5SU/5WV/5aW/5eX/5iY/5ub/5+f
	/6Cg/6Gh/6en/6mp/6qq/66u/6+v/7S0/7i4/7u7/729/7+//8DA/8LC/8PD/8rK/8zM/83N/87O
	/9PT/9fX/9jY/+Pj/+Tk/+bm/+jo/+vr/+zs//Hx//Ly//T0//b2//j4//z8////////////////
	/////////////////////////////////////////////////////////////////////////yH+
	EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAH8ALAAAAAAQABAAAAfjgFJTaF86R2dpXjlIZ2JQUFIV
	GGMnAAVFaCaWRlQKCRULE1cGBwIgWwQIASFSAAAMDBJKAC4XEEwALRcWTwAUKAwTQwA0GQs9ADIZ
	Dk0ALGmhw8ULPAAzGgvNK2nBQtYjHNUxJBxOABw/3dZcW0YANl1bUa4eod40aWlHADf5rQAegkmT
	8QIIgBozXvQqoUWgNWM7kmVg0EwFtAlFiE30kWxDA23cJiwBAAODBFwvdvXaFsvKgAcGQGQJEGGA
	iFYsJYT5ACBAEDMdAAggMi9FGiVMzmhhcYNMGiwrcJQBk6RKmkAAOw==
}
image create photo dnblnk -data {
	R0lGODlhFAAUALMAAAAAAGZmZld/u8zMzP8AAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	AAAAACH5BAEAAAQALAAAAAAUABQAAARkkMg5BaA4SxHs1RknjB5YdSQJfCGapismvjRLzDTM4vkI
	BB9e7ze4CHPEIsDT8wUGUAsHuKw9o8YAIUCFXQeWzbNQ4K4s37BkOSCTzWkb4dx2x0F0N9a0ZhfA
	ciZnanwYMSARAAA7
}
image create photo viaflnk -data {
	R0lGODlhEAAQAIQaAP8AAP8ICP8QEP8YGP8hIf8pKf8xMf85Of9CQv9SUv9aWv9jY/9zc/97e/+E
	hP+MjP+UlP+cnP+lpf+trf+1tf/Gxv/Ozv/W1v/e3v/v7////////////////////////yH+EUNy
	ZWF0ZWQgd2l0aCBHSU1QACH5BAEKAB8ALAAAAAAQABAAAAWDoCZm1lVp1ZVhqSWOSnBpEJNlynC+
	tCA2LwODJ4IENI+M6AKYESWACuXlIBBFFADwVdgSK9bRBCC5ajBOTYYiNWumIguFPSdmledA42JJ
	8DIHABhYghoqPAxZTgsEEQwTPBILDFEiAhBIeIYOhgBTd0QZCEpZEBcJA2lLFyolKayqGiEAOw==
}

proc ReplaceIDTags { pinfo } {
  # replace certain BIO lines by links to external media
  regsub -all ".*PND "    $pinfo "" pnd
  regsub -all ".*VIAF "   $pinfo "" viaf
  regsub -all ".*FIDEID " $pinfo "" fide
  regsub -all ".*ICCFID " $pinfo "" iccf
  regsub -all {<br>.*}    $pnd  "" pnd
  regsub -all {<br>.*}    $viaf "" viaf
  regsub -all {<br>.*}    $fide "" fide
  regsub -all {<br>.*}    $iccf "" iccf

  # add &name=$playerInfoName for wikipedia
  set wikiplink  "<run openURL $::pinfo::wikipurl?PND=$pnd; ::windows::stats::Refresh><button wikiplnk><blue>WP</blue></run>"
  set dnblink    "<run openURL $::pinfo::dnburl/$pnd; ::windows::stats::Refresh><button dnblnk><blue>DNB</blue></run>"
  set viaflink   "<run openURL $::pinfo::viafurl/$viaf; ::windows::stats::Refresh><button viaflnk><blue>VIAF</blue></run>"
  set fidelink   "<run openURL $::pinfo::fideurl=$fide; ::windows::stats::Refresh><button fidelnk><blue>FIDE</blue></run>"
  set iccflink   "<run openURL $::pinfo::iccfurl=$iccf; ::windows::stats::Refresh><button iccflnk><blue>ICCF</blue></run>"

  regsub -all "PND $pnd<br>"     $pinfo "$wikiplink $dnblink" pinfo
  regsub -all "FIDEID $fide<br>" $pinfo "$fidelink" pinfo
  regsub -all "ICCFID $iccf<br>" $pinfo "$iccflink" pinfo
  regsub -all "VIAF $viaf"   $pinfo "$viaflink" pinfo
  regsub -all "</run>  <run" $pinfo "</run> <run" pinfo

  return $pinfo
}


proc playerInfo {{player ""}} {
  global playerInfoName
  global spffile
  if {$player == ""} { set player $playerInfoName }
  if {[catch {sc_name info -htext $player} pinfo]} { return }
  set playerInfoName $player
  set ::rgraph(player) $player
  set w .playerInfoWin
  if {! [winfo exists $w]} {
    toplevel $w
    setWinLocation $w
    wm title $w "Scid: [tr ToolsPInfo]"
    wm minsize $w 40 5
    pack [frame $w.b2] -side bottom -fill x
    pack [frame $w.b] -side bottom -fill x
    button $w.b.graph -text [tr ToolsRating] \
      -command {::tools::graphs::rating::Refresh player $playerInfoName}
    button $w.b.edit -text $::tr(PInfoEditRatings) -command {
      makeNameEditor
      setNameEditorType rating
      set editName $playerInfoName
      set editNameSelect crosstable
    }
    button $w.b2.report -text [tr ToolsPlayerReport] \
      -command {::preport::preportDlg $playerInfoName}
    dialogbutton $w.b2.help -textvar ::tr(Help) -command {helpWindow PInfo}
    dialogbutton $w.b2.update -textvar ::tr(Update) -command {playerInfo $playerInfoName}
    dialogbutton $w.b2.close -textvar ::tr(Close) -command "focus .; destroy $w"
    packbuttons right $w.b2.close $w.b2.update $w.b2.help
    packbuttons left $w.b.graph $w.b.edit
    packbuttons left $w.b2.report

    autoscrollframe $w.frame text $w.text -font font_Regular -background white \
      -width $::winWidth($w) -height $::winHeight($w) -setgrid 1 -wrap none
    #scrollbar $w.ybar -command "$w.text yview"
    #pack $w.ybar -side right -fill y
    #text $w.text -font font_Regular -background white \
    #  -width $::winWidth($w) -height $::winHeight($w) \
    #  -setgrid 1 -wrap none -yscrollcommand "$w.ybar set"
    label $w.photo -background white
    #pack $w.text -side top -fill both -expand yes
    pack $w.frame -side top -fill both -expand yes
    bind $w <Escape> "focus .; destroy $w"
    ::htext::init $w.text
    ::htext::updateRate $w.text 0
    bind $w <Escape> "focus .; destroy $w"
    bind $w <F1> {helpWindow PInfo}
    bind $w <Configure> "recordWinSize $w"
    standardShortcuts $w
  }
  set player [trimEngineName $player]
  if {[info exists spffile($player)]} {
    image create photo photoPInfo -data [getphoto $player]
    $w.photo configure -image photoPInfo -anchor ne
    place $w.photo -in $w.text -relx 1.0 -x -1 -rely 0.0 -y 1 -anchor ne
  } else {
    place forget $w.photo
  }
  $w.text configure -state normal
  $w.text delete 1.0 end

  set pinfo [::pinfo::ReplaceIDTags $pinfo]

  # Display the player info
  ::htext::display $w.text $pinfo

  $w.text configure -state disabled
  ::windows::gamelist::Refresh
  ::maint::Refresh
  #raiseWin $w
}

}
