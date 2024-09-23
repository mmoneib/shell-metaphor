#!/bin/sh

numOfMatches=1000
numOfMaximizers=100
numOfSatisficers=100
maximizerThreshold=95
satisficerThreshold=60
strategyOfMatching="random"
strategyOfScoring="objectively_random"
maxmizers=()
satisficers=()
o_isMatch=0
o_output=""

if [ "$strategyOfScoring" == "objectively_random" ]; then
  for (( i=0;i<$numOfMaximizers;i++ )); do
    maxmizers[$i]=$(( RANDOM%101 ))
  done
  for (( i=0;i<$numOfSatisficers;i++ )); do
    satisficers[$i]=$(( RANDOM%101 ))
  done
fi
#echo "${maxmizers[@]}"

for (( i=0;i<$numOfMatches;i++ )); do
  o_isMatch=0
  if [ "$strategyOfMatching" == "random" ]; then
    maximizer=$(( RANDOM%numOfMaximizers ))
    satisficer=$(( RANDOM%numOfSatisficers ))
    maximizerScore=${maxmizers[$maximizer]}
    satisficerScore=${satisficers[$satisficer]}
    if [ $maximizerScore -ge $satisficerThreshold ] && [ $satisficerScore -ge $maximizerThreshold ]; then
      o_isMatch=1
    fi
    o_output+="Match=$o_isMatch -- Maximizer=$maximizer -- Satisficer=$satisficer -- Maximizer's Score=$maximizerScore -- Satisficer's Score=$satisficerScore\n"
  fi
done
printf "$o_output"
