#!/bin/sh

#TODO Let the streams disappear from the bottom of the screen.
#TODO Add options to prepare the output or to yield it during the process.

[ ! -z "$(command -v setopt)" ] && setopt KSH_ARRAYS # For zsh to act like bash when it comes to arrays.

filename=$1
width=$(tput cols)
height=$(tput lines)
numOfPixels=$(( width*height ))
streams=()
streamsIndices=()
numOfChars=0
frames=()

# Reading Input and Initializing Strams
while read line; do
  streamNumber=$(( RANDOM%width ))
  [ -z "${streams[streamNumber]}" ] && streams[$streamNumber]="" # Initialization of array. 
  line="$line "
  numOfChars=$(( numOfChars+${#line} ))
  streams[$streamNumber]+="$line "
done  <<< "$(cat $filename)"
#echo 1
# Initialize Indices
for (( i=0; i<width; i++ )); do
  streamsIndices[i]=0
done
#echo 2
# Initialize Canvas
for (( p=0; p<numOfPixels; p++ )); do
  canvas+=" "
done
#echo 3
# Simulate Matrix
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
    char="${canvas:$p:1}"
    canvas="${canvas:0:$p}$oldChar${canvas:$(( p+1 ))}"
    oldChar="$char"
    p=$(( p+width ))
  done
  frames+=("$canvas")
  #tput cup 0 0
  #printf "$canvas"
  (( count++ ))
done
#echo 4
# Output
for (( f=0; f<${#frames[@]}; f++ )); do
  printf "${frames[f]}"
  tput cup 0 0
#  sleep 0.1
done
#echo 5
