#!/bin/bash

### author: p.budrewicz

SLEEP=$1
shift

. $( dirname $0 )/user.key 

while read x y b ; do 
   echo ======================= $x $y $b   
   for light ; do 
     curl -s -X PUT -d '{"on":true, "xy":['$x', '$y'], "bri":'$b'}' http://$bridge_ip/api/$user_key/lights/$light/state 
   done
  sleep $SLEEP
done 
