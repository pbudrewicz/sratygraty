#!/bin/bash

### author: p.budrewicz

light=$1
if [ "$light" = "" ] ; then
  echo ERROR: Usage $0 light >&2
  exit 255
fi

if [ "$( dirname $0 )/get_lights.sh $light |json_pp |perl -ne 'print \$1 if m/\"on\" : (\\w+),/'" = "true" ] ; then
  exit 0
else
  exit 1
fi
