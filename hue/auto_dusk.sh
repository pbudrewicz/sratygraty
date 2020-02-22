#!/bin/bash

PATH=$PATH:$HOME/sratygraty/scripts:$HOME/sratygraty/hue

DAYLIGHT_COLOR='xy 0.3137 0.3289 254'


THE_LIGHT="$1"

if [ "$THE_LIGHT" = "" ] ; then
    echo need light nuber
    exit 13
fi

LAST_RUN_FILE=/tmp/auto_dusk_running.$THE_LIGHT

right_color () {
    THE_LIGHT=$1
    THE_COLOR=$2
    COLOR=$( hue get color $THE_LIGHT )
    BRIGHTNESS=$( echo $COLOR | awk '{print $NF }' )
    if [ "$COLOR" = "$THE_COLOR" ] ; then
	true
    else
	false
    fi
}




time_is_right () {

    SUNSET_TIME="$( curl -s 'https://api.sunrise-sunset.org/json?lat=52&lng=21&formatted=0' |  json_select.pl show '{results}{sunset}' | perl -ne 'print $1 if m/T(\d\d:\d\d:\d\d)\+/' )"
    SUNSET_HRS=$( echo $SUNSET_TIME | cut -d : -f 1 )
    SUNSET_MIN=$( echo $SUNSET_TIME | cut -d : -f 2 )
    
    CURRENT_TIME="$( date -u | awk '{print $4}' )"
    CURRENT_HRS=$( echo $CURRENT_TIME | cut -d : -f 1 )
    CURRENT_MIN=$( echo $CURRENT_TIME | cut -d : -f 2 )
    
    [ "$VERBOSE" = 1 ] && echo $CURRENT_HRS .. $CURRENT_MIN
    [ "$VERBOSE" = 1 ] && echo $SUNSET_HRS .. $SUNSET_MIN
    
    CUR_HOUR=$CURRENT_HRS$CURRENT_MIN
    NEXT_HOUR=$(( $CURRENT_HRS + 1 ))$CURRENT_MIN
    PREV_HOUR=$(( $CURRENT_HRS - 1 ))$CURRENT_MIN
    
    SUNSET_HOUR=$SUNSET_HRS$SUNSET_MIN
    
    
    if [ "$NEXT_HOUR" -lt "$SUNSET_HOUR" ] ; then
	[ "$VERBOSE" = 1 ] && echo Too early
	false
    elif [ "$PREV_HOUR" -gt "$SUNSET_HOUR" ] ; then
	[ "$VERBOSE" = 1 ] && echo too late...
	false
    elif [ "$CUR_HOUR" = "$SUNSET_HOUR" ] ; then
	[ "$VERBOSE" = 1 ] && echo pora
	true
    else
	[ "$VERBOSE" = 1 ] && echo about...
	true
    fi    
}

already_running () {
    LAST_RUN_TIME=$( cat $LAST_RUN_FILE )
    NOW=$( date +%s )

    if [ $(( $NOW - $LAST_RUN_TIME )) -lt 7200 ] ; then
	true
    else
	false
    fi
}

if ! time_is_right ; then    
    [ "$VERBOSE" = 1 ] && echo NOT NOW
    exit 0
fi


if ! right_color $THE_LIGHT "$DAYLIGHT_COLOR"  ; then
    [ "$VERBOSE" = 1 ] && echo Time is OK, but wrong color
    exit 0
fi

if already_running ; then
    [ "$VERBOSE" = 1 ] && echo Time and color is OK, but already running
    exit 0
fi

### everything is OK

[ "$VERBOSE" = 1 ] && echo Brightness $BRIGHTNESS
date +%s > $LAST_RUN_FILE
hue -l $THE_LIGHT transit from t 6500 $BRIGHTNESS t 2900 $BRIGHTNESS -p 10 -s 720








