#!/bin/bash

PATH=$PATH:~/sratygraty/scripts
DATA=/tmp/weather_info.dat
DIR=$( dirname $0 )

. ../hue/colors.sh

# echo $RED_COLOR
# echo $ORANGE_COLOR
# echo $YELLOW_COLOR
# echo $GREEN_COLOR
# echo $CYAN_COLOR
# echo $BLUE_COLOR

RED_POINT=35
ORANGE_POINT=25
YELLOW_POINT=15
GREEN_POINT=5
ZERO_POINT=0
CYAN_POINT=-5
BLUE_POINT=-15

if [ "$1" = "-f" ] ; then
    $DIR/get_weather.sh -f > $DATA
fi

weather () {
    json_select.pl "$@" < $DATA
}

interpolate () {

  deb "$@"
  LEFT=$1
  RIGHT=$2
  LCOLORX=$3
  LCOLORY=$4
  RCOLORX=$5
  RCOLORY=$6
  VALUE=$7
  FRAC=$( echo "( $VALUE  - $LEFT ) / ( $RIGHT - $LEFT )" | bc -l)
  deb frac:$FRAC
  COLX=$(printf "%f" $( echo "$LCOLORX + $FRAC * ($RCOLORX - $LCOLORX)" | bc -l))
  deb x:$COLX
  COLY=$(printf "%f" $( echo "$LCOLORY + $FRAC * ($RCOLORY - $LCOLORY)" | bc -l))
  deb x:$COLY
  echo $COLX $COLY
}

deb () {
  : echo "$@" >&2
}

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

CAST_COUNT=$( weather count '{list}' )

# COLOR=$(color_from_C $1)
# ../hue/hue -l 3 set color xy $COLOR 100

for i in $(seq 0 $(( $CAST_COUNT - 1 )) ) ; do
    temperature=$( weather get "{list}[$i]{main}{temp}" )
    T=$( C_from_K $temperature )
    condition=$( weather get "{list}[$i]{weather}[0]{main}" ) 
    date=$( weather get "{list}[$i]{dt_txt}" )
    COLOR=$( color_from_C $T)
    echo $date $condition $T color:$COLOR
    ../hue/hue -l 3 set color xy $COLOR 200
    sleep 1
done
