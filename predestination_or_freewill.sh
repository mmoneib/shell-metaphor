#!/bin/bash
#############################################################################################
# Predestination or Free Will?                                                              #                
#                                                                                           #
# Life is a mystery of our own creation, and randomness is the measure of our ignorance. We #
# experience our freedom as well as our limitations at the very same moment, which implies  #
# that both opposites are expressed in unison. With that in mind, and more to exoplore,     #
# PDoFW is a very simple "thought experiment" that has a touch of story-telling,            #
# philosophy, and technology in its soup. Only if you dare to drink it.                     #
# The game is meant to be abstract, symbolic, and highly probablistic, hence open for       # 
# interperations. It is exhaustive by design.                                               #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

destiny=();
clear
sleep 0.8s;
echo "* Hello!";
sleep 2.2s;
echo "* Welcome to the world!";
sleep 3.5s;
echo "* It's not the best of place, I know...but you have to blame your ancestors. Afterall, they are the ones who did the OS.";
sleep 5s;
echo "* Okay, okay. It's just a temporary situation, and you know what? You will find yourself lots of company here. ;-)"
sleep 6.8s;
echo "* Aaaaaaaaaaannny way... Let's get down to business, you grumpy mortal."
sleep 3.5s;
echo "* Which do you prefer? Predestination or Free Will? Choose wisely, if you can.;-)"
read inp; # No validation since the choice doesn't matter.
sleep 1s;
echo "* Fantastic choice!";
sleep 1.6s;
echo "* Now, to make it easier for both of us, and a bit more more fun..."
sleep 3.7s;
echo "* To know your destination, you have to guess it."
sleep 2.7s;
echo "* Again, may I remind you to choose wisely. :-)";
sleep 1.8s;
echo "* Pick a number from 1 to 100.";
while (true); do
  read inp; 
  if (($inp<1 || $inp>100)); then
    destiny+=$inp;
    sleep 2s;
    echo "* Are you kidding me? Pick a number from 1 to 100.";
    sleep 1.8s;
  elif (($inp==($RANDOM%100)+1)); then
    sleep 6s;
    echo "* Congratulations! You have chosen your destiny and it's $destiny.";
    break;
  else
    sleep 6s;
    echo "* You haven't chosen your destiny yet. Keep looking. Pick a number from 1 to 100.";
    sleep 2s;
  fi
done
sleep 2.6s;
echo "* Good luck!";

# TODO Add cheat detection only to display a reply abput cheating. Mo othe action should be invoked.
