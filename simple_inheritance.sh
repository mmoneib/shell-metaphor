#!/bin/bash

source father__sourced.sh;
source son__sourced.sh;
source simple_inheritance_state__sourced.sh # used to maintain the sourcing state fo parents for overriding purposes.

doesFatherHaveSivlerSpoon;
doesSonHaveSilverSpoon;
fatherDies;
doesFatherHaveSivlerSpoon;
doesSonHaveSilverSpoon;
swapFatherWithSon;
doesFatherHaveSivlerSpoon;
doesSonHaveSilverSpoon;
