#!/bin/bash

### author: p.budrewicz

. $( dirname $0 )/user.key 

if [ "$1" != "" ] ; then
  for light ; do 
    curl -s -X GET  http://$bridge_ip/api/$user_key/lights/$light
  done
else
  curl -s -X GET  http://$bridge_ip/api/$user_key/lights
fi

