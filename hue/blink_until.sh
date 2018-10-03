#!/bin/bash

### author: p.budrewicz

TIME=$1
shift

if [ "$TIME" = "" ] ; then
  echo "Usage: $0 time light [light [...]]"
  exit 1
fi

UNTIL=$( date --date $TIME +%s)

$( dirname $0)/lights_on.sh $*
sleep 1 # wait 4 reaction

while [ $( date +%s )  -lt $UNTIL ] ; do
  echo $( date +%s ) : $UNTIL 
  for light; do
    STATE="$( $( dirname $0)/get_on_off.sh $light )" 
    if [ "$STATE" = "true" ] ; then
      $(dirname $0)/alert.sh $light
    else
      exit 0
    fi

  done


  sleep 1
done

