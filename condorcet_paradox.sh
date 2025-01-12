#!/bin/sh
#############################################################################################
# Condorcet Paradox                                                                         #                
#                                                                                           #
# The paradox of democracy as a representation of the preference of the majority. The Monte #
# Carlo simulation here calculates the probability of having a winner of an election who is #
# not the most popular preference among voters across different election systems.           #
#                                                                                           #
# Conceptualized and developed by: Muhammad Moneib                                          #
#############################################################################################
#TODO Add parsing of parameters.
#TODO Add a print_verbos function to include output which is not directly part of the result.
#TODO Add option of raw output.
#TODO Add input parameters and remove hard-coded variables.
#TODO Group printing at the end of the script.
#TODO Add comment to explain the steps.
#TODO Add comparison of the winner and the popular candidate.
#TODO Interpret te cycles in the case of an Order of Preference system.

candidates=('A' 'B' 'C')
availableScoresOfRanks=(3 5 8)
numOfCandidates=${#candidates[@]}
#electionSystem="approval"
electionSystem="single_choice"
numOfBallots=1000
votes=()
rankedOrderOfPreference=() # The underlying ranking abstracted by the limiting voting system.
output=""
[ "$electionSystem" == "approval" ] && echo "The Condorcet paradox with regards to an Approval voting system lies in abstraction, where the scores of all approved candidates per a voter being the same regardless of his preferences. This may evade the Condorcet cycles theoretically, but it doesn't evade the fact that the really most preferred candidate may lose the vote."
[ "$electionSystem" == "single_choice" ] && echo "The Condorcet paradox with regards to a Single Choice voting system lies in ommmission, where the order of preference among all candidates from the voter's ballot is absent. This may evade the Condorcet cycles theoretically, but it doesn't evade the fact that the really most preferred candidate may lose the vote."
[ "$electionSystem" == "order_of_preference" ] && echo "The Condorcet paradox with regards to an Order of Preference voting system lies in ambiguity inherent in the essence of the paradox itself. Condorcet cycles may emerge, maniefested as the lack of emergence of a distinguished popular choice."
for (( i=0; i<numOfBallots; i++ )); do
  if [ "$electionSystem" == "approval" ]; then
    for (( j=0; j<numOfCandidates; j++ )); do
      votes+=( $(( RANDOM%2  )) )
    done
  elif [ "$electionSystem" == "single_choice" ]; then
    chosenCandidate=$(( RANDOM%numOfCandidates ))
    for (( j=0; j<numOfCandidates; j++ )); do
      if [ "$j" == "$chosenCandidate" ]; then
        votes+=(1)
      else
        votes+=(0)
      fi
    done
  fi
  numberOfPositiveVotes=0
  for (( j=${#votes[@]}-numOfCandidates; j<${#votes[@]}; j++ )); do # Looping through the last ballot.
    if [ "${votes[j]}" == "1" ]; then
      numberOfPositiveVotes=$(( numberOfPositiveVotes+1 ))
    fi
    numberOfNonPositiveVotes=$(( numOfCandidates-numberOfPositiveVotes ))
  done
  assignedScoresFor1=()
  assignedScoresFor0=()
  for (( j=${#votes[@]}-numOfCandidates; j<${#votes[@]}; j++ )); do # Looping through the last ballot.
   if [ "${votes[j]}" == "0" ]; then
      while ((1)); do
        scoreToAssign=$(( RANDOM%numberOfNonPositiveVotes ))
        lookForOtherScore=0
        for (( k=0; k<${#assignedScoresFor0[@]}; k++ )); do
          [ "$scoreToAssign" == "${assignedScoresFor0[k]}" ] && lookForOtherScore=1 && break
        done
        [ "$lookForOtherScore" == "0" ] && break
      done
      rankedOrderOfPreference+=(${availableScoresOfRanks[scoreToAssign]})
      assignedScoresFor0+=($scoreToAssign)
    else
      while ((1)); do
        scoreToAssign=$(( numberOfNonPositiveVotes+RANDOM%numberOfPositiveVotes  ))
        lookForOtherScore=0
        for (( k=0; k<${#assignedScoresFor1[@]}; k++ )); do
          [ "$scoreToAssign" == "${assignedScoresFor1[k]}" ] && lookForOtherScore=1 && break
        done
        [ "$lookForOtherScore" == "0" ] && break
      done
      rankedOrderOfPreference+=(${availableScoresOfRanks[scoreToAssign]})
      assignedScoresFor1+=($scoreToAssign)
   fi
  done
done
voteScores=()
echo "Votes:"
for (( i=0; i<${#votes[@]}; i++ )); do
  score=${voteScores[$(( i%${#candidates[@]} ))]}
  [ -z "$score" ] && score=0 || score=$(( score+${votes[i]} ))
  voteScores[$(( i%${#candidates[@]} ))]=$score
  output+="${votes[i]}"
  [ "$(( (i+1)%${#candidates[@]} ))" != "0" ] && output+="," || output+="\n"
done
printf "$output"
voteRanks=()
echo "Ranked Scores:"
for (( i=0; i<${#rankedOrderOfPreference[@]}; i++ )); do
  rank=${voteRanks[$(( i%${#candidates[@]} ))]}
  [ -z "$rank" ] && rank=0 || rank=$(( rank+${rankedOrderOfPreference[i]} ))
  voteRanks[$(( i%${#candidates[@]} ))]=$rank
  rankedOutput+="${rankedOrderOfPreference[i]}"
  [ "$(( (i+1)%${#candidates[@]} ))" != "0" ] && rankedOutput+="," || rankedOutput+="\n"
done
printf "$rankedOutput"
echo "Overall Score =  ${voteScores[@]}"
echo "Overall Rank =  ${voteRanks[@]}"
