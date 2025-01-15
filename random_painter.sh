#!/bin/sh
#############################################################################################
# Random Painter                                                                            #                
#                                                                                           #
# A visual demonstration of randomness and its relation to the evolution of organic shapes. #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################
#TODO Random mode with random emptiness.
#TODO Add pause by input.
#TODO Add obstacles to be avoided by the generation.

function print_usage {
  echo "USAGE: $0 -l height_here -w width_here -c charset_here -p percentage_of_emptiness [ -e emptiness_char_here -s is_sticky_here -t pause_in_seconds ]"
  exit
}

# Arguments parsing.
while getopts "c:e:i:l:p:st:w:" opt; do
  case $opt in
  c) charset=$OPTARG ;;
  e) emptinessChar=$OPTARG ;;
  l) height=$OPTARG ;;
  p) percentageOfEmptiness=$OPTARG ;;
  s) isSticky="true" ;;
  t) stopTimeBetweenFrames=$OPTARG ;;
  w) width=$OPTARG ;;
  h) print_usage ;;
  *) print_usage ;;
  esac
done
# Arguments validation.
[ -z "$1" ] && print_usage
[ -z "charset" ] && print_usage
[ -z "$height" ] && print_usage
[ -z "$percentageOfEmptiness" ] && print_usage
[ -z "$stopTimeBetweenFrames" = && stopTimeBetweenFrames=0
[ -z "$width" ] && print_usage
[ -z "$isSticky" ] && isSticky="false"
[ -z "$emptinessChar" ] && IFS=; emptinessChar=" " # IFS is unset for the variable assignation so as to correctly interpret the empty space as an empty space.
# Initialization commands
tput reset # Initializes the screen, to avoid leftovers from previous processes.
trap clear EXIT # CLean after exit.
# Initialization of internal variables.
frameSize=$(( width*height ))
numOfEmptyChars=$(echo "$frameSize*$percentageOfEmptiness/100"|bc) # Turning percentage into characters.
pallette="" # Calculated expansion of charset with inclusion of the number of empty chars corresponding to the provided percentage.
while [ ${#pallette} -lt $(( frameSize-numOfEmptyChars )) ]; do # Repeating the charset into a pallete where the percentage is meaningful.
  pallette+="$charset"
done
for (( i=0; i<numOfEmptyChars; i++ )); do
  pallette+="$emptinessChar"
done
canvas=()  # Array because there are lots of indexed retrieval involved, which are too expensive using string parsing.
stickies=() # The chars to persist over the frames. Maintaining that as an array outside canvas reduces complexity and improves performance.
for (( p=0; p<frameSize; p++ )); do # Needed to streamline the rules.
  stickies[$p]=" "
done
o_canvas="" # Mainly to add new lines. Maintaining that as an array outside canvas reduces complexity and improves performance.
# Processing
while true; do
  canvas=()
  o_canvas=""
  tput cup 0 0 # No flickering like 'tput reset'.
  for (( l=0; l<height; l++ )); do
    for (( p=0; p<width; p++ )); do
      # Rendering rules
      [ "$isSticky" == "true" ] && [ "${stickies[(( (l*width)+p ))]}" == " " ] && char="${pallette:$(( RANDOM%${#pallette} )):1}" || char="${stickies[(( (l*width)+p ))]}"
      [ "$isSticky" == "false" ] && char="${pallette:$(( RANDOM%${#pallette} )):1}" 
      canvas[l*width+p]="$char"
      o_canvas+="$char"
    done
    o_canvas+="\n"
  done
  if [ "$isSticky" == "true" ]; then
  # Stickiness rules
  for (( p=0;p<frameSize;p++ )); do
      [ $p -lt $width ] && charUp=" " || charUp=${canvas[(( p-width ))]} 
      [ $p -ge $(( frameSize-width )) ] && charDown=" " || charDown=${canvas[(( p+width ))]}
      [ $(( p%width )) -eq 0 ] && charLeft=" " || charLeft=${canvas[(( p-1 ))]}
      [ $(( p%(width-1) )) -eq 0 ] && charRight=" " || charRight=${canvas[(( p+1 ))]}
     if [ "$charLeft" != " " ] ||  [ "$charRight" != " " ] || [ "$charUp" != " " ] || [ "$charDown" != " " ]; then
        stickies[$p]="${canvas[$p]}"
      else
       stickies[$p]=" "
      fi
   done
  fi
  # Output
  printf "$o_canvas"
  sleep $stopTimeBetweenFrames
done
