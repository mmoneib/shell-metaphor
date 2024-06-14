#!/bin/bash
#############################################################################################
# Simple INheritance                                                                        #                
#                                                                                           #
# Partly an emulation of the Object-Oriented concept of Inheritence through Shell Script's  #
# concept of sourcing, partly a satire of the social concept of inheritence.
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

source father__sourced.sh;
source son__sourced.sh;
#source simple_inheritance_state__sourced.sh # Used to maintain the sourcing state fo parents for overriding purposes.

doesFatherHaveSivlerSpoon;
doesSonHaveSilverSpoon;
fatherDies;
doesFatherHaveSivlerSpoon;
doesSonHaveSilverSpoon;
swapFatherWithSon;  # Represents the will as propagated from father (higher point in the stack) to son.
doesFatherHaveSivlerSpoon;
doesSonHaveSilverSpoon;
