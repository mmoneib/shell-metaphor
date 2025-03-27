#!/bin/sh
#############################################################################################
# Toritoise and Hare                                                                        #                
#                                                                                           #
# The fable of The Tortoise and the Hare is a subtle take on the importance of consistency  #
# in addition to speed. For this Monte Carlo simulation, which is designed to analyze thi   #
# moral under different behaviours, I substtitute the napping of the Hare with a property I #
# call "jumpiness", which is a measure of the tendency of the Hare to move in the wrong     #
# direction. The Tortoise has an opposing property, "steadiness", which is a measure of its #
# consistency in moving forward.                                                            #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

function print_usage {
  echo "USAGE: $0 -l race_length_here -h hare_speed_here -j hare_jumpiness_here -t tortoise_speed_here -s tortoise_steadiness_here"
  echo "EXAMPLE: $0 -l 100 -h 4 -j 70 -t 1 -s 90"
  exit
}

[ -z $1 ] && print_usage

while getopts "h:l:t:s:j:" inp; do
  case $inp in
    h) hareSpeed=$OPTARG ;;
    l) raceLength=$OPTARG ;;
    t) tortoiseSpeed=$OPTARG ;;
    s) tortoiseSteadiness=$OPTARG ;;
    j) hareJumpiness=$OPTARG ;;
    *) print_usage
  esac
done

tortoisePlace=0
harePlace=0

echo "Once upon a time there was a hare amd there was a tortoise."
echo "They both decided to have a race."
count=0
while [ $tortoisePlace -lt $raceLength ] && [ $harePlace -lt $raceLength ]; do
  [ $(( RANDOM%100 )) -ge $tortoiseSteadiness ] && tortoisePlace=$(( tortoisePlace-tortoiseSpeed )) || tortoisePlace=$(( tortoisePlace+tortoiseSpeed ))
  [ $(( RANDOM%100 )) -ge $hareJumpiness ] && harePlace=$(( harePlace+hareSpeed )) || harePlace=$(( harePlace-hareSpeed )) 
  [ $tortoisePlace -lt 0 ] && tortoisePlace=0
  [ $harePlace -lt 0 ] && harePlace=0
  (( count++ ))
  echo "After $count units of time, the hare moved to place number $harePlace and the tortoise moved to place number $tortoisePlace."
done
[ $tortoisePlace -eq $harePlace ] && echo "Finally, it was a tie between them. They both lived happily ever after, separately." && exit
[ $tortoisePlace -ge $raceLength ] && echo "Finally, the tortoise emerged vicrotious against all expectations. Jumpiness is definitely not worthwhile." && exit
echo "Finally, the hare emerged vicrotious as expected. Jumpiness, despite the bad reputation, is definitely better than slowness." 
