#!/bin/bash

### author: p.budrewicz

if [ "$1" = "" ] ; then
  echo "$0 light_list"
  exit 0
fi


. $( dirname $0 )/user.key 


for light do
   curl -s -X PUT -d '{"alert":"select"}' http://$bridge_ip/api/$user_key/lights/$light/state 
done
