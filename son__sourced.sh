#!/bin/bash
#############################################################################################
# Son (Sourced)                                                                             #                
#                                                                                           #
# A non-stand-alone emulation of a stateful object through sourcing. It acts as a class     #
# extending by father__sourced.                                                             #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

silverSpoon=false;

function doesSonHaveSilverSpoon {
  [[ $silverSpoon == true ]] && echo "Son has a silver spoon." || echo "Son doesn't have a silver spoon.";
}

function fatherDies {
  fatherDies1; # Numbering since there is no way to refer to an overrider parent function.
  silverSpoon=true;
  echo "Son takes the silver spoon."
}

function swapFatherWithSon {
  # Calling the parent's same method (like Java's super) is possible with multiple sourcing.
  source father__sourced.sh;
  swapFatherWithSon; # Calls the funtion of the father.
  echo "A new son is born."
  source son__sourced.sh # Reinstates the son's object.
}

if [[ $_was_son_sourced_before != true ]]; then # Sourced, but not yet initialized at least once.
  echo "Son's address is $address."
  _was_son_sourced_before=true;
fi

