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

# Activation Functions
function perceptron_activation {
  echo $1
}
function sigmoid_activation {
  factor="0.5" # TODO: Determine values.
  echo "scale=3;$1*$factor|bc -l"
}
function tanh_activation {
  param=$1
  fadingFactor=$(( $param/100000000 ))
  #echo $param >&2
  echo $(( $param*(100-$fadingFactor)/100 ))
#echo $(( 1*$param ))
}
function relU_activation {
  inp=$1
  if [ $inp -le 0 ]; then
    ramp=-1
    inp=1
  else
    ramp=$(( $inp/10 +1 ))
  fi
  echo $(( $ramp*$inp ))
}
# Loss Functions
function deviation_loss {
  got="$1"
  expected="$2"
  dev=$(( $got-$expected ))
  [ $dev -lt 0 ] && dev=$(( -1*$dev ))
  #echo "DEV: $dev" >&2
  echo $dev
}
fibChoices=( 1 2 3 5 8 13 21 34 55 89 144 )
# Weight Adjustment Functions
function fibRandomWalk_weight_adjust {
  weight=$1
  choice=${fibChoices[$(( RANDOM%${#fibChoices[@]} ))]}
  newWeight=0
  while [ $newWeight -eq 0 ]; do
    [ 0 -eq $(( RANDOM%2 )) ] && newWeight=$(( $weight-$choice )) || newWeight=$(( $weight+$choice ))
  done
  echo "$newWeight"
}
maxJump=1000
function randomJump_weight_adjust {
  weight=$1
  choice=$(( RANDOM%$maxJump ))
  newWeight=0
  while [ $newWeight -eq 0 ]; do
    [ 0 -eq $(( RANDOM%2 )) ] && newWeight=$(( $weight-$choice )) || newWeight=$(( $weight+$choice ))
  done
  echo "$newWeight"
}
#range=2000
function randomGuess_weight_adjust {
  guess=0
  while [ $guess -eq 0 ]; do
    guess="$(( RANDOM%200-100 ))"
  done
  echo $guess
}
# Thinking Funciton
function think {
  layerOutputs=()
  inp=$1
  inp=$(( 10#$inp )) # To force base 10 in case of leading 0.
  nodeCount=0
  for (( i=0;i<${#structureArr[@]};i++ )); do
    count=0
    while [ $count -lt ${structureArr[$i]} ]; do
      (( nodeCount++ ))
      [ $(( $nodeCount%2 )) -eq 0 ] && bias=$(( $nodeCount+1 )) || bias=$(( 0-$nodeCount ))
      if [ $i -eq 0 ]; then
        nodeInput=$inp
      else
        nodeInput=${layerOutputs[$(( $i-1 ))]}
      fi
      nodeWeight=${weightsArr[$(( $nodeCount-1 ))]}
      #echo "DEBUG: NodeWeight = $nodeWeight" >&2
      nodeOutput=$($activeFunc $(( $nodeInput*$nodeWeight )) )
      [ -z "${layerOutputs[$i]}" ] && layerOuputs[$i]=0 # Initialization
      layerOutputs[$i]=$(( layerOutputs[$i]+$nodeOutput ))
      (( count++ ))
    done
  done
  #echo "DEBUG: LayerOuputs = ${layerOutputs[@]}" >&2
  thinkOutput=${layerOutputs[$(( ${#layerOutputs[@]}-1 ))]}
  echo $thinkOutput
}

input=
goodExamples=()
goodOutcome=1000
badExamples=()
badOutcome=-1000
odlWeightsArr=()
trainFilesDir="$HOME" # To maintain consistent training across discreet runs. Otherwise, only continuous training would be useful.
structureStr="1,50,50,1"
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
[ -z "$structureStr" ] && structureArr=(1 1) || IFS=,; read -a structureArr <<< "$structureStr"
numOfNodes=0
for (( i=0;i<${#structureArr[@]};i++ )); do
  numOfNodes=$(( $numOfNodes+${structureArr[$i]} ))
done
[ -z "$weightsStr" ] && weightsStr="$(cat $neural_net_weights)"
[ -z "$weightsStr" ] && weightsArr=(0 0 0 0 0 0) || IFS=,; read -a weightsArr <<< "$weightsStr" 
[ "${#weightsArr[@]}" -ne "$numOfNodes" ] && echo "ERROR: Number of weights must be $numOfNodes." && print_usage
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
  for (( i=0;i<${#weightsArr[@]};i++ )); do
    oldWeightsArr[$i]=0
  done
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
      #echo "Think: $thought Example: $example"
      accLoss=$(( $accLoss+$($lossFunc $thought $goodOutcome) ))
##      echo "Loss: $accLoss"
#  [ $accLoss -lt 0 ] && accLoss=999999999999999999999999999999999999
      (( trainedCount++ ))
      ### Train on Bad Example
      index=$(( RANDOM%${#badExamples[@]} ))
      #index=$(( ($batchCount*$trainBatchSize+$trainedCount)%${#badExamples[@]} ))
      example=${badExamples[$index]}
      thought=$(think $example)
      #echo "Think: $thought Example: $example"
      accLoss=$(( $accLoss+$($lossFunc $thought $badOutcome) ))
##      echo "Loss: $accLoss"
  [ $accLoss -lt 0 ] && accLoss=999999999999999999
      (( trainedCount++ ))
#[ $accLoss -eq 24975000 ] && exit
    done
    if [ $accLoss -ge $oldAccLoss ]; then
      for (( i=0;i<${#weightsArr[@]};i++ )); do
        weightsArr[$i]=${oldWeightsArr[$i]}
      done
      echo "Reverted to old weights due to lack of progress in reducing loss. $accLoss >= $oldAccLoss"
    else
      oldAccLoss=$accLoss
      echo "Acc Loss: $accLoss"
    fi
    ## Adjust Weights
    printf "Old Weights: " && printf '%s,' "${oldWeightsArr[@]}" && echo 
    for (( i=0;i<${#weightsArr[@]};i++ )); do
      oldWeightsArr[$i]=${weightsArr[$i]}
    done
    for (( i=0;i<${#weightsArr[@]};i++ )); do
      weightsArr[$i]="$($wAdjustFunc ${weightsArr[$i]})"
    done
    printf "New Weights: " && printf '%s,' "${weightsArr[@]}" && echo 
   (( batchCount++ ))
  done
  echo "END OF TRAINING"
fi
# Think
echo "$(think $input)"
