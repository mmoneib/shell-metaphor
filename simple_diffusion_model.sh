#!/bin/sh
#############################################################################################
# Simple Diffusion Model                                                                    #                
#                                                                                           #
# A simple way of modelling diffusion of two inter-mixing populations of elements and       # 
# measuring the degree of mixture as the time passes by through the purity of the mix       #
# compared to the original population into which the flow is directed.                      #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################

originalPopulation=5000000
flowingPopulation=1000000
growthRateOfOriginal=1.02
growthRateOfFlowing=1.05
rateOfFlow=0.04
periods=1000
currentPeriod=1
organicOriginalPopulation=$originalPopulation
totalOriginalPopulation=$originalPopulation

echo "Start of the Population Flow of Elements simulation through $periods periods."
while [ $currentPeriod -le $periods ]; do
  organicOriginalPopulation=$(echo "scale=5;$organicOriginalPopulation*$growthRateOfOriginal"|bc -l)
  totalOriginalPopulation=$(echo "scale=5;$totalOriginalPopulation*$growthRateOfOriginal"|bc -l)
  flowingPopulation=$(echo "scale=5;$flowingPopulation*$growthRateOfFlowing"|bc -l)
  numOfFlowingElements=$(echo "scale=5;$flowingPopulation*$rateOfFlow"|bc -l)
  totalOriginalPopulation=$(echo "scale=5;$totalOriginalPopulation+$numOfFlowingElements"|bc -l)
  flowingPopulation=$(echo "scale=5;$flowingPopulation-$numOfFlowingElements"|bc -l)
  purityOfOrigin=$(echo "scale=5;$organicOriginalPopulation/$totalOriginalPopulation"|bc -l)
  currentPeriod=$(( $currentPeriod + 1 ))

  echo "Period $currentPeriod: Original Population = $totalOriginalPopulation -- Flowing Population = $flowingPopulation -- Number of Migrants = $numOfFlowingElements -- Purity of Origin = $purityOfOrigin."
done
echo "End of the Population Flow of Elements simulation through $periods periods."
