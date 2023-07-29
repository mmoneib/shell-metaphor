#!/bin/sh
#############################################################################################
# The Irreducible Market with Monopoly                                                      #                
#                                                                                           #
# As an extension of the Irreducible Market "thought experiment", here I add the            #
# possibility of a monopoly by allowing a single participant to hold both products at the   #
# same time and simulating the consequent greed by doubling the profit. Two products are    #
# chosen carefully to be inter0dependent, whcih highlights the edge of the monoplizingc     #
# participant in controlling the market. The name are also chosen relevant to the topic.    #
# This simulation highlights the nature of monopoly and its relation to inflation.          #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

#TODO Updated desciption and add explanatory comments

# Constants
ROUND_SLEEP_INTERVAL=0.7 # seconds, for readability
LINE_SLEEP_INTERVAL=0.3 # seconds, more for aesthetics

# Static parameters
participant1="Warren"
wallet1=20
participant2="Bill"
wallet2=20
itemA="hammer"
priceA=1
itemB="nail"
priceB=1
# Dynamic parameters (references modified during runtime)
p1Owns=("$itemA")
p1Offer=("$priceA")
p2Owns=("$itemB")
p2Offer=("$priceB")

printf "%s has %s in his wallet.\n" "$participant1" "$wallet1"
sleep $LINE_SLEEP_INTERVAL
printf "%s has %s in his wallet.\n" "$participant2" "$wallet2"
sleep $LINE_SLEEP_INTERVAL
while true; do
  [ ! -z "${p1Owns[0]}" ] && [ ! -z "${p1Owns[1]}" ] && ownString="${p1Owns[0]} and ${p1Owns[1]} each" || ownString="${p1Owns[0]}${p1Owns[1]}" # Avoiding multiple conditions by concatination.
  [ ! -z "${p1Owns[0]}${p1Owns[1]}" ] && printf "%s offers %s for price %s.\n" "$participant1" "$ownString" "$p1Offer" || printf "%s offers nothing.\n" "$participant1"
  sleep $LINE_SLEEP_INTERVAL
  [ ! -z "${p2Owns[0]}" ] && [ ! -z "${p2Owns[1]}" ] && ownString="${p2Owns[0]} and ${p2Owns[1]} each" || ownString="${p2Owns[0]}${p2Owns[1]}" # Avoiding multiple conditions by concatination.
  [ ! -z "${p2Owns[0]}${p2Owns[1]}" ] && printf "%s offers %s for price %s.\n" "$participant2" "$ownString" "$p2Offer" || printf "%s offers nothing.\n" "$participant2"
  sleep $LINE_SLEEP_INTERVAL
  if [ "${p2Owns[0]}" != "" ] ; then
    if [ "$wallet1" -ge "${p2Offer[0]}" ]; then
      wallet1="$(($wallet1-${p2Offer[0]}))"
      wallet2="$(($wallet2+$p2Offer))"
      printf "%s buys %s from %s for %s and has %s left in his wallet and %s in %s's wallet. The item's price will increase by 1.\n" "$participant1" "${p2Owns[0]}" "$participant2" "${p2Offer[0]}" "$wallet1" "$wallet2" "$participant2"
      sleep $LINE_SLEEP_INTERVAL
      [ ! -z "${p1Owns[0]}" ] && elementIndex=1 || elementIndex=0
      [ ! -z "${p1Owns[1]}" ] && p1Owns[0]="${p1Owns[1]}"
      p1Owns[$elementIndex]="${p2Owns[0]}"
      p2Owns[0]="${p2Owns[1]}"
      p2Owns[1]=""
      [ ! -z "${p1Offer[1]}" ] && p1Offer[0]="${p1Offer[1]}"
      p1Offer[$elementIndex]="$((${p2Offer[0]}+1))"
      p2Offer[0]="${p2Offer[1]}"
      p2Offer[1]=""
      if [ "${p1Owns[0]}${p1Owns[1]}" == "$itemA$itemB" ] || [ "${p1Owns[0]}${p1Owns[1]}" == "$itemB$itemA" ]; then
        printf "%s holds a monopoly and raises the prices of both items by 2.\n" "$participant1"
        sleep $LINE_SLEEP_INTERVAL
        p1Offer[0]="$((p1Offer[0]+2))"
        p1Offer[1]="$((p1Offer[1]+2))"
      fi
    else
       printf "%s's wallet has only %s in it. He can't afford to buy %s offered for %s.\n" "$participant1" "$wallet1" "${p2Owns[0]}" "${p2Offer[0]}"
       sleep $LINE_SLEEP_INTERVAL
       p2Offer[0]="$((${p2Offer[0]}-1))"
       printf "Price of %s is reduced by 1.\n" "${p2Owns[0]}"
       sleep $LINE_SLEEP_INTERVAL
    fi
  fi
  if [ "${p1Owns[0]}" != "" ]; then
    if [ "$wallet2" -ge "${p1Offer[0]}" ]; then
      wallet2="$(($wallet2-${p1Offer[0]}))"
      wallet1="$(($wallet1+$p1Offer))"
      printf "%s buys %s from %s for %s and has %s left in his wallet and %s in %s's wallet. The item's price will increase by 1.\n" "$participant2" "${p1Owns[0]}" "$participant1" "${p1Offer[0]}" "$wallet2" "$wallet1" "$participant1"
      sleep $LINE_SLEEP_INTERVAL
      [ ! -z "${p2Owns[0]}" ] && elementIndex=1 || elementIndex=0
      [ ! -z "${p2Owns[1]}" ] && p2Owns[0]="${p2Owns[1]}"
      p2Owns[$elementIndex]="${p1Owns[0]}"
      p1Owns[0]="${p1Owns[1]}"
      p1Owns[1]=""
      elementIndex=0
      [ ! -z "${p1Offer[1]}" ] && p2Offer[0]="${p2Offer[1]}"
      p2Offer[$elementIndex]="$((${p1Offer[0]}+1))"
      p1Offer[0]="${p1Offer[1]}"
      p1Offer[1]=""
      if [ "${p2Owns[0]}${p2Owns[1]}" == "$itemA$itemB" ] || [ "${p2Owns[0]}${p2Owns[1]}" == "$itemB$itemA" ]; then
        printf "%s holds a monopoly and raises the prices of both items by 2." "$participant2"
        sleep $LINE_SLEEP_INTERVAL
        p2Offer[0]="$((p2Offer[0]+2))"
        p2Offer[1]="$((p2Offer[1]+2))"
      fi
    else
       printf "%s's wallet has only %s in it. He can't afford to buy %s offered for %s.\n" "$participant2" "$wallet2" "${p1Owns[0]}" "${p1Offer[0]}"
       sleep $LINE_SLEEP_INTERVAL
       p1Offer[0]="$((${p1Offer[0]}-1))"
       printf "Price of %s is reduced by 1.\n" "${p1Owns[0]}"
       sleep $LINE_SLEEP_INTERVAL
    fi
  fi
  sleep $ROUND_SLEEP_INTERVAL
done
