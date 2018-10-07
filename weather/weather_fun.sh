#!/bin/bash

PATH=$PATH:~/sratygraty/scripts
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


is_today () {
  if [ "$1" = "$THE_DAY" ] ; then
	  return 1
  else
	  return 0
  fi
}

MAX_TEMP=-50
MAX_DATE=""
for i in $(seq 0 $(( $CAST_COUNT - 1 )) ) ; do
    temperature=$( weather get "{list}[$i]{main}{temp}" )
    T=$( C_from_K $temperature )
    condition=$( weather get "{list}[$i]{weather}[0]{main}" ) 
    date=$( weather get "{list}[$i]{dt_txt}" )
    if is_today $date ; then continue ; else echo showing $date; fi 
    COLOR=$( $DIR/../hue/temp2color.sh $T)
    echo $date $condition $T color:$COLOR
    $DIR/../hue/hue -l 3 set color xy $COLOR 200
    sleep 2
    if [ "$condition" = "Rain" ] ; then
      echo ...raining...
      $DIR/../hue/hue -l 3 pulse xy $VIOLET_COLOR 100 -p 1
    fi	
    if [ "$( echo "$T > $MAX_TEMP"|bc)" = "1" ] ; then
	MAX_TEMP=$T
	MAX_DATE=$date
    fi	
done
echo MAX T = $MAX_TEMP at $MAX_DATE
$DIR/../hue/hue -l 3 set color xy $( $DIR/../hue/temp2color.sh $MAX_TEMP ) 200 -v

