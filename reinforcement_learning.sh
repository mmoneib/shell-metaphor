#!/bin/bash

set KSH_ARRAYS

secretCode="RED,WHITE,RED,YELLOW,BLUE,BLUE"
elements="RED,GREEN,BLUE,YELLOW,WHITE,BLACK"

IFS=,; read -a elementsArr <<< "$elements"
elementsSize=${#elementsArr[@]}
IFS=,; read -a codeArr <<< "$secretCode"
codeSize=${#codeArr[@]}

guess=()
for (( i=0; i<$codeSize; i++ )); do
  randomElementIndex=$(( RANDOM%$elementsSize  ))
  guess[$i]=${elementsArr[$randomElementIndex]}
done

utility=0
lastUtility=0
tryCount=1
while [ $utility -lt 60 ]; do
  utilityOutput=()
  # Storage for Backup
  utility=0
  oldGuess=(${guess[@]})
echo "Old Guess: ${oldGuess[@]}"
  # Guessing Evolution
  targetElementIndex=$(( RANDOM%codeSize ))
  targetElementNewValue=${elementsArr[$(( RANDOM%elementsSize ))]}
  echo "New Value: $targetElementNewValue"
  echo "New Value Index: $targetElementIndex"
  echo "BB: ${guess[@]}"
  guess[$targetElementIndex]="$targetElementNewValue"
  echo "AA: ${guess[@]}"
  # Guess Evaluation
  for (( i=0; i<$codeSize; i++ )); do
    [ "${guess[i]}" == "${codeArr[i]}" ] && utilityOutput+=("X") && continue
    for (( j=0; j<$codeSize; j++ )); do
      [ "${guess[i]}" == "${code[j]}" ] && utilityOutput+=("O") && continue # TODO Maybe check if the matching element in the code is not already matched with an X.
    done
  done
  # Utility Function Calculaton
  for (( i=0; i<${#utilityOutput[@]}; i++ )); do
    [ "${utilityOutput[$i]}" == "X" ] && utility=$(( utility+10 ))
    [ "${utilityOutput[$i]}" == "O" ] && utility=$(( utility+5 ))
  done
  echo "UtilityOutput: ${utilityOutput[@]}"
  echo "utility: $utility"
  echo "LastUtility: $lastUtility"
  echo "Guess: ${guess[@]}"
  # Backtracking
  if [ $utility -lt $lastUtility ]; then
    utility=$lastUtility
    guess=(${oldGuess[@]})
  else
    lastUtility=$utility
  fi
  (( tryCount++ ))
done
