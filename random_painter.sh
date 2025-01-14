#!/bin/sh

width=10
height=10
charset="* "
canvas=""
numOfChars=$(( width*height  ))
isSticky="true"
empty=" "
stickies=()
pixels=()
[ "$isSticky" == "true" ] && lazyInitializeSticky="true" && isSticky="false"
while true; do
  if [ "$isSticky" == "true" ]; then
    for (( p=0;p<numOfChars;p++ )); do
      leftPos=$(( p-1 ))
      rightPos=$(( p+1 ))
      upPos=$(( p-width ))
      downPos=$(( p+width ))
      [ $upPos -lt 0 ] && upPos=0
      [ $downPos 
      charLeft=${canvas:(( p-1 )):1}
      charRight=${canvas:(( p+1 )):1}
      charUp=${canvas:(( p-width )):1}
      charDown=${canvas:(( p+width )):1}
      #[ "$charLeft" == "\n" ] && charLeft=" "
      #[ "$charRight" == "\n" ] && charRight=" "
      #[ "$charUp" == "\n" ] && charUp=" "
      #[ "$charDown" == "\n" ] && charDowb=" "
      if [ "$charLeft$charRight$charUp$charDown" != "    " ]; then
echo "$charLeft$charRight$charUp$charDown" && exit
        stickies[$p]="${canvas:p:1}"
      else
        stickies[$p]=" "
      fi
    done
echo "$charLeft$charRight$charUp$charDown"
#exit
  fi
  [ "$lazyInitializeSticky" == "true" ] && lazyInitializeSticky="false" && isSticky="true"
  canvas=""
  tput reset
  for (( l=0; l<height; l++ )); do
    for (( p=0; p<width; p++ )); do
      [ "$isSticky" == "true" ] && [ "${stickies[(( ( (l+1)*width )+p ))]}" != " " ] && continue || char="${stickies[(( ( (l+1)*width )+p ))]}"
      [ "$isSticky" == "false" ] && char="${charset:$(( RANDOM%${#charset} )):1}" 
      canvas+="$char"
    done
    canvas+="\n"
  done
  printf "$canvas"
  sleep 1
done
