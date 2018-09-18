#!/bin/bash

if [ -t 0 ] ; then
  echo I do not think you know how to use it
  echo "Usage: $0 [ n [ regex [ output [ starting_counter ] ] ] ]"
  echo "this adds output line every n lines matching regex passing stdin to stdout"
  exit 1
fi

every=$1
regex=$2
what=$3

if [[ "$every" == "" ]] ; then
  every=1
fi

if [[ "$regex" == "" ]] ; then
  regex='.*'
fi

if [[ "$what" == "" ]] ; then
  what='========================================'
fi

if [[ "$4" == "" ]] ; then
  cnt=0;
else
  cnt=$4
fi

while read line  ; do
  echo $line
  if [[ $line =~ $regex ]] ; then
    cnt=$[ $cnt + 1 ]
    if [[ $[ $cnt % $every ] == 0 ]]  ; then
      echo $what
    fi
  fi
done
