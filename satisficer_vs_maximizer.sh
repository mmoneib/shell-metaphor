#!/bin/sh

satisficerScore=0
maximizerScore=0
satisficerAmbition=100
maximizerAmbition=1000
satisficerCache=0
maximizerCache=0
SatisficerScore=0
MaximizerScore=0

echo "Is it better to be a satisficer in life or a maximizer?"
echo "Let's see through a Monte Carlo simiulation in which life throws either a carrot or a stone in each iteration."
echo "Satificer will accumulate carrots in 100s."
echo "Maximizer will accumulate carrots in 1000s."
echo "Who will get the more carrots?"
count=0
while true; do
  [ $((count%10000)) -eq 0 ] && echo "After $count iterations, Satisficer has $satisficerScore carrots, while Maximizer has $maximizerScore carrots."
  delta=$(($RANDOM%2+1)) # -1 or 1
  if [ $delta -eq 1 ]; then #TODO Move to functiona and add options other than this independent time series (add dependent, [ercentages...etc.).
    satisficerCache=$((satisficerCache+1))
    maximizerCache=$((maximizerCache+1))
  fi
  [ $satisficerCache -eq $satisficerAmbition ] && satisficerScore=$((satisficerScore+satisficerCache)) && satisficerCache=0
  [ $maximizerCache -eq $maximizerAmbition ] && maximizerScore=$((maximizerScore+maximizerCache)) && maximizerCache=0
  count=$((count+1))
done
