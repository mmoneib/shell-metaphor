#!/bin/sh
################################################################################
# Random vs. Random                                                            #
#                                                                              #
# A simple simulation of random guessing the movement of a stream of random    #
# data. Each correct guess will increase the aggregate score by the value of   #
# the choice, while each incorrect one will decrease it by that value.         #
#                                                                              #
# Conceptualized and developed by: Muhammad Moneib                             #
################################################################################

#TODO Add customized, numerical choices. If not numerical, then the indices should be used.

function print_help {
  echo -e "A simple simulation of random guessing the movement of a stream of random data.
Required Parameters:
\tStart Number of Tries (n): The number of random choices before the stream comes to a close.
Optional Parmeters:
\tIs Raw Output? (r): If present, the ouput will be CSV in the form of Score.
Examples:
# Randomly guess a stream of 1000 tries.
$0 -n 1000"
  exit
}

function print_error {
  echo "$1">&2
  exit 1
}

while getopts "n:rh" c; do
  case $c in
  n) numberOfTries=$OPTARG ;;
  r) isRawOutput=1 ;;
  h) print_help ;;
  *) print_help ;;
  esac
done

[ -z $numberOfTries ] && print_error "ERROR: The parameter Number of Tries (n) is required." && exit 1 
aggregate=0

while [ $numberOfTries -gt 0 ]; do
  randomGuess=$(( RANDOM%2 ))
  randomReality=$(( RANDOM%2 ))
  [ $randomGuess -eq $randomReality ] && aggregate=$(( aggregate+1 )) || aggregate=$(( aggregate-1 ))
  numberOfTries=$(( numberOfTries-1 ))
done

echo $aggregate  
