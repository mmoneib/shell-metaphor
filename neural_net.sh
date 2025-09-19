#!/bin/sh

function print_usage {
  echo "USAGE: $0 -i input_here [-a active_function_name_here -j weight_adjust_function_name_here -l loss_function_name_here -t train_batches_number_by_size -w weights_csv_here]" && exit 1
}

# Activation Functions
function perceptron_activation {
  echo $1
}
function sigmoid_activation {
  factor="0.5" # TODO: Determine values.
  echo "scale=3;$1*$factor|bc -l"
}
function relU_activation {
  [ $1 -lt 0 ] && echo 0 || echo $1
}
# Loss Functions
function deviation_loss {
  got="$1"
  expected="$2"
  dev=$(( $got-$expected ))
  [ $dev -lt 0 ] && dev=$(( -1*$dev ))
  echo $dev
}
# Weight Adjustment Functions
function random_weight_adjust {
  weight=$1
  adjustment=$2
  [ 0 -eq $(( RANDOM%2 )) ] && echo "$(( $weight-$adjustment ))" || echo "$(( $weight+$adjustment ))"
}
# Thinking Funciton
function think {
  inp=$1
  inp=$(( 10#$inp )) # To force base 10 in case of leading 0.
  node1Out=$($activeFunc $(( $inp*$node1W )) )
  node21Out=$($activeFunc $(( $node1Out*$node21W )))
  node22Out=$($activeFunc $(( $node1Out*$node22W )))
  node31Out=$($activeFunc $(( $node21Out*$node31W + $node22Out*$node31W )))
  node32Out=$($activeFunc $(( $node21Out*$node32W + $node22Out*$node32W )))
  thinkOutput=$($activeFunc $(( $node31Out*$node4W + $node32Out*$node4W )))
  echo $thinkOutput
}

input=
goodExamples=()
goodOutcome=100
badExamples=()
badOutcome=-20
# Choose
while getopts "a:i:j:l:t:w:h" o; do
  case $o in
  a) activeFunc="$OPTARG""_activation" ;;
  i) input="$OPTARG" ;;
  j) wAdjustFunc="$OPTARG""_weight_adjust" ;;
  l) lossFunc="$OPTARG""_loss" ;;
  t) trainBatchNumSize="$OPTARG" ;;
  w) weightsStr="$OPTARG" ;;
  h) print_usage ;;
  *) print_usage ;;
  esac
done
[ -z "$input" ] && print_usage
trainBatchNum="$(echo $trainBatchNumSize|cut -d '*' -f 1)"
trainBatchSize="$(echo $trainBatchNumSize|cut -d '*' -f 2)"
[ -z "$weightsStr" ] && weightsStr="$(cat $neural_net_weights)"
[ -z "$weightsStr" ] && weightsStr=(0 0 0 0 0 0) || IFS=,; read -a weightsArr <<< "$weightsStr" 
[ "${#weightsArr[@]}" != "6" ] && echo "ERROR: Number of weights must be 6." && print_usage
# Read
node1W=${weightsArr[0]}
node21W=${weightsArr[1]}
node22W=${weightsArr[2]}
node31W=${weightsArr[3]}
node32W=${weightsArr[4]}
node4W=${weightsArr[5]}
# Train
if [ ! -z "$trainBatchNumSize" ]; then
  echo "BEGIN OF TRAINING"
  echo "Supervised training the neural network is about to start with $trainBatchNum batche(s), each of size equals $trainBatchSize..."
  ## Generate Examples
  ### Good Examples
  goodExampleCount=1000
  echo "Generating $goodExampleCount good examples."
  count=0
  while [ $count -lt $goodExampleCount ]; do
    reps=$(( RANDOM%11 + 1 ))
    char=$(( RANDOM%10 ))
    example=""
    for (( i=0;i<$reps;i++ )); do
      example+="$char"
    done
    goodExamples[$count]="$example"
    #echo $example
    (( count++ ))
  done
  ### Bad Examples
  badExampleCount=10000
  echo "Generating $badExampleCount bad examples."
  count=0
  while [ $count -lt $badExampleCount ]; do
    reps=$(( RANDOM%11 + 1 ))
    example=""
    chosen=
    for (( i=0;i<$reps;i++ )); do
      char=$(( RANDOM%10 ))
      [ -z "$chosen" ] && [ $char -eq 0 ] && char=1 
      [ -z "$chosen" ] && [ $char -ne 0 ] && char=$(( $char-1 )) # To insure at least one char is different.
      [ -z "$chosen" ] && chosen=$char
      example+="$char"
    done
    badExamples[$count]="$example"
    #echo "$example"
    (( count++ ))
  done
  batchCount=0
  oldAccLoss=9999999
  oldNode1W=0
  oldNode21W=0
  oldNode22W=0
  oldNode31W=0
  oldNode32W=0
  oldNode4W=0
  while [ $batchCount -lt $trainBatchNum ]; do
    ## Train on Examples
    trainedCount=0
      accLoss=0
    while [ $trainedCount -lt $trainBatchSize ]; do
      echo "Training Batch $batchCount, Example $trainedCount..."
      ### Train on Good Example
      index=$(( RANDOM%${#goodExamples[@]} ))
      example=${goodExamples[$index]}
      echo "Good: $example"
      thought=$(think $example)
  echo "Think: $thought Example: $example Weights: $node1W $node21W $node22W $node31W $node32W $node4W "
      accLoss=$(( $accLoss+$($lossFunc $thought $goodOutcome) ))
echo "A $accLoss"
      (( trainedCount++ ))
      ### Train on Bad Example
      index=$(( RANDOM%${#badExamples[@]} ))
      example=${badExamples[$index]}
      echo "Bad: $example"
      thought=$(think $example)
      accLoss=$(( $accLoss+$($lossFunc $thought $badOutcome) ))
echo "B $accLoss"
      (( trainedCount++ ))
    done
    if [ $accLoss -ge $oldAccLoss ]; then
      node1W="$oldNode1W"
      node21W="$oldNode21W"
      node22W="$oldNode22W"
      node31W="$oldNode31W"
      node32W="$oldNode32W"
      node4W="$oldNode4W"
      echo "Reverted to old weights due to lack of progress in reducing loss."
    else
      oldAccLoss=$accLoss
      echo "Acc Loss: $accLoss"
    fi
    ## Adjust Weights
    oldNode1W=$node1W
    oldNode21W=$node21W
    oldNode22W=$node22W
    oldNode31W=$node31W
    oldNode32W=$node32W
    oldNode4W=$node4W
    node1W="$($wAdjustFunc $node1W 1)"
    node21W="$($wAdjustFunc $node21W 1)"
    node22W="$($wAdjustFunc $node22W 1)"
    node31W="$($wAdjustFunc $node31W 1)"
    node32W="$($wAdjustFunc $node32W 1)"
    node4W="$($wAdjustFunc $node4W 1)"
    echo "New Weights: $node1W $node21W $node22W $node31W $node32W $node4W"
    (( batchCount++ ))
  done
  echo "END OF TRAINING"
fi
# Think
echo "$(think $input)"
