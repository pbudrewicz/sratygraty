#!/bin/bash

### author: p.budrewicz

tac $( dirname $0 )/data/sunrise-120.dat |$(dirname $0)/show_light_sequence.sh $1 "$2" 
$( dirname $0 )/lights_off.sh $2
