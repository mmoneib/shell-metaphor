#!/bin/sh
#############################################################################################
# Eventual Reversion                                                                        #                
#                                                                                           #
# A simple, but ineffective on the long-term, prediction strategy which relies on the       #
# statistical pheonomenon of reversion to the mean to choose the direction of a prediction  #
# opposite to the initialy prevailing direction of the seemingly random data stream.        #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################
# TODO Add option parameters.
# TODO Add option for raw output.

choices=("H" "T")
numOfChoices=${#choices[@]}

countT=0
countH=0
countOfFlips=0
initial=100
money=$initial
percentagT=0
buy=False
maxDown=9
while [ true ]; do
  choice=${choices[$(( RANDOM%numOfChoices ))]}
  [ "$choice" == "T" ] && countT=$(( countT+1 )) && [ $buy == true ] && money=$(( money-20 ))
  [ "$choice" == "H" ] && countH=$(( countH+1 )) && [ $buy == true ] && money=$(( money+20 ))
  echo $money
#  [ $money == 0 ] && break
  down=$(( money-initial ))
  [ $down -lt $maxDown ] && maxDown=$down
  countOfFlips=$(( countOfFlips+1 ))
  percentageOfT=$(( countT*100/countOfFlips ))
  if [ $percentageOfT -gt 99 ]; then
    buy=true;
  elif [ $percentageOfT -lt 50 ]; then
    break
  fi
done 
echo "Amount: $money -- P/L: $(( money-initial )) -- Initial: $initial -- MaxDown=$maxDown -- Flips: $countOfFlips"
