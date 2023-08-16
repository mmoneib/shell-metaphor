#!/bin/sh
################################################################################
# Skill vs. Luck with Geometric Progression                                    #
#                                                                              #
# A Monte Carlo simulation of the balance required in life (and a casino) for  #
# successful geometric progression.                                            #
#                                                                              #
# Conceptualized and developed by: Muhammad Moneib                             #
################################################################################

function print_help {
  echo "Skill vs. Luck with Geometric Progression: A Monte Carlo simulation of the balance required in life (and a casino) for successful geometric progression.
Required Parameters:
\tStarting Amount: The inherited amount to start with.
\tBets: The successive weights assigned to each decision until a successful one, constituting a weighted, geometric progression.
\tAccuracy: The probability of a suscessful decision.
Example:
./skill_vs_luck_with_geometric_progression.sh -s 100 -a 55 -b \"0.1 0.3 0.5 0.7 0.9\""
}

while getopts "hs:b:a:" o; do
  case $o in
    s) startingAmount=$OPTARG ;;
    b) bets=($OPTARG) ;;
    a) accuracy=$OPTARG ;;
    *) print_help ;;
  esac
done
[ -z $startingAmount ] && print_help && exit

invAccuracy=$((100-accuracy))
amount=$startingAmount
currBetIndex=0
count=0
echo "Starting Amount: $startingAmount."
echo "Bets: ${bets[@]}."
echo "Accuracy: $accuracy."
echo "Started betting..."
while [ $(echo "$amount>1"|bc) -eq 1 ]; do
  printf "Iteration %d: " "$count"
  choice=$((RANDOM%100))
  printf "Choice=%d, " "$choice"
  perc=${bets[currBetIndex]}
  printf "Delta=%f, " "$perc"
  [ $choice -ge $invAccuracy ] && amount=$(echo "scale=6;$amount+$amount*$perc" | bc -l) && currBetIndex=0 
  [ $choice -lt $invAccuracy ] && amount=$(echo "scale=6;$amount-$amount*$perc" | bc -l) && currBetIndex=$(((currBetIndex+1)%${#bets[@]}))
  printf "Amount=%f.\n" "$amount"
  count=$((count+1))
done
echo "Ended with bankruptcy."
