#!/bin/bash

### author: p.budrewicz

b=$1
shift

if [ "$1" = "" ] ; then
  echo "$0 brightness light_list"
  exit 0
fi

. $( dirname $0 )/user.key 

for light do
  curl -s -X PUT -d '{"bri":'$b'}' http://$bridge_ip/api/$user_key/lights/$light/state 
done
