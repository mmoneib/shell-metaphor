#!/bin/sh
#############################################################################################
# The Irreducible Market                                                                    #                
#                                                                                           #
# Employing reductionism has always been used by science to uncover the mysteries of our    #
# lives using the technique of modelling complex systems in simpler circumstances that      #
# ignore whatever is considered as noise.. In this  # "thought experiment", I reduce a      #
# market to its most basic form of 2 participants and 2 products, effectively removing the  #
# noises of choice, abundance, and scarcity. For this simple model, I choose 2 products,    #
# a hat and a wig, which are mutually-exclusive in terms of used, yet complement each other #
# in a certain way. This justifies the cycle of buying and selling between the 2            #
# participants whose name are chosen based on perceived competitiveness and hair-loss       #
# issues. The opposite transactions are only allowed to be simultaneous here in order to    #
# prevent monopoly and the subsequent failure of the market.                                #
# The experiment reveals fundamental characteristics about capital markets, sustainability, #
# and the dynamics of pricing.                                                              #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

participant1="Elon"
wallet1=20
participant2="Jeff"
wallet2=20
itemA="wig"
priceA=1
itemB="hat"
priceB=1

p1Owns="$itemA"
p1Offer="$priceA"
p2Owns="$itemB"
p2Offer="$priceB"

printf "%s has %s in his wallet." "$participant1" "$wallet1"
printf "%s has %s in his wallet." "$participant2" "$wallet2"
while true; do
  printf "%s offers %s for price %s.\n" "$participant1" "$p1Owns" "$p1Offer"
  printf "%s offers %s for price %s.\n" "$participant2" "$p2Owns" "$p2Offer"
  if [ "$wallet1" -lt "$p2Offer" ] && [ "$wallet1" -lt "$p2Offer" ]; then
    echo "A mutual transaction fails..."
    if [ "$wallet1" -lt "$p2Offer" ]; then
      printf "%s's wallet has only %s in it. He can't afford to buy %s offered for %s.\n" "$participant1" "$wallet1" "$p2Owns" "$p2Offer"
    fi
    if [ "$wallet2" -lt "$p1Offer" ]; then
      printf "%s's wallet has only %s in it. He can't afford to buy %s offered for %s.\n" "$participant2" "$wallet2" "$p1Owns" "$p1Offer"
    fi
    printf "Since one or both participants can't affor a transaction, both items' prices will be reduced by 1.\n"
    priceA="$(($priceA-1))"
    priceB="$(($priceB-1))"
    if [ "$p1Owns" == "itemA" ]; then
      p1Offer="$priceA"
      p2Offer="$priceB"
    else
      p1Offer="$priceB"
      p2Offer="$priceA"
    fi
  else
    echo "A mutual transaction starts..."
    if [ "$wallet1" -ge "$p2Offer" ]; then
      wallet1="$(($wallet1-$p2Offer))"
      wallet2="$(($wallet2+$p2Offer))"
      printf "%s buys %s from %s for %s and has %s left in his wallet and %s in %s's wallet. The item's price will increase by 1.\n" "$participant1" "$p2Owns" "$participant2" "$p2Offer" "$wallet1" "$wallet2" "$participant2"
      if [ "$p2Owns" == "$itemB" ]; then
        priceB="$(($priceB+1))"
        p2Offer="$priceB"
      else
        priceA="$(($priceA+1))"
        p2Offer="$priceA"
      fi
    fi 
    if [ "$wallet2" -ge "$p1Offer" ]; then
      wallet2="$(($wallet2-$p1Offer))"
      wallet1="$(($wallet1+$p1Offer))"
      printf "%s buys %s from %s for %s and has %s left in his wallet and %s in %s's wallet. The item's price will increase by 1.\n" "$participant2" "$p1Owns" "$participant1" "$p1Offer" "$wallet2" "$wallet1" "$participant1"
      if [ "$p1Owns" == "$itemB" ]; then
        priceB="$(($priceB+1))"
        p1Offer="$priceB"
      else
        priceA="$(($priceA+1))"
        p1Offer="$priceA"
      fi
    fi
    tmpOwns="$p1Owns"
    p1Owns="$p2Owns"
    p2Owns="$tmpOwns"
    tmpOffer="$p1Offer"
    p1Offer="$p2Offer"
    p2Offer="$tmpOffer"
  fi
  sleep 1
done
