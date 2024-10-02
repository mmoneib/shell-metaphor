#!/bin/sh
################################################################################
# Matching Saticficers with Maximizers                                         #
#                                                                              #
# A simple Monte Carlo simulation to analyze scarcity when matchcmaking a      #
# group of satisficers with maximizers.                                        #
#                                                                              #
# Conceptualized and developed by: Muhammad Moneib                             #
################################################################################

# TODO Add pretty and raw output.
# TODO Add subjectively_random strategyOfScoring where the object gets a random score with each match.
# TODO Add random_with_elementation strategyOfMatching to remove matched elements from the pool.
# TODO Add expiry of match to simulate end of relation.
# TODO Experiment with other distributions of scores.

function print_error {
  printf "$@">&2
  exit 1
}

function print_help {
  echo -e "Matching Saticficers with Maximizers: A simple Monte Carlo simulation to analyze scarcity when matching a group of satisficers with that of maximizers.
Required Parameters:
\tNumber of Matches (n): The number of attempts to match a pair, one being a maximizer and the other a satisficer.
\tNumber of Maximizers (x): The number of maximizers available to be matched.
\tNumber of Satisficers (s): The number of satisficers available to be matched.
Optional Parmeters:
\tMaximizer's Threshold (u): The lower bound threshold of the score to be matched with by a maximizer. Defaults to 95.
\tSatisficer's Threshold (l): The lower bound threshold of the score to be matched with by a satisficer. Defaults to 60.
\tStrategy of Matching (m): If 'random', then each pair will be formed by a random picking from each group. Defaults to 'random'.
\tStrategy of Scoring (c): If 'objectively_random', then each individual will have a random score assigned to him once. If 'subjectively_random', each individual will be assigned a random score before each match. Dafaults to 'objectively_random'.
\tIs Raw Output? (r): If present, the ouput will be CSV.
Examples:
# Simulation of matches through objectively random scoring.
$0 -n 1000 -x 100 -s 100 -u 95 -l 60 -m random -c objectively_random"
  exit
}

missingRequiredParamErr="ERROR: Missing required parameter (%s)!\n"
maximizerThreshold=95
satisficerThreshold=60
strategyOfMatching="random"
strategyOfScoring="objectively_random"
isRawOutput="false"
maximizers=()
satisficers=()
o_isMatch=0
o_output=""

while getopts "n:x:s:u:l:m:c:r" o; do
  case "$o" in
    n) numOfMatches="$OPTARG" ;;
    x) numOfMaximizers="$OPTARG" ;;
    s) numOfSatisficers="$OPTARG" ;;
    u) maximizerThreshold="$OPTARG" ;;
    l) satisficerThreshold="$OPTARG" ;;
    m) strategyOfMatching="$OPTARG" ;;
    c) strategyOfScoring="$OPTARG" ;;
    r) isRawOutput="true" ;;
    *) print_help ;;
  esac
done

[ -z "$numOfMatches" ] && print_error "$missingRequiredParamErr" 'n'
[ -z "$numOfMaximizers" ] && print_error "$missingRequiredParamErr" 'x'
[ -z "$numOfSatisficers" ] && print_error "$missingRequiredParamErr" 's'

if [ "$strategyOfScoring" == "objectively_random" ]; then
  for (( i=0;i<$numOfMaximizers;i++ )); do
    maximizers[$i]=$(( RANDOM%101 ))
  done
  for (( i=0;i<$numOfSatisficers;i++ )); do
    satisficers[$i]=$(( RANDOM%101 ))
  done
fi

for (( i=0;i<$numOfMatches;i++ )); do
  o_isMatch=0
  if [ "$strategyOfMatching" == "random" ]; then
    maximizer=$(( RANDOM%numOfMaximizers ))
    satisficer=$(( RANDOM%numOfSatisficers ))
    maximizerScore=${maximizers[$maximizer]}
    satisficerScore=${satisficers[$satisficer]}
    if [ $maximizerScore -ge $satisficerThreshold ] && [ $satisficerScore -ge $maximizerThreshold ]; then
      o_isMatch=1
    fi
    o_output+="Match=$o_isMatch -- Maximizer=$maximizer -- Satisficer=$satisficer -- Maximizer's Score=$maximizerScore -- Satisficer's Score=$satisficerScore\n"
  fi
done
printf "$o_output"
