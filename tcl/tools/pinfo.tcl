
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

image create photo seealsolnk -data {
R0lGODlhFQAVAMZ5AAAAAAEBAAICAQQGAhEXCSEtECMwESouJjw8PDJFGEJcH0xpJGFhYVRuMVV1
KF6CLH2IbmuVM4+Pj5SUlHysO4imYYGwQYK0PaKiooa6QIe7QKioqIi8Qoq9RIq9RYu9R4y+SI2+
SY2+SqysrI/ATZDAT62urK6urpHBUJLBUa+vr7GxsZXDVrKyspXEV5bEWJfEWrOzs7W1tZrGX7a2
tre3t57IZbm5ubq6uru7u6TLbry8vL29vajOdanOdsDAwMHBwavQecLCwqzQe63QfMPDw8TExLDS
gbDSgsXFxbHTg8bGxsfHx7LUhbTUh8jIyLXVicnJycrKyrfWjcvLy8zMzM3Nzc7OztDQ0L/bmdHR
0dLS0sbfpNbW1s/ks9bovdbovtrqxNrqxdvqxd3syN3syeLv0ePv0ubx1+jy2urz3fL46vP47Pf3
9/T57vb68Pn89vv7+/r8+Pz9+v3++/3+/P7+/f7+/v///v///////////////////////////yH+
EUNyZWF0ZWQgd2l0aCBHSU1QACwAAAAAFQAVAAAH/oAjKi00Nzs/QEJFi4tAPzw3NC0qJy01O0BJ
T1RWV55XVlVRS0A7NS0rNDt5rK15LxqxsrE7NDE3QHlsRCIcJTaws7JCODI8S3k+GmJzaEMvIXJ5
cB+ySzw1P1J5HhpsrS9NrUeyUkA3RVZ5KRooUF5sL2R5aXljsldFOUtYeWHssTq4qENnhh06JGJp
WbKDiRZWdc5wgaEBhD0NZfJMibWFScMtrvKs0eAhDxINSvKY4fjkYx4dYNyYOKAhCKs4NfLgYaFh
S0uHeXq8sDCAgJM3XzQ4CAAhT5aeTPb1Y9UFAAMqVCpEiGAAwAQ1GhaiU8fqDgIAaNOmvaDhipFs
TdtatcEgocGCuwUAJMigwZwxZCFfxXogYG+sa7dyBQ5GQQHfWMRSrVosTFatSqoyReH0CZQoUqZa
CCJkCJEiRkUcQZKkYoPr17Bjyw4EADs=
}

proc WikipNLS { LinkList } {

   # set WikiPediaAPI "http://de.wikipedia.org/w/api.php?action=query"

   set WikiPLL  "&prop=langlinks"
   set WikiPTI  "&titles="
   set lang     $::language
   set langlink [lindex $LinkList 3]

   # translate Scids internal single letter language representation by
   # a more common two letter one; the same is used by WP
   switch $lang {
      B {set wplanguage pt}
      C {set wplanguage cs}
      D {set wplanguage de}
      F {set wplanguage fr}
      H {set wplanguage hu}
      I {set wplanguage it}
      K {set wplanguage ca}
      N {set wplanguage nl}
      O {set wplanguage no}
      P {set wplanguage pl}
      R {set wplanguage ru}
      S {set wplanguage es}
      W {set wplanguage sv}
      Y {set wplanguage sr}
      default {set wplanguage en}
   }

   set Title    [lindex $LinkList 3]
   regsub -all {.*/} $Title "" Title

   # Spaces etc in URLs are bad, especially for TCL.
   # Use poor mans urlencoding:
   regsub -all { } $Title "%20" Title

   # collect all languages in $fullresult, each page contains a
   # llcontinue item linking to the following languages
   set fullresult ""
   set llcontinue ""

   # start out here:
   set WPfetchURL "$::pinfo::wikipAPI$WikiPLL$WikiPTI$Title"

   set token     [::http::geturl $WPfetchURL]
   set xmlresult [::http::data $token]
   ::http::cleanup $token

   # avoid requirement of tDOM and use simple regexping here as the
   # XML structure returned is simple enough

   # for more than 10 translations, a continue url is returned.
   # Extract it
   regsub -all {.*<langlinks llcontinue=} $xmlresult  "" llcontinue
   regsub -all {/>.*}                     $llcontinue "" llcontinue
   regsub -all {\|} $llcontinue "%7C" llcontinue
   regsub -all {\"} $llcontinue "" llcontinue

   # keep only the langlinks-section of the XML
   regsub -all {.*<langlinks>} $xmlresult "" xmlresult
   regsub -all {</langlinks>.*} $xmlresult "" xmlresult
   regsub -all {</ll>} $xmlresult "</ll>\n" xmlresult
   set fullresult $xmlresult
      puts stderr $xmlresult

   while { $llcontinue != "" } {

      set WPfetchURL "$::pinfo::wikipAPI$WikiPLL$WikiPTI$Title&llcontinue=$llcontinue"
      regsub -all { } $WPfetchURL "" WPfetchURL

      set token     [::http::geturl $WPfetchURL]
      set xmlresult [::http::data $token]
      ::http::cleanup $token

      if {[string match "*llcontinue*" $xmlresult]} {
         regsub -all {.*<langlinks llcontinue=} $xmlresult  "" llcontinue
         regsub -all {/>.*}                     $llcontinue "" llcontinue
         regsub -all {\|} $llcontinue "%7C" llcontinue
         regsub -all {\"} $llcontinue "" llcontinue
      } else {
         set llcontinue ""
      }

      regsub -all {.*<langlinks>} $xmlresult "" xmlresult
      regsub -all {</langlinks>.*} $xmlresult "" xmlresult
      regsub -all {</ll>} $xmlresult "</ll>\n" xmlresult
      puts stderr $llcontinue
      puts stderr $xmlresult
      set fullresult "$fullresult$xmlresult"
   }

   set langlist [split $fullresult "\n"]

   foreach ll $langlist {
      puts stderr $ll
      # construct the NLS-enabled link to WP
      if { [string match "*lang=\"$wplanguage\"*" $ll] } {
         set baselink "http://$wplanguage.wikipedia.org/wiki/"
         regsub -all {.*preserve">} $ll       "" pagename
         regsub -all {<.*} $pagename "" pagename
         set langlink "$baselink$pagename"
      }
   }

   openURL $langlink
}

proc saPND2WP { pnd } {


   set SeeAlso "$::pinfo::SeeAlsoPND2WP$pnd"

   set token [::http::geturl $SeeAlso]

   set LinkList [::http::data $token]
   regsub -all {\[} $LinkList "" LinkList
   regsub -all {\]} $LinkList "" LinkList
   regsub -all {\"} $LinkList "" LinkList
   set LinkList [split $LinkList ,]

   WikipNLS $LinkList
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

  # disable direct wikipedia linking till the resolver is up and
  # running again
  set wikiplink  "<run openURL $::pinfo::wikipurl?PND=$pnd; ::windows::stats::Refresh><button wikiplnk><blue>WP</blue></run>"
  set seealsolink  "<run ::pinfo::saPND2WP $pnd; ::windows::stats::Refresh><button seealsolnk><blue>SeeAlso</blue></run>"
  set dnblink    "<run openURL $::pinfo::dnburl/$pnd; ::windows::stats::Refresh><button dnblnk><blue>DNB</blue></run>"
  set viaflink   "<run openURL $::pinfo::viafurl/$viaf; ::windows::stats::Refresh><button viaflnk><blue>VIAF</blue></run>"
  set fidelink   "<run openURL $::pinfo::fideurl=$fide; ::windows::stats::Refresh><button fidelnk -command openURL $::pinfo::fideurl=$fide><blue>FIDE</blue></run>"
  set iccflink   "<run openURL $::pinfo::iccfurl=$iccf; ::windows::stats::Refresh><button iccflnk><blue>ICCF</blue></run>"

  # regsub -all "PND $pnd<br>"     $pinfo "$wikiplink $dnblink $seealsolink" pinfo
  regsub -all "PND $pnd<br>"     $pinfo "$dnblink $seealsolink" pinfo
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
    dialogbutton $w.b2.update -textvar ::tr(Update) -command {::pinfo::playerInfo $playerInfoName}
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
