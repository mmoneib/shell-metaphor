#!/bin/sh
#############################################################################################
# Infinite Painter                                                                          #                
#                                                                                           #
# A visual demonstration of brute force revelation.                                         #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

function print_usage {
  echo "USAGE: $0  -c filled_char_here [ -l length_of_side_here -e emptiness_char_here -s is_sticky_here -t pause_in_seconds ]"
  exit
}

function trap_on_exit {
  [ -z $isError ] && clear
}

# Arguments parsing.
while getopts "c:e:i:l:t:w:h" opt; do
  case $opt in
  c) char=$OPTARG ;;
  e) emptinessChar=$OPTARG ;;
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
frameSize=$(( width*height ))
charset="$emptinessChar$char"
width=$length
numOfChars=2
o_canvas="" 
# Processing
while [ $length -lt 8 ]; do
for (( c=0;c<numOfChars**(length*width);c++ )); do # Number of possible frames.
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
  sleep $stopTimeBetweenFrames
done
  if [ $isExpansiveUniverse == true ]; then
    (( length++ ))
    (( width++ ))
  else
    break
  fi
done
