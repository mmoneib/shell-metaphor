#!/bin/sh
#TODO Move to functiona and add options other than this independent time series (add dependent, [percentages...etc.).
#TODO Validate that maximizer's values are more than sitisficers.

probabilities="-3 -2 -1 1 2 3" # -ve for stones, +ve for carrots."

satisficerScore=0
maximizerScore=0
satisficerAmbition=250
maximizerAmbition=1000
satisficerCache=0
maximizerCache=0
SatisficerScore=0
MaximizerScore=0
ifs= read -a probabilitiesArr <<< "$probabilities"
numOfProbabilities=${#probabilitiesArr[@]}

echo "Is it better to be a satisficer in life or a maximizer?"
echo "Let's see through a Monte Carlo simiulation in which life throws either a carrot or a stone in each iteration."
echo "Who will get the more carrots? And who will avoid more stones?"
count=0
while true; do
  [ $((count%1)) -eq 0 ] && echo "After $count iterations, Satisficer has $satisficerScore carrots, while Maximizer has $maximizerScore carrots. Difference = $((satisficerScore-maximizerScore))"
  delta=i${probabilities[$(( RANDOM%numOfProbabilities ))}]
  satisficerCache=$((satisficerCache+1))
  maximizerCache=$((maximizerCache+1))
  [ $satisficerCache -eq $satisficerAmbition ] && satisficerScore=$((satisficerScore+satisficerCache)) && satisficerCache=0
  [ $maximizerCache -eq $maximizerAmbition ] && maximizerScore=$((maximizerScore+maximizerCache)) && maximizerCache=0
  count=$((count+1))
done
