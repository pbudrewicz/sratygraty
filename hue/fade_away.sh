#!/bin/bash

### author: p.budrewicz

sleep=$1
shift
light=$1

if [ "$1" = "" ] ; then
  echo "$0 sleep light"
  exit 0
fi


. $( dirname $0 )/user.key 

cd $( dirname $0 )

b=$(  ./get_lights.sh $light |json_pp |perl -ne 'print $1 if m/"bri"\s*:\s*(\d+),/' )
while [ $b -gt 0 ] ; do
   $( dirname $0 )/set_brightness.sh $b $light
   sleep $sleep
   b=$(( $b - 1 ))
done


$( dirname $0 )/lights_off.sh $light

