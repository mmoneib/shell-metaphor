#!/bin/sh
#############################################################################################
# Coincidence                                                                               #                
#                                                                                           #
# A simple simulation which employs randomness to test the probability of an occurence of a #
# coincidence through 2 "free" agents moving within a confined plane.                       #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################
# TODO Develop the other 2 strategies.
# TODO Check why problematic on Mac starting from l 4 and w 4. Takes much longer than expected.

function print_error {
  echo "ERROR: $1"
  print_usage
}

function print_usage {
  echo "USAGE: $0 -s strategy_of_agent1_here -S strategy_of_agent2_here -p pause_interval_here [-l height_here -w width_here]"
  exit
}

# Constants
strategies=( "random_walk" "stationary" "teleportation" ) # For validation.
# Arguments parsing
while getopts "l:p:s:S:w:h" opt; do
  case "$opt" in
  l) height=$OPTARG ;;
  p) pauseInterval=$OPTARG ;;
  s) agent1Strategy=$OPTARG ;;
  S) agent2Strategy=$OPTARG ;;
  w) width=$OPTARG ;;
  h) print_usage
  esac
done
# Arguments validation
[ -z "$agent1Strategy" ] && print_error "Missing strategy_of_agent1."
[ -z "$agent2Strategy" ] && print_error "Missing strategy_of_agent2."
matchCount=0
for (( i=0; i<${#strategies[@]}; i++ )); do
  [ "$agent1Strategy" == "${strategies[i]}" ] && (( matchCount++ ))
  [ "$agent2Strategy" == "${strategies[i]}" ] && (( matchCount++ ))
done
[ $matchCount -ne 2 ] && print_error "A supplied strategy must be one of the values 'random_walk', 'teleportation', or 'stationary'!"
[ -z "$width" ] && width=$(tput cols) || customSize=true
[ -z "$height" ] && height=$(tput lines) || customSize=true
# Initialization commands
tput reset
# Initialization of internal variables
deltas=( -1 1 +$width -$width )
#resize -s $height $width
spaceSize=$(( width*height ))
space=() # The canvas as an array makes it easier to print, manipulate, and add while printing.
agent1Position="$(( RANDOM%spaceSize ))"
agent2Position="$(( RANDOM%spaceSize ))"
count=0
for (( i=0; i<$spaceSize; i++ )); do # Initializing Space
  space+=(".")
done
# Processing
while true; do
  space[$agent1Position]="."
  space[$agent2Position]="."
  function teleportation {
    echo "$(( RANDOM%spaceSize ))"
  }
  function random_walk {
    oldPosition=$1
    delta=${deltas[ RANDOM%${#deltas[@]} ]}
    [ $(( oldPosition%width )) -eq $(( width-1 )) ] && [ $delta -eq 1 ] && delta=0 # Right edge as a barrier.
    [ $(( oldPosition%width )) -eq 0 ] && [ $delta -eq -1 ] && delta=0 # Left edge as a barrier.
    newAgentPosition=$(( $oldPosition+$delta )) 
    [ $newAgentPosition -ge 0 ] && [ $newAgentPosition -lt $spaceSize ] &&  echo "$newAgentPosition" || echo $oldPosition
  }
  agent1Position=$($agent1Strategy $agent1Position)
  agent2Position=$($agent2Strategy $agent2Position)
  tput cup 0 0 # Faster than reset or clear.
  space[$agent1Position]="1"
  space[$agent2Position]="2"
  # Output
  if [ "$customSize" != "true" ]; then
    printf "%s" "${space[@]}" # Better flowing performance, as new line are free through text wrapping.
  else
    for (( i=0; i<$height; i++ )); do
      echo "${space[@]:$(( i*width  )):width}" # Printing each line individually to do new lines manually for a smaller canvas within the windwo. It is more convenient for the user than using the resize command.
    done
  fi
  (( count++ ))
  [ $agent1Position -eq $agent2Position ] && break
  [ ! -z "$pauseInterval" ] && sleep $pauseInterval
done
# Report
echo "Coincidence happened after $count movements!" 
