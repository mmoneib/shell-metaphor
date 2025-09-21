#!/bin/sh

#TODO: Add multiplier of weight adjustments to simulate steps.
# Maintaining batch of training is not so useful if random picking is to be employed. But maybe it speeds up things.
# Resuming training will not yield the same last accLoss because it will start at a different place in the training set.
# TODO Maintain full state of training procedure including positions. 

function print_usage {
  echo "USAGE: $0 -i input_here [-a active_function_name_here -j weight_adjust_function_name_here -l loss_function_name_here -p training_files_path_here -t train_batches_number_by_size_here -w weights_csv_here]"
  echo "Examples:"
  echo -e "\t$0 -i 22222 -a perceptron -j randomJump -l deviation -p '$HOME' -t 100*100 -w 1,1,1,1,1,1,1"
  exit 1
}

function calc {
  printf '%.2f' "$(echo $1|bc -l)"
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
  inp=$1
  if [ "$(echo "$inp<0"|bc)" -eq 1 ]; then
    ramp="-0.1"
    inp=1
  else
    ramp="$(calc "$inp/100+1" )"
  fi
  echo "$(calc "$ramp*$inp" )"
}
# Loss Functions
function deviation_loss {
  got="$1"
  expected="$2"
  dev="$(calc "$got-$expected")"
  [ "$(echo "$dev<0"|bc)" -eq 1 ] && dev="$(calc "-1*$dev" )"
  #echo "DEV: $dev" >&2
  echo $dev
}
fibChoices=( "0.1" "0.2" "0.3" "0.5" "0.8" "0.13" "0.21" "0.34" "0.55" )
# Weight Adjustment Functions
function fibRandomWalk_weight_adjust {
  weight=$1
  choice=${fibChoices[$(( RANDOM%${#fibChoices[@]} ))]}
  newWeight=0
  while [ $(echo "$newWeight==0"|bc) -eq 1 ]; do
    [ 0 -eq $(( RANDOM%2 )) ] && newWeight="$(calc "$weight-$choice" )" || newWeight="$(calc "$weight+$choice" )"
  done
  echo "$newWeight"
}
maxJump=1000
function randomJump_weight_adjust {
  weight=$1
  choice=$(( RANDOM%$maxJump ))
  newWeight=0
  while [ $newWeight -eq 0 ]; do
    [ 0 -eq $(( RANDOM%2 )) ] && newWeight="$(calc "$weight-$choice" )" || newWeight="$(calc "$weight+$choice" )"
  done
  echo "$newWeight"
}
function randomGuess_weight_adjust {
  echo "$(calc "$(( RANDOM%200-100 ))/100")"
}
# Thinking Funciton
function think {
  inp=$1
  inp=$(( 10#$inp )) # To force base 10 in case of leading 0.
  node1Out="$($activeFunc "$(calc "$inp*$node1W+1" )" )"
  node21Out="$($activeFunc "$(calc "$node1Out*$node21W + 2" )" )"
  node22Out="$($activeFunc "$(calc "$node1Out*$node22W + 3" )" )"
  node23Out="$($activeFunc "$(calc "$node1Out*$node23W - 6" )" )"
  node31Out="$($activeFunc "$(calc "$node31W*($node21Out+$node22Out+$node23Out) +4" )" )"
  node32Out="$($activeFunc "$(calc "$node32W*($node21Out+$node22Out+$node23Out) + 5" )" )"
  node33Out="$($activeFunc "$(calc "$node33W*($node21Out+$node22Out+$node23Out) - 7" )" )"
  thinkOutput="$($activeFunc "$(calc "$node4W*($node31Out+$node32Out+$node33Out) + 6" )" )"
  echo $thinkOutput
}

input=
goodExamples=()
goodOutcome=999999999
badExamples=()
badOutcome=888888888
trainFilesDir="$HOME" # To maintain consistent training across discreet runs. Otherwise, only continuous training would be useful.
# Choose
while getopts "a:i:j:l:p:t:w:h" o; do
  case $o in
  a) activeFunc="$OPTARG""_activation" ;;
  i) input="$OPTARG" ;;
  j) wAdjustFunc="$OPTARG""_weight_adjust" ;;
  l) lossFunc="$OPTARG""_loss" ;;
  p) trainFilesDir="$OPTARG" ;;
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
[ "${#weightsArr[@]}" != "8" ] && echo "ERROR: Number of weights must be 7." && print_usage
# Read
node1W=${weightsArr[0]}
node21W=${weightsArr[1]}
node22W=${weightsArr[2]}
node23W=${weightsArr[3]}
node31W=${weightsArr[4]}
node32W=${weightsArr[5]}
node33W=${weightsArr[6]}
node4W=${weightsArr[7]}
# Train
if [ ! -z "$trainBatchNumSize" ]; then
  echo "BEGIN OF TRAINING"
  echo "Supervised training the neural network is about to start with $trainBatchNum batche(s), each of size equals $trainBatchSize..."
  ## Generate Examples
  goodExamplesFile="$trainFilesDir/nn_good_examples"
  badExamplesFile="$trainFilesDir/nn_bad_examples"
  ### Good Examples
  if [ -f "$goodExamplesFile" ]; then
    IFS=,; read -a goodExamples <<< "$(cat $goodExamplesFile)"
    echo "Loaded ${#goodExamples[@]} good examples from the file $goodExamplesFile."
  else
    goodExampleCount=1000
    echo "Generating $goodExampleCount good examples."
    count=0
    while [ $count -lt $goodExampleCount ]; do
      reps=$(( RANDOM%6 + 1 ))
      char=$(( RANDOM%10 ))
      example=""
      for (( i=0;i<$reps;i++ )); do
        example+="$char"
      done
      goodExamples[$count]="$example"
      #echo $example
      (( count++ ))
    done
  fi
  ### Bad Examples
  if [ -f "$badExamplesFile" ]; then
    IFS=,; read -a badExamples <<< "$(cat $badExamplesFile)"
    echo "Loaded ${#badExamples[@]} bad examples from the file $badExamplesFile."
  else
    badExampleCount=10000
    echo "Generating $badExampleCount bad examples."
    count=0
    while [ $count -lt $badExampleCount ]; do
      reps=$(( RANDOM%6 + 1 ))
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
  fi
  [ ! -f "$goodExamplesFile" ] && touch "$goodExamplesFile" && printf "%s," "${goodExamples[@]}">"$goodExamplesFile"
  [ ! -f "$badExamplesFile" ] && touch "$badExamplesFile" && printf "%s," "${badExamples[@]}">"$badExamplesFile"
  # Initialization
  batchCount=0
  oldAccLoss=999999999999999999
  oldNode1W=0
  oldNode21W=0
  oldNode22W=0
  oldNode23W=0
  oldNode31W=0
  oldNode32W=0
  oldNode33W=0
  oldNode4W=0
  while [ $batchCount -lt $trainBatchNum ]; do
      echo "Training Batch $batchCount, of $trainBatchSize items..."
    ## Train on Examples
    trainedCount=0
      accLoss=0
    while [ $trainedCount -lt $trainBatchSize ]; do
##      echo "Training Batch $batchCount, Item $trainedCount..."
      ### Train on Good Example
      index=$(( RANDOM%${#goodExamples[@]} ))
      #index=$(( ($batchCount*$trainBatchSize+$trainedCount)%${#goodExamples[@]} ))
      example=${goodExamples[$index]}
      #echo "Good: $example"
      thought=$(think $example)
 #     echo "Think: $thought Example: $example"
      accLoss="$(calc "$accLoss+$($lossFunc $thought $goodOutcome)" )"
##      echo "Loss: $accLoss"
#  [ $accLoss -lt 0 ] && accLoss=999999999999999999999999999999999999
      (( trainedCount++ ))
      ### Train on Bad Example
      index=$(( RANDOM%${#badExamples[@]} ))
      #index=$(( ($batchCount*$trainBatchSize+$trainedCount)%${#badExamples[@]} ))
      example=${badExamples[$index]}
      thought=$(think $example)
#      echo "Think: $thought Example: $example"
      accLoss="$(calc "$accLoss+$($lossFunc $thought $badOutcome)" )"
##      echo "Loss: $accLoss"
      [ $(echo "$accLoss<0"|bc) -eq 1 ] && accLoss=999999999999999999
      (( trainedCount++ ))
#[ $accLoss -eq 24975000 ] && exit
    done
    if [ $(echo "$accLoss>=$oldAccLoss"|bc) -eq 1 ]; then
      node1W="$oldNode1W"
      node21W="$oldNode21W"
      node22W="$oldNode22W"
      node23W="$oldNode23W"
      node31W="$oldNode31W"
      node32W="$oldNode32W"
      node33W="$oldNode33W"
      node4W="$oldNode4W"
      echo "Reverted to old weights due to lack of progress in reducing loss. $accLoss >= $oldAccLoss"
    else
      oldAccLoss=$accLoss
      echo "Acc Loss: $accLoss"
    fi
    ## Adjust Weights
    echo "Old Weights: $node1W $node21W $node22W $node23W $node31W $node32W $node33W $node4W"
    oldNode1W=$node1W
    oldNode21W=$node21W
    oldNode22W=$node22W
    oldNode23W=$node23W
    oldNode31W=$node31W
    oldNode32W=$node32W
    oldNode33W=$node33W
    oldNode4W=$node4W
    node1W="$($wAdjustFunc $node1W)"
    node21W="$($wAdjustFunc $node21W)"
    node22W="$($wAdjustFunc $node22W)"
    node23W="$($wAdjustFunc $node23W)"
    node31W="$($wAdjustFunc $node31W)"
    node32W="$($wAdjustFunc $node32W)"
    node33W="$($wAdjustFunc $node33W)"
    node4W="$($wAdjustFunc $node4W)"
    echo "New Weights: $node1W $node21W $node22W $node23W $node31W $node32W $node33W $node4W"
    (( batchCount++ ))
  done
  echo "END OF TRAINING"
fi
# Think
echo "$(think $input)"
