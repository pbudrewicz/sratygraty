#!/bin/bash

#TODO: ignore brightness when comparing colors

PATH=$PATH:$HOME/sratygraty/scripts:$HOME/sratygraty/hue

DAYLIGHT_COLOR[0]='xy 0.3137 0.3289 254' # switch
DAYLIGHT_COLOR[1]='xy 0.3103 0.3302 254' # t 6500
DAYLIGHT_COLOR[2]='ct 155 254'           # switch
DAYLIGHT_COLOR[3]='ct 153 254'           # t 6500

if [ "$VERBOSE" = "" ] ; then
	VERBOSE=1
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
	[ "$VERBOSE" = 1 ] && echo comparing $COLOR with $THE_COLOR
	if [ "$COLOR" = "$THE_COLOR" ] ; then
	    return 0 # True
	fi
    done
    false
}




time_is_right () {

    SUNSET_HOUR="$( curl -s 'https://api.sunrise-sunset.org/json?lat=52&lng=21&formatted=0' |  json_select.pl show '{results}{sunset}' | perl -ne 'print $1 if m/T(\d\d:\d\d:\d\d)\+/' )"
    SUNSET_HRS=$( echo $SUNSET_HOUR | cut -d : -f 1 )
    SUNSET_MIN=$( echo $SUNSET_HOUR | cut -d : -f 2 )
    SUNSET_TIME=$( date --date "$SUNSET_HRS:$SUNSET_MIN" +%s ) 
        
    CUR_TIME=$(date +%s)
    NEXT_TIME=$(date --date 'next hour' +%s )
    PREV_TIME=$(date --date '3 hours ago' +%s)    
    
    if [ "$NEXT_TIME" -lt "$SUNSET_TIME" ] ; then
	[ "$VERBOSE" = 1 ] && echo Too early
	false
    elif [ "$PREV_TIME" -gt "$SUNSET_TIME" ] ; then
	[ "$VERBOSE" = 1 ] && echo too late...
	false
    elif [ "$CUR_TIME" = "$SUNSET_TIME" ] ; then
	[ "$VERBOSE" = 1 ] && echo pora
	true
    else
	[ "$VERBOSE" = 1 ] && echo about...
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
  [ "$VERBOSE" = "1" ] && echo starting dusk for light $THE_LIGHT
  date +%s > $LAST_RUN_FILE
  hue -c -l $THE_LIGHT transit from ct 153 $BRIGHTNESS ct 345 $BRIGHTNESS -p 10 -s 720
  rm $LAST_RUN_FILE
}

if already_running ; then
    [ "$VERBOSE" = 1 ] && echo the script is already running
    exit 0
fi

if ! right_color $THE_LIGHT "${DAYLIGHT_COLOR[@]}"  ; then
    [ "$VERBOSE" = 1 ] && echo The color is wrong
    exit 0
fi

if ! time_is_right ; then    
    [ "$VERBOSE" = 1 ] && echo NOT NOW
    exit 0
fi

### everything is OK

[ "$VERBOSE" = 1 ] && echo Brightness $BRIGHTNESS

run_dusk &
