#!/bin/bash

### author: p.budrewicz

light=$1
if [ "$light" = "" ] ; then
  echo Usage $0 light
  exit 1
fi

$( dirname $0 )/get_lights.sh $light |json_pp |perl -ne 'print $1 if m/"on" : (\w+),/' 
