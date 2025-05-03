#!/bin/sh
#############################################################################################
# Risk Portfolio                                                                            #                
#                                                                                           #
# A simple stochastic simulation of the performance of a prtfolio of different risks. Risk, #
# for simplicity, is represented as a percentage of volatility, which also acts as a        #
# to determine the outcome (for example, a risk of 90 has 10% chance of gaining 90% and 90% #
# of losing 90%).                                                                           #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################
#TODO Make risks more fine tuned to include assymetrical win/loss potentials in addition to odds.

function print_usage {
  echo "USAGE: $0 -a allocations_here -c categories_here -r risks_here"
  echo "Example: $0 -i 10000 -n 50 -a '10,20,30,40' -c 'A,B,C,D' -r '90,70,50,10'"
  exit
}

categories=""
risks=""
allocPerc=""
numOfIterations=100
# Arguments parsing.
while getopts "a:c:i:n:r:h" opt; do
  case $opt in
    a) allocPerc="$OPTARG" ;;
    c) categories="$OPTARG" ;;
    i) initialAmount="$OPTARG" ;;
    r) risks="$OPTARG" ;;
    n) numOfIterations="$OPTARG" ;;
    h) print_usage ;;
    *) print_usage ;;
  esac
done
# Arguments validation.
[ -z "$1" ] && print_usage
# Initialization of internal variables.
catsArr=()
risksArr=()
allocsArr=()
IFS=,; read -a catsArr <<< "$categories"
IFS=,; read -a risksArr <<< "$risks"
IFS=,; read -a allocsArr <<< "$allocPerc"
# Validation of internal variables.
[ ${#catsArr[@]} -ne ${#risksArr[@]} ] || [ ${#risksArr[@]} -ne ${#allocsArr[@]} ] && echo "ERROR: Number of categories, their associated risks, and their allocated percentages must be the same." && exit 1
allocsSum=0
for (( i=0; i<${#allocsArr[@]}; i++ )); do
  allocsSum=$(( allocsSum+${allocsArr[$i]}  ))
done
[ $allocsSum -ne 100 ] && echo "ERROR: The sum of allocations must be equal to 100."
# Processing
echo "Initial Amount = $initialAmount, to be allocated over ${#catsArr[@]} risk categories."
allocatedAmounts=()
allocsSize=${#allocsArr[@]}
for (( i=0; i<$allocsSize; i++ )); do
  allocatedAmounts[i]=$(echo "scale=2;$initialAmount*${allocsArr[$i]}/100"|bc -l)
done
allocationsStr=""
for (( i=0; i<${#allocatedAmounts[@]}; i++ )); do
  allocationsStr+="${catsArr[$i]}=${allocatedAmounts[$i]} -- "
done
echo "Iteration 0: $allocationsStr"
count=0
while [ $(( ++count )) -lt $numOfIterations ]; do
  allocationsStr=""
  for (( i=0; i<${#allocatedAmounts[@]}; i++ )); do
    amountOfCategory=${allocatedAmounts[i]}
    riskOfCategory=${risksArr[i]}
    [ $(( RANDOM%100 )) -ge $riskOfCategory ] && deltaFactor=1 || deltaFactor=-1
    allocatedAmounts[i]=$(echo "scale=2;$amountOfCategory+($deltaFactor*$amountOfCategory*$riskOfCategory)/100"|bc -l)
  allocationsStr+="${catsArr[$i]}=${allocatedAmounts[$i]} -- "
  done
  echo "Iteration $count: $allocationsStr"
done
