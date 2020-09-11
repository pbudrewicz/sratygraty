#!/bin/bash

#TODO: ignore brightness when comparing colors

TZ=UTC

PATH=$PATH:$HOME/sratygraty/scripts

DAYLIGHT_COLOR[0]='xy 0.3137 0.3289 254' # switch
DAYLIGHT_COLOR[1]='xy 0.3103 0.3302 254' # t 6500
DAYLIGHT_COLOR[2]='ct 155 254'           # switch
DAYLIGHT_COLOR[3]='ct 153 254'           # t 6500
SUNSET_HOUR_FILE=$HOME/etc/sunset_hour.dat

if [ "$VERBOSE" = "" ] ; then
	VERBOSE=0
fi


THE_LIGHT="$1"

if [ "$THE_LIGHT" = "" ] ; then
    echo need light nuber
    exit 13
fi

LAST_RUN_FILE=/tmp/auto_dusk_running.$THE_LIGHT

right_color () {
    THE_LIGHT=$1
    shift
    COLOR=$( hue -c get color $THE_LIGHT )
    BRIGHTNESS=$( echo $COLOR | awk '{print $NF }' )
    for THE_COLOR ; do
	[ "$VERBOSE" = 1 ] && echo comparing $COLOR with $THE_COLOR >&2
	if [ "$COLOR" = "$THE_COLOR" ] ; then
	    return 0 # True
	fi
    done
    false
}

get_sunset_hour () {
    if ! [ -f $SUNSET_HOUR_FILE ] ; then
	[ "$VERBOSE" = "1" ] && echo No cache data - querying sunrise-sunset.org >&2
	curl -s 'https://api.sunrise-sunset.org/json?lat=52&lng=21&formatted=0' > $SUNSET_HOUR_FILE
    else
	SUNSET_DATA_DAY=$( date --date "$( ls -l $SUNSET_HOUR_FILE |awk '{print $6, $7, $8}' )" +%Y%m%d )
	TODAY=$( date +%Y%m%d )	
	if [ "$SUNSET_DATA_DAY" != "$TODAY" ] ; then
	    [ "$VERBOSE" = "1" ] && echo Cache is stale - querying sunrise-sunset.org >&2
	    curl -s 'https://api.sunrise-sunset.org/json?lat=52&lng=21&formatted=0' > $SUNSET_HOUR_FILE
	else
	    [ "$VERBOSE" = "1" ] && echo Using cache data for sunset >&2
	fi
    fi    
    cat $SUNSET_HOUR_FILE 
}


time_is_right () {

    SUNSET_HOUR="$( get_sunset_hour | json_select.pl show '{results}{sunset}' | perl -ne 'print $1 if m/T(\d\d:\d\d:\d\d)\+/' )"
    SUNSET_HRS=$( echo $SUNSET_HOUR | cut -d : -f 1 )
    SUNSET_MIN=$( echo $SUNSET_HOUR | cut -d : -f 2 )
    SUNSET_TIME=$( date --date "$SUNSET_HRS:$SUNSET_MIN" +%s ) 
        
    CUR_TIME=$(date +%s)
    IN_AN_HOUR=$(date --date 'next hour' +%s )
    THREE_HOURS_AGO=$(date --date '3 hours ago' +%s)    
    
    if [ "$IN_AN_HOUR" -lt "$SUNSET_TIME" ] ; then
	[ "$VERBOSE" = 1 ] && echo Too early >&2
	false
    elif [ "$THREE_HOURS_AGO" -gt "$SUNSET_TIME" ] ; then
	[ "$VERBOSE" = 1 ] && echo too late... >&2
	false
    elif [ "$CUR_TIME" = "$SUNSET_TIME" ] ; then
	[ "$VERBOSE" = 1 ] && echo pora >&2
	true
    else
	[ "$VERBOSE" = 1 ] && echo about... >&2
	true
    fi    
}

already_running () {
    if [ -f $LAST_RUN_FILE ] ; then
      LAST_RUN_TIME=$( cat $LAST_RUN_FILE )
      NOW=$( date +%s )

      if [ $(( $NOW - $LAST_RUN_TIME )) -lt 7200 ] ; then
         true
      else
	false
      fi
    else
      false
    fi
}

run_dusk () {
  [ "$VERBOSE" = "1" ] &&  echo starting dusk for light $THE_LIGHT >&2
  date +%s > $LAST_RUN_FILE
  hue -c -l $THE_LIGHT transit from ct 153 $BRIGHTNESS ct 500 $BRIGHTNESS -p 10 -s 1080
  rm $LAST_RUN_FILE
}

if already_running ; then
    [ "$VERBOSE" = 1 ] && echo the script is already running >&2
    exit 0
fi

if ! right_color $THE_LIGHT "${DAYLIGHT_COLOR[@]}"  ; then
    [ "$VERBOSE" = 1 ] && echo The color is wrong >&2
    exit 0
fi

if ! time_is_right ; then    
    [ "$VERBOSE" = 1 ] && echo NOT NOW >&2
    exit 0
fi

### everything is OK

[ "$VERBOSE" = 1 ] && echo Brightness $BRIGHTNESS >&2

run_dusk &
