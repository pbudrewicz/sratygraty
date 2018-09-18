#!/bin/bash

### author: p.budrewicz

. $( dirname $0 )/user.key 


curl -s -X GET  http://$bridge_ip/api/$user_key/config
