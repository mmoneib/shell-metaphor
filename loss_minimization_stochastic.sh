#!/bin/sh
################################################################################
# Stochastic Loss Minimization                                                 #
#                                                                              #
# A simple stochastic simulation of iterative minimization of loss for any     #
# affine function. The function is in the form of c1*a+c2*b+...+c.             #
#                                                                              #
# Conceptualized and developed by: Muhammad Moneib                             #
################################################################################

#TODO Add documentation
#TODO Add more strategies to variable adjustment.
#TODO Add multiplied variables (like x*y).
#TODO Script for linear regression absed on input table of independent/dependent pair of variables.
function __print_usage {
  echo "$0 -c coefficients_list_here -e expected_output_here -n num_of_runs_here"
  echo "Example: $0 -c 2,1,4,7 -e 13 -n 1000"
  exit
}

isVerbose=0
[ -z $1 ] && __print_usage
while getopts "c:e:n:v" o; do
  case $o in
  c) coefficientsList=$OPTARG ;;
  e) expectedY=$OPTARG ;;
  n) numOfRuns=$OPTARG ;;
  v) isVerbose=1 ;;
  *) __print+usage ;;
  esac
done
IFS=,; read -a coefficientsArr <<< "$coefficientsList"
numOfVariables=$(( ${#coefficientsArr[@]}-1 )) # Variables + Constant --> Coefficients.
[ -z $numOfRuns ] && __print_usage

function x { 
  sign=$(( RANDOM%2 ))
  [ $sign -eq 0 ] && sign=-1
  echo $(( RANDOM%100 * sign )) 
}
res=0
loss=9999999999999999
for (( count=0; count<$numOfRuns; count++ )); do
  vars=()
  lastVars=()
  eq=""
  for (( i=0; i<$numOfVariables; i++ )); do
    lastVars[i]=${vars[i]}
    var=$(x)
    vars[i]=$var
    eq+="${coefficientsArr[i]}*$var+"
  done
  eq+="${coefficientsArr[$numOfVariables]}"
  res=$(( $(echo $eq) ))
  lastLoss=$loss
  [ $loss -eq 0 ] && echo "Optimum solution found. No further loss minimization is possible." && break
  loss=$(( expectedY-res ))
  [ $loss -lt 0 ] && loss=$((  $loss*-1 )) # abs
  if [ $loss -lt $lastLoss ]; then
    lastMinimizationStr="Iteration: $count -- Equation: $eq -- Result: $res -- Loss: $loss"
    echo $lastMinimizationStr
  else
    loss=$lastLoss
    for (( i=0; i<$numOfVariables; i++ )); do
      vars[i]=${lastVars[i]}
    done
    [ $isVerbose -eq 1 ] && echo "Iteration: $count -- Skipped..."
  fi
done
echo "Last Successful Minimization: $lastMinimizationStr"
