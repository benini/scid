### lang.tcl: Support for multiple-language menus, buttons, etc.
### Part of Scid, which is Copyright 2001-2003 Shane Hudson.

array set langEncoding {}
set languages {}

if {[catch {encoding names}]} {
  set hasEncoding 0
} else {
  set hasEncoding 1
}
################################################################################
#  Translation of pieces
################################################################################
array set transPieces {}

set transPieces(F)   { P P K R Q D R T B F N C }
set untransPieces(F) { P P R K D Q T R F B C N }
set transPieces(S)   { P P K R Q D R T B A N C }
set untransPieces(S) { P P R K D Q T R A B C N }
set transPieces(D)   { P B K K Q D R T B L N S }
set untransPieces(D) { B P K K D Q T R L B S N }
set transPieces(I)   { P P K R Q D R T B A N C }
set untransPieces(I) { P P R K D Q T R A B C N }
set transPieces(N)   { P p K K Q D R T B L N P }
set untransPieces(N) { p P K K D Q T R L B P N }
set transPieces(C)   { P P K K Q D R V B S N J }
set untransPieces(C) { P P K K D Q V R S B J N }
set transPieces(H)   { P G K K Q V R B B F N H }
set untransPieces(H) { G P K K V Q B R F B H N }
set transPieces(O)   { P B K K Q D R T B L N S }
set untransPieces(O) { B P K K D Q T R L B S N }
set transPieces(W)   { P B K K Q D R T B L N S }
set untransPieces(W) { B P K K D Q T R L B S N }
set transPieces(K)   { P P K R Q D R T B A N C }
set untransPieces(K) { P P R K D Q T R A B C N }

################################################################################
proc trans { msg } {
  if { $::language == "E" || ! $::translatePieces || $msg == "\[end\]"} {
    return $msg
  }
  if { [ catch { set t [string map $::transPieces($::language) $msg ]} ] } {
    return $msg
  }
  return $t
}
################################################################################
proc untrans { msg } {
  if { $::language == "E"  || ! $::translatePieces || $msg == "\[end\]"} {
    return $msg
  }
  if { [ catch { set t [string map $::untransPieces($::language) $msg ]} ] } {
    return $msg
  }
  return $t
}
################################################################################
#
################################################################################
proc addLanguage {letter name underline {encodingSystem ""}} {
  global langEncoding languages
  .menu.options.language add radiobutton -label $name \
      -underline $underline -variable language -value $letter \
      -command setLanguage
  set ::langEncoding($letter) $encodingSystem
  lappend languages $letter
}
################################################################################
# menuText:
#    Assigns the menu name and help message for a menu entry and language.
################################################################################
proc menuText {lang tag label underline {helpMsg ""}} {
  global hasEncoding langEncoding
  if {$hasEncoding  &&  $langEncoding($lang) != ""  &&  $::tcl_version <= 8.3} {
    catch {set label [encoding convertfrom $langEncoding($lang) $label]}
    catch {set helpMsg [encoding convertfrom $langEncoding($lang) $helpMsg]}
  }
  
  set ::menuLabel($lang,$tag) $label
  set ::menuUnder($lang,$tag) $underline
  if {$helpMsg != ""} {
    set ::helpMessage($lang,$tag) $helpMsg
  }
}
################################################################################
# helpMsg:
#    Assigns the help message for a particular language for a button.
# ################################################################################
proc helpMsg {lang button message} {
  global hasEncoding langEncoding
  if {$hasEncoding  &&  $langEncoding($lang) != ""  &&  $::tcl_version <= 8.3} {
    catch {set message [encoding convertfrom $langEncoding($lang) $message]}
  }
  set ::helpMessage($lang,$button) $message
}

array set tr {}
array set translations {}
################################################################################
# translate:
#    Assigns a translation for future reference.
################################################################################
proc translate {lang tag label} {
  global menuLabel hasEncoding langEncoding
  regsub {\\n} $label "\n" label
  if {$hasEncoding  &&  $langEncoding($lang) != ""  &&  $::tcl_version <= 8.3} {
    catch {set label [encoding convertfrom $langEncoding($lang) $label]}
  }
  set ::translations($lang,$tag) $label
  set ::tr($tag) $label
  foreach extra {":" "..."} {
    set newtag "${tag}${extra}"
    set newlabel "${label}${extra}"
    set ::translations($lang,$newtag) $newlabel
    set ::tr($newtag) $newlabel
  }
}
################################################################################
# translateECO:
#    Given a pair list of ECO opening name phrase translations,
#    assigns the translations for future reference.
################################################################################
proc translateECO {lang pairList} {
  global hasEncoding langEncoding
  foreach {from to} $pairList {
    if {$hasEncoding  &&  $langEncoding($lang) != ""  &&  $::tcl_version <= 8.3} {
      catch {set to [encoding convertfrom $langEncoding($lang) $to]}
    }
    sc_eco translate $lang $from $to
  }
}
################################################################################
# tr:
#    Given a tag and language, returns the stored text for that tag.
################################################################################
proc tr {tag {lang ""}} {
  global menuLabel tr
  if {$lang == ""} {set lang $::language}
  if {$lang == "X"} {return $tag}
  # First, look for a menu label
  if {[info exists menuLabel($lang,$tag)]} {
    return $menuLabel($lang,$tag)
  }
  if {[info exists menuLabel(E,$tag)]} {
    return $menuLabel(E,$tag)
  }
  # Now look for a regular button/message translation
  if {[info exists tr($tag)]} {
    return $tr($tag)
  }
  # Finally, just give up and return the original tag
  return $tag
}
################################################################################
#
################################################################################
proc setLanguage {{lang ""}} {
  global menuLabel menuUnder oldLang hasEncoding langEncoding
  
  if {$lang == ""} {set lang $::language}
  
  if { $::translatePieces } {
    switch $lang {
      F {sc_info language fr}
      S {sc_info language es}
      D {sc_info language de}
      I {sc_info language it}
      N {sc_info language ne}
      C {sc_info language cz}
      H {sc_info language hu}
      O {sc_info language no}
      W {sc_info language sw}
      K {sc_info language ca}
      default {sc_info language en}
    }
  } else {
    sc_info language en
  }
  
  if {[catch {setLanguage_$lang} err]} { puts "Error: $err" }
  # TODO: Check this:
  if {$hasEncoding  &&  $langEncoding($lang) != ""} {
    # encoding system $langEncoding($lang)
  }
  
  # If using Tk, translate all menus:
  if {! [catch {winfo exists .}]} { setLanguageMenus $lang }
  
  foreach i [array names ::tr] {
    if {[info exists ::translations($lang,$i)]} {
      set ::tr($i) $::translations($lang,$i)
    } elseif {[info exists ::translations(E,$i)]} {
      set ::tr($i) $::translations(E,$i)
    }
  }
  set oldLang $lang
}
################################################################################
# Will switch language only for Scid backoffice, no UI
# Used to make callbacks use english by default
################################################################################
proc setLanguageTemp { lang } {
  switch $lang {
    F {sc_info language fr}
    S {sc_info language es}
    D {sc_info language de}
    I {sc_info language it}
    N {sc_info language ne}
    C {sc_info language cz}
    H {sc_info language hu}
    O {sc_info language no}
    W {sc_info language sw}
    K {sc_info language ca}
    default {sc_info language en}
  }
}

### End of file: lang.tcl

