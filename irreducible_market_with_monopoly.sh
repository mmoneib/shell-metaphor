#!/bin/sh
#############################################################################################
# The Irreducible Market with Monopoly                                                      #                
#                                                                                           #
# Employing reductionism has always been used by science to uncover the mysteries of our    #
# lives using the technique of modelling complex systems in simpler circumstances that      #
# ignore whatever is considered to be noise. In this "thought experiment", I reduce a       #
# market to its most basic form of 2 participants and 2 products, effectively removing the  #
# noises of choice, abundance, and scarcity. For this simple model, I choose 2 products,    #
# a hat and a wig, which can be mutually-exclusive in terms of use, yet complement each     #
# other in a certain way. This justifies the cycle of buying and selling between the 2      #
# participants whose names are chosen based on perceived competitiveness and hair-loss      #
# issues. The opposite transactions are only allowed to be simultaneous here in order to    #
# prevent monopoly and the subsequent collapse of the market.                               #
# The experiment reveals fundamental characteristics about capital markets, sustainability, #
# and the dynamics of pricing.                                                              #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

# Static parameters
participant1="Warren"
wallet1=20
participant2="Bill"
wallet2=20
itemA="oil"
priceA=1
itemB="lighter"
priceB=1
# Dynamic parameters (references modified during runtime)
p1Owns=("$itemA")
p1Offer=("$priceA")
p2Owns=("$itemB")
p2Offer=("$priceB")

printf "%s has %s in his wallet.\n" "$participant1" "$wallet1"
printf "%s has %s in his wallet.\n" "$participant2" "$wallet2"
while true; do
  printf "%s offers %s for price %s.\n" "$participant1" "$p1Owns" "$p1Offer"
  printf "%s offers %s for price %s.\n" "$participant2" "$p2Owns" "$p2Offer"
  if [ "${p2Owns[0]}" != "" ] ; then
  if [ "$wallet1" -ge "${p2Offer[0]}" ]; then
    printf "%s buys %s from %s for %s and has %s left in his wallet and %s in %s's wallet. The item's price will increase by 1.\n" "$participant1" "${p2Owns[0]}" "$participant2" "${p2Offer[0]}" "$wallet1" "$wallet2" "$participant2"
    [ ! -z "${p1Owns[1]}" ] && p1Owns[0]="${p1Owns[1]}"
    p1Owns[1]="${p2Owns[0]}"
    p2Owns[0]="${p2Owns[1]}"
    p2Owns[1]=""
    [ ! -z "${p1Offer[1]}" ] && p1Offer[0]="${p1Offer[1]}"
    p1Offer[0]="$((${p2Offer[0]}+1))"
    p2Offer[0]="${p2Offer[1]}"
    p2Offer[1]=""
echo "${p1Owns[0]}" "${p1Owns[1]}"
    if [ "${p1Owns[0]}" == "$itemA" ] && [ "${p1Owns[1]}" == "$itemB" ] || [ "${p1Owns[0]}" == "$itemB" ] && [ "${p1Owns[1]}" == "$itemA" ]; then
      printf "%s holds a monopoly and raises the prices of both items by 2." "$participant1"
      p1Offer[0]="$((p1Offer[0]+2))"
      p1Offer[0]="$((p1Offer[0]+2))"
    fi
  else
     printf "%s's wallet has only %s in it. He can't afford to buy %s offered for %s.\n" "$participant1" "$wallet1" "$p2Owns" "$p2Offer"
  fi
  fi
  if [ "${p1Owns[0]}" != "" ]; then
  if [ "$wallet2" -ge "${p1Offer[0]}" ]; then
    printf "%s buys %s from %s for %s and has %s left in his wallet and %s in %s's wallet. The item's price will increase by 1.\n" "$participant2" "${p1Owns[0]}" "$participant1" "${p1Offer[0]}" "$wallet2" "$wallet1" "$participant1"
    [ ! -z "${p2Owns[1]}" ] && p2Owns[0]="${p2Owns[1]}"
    p2Owns[1]="${p1Owns[0]}"
    p1Owns[0]="${p1Owns[1]}"
    p1Owns[1]=""
    [ ! -z "${p1Offer[1]}" ] && p2Offer[0]="${p2Offer[1]}"
    p2Offer[0]="$((${p1Offer[0]}+1))"
    p1Offer[0]="${p1Offer[1]}"
    p1Offer[1]=""
    if [ "${p2Owns[0]}" == "$itemA" ] && [ "${p2Owns[1]}" == "$itemB" ] || [ "${p2Owns[0]}" == "$itemB" ] && [ "${p2Owns[1]}" == "$itemA" ]; then
      printf "%s holds a monopoly and raises the prices of both items by 2." "$participant2"
      p1Offer[0]="$((p1Offer[0]+2))"
      p1Offer[0]="$((p1Offer[0]+2))"
    fi
  else
     printf "%s's wallet has only %s in it. He can't afford to buy %s offered for %s.\n" "$participant2" "$wallet2" "$p1Owns" "$p1Offer"
  fi
  fi
  sleep 1
done
