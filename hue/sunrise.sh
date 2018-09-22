#!/bin/bash

### author: p.budrewicz

$(dirname $0)/lights_on.sh "$2"
$(dirname $0)/show_light_sequence.sh $1 "$2" < $(dirname $0)/data/sunrise-96.dat
