#!/bin/sh
#############################################################################################
# Opposing FOrces                                                                           #                
#                                                                                           #
# A simulation of the action of opposing forces, represented as linear ramps, on a signal,  #
# which shows how the interaction of those forces affect the shape and nature of the        #
# signal. The simple model done here explores the notions of non-linearity, uncertainty,    #
# and disorder, with various patterns emerging with a mix of periodicity, oscillations,     #
# and linearity.                                                                            #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

signal=($(seq -s " " 0 99))
forcesPhaseShifts=($(seq -s " " 1 100))
numOfForces=60
signs=(1 1 -1 -1 -1 1 -1 -1 1 1 1 1 -1 -1 1 -1)

for ((f=0; f<numOfForces;f++)); do
  prefix=""
  for ((p=0; p<$((f+1)); p++)); do
    prefix="$prefix""0 "
  done
  prefixCount=$((f+1))
  echo $prefixCount
  eval "force$prefixCount=($prefix $(seq -s " " 0 $((99-$f-1))))"
done

equation=""
for ((i=1; i<=numOfForces; i++)); do
  varrName="force$i"
  varrName2="$varrName"
  printf "%s %s\n" "Force$i: " "$(eval echo '${'"$varrName2"'[@]}')"
  if [ ${signs[$(($((i-1))%${#signs[@]}))]} -lt 0 ]; then 
    sign="-" 
  else 
    sign="+"
  fi
  equation+="$sign""Force$i"
  c=0
  if [ "$sign" == "-" ]; then
    for e in $(eval echo '${'"$varrName2"'[@]}'); do
      e=$((-1*e))
      eval "$varrName2"'[$c]'=$e
      ((c++))
    done
  fi
done

echo "Equation: Signal$equation"

outputSignal=()
for ((i=0; i<${#signal[@]}; i++)); do
  value=${signal[0]}
  for ((j=1;j<=$numOfForces;j++)); do
    varrName="force$j"
    varrName2="$varrName"
    forceValue=$(eval echo '${'"$varrName2""[$i]}")
    value=$((value+forceValue))
  done
  outputSignal[$i]=$value
done

echo "Output Signal: ${outputSignal[@]}"
