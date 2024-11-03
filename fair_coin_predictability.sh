#!/bin/sh
#############################################################################################
# Fair Coin Predictabliliy                                                                  #                
#                                                                                           #
# A Monte Carlo simulation which assess the predictability of the behaviour of a fair coin  #
# through starting from an extremely unfair situation.                                      #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

#TODO Add input parameters.
#TODO Add pretty and row output.
#TODO Separate logic from output.
#TODO Add geometrical staking.

numOfFlipsInRow=5
numOfRows=32
choices=("H" "T")
amount=100
buy=false
stakes=(10 20 40 80) # Smoothing.
betCount=0
partition=$(( numOfRows/2 ))
thresholdPercentage=60

while [ true ]; do
  countTails=0
  countHeads=0
  stakesCount=0
  buy=false
  for (( r=0; r < $partition; r++ )); do # r for row.
    for (( f=0; f < $numOfFlipsInRow; f++ )); do # f for field.
      res=${choices[$(( $RANDOM%2 ))]}
      [ "$res" == "T" ] && countTails=$(( $countTails+1 ))
      [ "$res" == "H" ] && countHeads=$(( $countHeads+1 ))
    done
  done
  tailPercentage=$(( countTails*100/(partition*numOfFlipsInRow) ))
  [ $tailPercentage -gt $thresholdPercentage ] && buy=true # Bet on HEAD.
  for (( r=0; r < $(( numOfRows-partition )); r++ )); do # r for row.
    for (( f=0; f < $numOfFlipsInRow; f++ )); do # f for field.
      isAmountChanged=false
      betCount=$(( betCount+1 ))
      res=${choices[$(( $RANDOM%2 ))]}
      if [ $buy == true ] && [ "$res" == "H" ]; then
        amount=$(echo "scale=2;$amount+${stakes[$stakesCount]}"|bc -l)
        buy=false
        isAmountChanged=true
      elif [ $buy == true ] && [ "$res" == "T" ]; then
        amount=$(echo "scale=2;$amount-${stakes[$stakesCount]}"|bc -l)
        stakesCount=$(( $stakesCount+1 ))
        isAmountChanged=true
      fi              
      [ $isAmountChanged == true ] && printf "Iteration $betCount: Tail Percentage=$tailPercentage, Outcome=$res, Amount=$amount\n"
      [ $(echo "$amount>=200"|bc) -eq 1 ] && exit
      [ $(echo "$amount<=0"|bc) -eq 1 ] && exit
    done
  done
done
