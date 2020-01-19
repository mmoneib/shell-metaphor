#!/bin/bash

silverSpoon1=true;
address="Planet Earth";

function doesFatherHaveSivlerSpoon {
  [[ $silverSpoon1 == true ]] && echo "Father has a silver spoon." || echo "Father doesn't have a silver spoon.";
}

function fatherDies1 { # Numbering since there is no way to refer to an overrider parent function.
  silverSpoon1=false;
  echo "The father dies, leaving the silver spoon.";
}

function swapFatherWithSon { # Overridden yet called by Son.
  echo "Son becomes father."
}

if [[ $_was_father_sourced_before != true ]]; then
  echo "Father's address is $address."
fi

