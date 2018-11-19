
####################
# Player Info window

namespace eval pinfo {
set playerInfoName ""
set ::eloFromRating 0

# the following icons are used as buttons with PND as input, this has
# to be handled specially and they involve some technicalities. All
# other icons and link resolvers come from the config file
image create photo wikiplnk -data {
   R0lGODlhEAAQAIQQAAQCBBkYGSgoKDw6PEhHSFdYV2lqaXp7eoSDhJiYmKmoqbm6ucjHyNjZ2Ono
   6fz9/P///////////////////////////////////////////////////////////////yH+EUNy
   ZWF0ZWQgd2l0aCBHSU1QACH5BAEKABAALAAAAAAQABAAAAV24COOZGmeaDouBbE8CnE0z1E0jVE8
   iPA+BEHDgUg8HAZjI2BwPBIBBcMgQo4KAcajEUQoRIsvOIAQJQC7I+InIhBojQFB1DiUEIBv3Pc0
   lgQFDgoGA1QITncDBwp1AgllJgoCAl8Lk1onbjQPBgIpC5hbbConIQA7
}
image create photo dnblnk -data {
   R0lGODlhFAAUALMAAAAAAGZmZld/u8zMzP8AAP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
   AAAAACH5BAEAAAQALAAAAAAUABQAAARkkMg5BaA4SxHs1RknjB5YdSQJfCGapismvjRLzDTM4vkI
   BB9e7ze4CHPEIsDT8wUGUAsHuKw9o8YAIUCFXQeWzbNQ4K4s37BkOSCTzWkb4dx2x0F0N9a0ZhfA
   ciZnanwYMSARAAA7
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

proc setupDefaultResolvers { } {
   set optionF ""
   if {[catch {open [scidConfigFile resolvers] w} optionF]} {
      tk_messageBox -title "Scid: Unable to write file" -type ok -icon warning \
         -message "Unable to write options file: [scidConfigFile resolvers]\n$optionF"
   } else {
      puts $optionF "# Scid resolver configuration"
      puts $optionF "# Version: $::scidVersion, $::scidVersionDate"
      puts $optionF "# This file contains commands in the Tcl language format."
      puts $optionF "# If you edit this file, you must preserve valid Tcl"
      puts $optionF "# format or it will not set your Scid options properly."
      puts $optionF "#"
      puts $optionF "# Define how to interpret IDs stored in ssp files. Each ID has to"
      puts $optionF "# have a unique page to link to. It is currently not possible to link"
      puts $optionF "# to more than one page by means of a single ID, or to get more"
      puts $optionF "# than one button by any ID. Therefore, PND is handled specially"
      puts $optionF "# and within pinfo.tcl"
      puts $optionF "#"
      puts $optionF "# Syntax of the following array's list entries:"
      puts $optionF "#"
      puts $optionF "# IDName: the tag to search for e.g. VIAF searches for"
      puts $optionF "#         %Bio VIAF-lines and so on"
      puts $optionF "# link target url: %ID% is replaced by the ID"
      puts $optionF "# icon name: the icons are specified below as base64 encoded images"
      puts $optionF "#            They must not live in ::pinfo-namespace!"
      puts $optionF "# Link text: what to display in pinfo window"
      puts $optionF "set ::pinfo::idlink(0) {{VIAF} {http://viaf.org/%ID%} {viaflnk} {VIAF}}"
      puts $optionF "set ::pinfo::idlink(1) {{FIDEID} {http://ratings.fide.com/card.phtml?event=%ID%} {fidelnk} {FIDE}}"
      puts $optionF "set ::pinfo::idlink(2) {{ICCFID} {http://www.iccf-webchess.com/PlayerDetails.aspx?id=%ID%} {iccflnk} {ICCF}}"
      puts $optionF "set ::pinfo::idlink(3) {{DSB} {http://www.schachbund.de/dwz/db/spieler.html?zps=%ID%} {dsblnk} {DSB}}"
      puts $optionF "set ::pinfo::idlink(4) {{BCF} {http://grading.bcfservices.org.uk/getref.php?ref=%ID%} {bcflnk} {BCF}}"
      puts $optionF "set ::pinfo::idlink(5) {{SchemingMind} {http://www.schemingmind.com/plyrprofile.aspx?profile_id=%ID%} {smlnk} {SchemingMind}}"
      puts $optionF "#"
      puts $optionF "# Icons for the icons defined here MUST NOT live in ::pinfo namespace"
      puts $optionF "#"
      puts $optionF "image create photo fidelnk -data {"
      puts $optionF "   R0lGODlhEAAQAOecACIxWSY0XSc2XSg2YCc3Xig3Xik3Xyk4Xyo4Xyo4YCo5Xyo5YCs5Xyo6Xys6"
      puts $optionF "   YCs6YSw6YCw6YSw7YSw7Yi07Yi48Yi48Yy88Yi89YzA+ZDE/ZDE/ZTI/ZTJAZTJBZjNBZTNBZjRB"
      puts $optionF "   ZjNCZTRCZjZEaDdEaThEaThGaTlGaTpIazxKbT1KbT9MbkBNb0NQc0VRc0ZScUZUdEhUdEdVdkhV"
      puts $optionF "   dElVdEpXdk1ZeE5ZeFRef1NgfVRgf1dgf1hhf11nhGFsh2JsiGFtiGJtiGNtiGZyi2lzjWt3kHB4"
      puts $optionF "   kHN+lnqEm36GnYCJnYmSo4qTpZWbrpWcq5eerZeer5qgrp6ltaGns6asuKesuqetvK60wrC1wLa6"
      puts $optionF "   xra8x7i9xLu/x7vAyb3CyMvO1MzP09DS2tDT2dHU2dHV2tLV2dPV29PX29fZ3tna3dna3tra3tzd"
      puts $optionF "   4d3d4dze4Nze4d3e4d3e4tzf4d3f4d3f497f4d7f5N/g4d7h497h5t/h5ODi5OHi5eHj5eLj5eLk"
      puts $optionF "   5uPl6OTm6efn6eXo6ejq6+rq6+rq7Orr7Ors6+vs7ezt7+3u7+/w8vDw8O/x8fDx8vHx8vHy9PHz"
      puts $optionF "   9PX19fb29vf39/j4+fr6+/v6+/z9/f39/v//////////////////////////////////////////"
      puts $optionF "   ////////////////////////////////////////////////////////////////////////////"
      puts $optionF "   ////////////////////////////////////////////////////////////////////////////"
      puts $optionF "   ////////////////////////////////////////////////////////////////////////////"
      puts $optionF "   ////////////////////////////////////////////////////////////////////////////"
      puts $optionF "   /////////////////////////////////////////////////////yH+EUNyZWF0ZWQgd2l0aCBH"
      puts $optionF "   SU1QACH5BAEKAP8ALAAAAAAQABAAAAjbAEEIHEiwoMGDBz1IGGDhhIkKBhx0IBhiAgUjWMSYiXRH"
      puts $optionF "   C5IPC0YIfLBji51KV1wESWPpT5chCUBggDGH06UsACYE0DFIEqdGPSBsKIMojxwgRFg84MGmzh5B"
      puts $optionF "   elbccATp0SNGVjgIWBKpUCJFjH7gcPOGDh8yFzAISGLID6A+f4SQCMQIzhovJVqouDFGTZtDk15Q"
      puts $optionF "   8EEI0yZKVGrIgCJJU6ZFRxiAQFAEDR4wVXLYkBImzhklCgY2ENEkChMuX55McYLiQMEOBSCkiEFj"
      puts $optionF "   RgQCGhCC6JCht+7fAwMCADs="
      puts $optionF "}"
      puts $optionF "image create photo iccflnk -data {"
      puts $optionF "   R0lGODlhEAAQAMZqAAAA/wEB/wMD/wQE/wUF/wYG/wcH/wgI/woK/wsL/wwM/xAQ/xER/xIS/xMT"
      puts $optionF "   /xQU/xYW/xcX/xgY/xkZ/xoa/xsb/x4e/yEh/yIi/yUl/yYm/ycn/ykp/zIy/zQ0/zY2/zc3/zo6"
      puts $optionF "   /zs7/zw8/z09/0ZG/0lJ/01N/1hY/1lZ/1pa/1tb/1xc/2Nj/2Vl/2lp/2pq/3R0/3V1/3Z2/3d3"
      puts $optionF "   /3h4/3t7/3x8/39//4SE/4WF/4uL/42N/4+P/5CQ/5KS/5OT/5SU/5WV/5aW/5eX/5iY/5ub/5+f"
      puts $optionF "   /6Cg/6Gh/6en/6mp/6qq/66u/6+v/7S0/7i4/7u7/729/7+//8DA/8LC/8PD/8rK/8zM/83N/87O"
      puts $optionF "   /9PT/9fX/9jY/+Pj/+Tk/+bm/+jo/+vr/+zs//Hx//Ly//T0//b2//j4//z8////////////////"
      puts $optionF "   /////////////////////////////////////////////////////////////////////////yH+"
      puts $optionF "   EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAH8ALAAAAAAQABAAAAfjgFJTaF86R2dpXjlIZ2JQUFIV"
      puts $optionF "   GGMnAAVFaCaWRlQKCRULE1cGBwIgWwQIASFSAAAMDBJKAC4XEEwALRcWTwAUKAwTQwA0GQs9ADIZ"
      puts $optionF "   Dk0ALGmhw8ULPAAzGgvNK2nBQtYjHNUxJBxOABw/3dZcW0YANl1bUa4eod40aWlHADf5rQAegkmT"
      puts $optionF "   8QIIgBozXvQqoUWgNWM7kmVg0EwFtAlFiE30kWxDA23cJiwBAAODBFwvdvXaFsvKgAcGQGQJEGGA"
      puts $optionF "   iFYsJYT5ACBAEDMdAAggMi9FGiVMzmhhcYNMGiwrcJQBk6RKmkAAOw=="
      puts $optionF "}"
      puts $optionF "image create photo viaflnk -data {"
      puts $optionF "   R0lGODlhEAAQAIQaAP8AAP8ICP8QEP8YGP8hIf8pKf8xMf85Of9CQv9SUv9aWv9jY/9zc/97e/+E"
      puts $optionF "   hP+MjP+UlP+cnP+lpf+trf+1tf/Gxv/Ozv/W1v/e3v/v7////////////////////////yH+EUNy"
      puts $optionF "   ZWF0ZWQgd2l0aCBHSU1QACH5BAEKAB8ALAAAAAAQABAAAAWDoCZm1lVp1ZVhqSWOSnBpEJNlynC+"
      puts $optionF "   tCA2LwODJ4IENI+M6AKYESWACuXlIBBFFADwVdgSK9bRBCC5ajBOTYYiNWumIguFPSdmledA42JJ"
      puts $optionF "   8DIHABhYghoqPAxZTgsEEQwTPBILDFEiAhBIeIYOhgBTd0QZCEpZEBcJA2lLFyolKayqGiEAOw=="
      puts $optionF "}"
      puts $optionF ""
      puts $optionF "image create photo smlnk -data {"
      puts $optionF "   R0lGODlhEAAQAOMNAAAAABgYITE5OVJSUmNja3Nzc4SEjJycpbW1tcbOztbW3ufn5+/39///////"
      puts $optionF "   /////yH+EUNyZWF0ZWQgd2l0aCBHSU1QACwAAAAAEAAQAAAEl7AVZEprawCSmkJLQy2HwCiFJgzK"
      puts $optionF "   1RyAUBBKMhjBEAgGchSFWOGAahACh8GNsEDkBhaPStA6SAA7gytRMHQ8GQFCYcWEMK4DsoNwoS+L"
      puts $optionF "   hIAwUnxA8Iv6N0gYBDkdDC5KCF0JCAQEgw0MIQxiBD0GTQRdUSETfQcHCAgCADEIjJwgY2N/VIw1"
      puts $optionF "   lJ0vnTEKISEGRAOeuAhfLhEAOw=="
      puts $optionF "}"
      puts $optionF ""
      puts $optionF "image create photo bcflnk -data {"
      puts $optionF "   R0lGODlhEAAQAIQRAAAAAAAAIAAAQAAgYCAgIDAwMABAgEBAQGBgYDBvbwCAgD9/fzCQkH9/f2Cg"
      puts $optionF "   oDCvr4/Pz////////////////////////////////////////////////////////////yH+EUNy"
      puts $optionF "   ZWF0ZWQgd2l0aCBHSU1QACwAAAAAEAAQAAAFWmCBjGRZEgixFE3kqqwbHUjCGK1r4zJdGINc5Bfs"
      puts $optionF "   IRrIpFJJkzUAUCcU0HQ9o9ZpNXIFSKE0mFBs3AnNRqJQbVy6k9uuE/IIxKdOh0Jwx3IDAlQEB4SF"
      puts $optionF "   hoYEIQA7"
      puts $optionF "}"
      puts $optionF ""
      puts $optionF "image create photo dsblnk -data {"
      puts $optionF "   R0lGODlhEAAQAMZMABIRERYVFDsQDUoTDyMiInUfGWclIDQzM3QmF4QiG0A3G0A3HU47OU49O0VE"
      puts $optionF "   RE9FI1BNTFFNTFFOTVFOTlJOTlJQT1JRUVJSUVNSUlRTU1VUVFZVVds5LMw+Mto7Kds7L80/NF1d"
      puts $optionF "   XNs9Mdo/K9s+Mts+M9pAK9xAM9xANNtBNW9iNtxDN9xDONpGLNxFOdlIK9lILH5tN9xQRXh3d458"
      puts $optionF "   P4iIiK2XTJmZmb2lU6qqqru7u9zAYszMzOzNZuzNZ+zOZ+zOaOzOae3Qbe3Qbu7Rce3Sc93d3e7u"
      puts $optionF "   7vn39/v5+fz6+v37+///////////////////////////////////////////////////////////"
      puts $optionF "   ////////////////////////////////////////////////////////////////////////////"
      puts $optionF "   /////////////////////////////////////////////////////////////////////////yH+"
      puts $optionF "   EUNyZWF0ZWQgd2l0aCBHSU1QACwAAAAAEAAQAAAHs4BMghAUIi5CPT2Ci4sVEgwpJkGJjI0SDSgv"
      puts $optionF "   lJWLExUiIj49RZyCGBMyJCk9Q6WCS0sCBSM7Kg41gg66OUxIIScGNDG4NTdMDkxHB0xKFxwgCjYb"
      puts $optionF "   N0aCBDUzM0xJEyIfCz1GNw7GBzo6DkZIqAkID9VHyMhMMzqwAQMdOAsOBzxMAHRp0xBhAosTQBS5"
      puts $optionF "   YmIhQoYTHn4odBUhgowSLSQuzDABwooTMIAAIeKKYzcUMnokZBQIADs="
      puts $optionF "}"
      close $optionF
   }
}

# Resolve Wikipedias language sites by means of the Wikipedia API
proc WikipNLS { LinkList } {

   # set WikiPediaAPI "http://de.wikipedia.org/w/api.php?action=query"

   set WikiPLL  "&prop=langlinks"
   set WikiPTI  "&titles="
   set lang     $::language
   set langlink [lindex $LinkList 3]

   # translate Scid's internal single letter language representation by
   # a more common two letter one; the same is used by WP
   switch $lang {
      B {set wplanguage pt}
      C {set wplanguage cs}
      D {set wplanguage de}
      F {set wplanguage fr}
      G {set wplanguage gr}
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

   # check if more langlinks exist, if so set the watermark, otherwise
   # it has to be emptied.
   if {[string match "*llcontinue*" $xmlresult]} {
      # keep only the langlinks-section of the XML
      regsub -all {.*<langlinks>} $xmlresult "" xmlresult
      regsub -all {</langlinks>.*} $xmlresult "" xmlresult
      regsub -all {</ll>} $xmlresult "</ll>\n" xmlresult
   } else {
      set llcontinue ""
   }
   set fullresult $xmlresult

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
      set fullresult "$fullresult$xmlresult"
   }

   set langlist [split $fullresult "\n"]

   foreach ll $langlist {
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

# Use the SeeAlso service hosted at Gemeinsamer Bibliotheks Verbund
# (Goettingen) to resolve the PND to german Wikipedia. SeeAlso might
# proove useful later for other services as they appear on SeeAlso
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

# Replace the ID-Tags by proper links
proc ReplaceIDTags { pinfo } {
  # replace certain BIO lines by links to external media
  regsub -all ".*PND "    $pinfo "" pnd
  regsub -all {<br>.*}    $pnd  "" pnd

  set pnd   [string trim $pnd]

  switch $::language {
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


  # the following three resolvers hook up with PND and need special
  # treatment as additional functions need to be called
  set wikiplink  "<run openURL $::pinfo::wikipurl/$wplanguage/$pnd; ::windows::stats::Refresh><button wikiplnk -command openURL $::pinfo::wikipurl/$wplanguage/$pnd;><blue>WP</blue></run>"

  # As we have direct linkage to WikiPedia SeeAlso is currently
  # obsolete. It might become of interest again if it offers other
  # services to connect to.
  ### set seealsolink  "<run ::pinfo::saPND2WP $pnd; ::windows::stats::Refresh><button seealsolnk -command ::pinfo::saPND2WP $pnd><blue>SeeAlso</blue></run>"
  set seealsolink ""

  set dnblink    "<run openURL $::pinfo::dnburl/$pnd; ::windows::stats::Refresh><button dnblnk -command openURL $::pinfo::dnburl/$pnd><blue>DNB</blue></run>"

  # Handle all id definitions and link resolvers from the config file
  foreach index [array names ::pinfo::idlink] {
     set federation $::pinfo::idlink($index)
     set searchterm [lindex $federation 0]
     set link       [lindex $federation 1]
     set icon       [lindex $federation 2]
     set str        [lindex $federation 3]

     # extract the ID
     regsub -all ".*$searchterm " $pinfo "" id
     regsub -all {<br>.*} $id "" id
     set id [string trim $id]

     if {$id != ""} {
        regsub -all "%ID%" $link $id link
        set btn "<run openURL $link; ::windows::stats::Refresh><button $icon -command openURL $link><blue>$str</blue></run>"
        regsub -all "$searchterm $id<br>" $pinfo $btn pinfo
     }
  }

  # Replace PND by all services linked to that ID
  regsub -all "PND $pnd<br>" $pinfo "$seealsolink $wikiplink $dnblink" pinfo
  regsub -all "</run>  <run" $pinfo "</run> <run" pinfo

  return $pinfo
}

proc playerInfo {{player ""}} {
  global playerInfoName eloFromRating
  if {$player == "" && [info exists playerInfoName]} { set player $playerInfoName }
  if {[catch {sc_name info -htext $player} pinfo]} { return }
  # append Elo History
  append pinfo "<br><br><darkblue>$::tr(PInfoRating):</darkblue><br>"
  if { $::eloFromRating } {
    set eloList [sc_name elo $player]
  } else {
    set filter [sc_filter new $::curr_db]
    set eloList [sc_base player_elo $::curr_db $filter $player]
    sc_filter release $::curr_db $filter
  }
  set i 0
  foreach { date elo } $eloList {
    set d [string range $date 0 4]
    scan [string range $date 5 6] %d m
    set m [format "%02d" [expr {round( ($m+1) * 12 / 100 )+1 } ]]
    append pinfo "$d$m  $elo     "
    incr i
    if { $i == 3 } { append pinfo "<br>"; set i 0 }
  }

  set playerInfoName $player
  set ::rgraph(player) $player
  set w .playerInfoWin
  if {! [winfo exists $w]} {
    ::createToplevel $w
    wm title $w "Scid: [tr ToolsPInfo]"
    ::setTitle $w "Scid: [tr ToolsPInfo]"
    wm minsize $w 40 5
    pack [ttk::frame $w.b2] -side bottom -fill x
    pack [ttk::frame $w.b] -side bottom -fill x
    ttk::radiobutton $w.b.eloF -text $::tr(PInfoEloFile) -value 1 -variable ::eloFromRating -command {::pinfo::playerInfo $playerInfoName}
    ttk::radiobutton $w.b.eloD -text $::tr(Database) -value 0 -variable ::eloFromRating -command {::pinfo::playerInfo $playerInfoName}
    ttk::label $w.b.eloT  -text "$::tr(Rating):"
    ttk::button $w.b.graph -text [tr ToolsRating] \
      -command {::tools::graphs::rating::Refresh player $playerInfoName}
    ttk::button $w.b.edit -text $::tr(PInfoEditRatings) -command {
      makeNameEditor
      setNameEditorType rating
      set editName $playerInfoName
      set editNameSelect crosstable
    }
    ttk::button $w.b2.report -text [tr ToolsPlayerReport] \
      -command {::preport::preportDlg $playerInfoName}
    dialogbutton $w.b2.help -textvar ::tr(Help) -command {helpWindow PInfo}
    dialogbutton $w.b2.update -textvar ::tr(Update) -command {::pinfo::playerInfo $playerInfoName}
    dialogbutton $w.b2.close -textvar ::tr(Close) -command "focus .; destroy $w"
    packbuttons right $w.b2.close $w.b2.update $w.b2.help
    pack $w.b.eloT $w.b.eloF $w.b.eloD -side left -padx "5 0"
    packbuttons left $w.b.graph $w.b.edit
    packbuttons left $w.b2.report

    autoscrollframe $w.frame text $w.text -font font_Regular -background white \
      -setgrid 1 -wrap none

    ttk::label $w.photo -background white
    #pack $w.text -side top -fill both -expand yes
    pack $w.frame -side top -fill both -expand yes
    bind $w <Escape> "focus .; destroy $w"
    ::htext::init $w.text
    ::htext::updateRate $w.text 0
    bind $w <Escape> "focus .; destroy $w"
    bind $w <F1> {helpWindow PInfo}
    ::createToplevelFinalize $w
  }
  set player [trimEngineName $player]
  set imgdata [getphoto $player]
  if {$imgdata != ""} {
    image create photo photoPInfo -data $imgdata
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
}

# Call in the idlink config file.
   if {[catch {source [scidConfigFile resolvers]} ]} {
     ::splash::add "No configuration for link resolvers found. Creating default..."
     ::pinfo::setupDefaultResolvers
      if {[catch {source [scidConfigFile resolvers]} ]} {
         ::splash::add "Oops there is something wrong with the resolvers file..."
      } else {
         ::splash::add "Default resolvers created and loaded."
      }
   } else {
     ::splash::add "ID resolvers found, extended player info available."
   }
}
