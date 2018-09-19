#!/bin/bash

### author: p.budrewicz

TIME=$1
shift

if [ "$TIME" = "" ] ; then
  echo "Usage: $0 time light [light [...]]"
  exit 1
fi

UNTIL=$( date --date $TIME +%s)

while [ $( date +%s )  -lt $UNTIL ] ; do

  $(dirname $0)/alert.sh $*

#  echo still blinking... $(date): $( date +%s) == $(date --date $TIME +%s)

  sleep 1
done

