#!/bin/bash

### author: p.budrewicz

if [ "$1" = "" ] ; then
  echo "$0 light_list (xy|ct|hue) bri (x y|ct|hue)"
  echo "  bri 1-254 ; ct - 153 - 500 (cold - warm)"
  exit 0
fi


lights="$1"
schema=$2
b=$3

. $( dirname $0 )/user.key 


for light in $lights do
  case $schema in
	xy)	
           curl -s -X PUT -d '{"on":true, "xy":['$4', '$5'], "bri":'$b'}' http://$bridge_ip/api/$user_key/lights/$light/state 
         ;;
       ct)
           curl -s -X PUT -d '{"on":true, "ct":'$4', "bri":'$b'}' http://$bridge_ip/api/$user_key/lights/$light/state 
        ;;
       hue)
           curl -s -X PUT -d '{"on":true, "hue":'$4', "bri":'$b'}' http://$bridge_ip/api/$user_key/lights/$light/state 
       ;;
  esac
done
