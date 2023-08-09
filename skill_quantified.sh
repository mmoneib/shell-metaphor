#!/bin/sh

startingAmount=100
#bets=(1 3 9 81)
#bets=(1 2 4 8 16 32 64 128)
bets=(1 2 3 5 8 13 21 34 55)
accuracy=53
invAccuracy=$((101-accuracy))

amount=$startingAmount
currBetIndex=0
count=0
echo "Started betting..."
while [ $amount -gt 0 ]; do
  printf "Iteration %d: " "$count"
  choice=$((RANDOM%101))
  printf "Choice=%d, " "$choice"
  delta=${bets[currBetIndex]}
  printf "Delta=%d, " "$delta"
  [ $choice -ge $invAccuracy ] && amount=$((amount+delta)) && currBetIndex=0 
  [ $choice -lt $invAccuracy ] && amount=$((amount-delta)) && currBetIndex=$(((currBetIndex+1)%${#bets[@]}))
  printf "Amount=%d.\n" "$amount"
  count=$((count+1))
done
echo "Ended with bankruptcy."
