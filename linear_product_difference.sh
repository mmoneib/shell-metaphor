#!/bin/sh
#############################################################################################
# Linear Product DIfference                                                                 #                
#                                                                                           #
# Breakdown of a non-linear product to its linear basis         .                           #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

function print_usage {
  echo "USAGE: $0 -d differences_list_here -s starts_list_here -n iterations_count_here"
  echo "Examples:"
  printf "\t$0 -d 2,3 -s 1,1 -n 100\n"
  printf "\t$0 -d 2,3,5,11 -s 1,1,1,1 -n 100\n"
  exit
}

while getopts "d:n:s:h" o; do
  case $o in
  d) differences="$OPTARG" ;;
  n) numOfIterations="$OPTARG" ;;
  s) starts="$OPTARG" ;;
  *) print_usage ;;
  esac
done
[ -z "$differences" ] || [ -z "$starts" ] || [ -z "$numOfIterations" ] && print_usage

onLinearProduct=()
output=()
linearElements=()

startsArr=()
IFS=,; read -a startsArr <<< "$starts"
linearElementsArr=()
differencesArr=()
IFS=,; read -a differencesArr <<< "$differences"

for (( i=0;i<${#startsArr[@]};i++ )); do
  linearElementsArr[i]=${startsArr[i]}
done
count=0
while [ $count -lt $numOfIterations ]; do
  nonLinearProduct[count]=1 # Base for multiplication.
  for (( i=0;i<${#linearElementsArr[@]};i++ )); do
    nonLinearProduct[count]=$(( ${nonLinearProduct[count]}*${linearElementsArr[i]} ))
  done
  printf "DEBUG: " && printf '%s,' "${linearElementsArr[@]}" && printf '%s\n' "-- ${nonLinearProduct[count]}"
  for (( i=0;i<${#linearElementsArr[@]};i++ )); do
    linearElementsArr[i]=$(( ${linearElementsArr[i]}+${differencesArr[i]} ))
  done
  (( count++ ))
done
for (( i=1;i<${#nonLinearProduct[@]};i++ )); do
  output[i-1]=$(( ${nonLinearProduct[i]}-${nonLinearProduct[i-1]} ))
done
factorial=1
for (( i=1;i<=${#differencesArr[@]};i++ )); do
  factorial=$(( $factorial*i ))
done
expectedDifference=$(( $factorial ))
for (( i=0; i<${#differencesArr[@]}; i++ )); do
  expectedDifference=$(( $expectedDifference*${differencesArr[i]} ))
done
echo "Expected Common Difference of Linear Slopes = $expectedDifference"
echo "Non-Linear Product:"
printf "%s " "${nonLinearProduct[@]}"
echo
echo "Breakdown to Linearity:"
printf "%s " "${output[@]}"
echo
while [ ${#output[@]} -gt 1 ]; do
  secondOutput=()
  for (( i=1;i<${#output[@]};i++ )); do
    secondOutput[i]=$(( ${output[i]}-${output[i-1]} ))
  done
  printf "%s " "${secondOutput[@]}" && echo
  output=("${secondOutput[@]}")
  (( count++ ))
done
