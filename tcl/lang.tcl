### lang.tcl: Support for multiple-language menus, buttons, etc.
### Part of Scid. Copyright 2001 Shane Hudson.

array set langEncoding {}
set languages {}

if {[catch {encoding names}]} {
  set hasEncoding 0
} else {
  set hasEncoding 1
}

proc addLanguage {letter name underline {encodingSystem ""}} {
  global langEncoding languages
  .menu.options.language add radiobutton -label $name \
    -underline $underline -variable language -value $letter \
    -command setLanguage
  set ::langEncoding($letter) $encodingSystem
  lappend languages $letter
}

# menuText:
#    Assigns the menu name and help message for a menu entry and language.
#
proc menuText {lang tag label underline {helpMsg ""}} {
  global hasEncoding langEncoding
  if {$hasEncoding  &&  $langEncoding($lang) != ""} {
    catch {set label [encoding convertfrom $langEncoding($lang) $label]}
    catch {set helpMsg [encoding convertfrom $langEncoding($lang) $helpMsg]}
  }
  set ::menuLabel($lang,$tag) $label
  set ::menuUnder($lang,$tag) $underline
  if {$helpMsg != ""} {
    set ::helpMessage($lang,$tag) $helpMsg
  }
}


# helpMsg:
#    Assigns the help message for a particular language for a button.
#
proc helpMsg {lang button message} {
  global hasEncoding langEncoding
  if {$hasEncoding  &&  $langEncoding($lang) != ""} {
    catch {set message [encoding convertfrom $langEncoding($lang) $message]}
  }
  set ::helpMessage($lang,$button) $message
}

array set tr {}
array set translations {}

# translate:
#    Assigns a translation for future reference.
#
proc translate {lang tag label} {
  global menuLabel hasEncoding langEncoding
  if {$hasEncoding  &&  $langEncoding($lang) != ""} {
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

# translateECO:
#    Given a pair list of ECO opening name phrase translations,
#    assigns the translations for furute reference.
#
proc translateECO {lang pairList} {
  global hasEncoding langEncoding
  foreach {from to} $pairList {
    if {$hasEncoding  &&  $langEncoding($lang) != ""} {
      catch {set to [encoding convertfrom $langEncoding($lang) $to]}
    }
    sc_eco translate $lang $from $to
  }
}

# tr:
#    Given a tag and language, returns the stored text for that tag.
#
proc tr {tag {lang ""}} {
  global menuLabel
  if {$lang == ""} {set lang $::language}
  if {$lang == "X"} {return $tag}
  if {[info exists menuLabel($lang,$tag)]} {
    return $menuLabel($lang,$tag)
  }
  if {[info exists menuLabel(E,$tag)]} {
    return $menuLabel(E,$tag)
  }
  return $tag
}

proc setLanguage {{lang ""}} {
  global menuLabel menuUnder oldLang

  if {$lang == ""} {set lang $::language}

  if {[catch {setLanguage_$lang} err]} { puts "Error: $err" }

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


### End of file: lang.tcl

