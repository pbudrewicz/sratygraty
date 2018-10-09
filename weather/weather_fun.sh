#!/bin/bash

PATH=$PATH:~/sratygraty/scripts:~/sratygraty/hue
DATA=/tmp/weather_info.dat
DIR=$( dirname $0 )

. $DIR/../hue/colors.sh

if [ "$1" = "-f" ] ; then
    $DIR/get_weather.sh -f > $DATA
    shift
fi

if [ "$1" != "" ] ; then
   THE_DAY=$( date --date "$1" +%Y-%m-%d )
else
   THE_DAY=$( date +%Y-%m-%d )
fi	

weather () {
    json_select.pl "$@" < $DATA
}

deb () {
  : echo "$@" >&2
}

C_from_K () {
  echo "$1" - 273.15 | bc
}	

CAST_COUNT=$( weather count '{list}' )


is_the_day () {
  if [ "$1" = "$THE_DAY" ] ; then
	  return 1
  else
	  return 0
  fi
}

hue -l 3 set light off
hue -l 3 set color xy 0.35 0.35 1 
sleep 1
hue -l 3 alert 
sleep 4

MAX_TEMP=-50
MAX_DATE=""
for i in $(seq 0 $(( $CAST_COUNT - 1 )) ) ; do
    temperature=$( weather get "{list}[$i]{main}{temp}" )
    T=$( C_from_K $temperature )
    condition=$( weather get "{list}[$i]{weather}[0]{main}" ) 
    date=$( weather get "{list}[$i]{dt_txt}" )
    if is_the_day $date ; then continue ; fi 
    COLOR=$( $DIR/../hue/temp2color.sh $T)
    echo $date $condition $T 
    hue -l 3 set color xy $COLOR 1 
    sleep 1
    hue -l 3 alert 
#    sleep 1
    if [ "$condition" = "Rain" ] ; then
      sleep 1
      echo ...raining...
      $DIR/../hue/hue -l 3 pulse xy $VIOLET_COLOR 200 -p 1
    fi	
    if [ "$( echo "$T > $MAX_TEMP"|bc)" = "1" ] ; then
	MAX_TEMP=$T
	MAX_DATE=$date
    fi	
done
echo MAX T = $MAX_TEMP at $MAX_DATE
$DIR/../hue/hue -l 3 set color xy $( $DIR/../hue/temp2color.sh $MAX_TEMP ) 200 -v

