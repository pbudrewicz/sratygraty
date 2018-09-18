#!/bin/bash

### author: p.budrewicz

v=$1
shift

if [ "$1" = "" ] ; then
  echo "$0 brightness light_list"
  exit 0
fi

. $( dirname $0 )/user.key 

for light do
  curl -s -X PUT -d '{"sat":'$v'}' http://$bridge_ip/api/$user_key/lights/$light/state 
done
