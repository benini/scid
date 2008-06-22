### move.tcl
### Functions for moving within a game.

namespace eval ::move {}

proc ::move::Start {} {
  if {$::tree(refresh)} { return }
  sc_move start
  updateBoard
}

proc ::move::End {} {
  if {$::tree(refresh)} { return }
  sc_move end
  updateBoard
}

proc ::move::Back {{count 1}} {
  if {$::tree(refresh)} { return }
  if {[sc_pos isAt start]} { return }
  
  sc_move back $count
  # Pascal Georges : make it easier to navigate in a game
  # TODO : if left mouse arrow leaves var, then comments are doubled at Var start and comments can no longer be entered
  # before the first move of a line
  # if {[sc_pos isAt vstart]} {
    # sc_var exit
  # }
  
  if {$count == 1} {
    # Do animation and speech:
    updateBoard -animate
    ::utils::sound::AnnounceBack
  } else {
    updateBoard
  }
}

proc ::move::Forward {{count 1}} {
  global autoplayMode
  if {$::tree(refresh)} { return }
  if {[sc_pos isAt end]  ||  [sc_pos isAt vend]} { return }
  set move [sc_game info next]
  if {$count == 1} {
    if {[sc_var count] != 0 && ! $autoplayMode && $::showVarPopup} {
      ::commenteditor::storeComment
      showVars
    } else  {
      sc_move forward
    }
    
    # Animate and speak this move:
    updateBoard -animate
    ::utils::sound::AnnounceForward $move
  } else {
    sc_move forward $count
    updateBoard
  }
}


