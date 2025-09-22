#!/bin/sh

#TODO: Add multiplier of weight adjustments to simulate steps.
# Maintaining batch of training is not so useful if random picking is to be employed. But maybe it speeds up things.
# Resuming training will not yield the same last accLoss because it will start at a different place in the training set.
# TODO Maintain full state of training procedure including positions. 
# TODO Why resuming with the sane weights doesn't converge quickly to the last pruced loss with the same weights."

function print_usage {
  echo "USAGE: $0 -i input_here [-a active_function_name_here -j weight_adjust_function_name_here -l loss_function_name_here -p training_files_path_here -s structure_layers_csv -t train_batches_number_by_size_here -w weights_csv_here]"
  echo "Examples:"
  printf "\t%s\n" "$0 -i 22222 -a perceptron -j randomJump -l deviation -p '$HOME' -s 1,3,2,1 -t '100*100' -w 1,1,1,1,1,1,1"
  printf "\t%s\n" "$0 -i 22222 -a tanh -j fibRandomWalk -l deviation  -s 1,50,50,1 -t '1000*25' -w 1,-240,-55,240,-149,-136,-275,-226,52,-1,100,16,165,203,-314,159,36,-129,163,161,-97,218,-23,-23,-130,-65,9,-105,284,-86,111,-168,86,141,94,6,-46,15,-155,-20,-214,-25,83,-95,272,-78,56,-45,17,134,75,94,17,-78,166,74,102,109,-134,14,169,8,-79,7,20,-34,-100,161,40,-200,28,45,114,85,119,-18,65,-67,185,-121,-207,111,19,165,-5,129,-166,32,130,-60,-30,-106,-154,11,-49,-74,-102,-64,-105,-68,-51,-98,"  
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
# Weight Adjustment Functions
function applyWeightAdjust { # Allows decoration of the specified functions.
  weight=$($wAdjustFunc $1)
  #[ $weight -eq 0 ] && weight=${oldWeightsArr[$(( $nodeCount-1 ))]} # Not recommended. Better use regularization.
  #[ -z $weight ] && weight=1 # In case no training is done (direct evaluation).
  [ $weight -eq 0 ] && weight=$(( RANDOM%2 )) && [ $weight -eq 0 ] && weight=-1 # TODO Choose strategy. 
  echo $weight
}
buzzBoundary=2
function buzz_weight_adjust {
  weight=$1
  delta=$(( RANDOM%$buzzBoundary ))
  [ $(( RANDOM%2 )) -eq 0 ] && echo $(( $weight+$delta )) || echo $(( $weight-$delta )) 
}
fibChoices=( 1 2 3 5 8 13 21 34 55 89 144 )
function fibRandomWalk_weight_adjust {
  weight=$1
  choice=${fibChoices[$(( RANDOM%${#fibChoices[@]} ))]}
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
#maxJump=1000
function randomJump_weight_adjust {
  weight=$1
  choice=$(( RANDOM%$maxJump ))
  newWeight=0
  while [ $newWeight -eq 0 ]; do
    [ 0 -eq $(( RANDOM%2 )) ] && newWeight=$(( $weight-$choice )) || newWeight=$(( $weight+$choice ))
  done
  echo "$newWeight"
}
# Thinking Funciton
function think {
  inp=$1
  inp=$(( 10#$inp )) # To force base 10 in case of leading 0.
  nodeCount=0
  weightCount=0
  for (( layerCount=0;layerCount<${#structureArr[@]};layerCount++ )); do
    nodeInLayerCount=0
    while [ $nodeInLayerCount -lt ${structureArr[$layerCount]} ]; do
      # No weight or biases for entry nodes.
      if [ $layerCount -eq 0 ]; then
        nodeInputs=$inp
        nodeValue=$(( $nodeInputs )) # TODO support multiple inputs.
      else
        nodeValue=0
        for (( nodeIndex=$previousLayerStartNodeIndex;nodeIndex<$previousLayerEndNodeIndex;nodeIndex++ )); do
          linkWeight=${weightsArr[$weightCount]}
          nodeValue=$(( $nodeValue+${nodeValues[$nodeIndex]}*$linkWeight )) # Sum of weights.
          (( weightCount++ ))
        done
      #[ $(( $nodeCount%2 )) -eq 0 ] && bias=$(( $nodeCount+1 )) || bias=$(( 0-$nodeCount ))
        bias=$(( $nodeCount+1 )) # Positive bias acts against the improbable case of having all negative weight that would produce a 0.
        nodeValue=$(( $nodeValue+$bias ))
      fi
      #echo "DEBUG: Layer $layerCount Node $nodeInLayerCount Value = $nodeValue" >&2
      nodeValues[$nodeCount]=$nodeValue
      (( nodeCount++ ))
      (( nodeInLayerCount++ ))
    done
    previousLayerEndNodeIndex=$(( $nodeCount ))
    previousLayerStartNodeIndex=$(( $previousLayerEndNodeIndex-${structureArr[$layerCount]} ))
  done
  echo $nodeValue #TODO Support multiple outputs.
}

input=
goodExamples=()
goodOutcome=1000000
badExamples=()
badOutcome=-1000000
odlWeightsArr=()
trainFilesDir="$HOME" # To maintain consistent training across discreet runs. Otherwise, only continuous training would be useful.
#structureStr="1,50,50,1"
# Choose
while getopts "a:i:j:l:p:s:t:w:h" o; do
  case $o in
  a) activeFunc="$OPTARG""_activation" ;;
  i) input="$OPTARG" ;;
  j) wAdjustFunc="$OPTARG""_weight_adjust" ;;
  l) lossFunc="$OPTARG""_loss" ;;
  p) trainFilesDir="$OPTARG" ;;
  s) structureStr="$OPTARG" ;;
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
expectNumOfWeights=0
for (( i=1;i<${#structureArr[@]};i++ )); do
  expectNumOfWeights=$(( $expectNumOfWeights+${structureArr[$i]}*${structureArr[$(( $i-1 ))]} ))
done
[ -f "$weightsStr" ] && weightsStr="$(cat $neural_net_weights)" # TODO Add weights in file.
[ -z "$weightsStr" ] && weightsArr=() || IFS=,; read -a weightsArr <<< "$weightsStr"
if [ ${#weightsArr[@]} -eq 0 ]; then
  echo "Generating random weights..."
  for (( i=0;i<$expectNumOfWeights;i++ )); do
     weightsArr[$i]=$(( RANDOM%199-99 ))
  done
fi 
[ "${#weightsArr[@]}" -ne "$expectNumOfWeights" ] && echo "ERROR: Number of weights must be $expectNumOfWeights (provided ${#weightsArr[@]})." && print_usage
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
      weightsArr[$i]="$(applyWeightAdjust ${weightsArr[$i]})"
    done
    printf "New Weights: " && printf '%s,' "${weightsArr[@]}" && echo 
   (( batchCount++ ))
  done
  echo "END OF TRAINING"
  weightsArr=(${oldWeightsArr[@]})
fi
# Think
echo "$(think $input)"
