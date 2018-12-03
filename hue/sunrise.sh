#!/bin/bash

### author: p.budrewicz

$(dirname $0)/lights_on.sh "$2"
$(dirname $0)/show_light_sequence.sh $1 "$2" < $(dirname $0)/data/sunrise-96.dat
#$( dirname $0 )/hue -l $2 color ct 153 254
#$( dirname $0 )/hue -l $2 transit ct 300 254 -s 150 -p 1
