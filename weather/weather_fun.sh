#!/bin/bash

PATH=$PATH:~/sratygraty/scripts:~/sratygraty/hue:~/sratygraty/weather
DATA_CACHE=/tmp/weather_fun_info.dat
DIR=$( dirname $0 )

. $DIR/../hue/colors.sh

if [ "$1" = "-f" ] ; then
    $DIR/get_weather.sh -f > $DATA_CACHE
    shift
fi

if [ "$1" != "" ] ; then
   THE_DAY=$( date --date "$1" +%Y-%m-%d )
else
   THE_DAY=$( date +%Y-%m-%d )
fi	

weather () {
    json_select.pl "$@" < $DATA_CACHE
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

#hue -l 3 set light off
hue -l 3 set color xy 0.35 0.35 1 
sleep 3

MAX_TEMP=-50
MAX_DATE=""
for i in $(seq 0 $(( $CAST_COUNT - 1 )) ) ; do
    temperature=$( weather get "{list}[$i]{main}{temp}" )
    T=$( C_from_K $temperature )
    condition=$( weather get "{list}[$i]{weather}[0]{main}" ) 
    date=$( weather get "{list}[$i]{dt_txt}" )
    if is_the_day $date ; then continue ; fi 
    COLOR=$( temp2color.sh $T)
    echo $date $condition $T 
    hue -l 3 set color xy $COLOR 200
    sleep 1
    #hue -l 3 alert 
#    sleep 1
    if [ "$condition" = "Rain" ] ; then
	sleep 1
	echo ...raining...
	hue -l 3 pulse xy $BLUE_COLOR 100 -p 1
    elif [ "$condition" = "Snow" ] ; then
	sleep 1
	echo ...snowing...
	hue -l 3 pulse xy $WHITE_COLOR 200 -p 1
    elif [ "$condition" = "Mist" ] ; then
	sleep 1
	echo ...fog...
	hue -l 3 pulse xy $WHITE_COLOR 1 -p 1
    fi	
    if [ "$( echo "$T > $MAX_TEMP"|bc)" = "1" ] ; then
	MAX_TEMP=$T
	MAX_DATE=$date
    fi	
done
echo MAX T = $MAX_TEMP at $MAX_DATE
hue -l 3 set color xy $( temp2color.sh $MAX_TEMP ) 200 -v

