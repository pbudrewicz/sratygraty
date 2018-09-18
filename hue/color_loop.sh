#!/bin/bash

### author: p.budrewicz

effect=colorloop
if [ "$1" = "off" ] ; then
  effect=none
  shift
fi

if [ "$1" = "" ] ; then
  echo "$0 [off] light_list"
  exit 0
fi


. $( dirname $0 )/user.key 


for light do
   curl -s -X PUT -d '{"effect":"'$effect'"}' http://$bridge_ip/api/$user_key/lights/$light/state 
done
