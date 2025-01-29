#!/bin/sh
#############################################################################################
# Matirx                                                                                    #                
#                                                                                           #
# A similar, yet not exact, visual representation of a text file the famous digital rain    #
# made popular by The Matrix.                                                               #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################
#TODO Let the streams disappear from the bottom of the screen.
#TODO Limit max width and length.
#TODO Add random number of spaces between consecutive sentences.
#TODO Option to force output to be green on black.

function __print_usage {
  echo "USAGE: $0  -f file_path_here [ -l height_here -w width_here ]"
  isError=true
  exit
}

function __print_error {
  echo "ERROR: $1">&2
  isError=true
  exit
}

function __trap_on_exit {
  [ -z "$isError" ] && clear
}

function yield_frame {
  tput cup 0 0 # Faster than rese and clear. Needed because of custom heights.
  echo -e "$frame" # The variable contains \n, and hence, printf produce errors.
}

function collect_frame {
  frames+=("$frame")
}

# System Configuration
[ ! -z "$(command -v setopt)" ] && setopt KSH_ARRAYS # For zsh to act like bash when it comes to arrays.
trap __trap_on_exit EXIT
# Configuration
width=$(tput cols)
height=$(tput lines)
lazyOutput=false
while getopts "f:l:w:z" o; do
  case $o in
  f) filename=$OPTARG ;;
  l) height=$OPTARG ;;
  w) width=$OPTARG ;;
  z) lazyOutput=true ;;
  *) print_usage ;;
  esac
done
[ -z $1 ] && __print_usage
[ -z $filename ] && __print_usage
numOfPixels=$(( width*height ))
streams=()
streamsIndices=()
numOfChars=0
frames=()
canvas=()
[ $lazyOutput == false ] && funcOnFrame="yield_frame" || funcOnFrame="collect_frame" # Design guided by optimization; otherwise, there would be an if check inside the loop.

# Reading Input and Initializing Strams
while read line; do
  streamNumber=$(( RANDOM%width ))
  [ -z "${streams[streamNumber]}" ] && streams[$streamNumber]="" # Initialization of array. 
  line="$line "
  numOfChars=$(( numOfChars+${#line} ))
  streams[$streamNumber]+="$line "
done  <<< "$(cat $filename)"
# Initialize Indices
for (( i=0; i<width; i++ )); do
  streamsIndices[i]=0
done
# Initialize Canvas
for (( p=0; p<numOfPixels; p++ )); do
  canvas[$p]=" "
done
# Simulate Matrix
tput reset
count=0
while [ $count -lt $numOfChars ]; do
  streamNumber=$(( RANDOM%width ))
  indexInStream=${streamsIndices[streamNumber]}
  streamsIndices[streamNumber]=$(( indexInStream+1 ))
  stream="${streams[streamNumber]}"
  oldChar="${stream:indexInStream:1}"
  [ -z "$oldChar" ] && oldChar=" "
  p=$streamNumber
  while [ $p -lt $numOfPixels ]; do
    char="${canvas[$p]}"
    canvas[$p]="$oldChar"
    oldChar="$char"
    p=$(( p+width ))
  done
  frame=""
  for (( c=0; c<${#canvas[@]}; c++ )); do
    frame+="${canvas[$c]}"
    [ $(( c%width )) -eq 0 ] && [ $c -ne 0 ] && frame+="\n"
  done
  $funcOnFrame
  (( count++ ))
done
if [ $lazyOutput == true ]; then
  for (( f=0; f<${#frames[@]}; f++ )); do
    tput cup 0 0
    echo -e "${frames[f]}"
  done
fi
