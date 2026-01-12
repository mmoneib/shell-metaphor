#!/bin/sh
################################################################################
# Stochastic Fitting Loss Minimization                                         #
#                                                                              #
# A simple script to fit a curve to provided data points and their             #
# corresponding expected outputs using loss minimization technique in          #
# combination with stochastic progression.                                     #
#                                                                              #
# Conceptualized and developed by: Muhammad Moneib                             #
################################################################################

# Configuration
## Support Functions
function __print_usage {
  echo "$0 -i inputs_list_here -n num_of_runs_here -o outputs_expected_list_here"
  echo "Example: $0 -i 1,2,3,4 -o 4,7,10,13 -n 1000"
  exit
}
## Fallback
[ -z $1 ] && __print_usage
## Defaults
isVerbose=0
## Inputs
while getopts "d:i:n:o:v" o; do
  case $o in
  i) inputsList=$OPTARG ;;
  n) numOfRuns=$OPTARG ;;
  o) outputsList=$OPTARG ;;
  v) isVerbose=1 ;;
  *) __print+usage ;;
  esac
done
IFS=,; read -a inputsArr <<< "$inputsList"
IFS=,; read -a outputsArr <<< "$outputsList"
numOfInputs=${#inputsArr[@]} 
## Validation
[ -z $numOfRuns ] && __print_usage
[ $numOfInputs -ne ${#outputsArr[@]} ] && echo "ERROR: Number ov inputs must be the same as that of outputs." && exit 1

# Processing
## Support Functions
function random_parameter { 
  sign=$(( RANDOM%2 ))
  [ $sign -eq 0 ] && sign=-1
  echo $(( RANDOM%100 * sign )) 
}

## Defaults
numOfParams=1

loss=9999999999999999
params=()
## Engine
for (( count=0; count<$numOfRuns; count++ )); do
  ### Initialization
  errors=()
  lastParams=()
  for (( pi=0;pi<$numOfParams;pi++ )); do
    lastParams[pi]=${params[pi]}
    param=$(random_parameter)
    params[pi]=$param 
  done
  interceptor=$(random_parameter)
  ### Equation Build Up
  for (( i=0; i<$numOfInputs; i++ )); do
    #### Evaluate Equation
    y=$(( ${param[0]}*${inputsArr[$i]}+$interceptor )) # Assume linear fitting. TODO: Support higher orders based on numOfParams.
#echo " y=${param[0]}*${inputsArr[$i]}+$interceptor"
    #### Error Calculation
    errorToAdd=$(( $y-${outputsArr[$i]} ))
    errors[i]=$errorToAdd
  done
  ### Loss Calculation
  lastLoss=$loss
  [ $loss -eq 0 ] && echo "Optimum solution found. No further loss minimization is possible." && break
  loss=0
  for (( ei=0;ei<${#errors[@]};ei++ )); do
    error=${errors[$ei]}
    [ $error -lt 0 ] && error=$(( $error*-1 )) # abs.
    loss=$(( $loss+$error ))
  done
  if [ $loss -lt $lastLoss ]; then
    #### Loss Improvement
    lastMinimizationStr="Iteration: $count -- Loss: $loss -- Parameters: ${params[@]} -- Interceptor: $interceptor"
    echo $lastMinimizationStr
  else
    #### Loss Fallback
    loss=$lastLoss
    for (( i=0; i<$numOfParams; i++ )); do
      params[i]=${lastParams[i]}
    done
    [ $isVerbose -eq 1 ] && echo "Iteration: $count -- Skipped..."
  fi
done
echo "Last Successful Minimization: $lastMinimizationStr"
