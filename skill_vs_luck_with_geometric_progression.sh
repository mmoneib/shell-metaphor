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
  echo -e "Skill vs. Luck with Geometric Progression: A Monte Carlo simulation of the balance required in life (and a casino) for successful geometric progression.
Required Parameters:
\tStart Amount (s): The inherited amount to start with.
\tBets (b): If assignation is sequential, it is the successive weights assigned to each decision until a successful one, constituting a weighted, geometric progression. If not, the weights are assigned at random.  All bets should positive in case of AppliedSign set to 'random'.
\tAssignation (g): The assignation of bets, either 'sequential' or 'random'.
\tAppliedSign (p): If 'fixed', the polarity of the geometric progression is dependant on the sign of the bet. If 'random', the probability of a positive progression will depend on the accuracy.
Optional Parmeters:
\tAccuracy (a): The probability of a suscessful decision. Only applicable for 'random' AppliedSign.
\tExit Amount (x): The amount at which the simulation ends.
Examples:
# Explicit skill quantification through a threshold of succes with luck modelled by unbiased randomness and progress through sequential scaling.
./skill_vs_luck_with_geometric_progression.sh -s 100 -a 55 -b \"0.1 0.3 0.5 0.7 0.9\" -g sequential -p random -x 1000000
# Implicit skill representation through enumeration of choices of geometric coefficient with luck qualified by a random choice among them.
./skill_vs_luck_with_geometric_progression.sh -s 100 -b \"0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 -0.4\" -g random -p fixed -x 100000
# Chaotic intertwining of skill and luck through explicit, quantified skill threshold and progressing through a random choice among geometric coefficients.
./skill_vs_luck_with_geometric_progression.sh -s 100 -a 55 -b \"0.1 0.3 0.5 0.7 0.9\" -g random -p random -x 1000000"
  exit
}

function print_error {
  echo "$1">&2
  exit 1
}

while getopts "hs:b:a:x:g:p:" o; do
  case $o in
    s) startAmount=$OPTARG ;;
    b) bets=($OPTARG) ;;
    a) accuracy=$OPTARG ;;
    x) exitAmount=$OPTARG ;;
    g) assignation=$OPTARG ;;
    p) appliedSign=$OPTARG ;;
    *) print_help ;;
  esac
done
[ -z $startAmount ] && print_help && exit
[ "$assignation" == "sequential" ] || [ "$assignation" == "random" ] || print_error "The parameter 'assignation' is required and set to either 'sequential' or 'random'."
[ "$appliedSign" == "fixed" ] || [ "$appliedSign" == "random" ] || print_error "The parameter 'appliedSign' is required and set to either 'fixed' or 'random'."
[ "$appliedSign" == "random" ] && [ -z "$accuracy" ] && print_error "The parameter 'accuracy' is required when 'aapliedSign' is set to 'random'."
[ "$appliedSign" == "fixed" ] && [ -z "$assignation" == "sequential" ] && print_error "The combination of the parameters 'assignation' set 'sequential' and 'appliedSign' set to 'fixed' is not allowed."

invAccuracy=$((100-accuracy))
amount=$startAmount
currBetIndex=0
count=0
echo "Starting Amount: $startAmount."
echo "Bets: ${bets[@]}."
echo "Accuracy: $accuracy."
echo "Assignation: $assignation."
echo "Applied Sign: $appliedSign."
echo "Started betting..."
while [ $(echo "$amount>1"|bc) -eq 1 ]; do
  sign=1
  [ "$assignation" == "random" ] && currBetIndex=$(echo $RANDOM%${#bets[@]}) 
  perc=${bets[currBetIndex]}
  [ "$appliedSign" == "fixed" ] && [ "$(echo "$perc>0"|bc)" == "1" ] && choice=$((invAccuracy+1)) || choice=$((invAccuracy-1))
  [ "$appliedSign" == "random" ] && choice=$((RANDOM%100))
  [ "$assignation" == "sequential" ] && [ $choice -ge $invAccuracy ] && currBetIndex=0 
  [ "$assignation" == "sequential" ] && [ $choice -lt $invAccuracy ] && sign=-1 && currBetIndex=$(((currBetIndex+1)%${#bets[@]}))
  amount=$(echo "scale=6;$amount+$amount*$perc*$sign" | bc -l) 
  printf "Iteration %d: Choice=%d, Delta=%f, Amount=%f.\n" "$count" "$choice" "$(echo "0+$perc*$sign"|bc -l)" "$amount"
  [ ! -z $exitAmount ] && [ $(echo "$exitAmount<=$amount"| bc) -eq 1 ] && exit
  count=$((count+1))
done
echo "Ended with bankruptcy."
