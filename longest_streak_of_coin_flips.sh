#!/bin/sh
################################################################################
# Longest Streak of Coin Flips                                                 #
#                                                                              #
# A simple simulation of coin flips with a report over the longest streaks of  #
# Heads or Tails as a measure of development of spontaneous trends.            #
#                                                                              #
# Conceptualized and developed by: Muhammad Moneib                             #
################################################################################

function print_help {
  echo -e "Longest Streak of Coin Flips: A simple simulation of coin flips with a report over the longest streaks of Heads or Tails as a measure of development of spontaneous trends.
Required Parameters:
\tStart Number of Flips (n): The number of consecutive flips of a coin.
Optional Parmeters:
\tIs Raw Output? (r): If present, the ouput will be CSV in the form of FlipRun,LongestStreakOfH,LongestStreakOfT.
Examples:
# Flipping a fair coin 1000 times.
$0 -n 1000"
  exit
}

function print_error {
  echo "$1">&2
  exit 1
}

while getopts "n:rh" c; do
  case $c in
  n) numOfFlips=$OPTARG ;;
  r) isRawOutput=1 ;;
  h) print_help ;;
  *) print_help ;;
  esac
done

[ -z $numOfFlips ] && print_error "ERROR: The parameter Number of Flips (n) is required." && exit 1 

function searchStreak {
  longestStreak=0
  streak=0
  while true; do
    streak=$(( streak+1  ))
    criterion=""
    for (( i=0; i< $streak; i++ )); do
      criterion+="$1"
    done
    searchResult=$(echo "$flipRun" | grep "$criterion")
    [ -z "$searchResult" ] && longestStreak=$(( streak-1 )) && break
  done
  echo $longestStreak
}

flipRun=""
while [ $numOfFlips -gt 0 ]; do
  [ $(( RANDOM % 2 )) -eq 1 ] && flip="H" || flip="T"
  flipRun+="$flip"
  numOfFlips=$(( numOfFlips - 1 ))
done
longestStreakOfH="$(searchStreak H)"
longestStreakOfT="$(searchStreak T)"

if [ -z $isRawOutput ]; then
  outputTemplate="Flip Run: %s\nLongest streak of H: %s\nLongest streak of T: %s\n"
else
  outputTemplate="%s,%s,%s\n"
fi
printf "$outputTemplate" "$flipRun" "$longestStreakOfH" "$longestStreakOfT"
