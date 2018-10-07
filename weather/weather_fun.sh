#!/bin/bash

PATH=$PATH:~/sratygraty/scripts
DATA=/tmp/weather_info.dat
DIR=$( dirname $0 )

if [ "$1" = "-f" ] ; then
    $DIR/get_weather.sh -f > $DATA
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
  TODAY=$( date +%Y-%m-%d )
  if [ "$1" = "$TODAY" ] ; then
	  return 1
  else
	  return 0
  fi
}

for i in $(seq 0 $(( $CAST_COUNT - 1 )) ) ; do
    temperature=$( weather get "{list}[$i]{main}{temp}" )
    T=$( C_from_K $temperature )
    condition=$( weather get "{list}[$i]{weather}[0]{main}" ) 
    date=$( weather get "{list}[$i]{dt_txt}" )
    if is_today $date ; then break ; fi 
    COLOR=$( $DIR/../hue/temp2color.sh $T)
    echo $date $condition $T color:$COLOR
    $DIR/../hue/hue -l 3 set color xy $COLOR 200
    sleep 1
done
