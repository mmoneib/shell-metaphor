#!/bin/sh
#############################################################################################
# Coincidence                                                                               #                
#                                                                                           #
# A simple simulation which employs randomness to test the probability of an occurence of a #
# coincidence through 2 "free" agents moving within a confined plane.                       #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################
# TODO Add option to manage pauses between frames.
# TODO Develop the other 2 strategies.
# TODO Add comments including rationale behind design decisions.

while getopts "l:w:" opt; do
  case "$opt" in
  l) height=$OPTARG ;;
  w) width=$OPTARG ;;
  esac
done

[ -z "$width" ] && width=$(tput cols) || customSize=true
[ -z "$height" ] && height=$(tput lines) || customSize=true

#resize -s $height $width
spaceSize=$(( width*height ))
space=()
agent1strategy="teleporation" # "random-walk" "stationary"
agent2strategy="teleporation" # "random-walk" "stationary"

agent1Position=0
agent2position=0

count=0
for (( i=0; i<$spaceSize; i++ )); do
  if [ "$customSize" == "true" ] && [ $(( i%width )) -eq 0  ]; then
    o_space+=("\n")
  fi 
  space+=(".")
done
tput reset
while true; do
  tput cup 0 0
  space[$agent1Position]="."
  space[$agent2Position]="."
  function teleportation {
    echo "$(( RANDOM%spaceSize ))"
  }
  agent1Position="$(teleportation)"
  agent2Position="$(teleportation)"
  space[$agent1Position]="1"
  space[$agent2Position]="2"
  if [ "$customSize" == "$true" ]; then
    printf "%s" "${space[@]}"
  else
    for (( i=0; i<$height; i++ )); do
      echo "${space[@]:$(( i*width  )):width}"
    done
  fi
  (( count++ ))
  [ $agent1Position -eq $agent2Position ] && break
  sleep 0.5
done
echo "Coincidence happened after $count movements!" 
