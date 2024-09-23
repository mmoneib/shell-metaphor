#!/bin/sh
################################################################################
# Matching Saticficers with Maximizers                                         #
#                                                                              #
# A simple Monte Carlo simulation to analyze scarcity when matchcmaking a      #
# groups of satisficers with maximizers. The simulation can provide inside in  #
# situations when there is a descrepancy between the needs of two groups and   #
# such a group behaviour can affect individuals. It can be viewed as a         #
# simplification of the job market, dating, and trading among unqual partners  #
# aming other real-life situations.                                            @
#                                                                              #
# Conceptualized and developed by: Muhammad Moneib                             #
################################################################################

# TODO Add help
# TODO Make variables configurable through input parameters.
# TODO Add subjectively_random strategyOfScoring where the object gets a random score with each match.
# TODO Add prettyb and raw output.
# TODO Add random_with_elementation strategyOfMatching to remove mathced elements from the pool.
# TODO Add expiry of match to simulate end of relation.
# TODO Experiment with other distributions of scores.

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
