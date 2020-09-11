#!/bin/bash

### author: p.budrewicz

if [ "$1" = "" ] ; then
  echo "$0 light_list"
  exit 0
fi


. $HOME/etc/user.key 


for light do
   curl -s -X PUT -d '{"on":true}' http://$bridge_ip/api/$user_key/lights/$light/state 
done
