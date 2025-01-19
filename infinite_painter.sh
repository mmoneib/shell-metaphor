#!/bin/sh
#############################################################################################
# Infinite Painter                                                                          #                
#                                                                                           #
# A visual demonstration of brute force revelation.                                         #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################
# TODO Refactor into a function to reduce specific condition.
# TODO Add collage.

function print_usage {
  echo "USAGE: $0  -c filled_char_here [ -l length_of_side_here -e emptiness_char_here -s is_sticky_here -t pause_in_seconds ]"
  exit
}

function print_error {
  echo "ERROR: $1">&2
  isError=true
  exit
}

function trap_on_exit {
  [ -z "$isError" ] && [ -z "$specificFrame" ] && clear
}

# Arguments parsing.
while getopts "c:e:f:i:l:t:w:h" opt; do
  case $opt in
  c) char=$OPTARG ;;
  e) emptinessChar=$OPTARG ;;
  f) specificFrame=$OPTARG ;;
  l) length=$OPTARG ;;
  t) stopTimeBetweenFrames=$OPTARG ;;
  h) print_usage ;;
  *) print_usage ;;
  esac
done
# Arguments validation.
[ -z "$1" ] && print_usage
[ -z "$char" ] && print_usage
[ -z "$stopTimeBetweenFrames" ] && stopTimeBetweenFrames=0
[ -z "$length" ] && length=0 && isExpansiveUniverse=true
[ -z "$emptinessChar" ] && IFS=; emptinessChar=" " # IFS is unset for the variable assignation so as to correctly interpret the empty space as an empty space.
if [ -z "$isExpansiveUniverse" ]; then
  [  $length -gt 7 ] || [ $length -lt 1 ] && isError=true && echo "ERROR: Length of the square universe shouldn't exceed 7 or be less than 1.">&2 && exit
fi
# Initialization commands
tput reset # Initializes the screen, to avoid leftovers from previous processes.
trap trap_on_exit EXIT # CLean after exit.
# Initialization of internal variables.
width=$length
numOfChars=2
charset="$emptinessChar$char"
o_canvas="" 
# Processing
while [ $length -lt 8 ]; do
  numOfPossibleFrames=$(( numOfChars**(length*width) ))
  [ ! -z "$specificFrame" ] && [ $numOfPossibleFrames -le $specificFrame ] && print_error "Maximum number of a frame for this size is $(( numOfPossibleFrames-1 ))."
  [ -z "$specificFrame" ] && cStart=0 || cStart="$specificFrame"
  for (( c=$cStart;c<numOfPossibleFrames;c++ )); do # Number of possible frames.
    o_canvas=""
    tput cup 0 0 # No flickering like 'tput reset'.
    for (( l=0;l<length;l++ )); do
      for (( w=0;w<width;w++ )); do
        posInCanvas=$(( l*width+w ))
        posInCharset=$(( (c/(numOfChars**posInCanvas))%numOfChars )) # Rolling frequency decreases geometrically with advanced position in canvas.
#echo $posInCharset
        o_canvas+="${charset:$posInCharset:1}"
      done
      o_canvas+="\n"
    done
    # Output
    printf "$o_canvas"
    [ ! -z "$specificFrame" ] && exit
    sleep $stopTimeBetweenFrames
  done
  if [ $isExpansiveUniverse == true ]; then
    (( length++ ))
    (( width++ ))
  else
    break # Could also have separated the outer while in a conditional, but the flow is better like this for the ourpose of the script.
  fi
done
