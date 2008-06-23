namespace eval utils {
  namespace eval validate {
    
    # ::utils::validate::Integer
    #
    #   Used to check the size of integers in entry boxes.
    #
    proc Integer {maxValue allowQuestionMarks name el op} {
      global $name ${name}_old
      if {[string comp {} $el]} {
        set old  ${name}_old\($el\)
        set name $name\($el\)
      } else {
        set old ${name}_old
      }
      
      if {$allowQuestionMarks > 0} {
        if {[regexp {^\?*$} [set $name]]} {
          # Accept this value:
          set $old [set $name]
          return
        }
      }
      
      # Only non-negative integers up to maxValue are allowed, unless the
      # value is negative:
      set allowNegatives 0
      if {$maxValue < 0} {
        set allowNegatives 1
        set maxValue [expr {0 - $maxValue}]
      }
      
      if {$allowNegatives} {
        if {![regexp {^[-+]?[0-9]*$} [set $name]]} {
          set $name [set $old]
          bell
          return
        }
      } else {
        if {![regexp {^[+]?[0-9]*$} [set $name]]} {
          set $name [set $old]
          bell
          return
        }
      }
      if {[set $name] > $maxValue} {
        set $name [set $old]
        bell
        return
      }
      set $old [set $name]
    }
    
    # ::utils::validate::Date
    #
    #    Used to check the validity of a date string as it is entered.
    #
    proc Date {name el op} {
      global $name ${name}_old
      set old ${name}_old
      if {![sc_info validDate [set $name]]} {
        set $name [set $old]
        bell
        return
      }
      set $old [set $name]
    }
    
    # ::utils::validate::Result
    #
    #    Used to check the validity of a result entrybox value.
    #    Result can be empty, "1", "0", "=", or "*".
    #
    proc Result {name el op} {
      global $name ${name}_old
      set old ${name}_old
      if {![regexp {^[1|0|=|\*]?$} [set $name]]} {
        set $name [set $old]
        bell
        return
      }
      set $old [set $name]
    }
    
    # ::utils::validate::Alpha
    #
    #    Used to check that an entrybox contains only letters.
    #
    proc Alpha {name el op} {
      global $name ${name}_old
      set old ${name}_old
      if {![regexp {^[A-Za-z]*$} [set $name]]} {
        set $name [set $old]
        bell
        return
      }
      set $old [set $name]
      
    }
    
    # ::utils::validate::Regexp
    #
    #    Used to check the validity of an entrybox given a regular expression.
    #    Used to verify a file is "a-h", for example.
    #
    proc Regexp {expression name el op} {
      global $name ${name}_old
      set old ${name}_old
      if {![regexp $expression [set $name]]} {
        set $name [set $old]
        bell
        return
      }
      set $old [set $name]
    }
  }
}
