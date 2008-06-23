namespace eval ::utils::string {
  # ::utils::string::Surname
  #
  #   Returns the surname of a player name.
  #
  proc Surname {name} {
    set idx [string first "," $name]
    if {$idx > 0} { set name [string range $name 0 [expr {$idx - 1} ]] }
    return $name
  }
  
  
  proc CityName {siteName} {
    regsub { [A-Z][A-Z][A-Z]$} $siteName "" siteName
    return [string trim [::utils::string::Surname $siteName]]
  }
  
  
  # ::utils::string::Capital
  #
  #    Returns a string with the first character capitalised.
  #
  proc Capital {str} {
    set s [string toupper [string index $str 0]]
    append s [string range $str 1 end]
    return $s
  }
  
  # PadLeft
  #
  #   Given a string and a length, pads the string with padChar to have
  #   the required length.
  #
  proc PadLeft {str length {padChar " "}} {
    set s $str
    for {set actual [string length $s]} {$actual < $length} {incr actual} {
      append s $padChar
    }
    return $s
  }
  
  # Pad
  #
  #   Same as PadLeft.
  #
  proc Pad {str length {padChar " "}} {
    return [::utils::string::PadLeft $str $length $padChar]
  }
  
  # PadRight
  #
  #   Like PadLeft, but adds the padding characters to the start of the string.
  #
  proc PadRight {str length {padChar " "}} {
    set s $str
    for {set actual [string length $s]} {$actual < $length} {incr actual} {
      set s "$padChar$s"
    }
    return $s
  }
  
  # PadCenter
  #
  #   Like PadLeft and PadRight, but centers the specified string.
  #
  proc PadCenter {str length {padChar " "}} {
    set pre 1
    set s $str
    for {set actual [string length $s]} {$actual < $length} {incr actual} {
      if {$pre} {
        set s "$padChar$s"
        set pre 0
      } else {
        append s $padChar
        set pre 1
      }
    }
    return $s
  }
  
}
