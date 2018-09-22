#!/bin/bash

### author: p.budrewicz

SLEEP=$1
shift
light=$1

. $( dirname $0 )/user.key 

while read x y b ; do 
   echo ======================= $x $y $b   
     curl -s -X PUT -d '{"on":true, "xy":['$x', '$y'], "bri":'$b'}' http://$bridge_ip/api/$user_key/lights/$light/state > /dev/null
   sleep $SLEEP
   if [ "$( $( dirname $0 )/get_on_off.sh $light )" = "false" ] ; then
     $( dirname $0 )/set_color.sh $light hue 254 45000 
     $( dirname $0 )/lights_off.sh $light
     exit 0
   fi
done 
