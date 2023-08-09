#!/bin/sh

startingAmount=100
#bets=(0.1 0.3 0.9 0.81)
#bets=(0.1)
bets=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9)
#bets=(0.01 0.02 0.04 0.08 0.16 0.32 0.64)
#bets=(0.01 0.02 0.03 0.05 0.08 0.13 0.21 0.34 0.55)
accuracy=58
invAccuracy=$((100-accuracy))

amount=$startingAmount
currBetIndex=0
count=0
echo "Started betting..."
while [ $(echo "$amount>1"|bc) -eq 1 ]; do
  printf "Iteration %d: " "$count"
  choice=$((RANDOM%100))
  printf "Choice=%d, " "$choice"
  perc=${bets[currBetIndex]}
  printf "Delta=%f, " "$perc"
  [ $choice -ge $invAccuracy ] && amount=$(echo "scale=6;$amount+$amount*$perc" | bc -l) && currBetIndex=0 
  [ $choice -lt $invAccuracy ] && amount=$(echo "scale=6;$amount-$amount*$perc" | bc -l) && currBetIndex=$(((currBetIndex+1)%${#bets[@]}))
  printf "Amount=%f.\n" "$amount"
  count=$((count+1))
done
echo "Ended with bankruptcy."
