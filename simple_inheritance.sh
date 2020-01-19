#!/bin/bash

source father__sourced.sh;
source son__sourced.sh;
source simple_inheritance_state__sourced.sh # Used to maintain the sourcing state fo parents for overriding purposes.

doesFatherHaveSivlerSpoon;
doesSonHaveSilverSpoon;
fatherDies;
doesFatherHaveSivlerSpoon;
doesSonHaveSilverSpoon;
swapFatherWithSon;  # Represents the will as propagated from father (higher point in the stack) to son.
doesFatherHaveSivlerSpoon;
doesSonHaveSilverSpoon;
