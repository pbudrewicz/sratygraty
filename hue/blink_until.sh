#!/bin/bash

### author: p.budrewicz

TIME=$1
shift

if [ "$TIME" = "" ] ; then
  echo "Usage: $0 time light [light [...]]"
  exit 1
fi

UNTIL=$( date --date $TIME +%s)

# $( dirname $0)/lights_on.sh $* -- replaced below
for l ; do hue -l $l on ; done
sleep 1 # wait 4 reaction

while [ $( date +%s )  -lt $UNTIL ] ; do
  echo $( date +%s ) : $UNTIL 
  for light; do
    STATE="$( hue get onoff $light )" 
    if [ "$STATE" = "1" ] ; then
	curl -s -X PUT -d '{"alert":"select"}' http://$bridge_ip/api/$user_key/lights/$light/state	
    else
      exit 0
    fi

  done
  sleep 1
done

