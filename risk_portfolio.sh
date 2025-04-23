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
#TODO Add initial amount.
#TODO Add processing.
#TODO Make risks more fine tuned to include assymetrical win/loss potentials in addition to odds.

function print_usage {
  echo "USAGE: $0 -a allocations_here -c categories_here -r risks_here"
  echo "Example: $0 -a '10,20,30,40' -c 'A,B,C,D' -r '90,70,50,10'"
  exit
}

categories=""
risks=""
allocPerc=""
# Arguments parsing.
while getopts "a:c:r:h" opt; do
  case $opt in
    a) allocPerc="$OPTARG" ;;
    c) categories="$OPTARG" ;;
    r) risks="$OPTARG" ;;
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
[ ${#catsArr[@]} -ne ${#riskArr[@]} ] || [ ${riskArr[@]} -ne ${allocsArr[@]} ] && echo "ERROR: Number of categories, their associated risks, and their allocated percentages must be the same."
allocsSum=0
for (( i=0; i<${#allocsArr[@]}; i++ )); do
  allocsSum=$(( allocsSum+${allocsArr[$i]}  ))
done
[ $allocsSum -ne 100 ] && echo "ERROR: The sum of allocations must be equal to 100."
# Processing

