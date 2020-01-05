#!/bin/bash

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
  # Calling the parent's same method (like Java's super) is possible with multiple sourcing. However, initializations must be accomodated by a stateful grandparent (simple_inheritance_state__sourced.sh).
  source father__sourced.sh;
  swapFatherWithSon;
  echo "A new son is born."
  source son__sourced.sh
}

if [[ $_was_son_sourced_before != true ]]; then
  echo "Son's address is $address."
fi

