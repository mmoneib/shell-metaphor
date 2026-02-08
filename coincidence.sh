#!/bin/sh
#############################################################################################
# Coincidence                                                                               #                
#                                                                                           #
# A simple simulation which employs randomness to test the probability of an occurence of a #
# coincidence through 2 "free" agents moving within a confined plane.                       #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################
# TODO Check why problematic on Mac starting from l 4 and w 4. Takes much longer than expected.
# TODO Add strategies based on chess movements.
# TODO More than 2 agents?

function print_error {
  echo "ERROR: $1"
  print_usage
}

function print_help {
  printf "Stochastic simulation of coincidence occurring between two independent agents.\n"
  printf "Options:\n"
  printf "\tHeight (h): Height of the plane of movement.\n"
  printf "\tWidth (w): Width of the plane of movement.\n"
  printf "\tPause Interval (w): Time between each movement, in seconds.\n"
  printf "\tStrategy of Agent 1 (s): One of the strategy enumerations below.\n"
  printf "\tStrategy of Agent 2 (S): One of the strategy enumerations below.\n"
  printf "\tBlocks: Comma-separated list of blocked positions on the plane.\n"
  printf "Enumerations:\n"
  printf "\tStrategy:\n"
  printf "\t\trandom_walk: Agent moves in any of the 4 main directions free of boundaries in the plane with respect to his last position.\n"
  printf "\t\tstationary: Agent doesn't move.\n"
  printf "\t\tteleportation: Agent moves in any slot in the plane free of boundaries, indepent to his last position.\n"
  printf "Examples:\n"
  printf "\t$0 -l 10 -w 10 -s random_walk -S stationary -p 1\n"
  printf "\t$0 -l 10 -w 10 -s random_walk -S stationary -p 0.1 -b 1,2,3,5,7\n"
  print_usage
}

function print_usage {
  echo "USAGE: $0 -s strategy_of_agent1_here -S strategy_of_agent2_here -p pause_interval_here [-l height_here -w width_here -b blocks_list_here -r]"
  exit
}

# Constants
strategies=( "random_walk" "stationary" "teleportation" ) # For validation.
blockChar="█"
# Defaults
blocksList=""
# Arguments parsing
[ -z "$1" ] && print_usage
while getopts "b:l:p:s:S:w:rh" opt; do
  case "$opt" in
  b) blocksList=$OPTARG ;;
  l) height=$OPTARG ;;
  p) pauseInterval=$OPTARG ;;
  s) agent1Strategy=$OPTARG ;;
  S) agent2Strategy=$OPTARG ;;
  w) width=$OPTARG ;;
  r) isRawOutput=true ;;
  h) print_help ;;
  *) print_usage ;;
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
count=0
for (( i=0; i<$spaceSize; i++ )); do # Initializing Space
  space+=(".")
done
IFS=,; read -a blocksArr <<< "$blocksList"
for (( i=0;i<${#blocksArr[@]};i++ )); do
  blockIndex=${blocksArr[$i]}
  if [ $blockIndex -ge $spaceSize ]; then
    print_error "Block index $blockIndex does not lie on the plane. Please use an index less than $spaceSize."
  fi
  space[$blockIndex]="$blockChar"
done
agent1Position=$(( RANDOM%spaceSize ))
while [ "${space[agent1Position]}" == "$blockChar" ]; do
  agent1Position=$(( RANDOM%spaceSize ))
done
agent2Position=$(( RANDOM%spaceSize ))
while [ "${space[agent2Position]}" == "$blockChar" ]; do
  agent2Position=$(( RANDOM%spaceSize ))
done
# Processing
while true; do
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
  function stationary {
    oldPosition=$1
    echo $oldPosition
  }
  function teleportation {
    newAgentPosition=$(( RANDOM%$spaceSize ))
    echo $newAgentPosition
  }
  oldAgent1Position=$agent1Position
  agent1Position=$($agent1Strategy $oldAgent1Position)
  [ ${#blocksArr[@]} -gt 0 ] && [ "${space[agent1Position]}" == "$blockChar" ] && agent1Position=$oldAgent1Position
  oldAgent2Position=$agent2Position
  agent2Position=$($agent2Strategy $oldAgent2Position)
  [ ${#blocksArr[@]} -gt 0 ] && [ "${space[agent2Position]}" == "$blockChar" ] && agent2Position=$oldAgent2Position
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
  space[$agent1Position]="."
  space[$agent2Position]="."
  [ ! -z "$pauseInterval" ] && sleep $pauseInterval
done
# Report
if [ "$isRawOutput" != "true" ]; then
  echo "Coincidence happened at last!"
  template="Movements: %d -- Width: %d -- Height: %d -- Size: %d"
else
  echo "Count,Width,Height,Plane Size"
  template="%d,%d,%d,%d"
fi
printf "$template\n" $count $width $height $spaceSize
