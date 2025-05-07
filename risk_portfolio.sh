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
#TODO Add template for echoing and raw output.
#TODO Add optional percentage of amount gained per iteration.
#TODO Add more examples.
#TODO Add recurrent additions to the amount.

function print_help {
  echo -e "A simple stochastic simulation of the performance of a prtfolio of different risks.
Required Parameters:
\tAllocated Percentages (a): A comma-separated-list of percentages to be allocated from the initial amount and corresponding to the risk categories. The sum must be 100.
\tCategories (c): Identifiers of the risk categories.
\tInitial Amount (i): The amount first put at risk; the base of the accumulation to come.
\tRisks (r): A comma-separated-list of the threshold percentage representing the risk and corresponding to the risk categories. The higher, the riskier.
Optional Parmeters:
\tGain Percentages (g): A comma-separated list of the percentage to be gained to the risked amount in case of successful risk. Defaults to the risk percentage.
\tLoss Percentages (l): A comma-separated list of the percentage to be lost from the risked amount in case of unsuccessful risk. Defaults to the risk percentage.  
\tNumber of Iternations (n): Number of times the accumulative amount is put at risk. Defaults to 100.
Examples:
# Simulating odds of bets.
$0 -i 1000 -a '25,25,25,25' -c 'o1%,o10%,o25%,o50%' -r '99,90,75,50' -g '9900,900,300,100' -l '100,100,100,100'"
  exit
}

function print_error {
  echo "ERROR: $1">&2
  exit 1
}


function print_usage {
  echo "USAGE: $0 -a allocations_here -c categories_here -r risks_here -n num_of_iterations_here [ -g gains_here -l losses_here ]"
  echo "Example: $0 -i 10000 -n 50 -a '10,20,30,40' -c 'A,B,C,D' -r '90,70,50,10' -n 50 -g '200,100,50,10' -l '50,30,20,10"
  exit
}

numOfIterations=100
# Arguments parsing.
while getopts "a:c:g:i:l:n:r:h" opt; do
  case $opt in
    a) allocPerc="$OPTARG" ;;
    c) categories="$OPTARG" ;;
    g) gains="$OPTARG" ;;
    i) initialAmount="$OPTARG" ;;
    l) losses="$OPTARG" ;;
    r) risks="$OPTARG" ;;
    n) numOfIterations="$OPTARG" ;;
    h) print_help ;;
    *) print_usage ;;
  esac
done
# Arguments validation.
[ -z "$1" ] && print_usage
[ -z "$allocPerc" ] && print_error "Missing required parameter Allocated Percentages (a)."
[ -z "$categories" ] && print_error "Missing required parameter Categories (c)."
[ -z "$risks" ] && print_error "Missing required parameter Risks (r)."
[ -z "$gains" ] && gains="$risks"
[ -z "$losses" ] && losses="$risks"
# Initialization of internal variables.
allocsArr=()
catsArr=()
risksArr=()
gainsArr=()
lossesArr=()
IFS=,; read -a allocsArr <<< "$allocPerc"
IFS=,; read -a catsArr <<< "$categories"
IFS=,; read -a risksArr <<< "$risks"
IFS=,; read -a gainsArr <<< "$gains"
IFS=,; read -a lossesArr <<< "$losses"
# Validation of internal variables.
[ ${#catsArr[@]} -ne ${#risksArr[@]} ] || [ ${#risksArr[@]} -ne ${#allocsArr[@]} ] && print_error "Number of categories, their associated risks, and their allocated percentages must be the same."
allocsSum=0
for (( i=0; i<${#allocsArr[@]}; i++ )); do
  allocsSum=$(( allocsSum+${allocsArr[$i]}  ))
done
[ $allocsSum -ne 100 ] && print_error "The sum of allocated percentages must be equal to 100."
# Processing
echo "Initial Amount = $initialAmount, to be allocated over ${#catsArr[@]} risk categories."
allocatedAmounts=()
allocsSize=${#allocsArr[@]}
for (( i=0; i<$allocsSize; i++ )); do # Preparation of initial amounts per category.
  allocatedAmounts[i]=$(printf %.2f $(echo "scale=2;$initialAmount*${allocsArr[$i]}/100"|bc -l))
done
allocationsStr=""
totalAllocations=0
for (( i=0; i<${#allocatedAmounts[@]}; i++ )); do
  allocationsStr+="${catsArr[$i]}=${allocatedAmounts[$i]} -- "
done
totalAllocations=$initialAmount
allocationsStr+="Total=$totalAllocations"
echo "Iteration 0: $allocationsStr"
count=0
while [ $(( ++count )) -lt $numOfIterations ]; do
  allocationsStr=""
  totalAllocations=0
  totalAllocationsEquation="0" # Used to prepare the statement to be calculated by 'bc'; reduces expensive calls.
  for (( i=0; i<${#allocatedAmounts[@]}; i++ )); do
    amountOfCategory=${allocatedAmounts[i]}
    riskOfCategory=${risksArr[i]}
    [ $(( RANDOM%100 )) -ge $riskOfCategory ] && delta="(1*${gainsArr[$i]})" || delta="(-1*${lossesArr[$i]})"
    allocatedAmounts[i]=$(printf %.2f $(echo "scale=2;$amountOfCategory+($amountOfCategory*$delta)/100"|bc -l))
    allocationsStr+="${catsArr[$i]}=${allocatedAmounts[$i]} -- "
    totalAllocationsEquation+="+${allocatedAmounts[$i]}"
  done
  totalAllocations=$(printf %.2f "$(echo "scale=2;$totalAllocationsEquation"|bc -l)" )
  allocationsStr+="total=$totalAllocations"
  echo "Iteration $count: $allocationsStr"|sed 's/ -- $//g'
done
