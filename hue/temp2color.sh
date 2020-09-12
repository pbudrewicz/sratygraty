#!/bin/bash

PATH=$PATH:~/sratygraty/scripts
DIR=$( dirname $0 )

. $DIR/colors.env

deb () {
   : echo "$@" >&2
}

deb $RED_COLOR
deb $ORANGE_COLOR
deb $YELLOW_COLOR
deb $GREEN_COLOR
deb $CYAN_COLOR
deb $BLUE_COLOR

RED_POINT=35
ORANGE_POINT=25
YELLOW_POINT=15
GREEN_POINT=5
ZERO_POINT=0
CYAN_POINT=-5
BLUE_POINT=-15

interpolate () {

  deb "$@"
  LEFT=$1
  RIGHT=$2
  LCOLORX=$3
  LCOLORY=$4
  RCOLORX=$5
  RCOLORY=$6
  VALUE=$7
  FRAC=$( calc "( $VALUE  - $LEFT ) / ( $RIGHT - $LEFT )" )
  deb frac:$FRAC
  COLX=$( calc "$LCOLORX + $FRAC * ($RCOLORX - $LCOLORX)")
  deb x:$COLX
  COLY=$( calc "$LCOLORY + $FRAC * ($RCOLORY - $LCOLORY)" )
  deb x:$COLY
  echo $COLX $COLY
}

calc () {
    RES="$( echo "$@" | bc -l )"
    printf "%f" $RES
}

CONTINOUS_RANGE=1  ###

color_from_C () {
  T=$1
  if [ "$( echo "$T > $RED_POINT"|bc)" = "1" ] ; then
    deb red
    echo $RED_COLOR
  elif [ "$( echo "$T > $ORANGE_POINT"|bc)" = "1" ] ; then
    deb orange red
    interpolate $ORANGE_POINT $RED_POINT $ORANGE_COLOR $RED_COLOR $T
  elif [ "$( echo "$T > $YELLOW_POINT"|bc)" = "1" ] ; then
    deb yellow orange 
    interpolate $YELLOW_POINT $ORANGE_POINT $YELLOW_COLOR $ORANGE_COLOR $T
  elif [ "$( echo "$T > $GREEN_POINT"|bc)" = "1" ] ; then
    deb green yellow 
    interpolate $GREEN_POINT $YELLOW_POINT $GREEN_COLOR $YELLOW_COLOR $T
  elif [ "$( echo "$T >= $ZERO_POINT"|bc)" = "1" ] ; then
    deb cyan green 
    interpolate $ZERO_POINT $GREEN_POINT $GREEN_ZERO $GREEN_COLOR $T
  elif [ "$( echo "$T > $CYAN_POINT"|bc)" = "1" ] && [ "$CONTINOUS_RANGE" = "1" ] ; then
    deb blue cyan 
    interpolate $CYAN_POINT $ZERO_POINT $CYAN_COLOR $GREEN_ZERO $T
  elif [ "$( echo "$T > $BLUE_POINT"|bc)" = "1" ] && [ "$CONTINOUS_RANGE" = "1" ] ; then
    deb blue cyan 
    interpolate $BLUE_POINT $CYAN_POINT $BLUE_COLOR $CYAN_COLOR $T
  elif [ "$( echo "$T > $BLUE_POINT"|bc)" = "1" ] ; then
    deb blue cyan 
    interpolate $BLUE_POINT $ZERO_POINT $BLUE_COLOR $CYAN_COLOR $T
  else
    deb blue
    echo $BLUE_COLOR
  fi
}

C_from_K () {
  echo "$1" - 273.15 | bc
}	

COLOR=$(color_from_C $1)
echo $COLOR
exit
