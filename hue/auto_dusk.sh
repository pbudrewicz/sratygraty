#!/bin/bash

#TODO: ignore brightness when comparing colors

TZ=UTC

PATH=$PATH:$HOME/sratygraty/scripts

DAYLIGHT_COLOR[0]='xy 0.3137 0.3289 254' # switch
DAYLIGHT_COLOR[1]='xy 0.3137 0.3289 253' # dawn
DAYLIGHT_COLOR[2]='xy 0.3103 0.3302 254' # t 6500
DAYLIGHT_COLOR[3]='ct 155 254'           # switch
DAYLIGHT_COLOR[4]='ct 153 254'           # t 6500
DAYLIGHT_COLOR[5]='ct 153 253'           # t 6500

EVENING_COLOR[0]='ct 344 254'
NIGHT_COLOR[0]='ct 400 150' 

if [ "$VERBOSE" = "" ] ; then
	VERBOSE=0
fi


THE_LIGHT="$1"

if [ "$THE_LIGHT" = "" ] ; then
    echo need light nuber
    exit 13
fi

LAST_RUN_FILE=$HOME/etc/auto_dusk_running.$THE_LIGHT

right_color () {
    THE_LIGHT=$1
    shift
    COLOR=$( hue get color $THE_LIGHT )
    BRIGHTNESS=$( echo $COLOR | awk '{print $NF }' )
    for THE_COLOR ; do
	[ "$VERBOSE" = 1 ] && echo comparing $COLOR with $THE_COLOR >&2
	if [ "$COLOR" = "$THE_COLOR" ] ; then
	    return 0 # True
	fi
    done
    false
}



time_is_right () {

    SUNSET_HOUR="$( get_sun_data.sh | json_select.pl show '{results}{sunset}' | perl -ne 'print $1 if m/T(\d\d:\d\d:\d\d)\+/' )"
    SUNSET_HRS=$( echo $SUNSET_HOUR | cut -d : -f 1 )
    SUNSET_MIN=$( echo $SUNSET_HOUR | cut -d : -f 2 )
    SUNSET_TIME=$( date -u --date "$SUNSET_HRS:$SUNSET_MIN" +%s ) 
        
    CURRENT_TIME=$(date -u +%s)
    IN_AN_HOUR=$(date -u --date 'next hour' +%s )
    THREE_HOURS_AGO=$(date -u --date '3 hours ago' +%s)    
    
    if [ "$IN_AN_HOUR" -lt "$SUNSET_TIME" ] ; then # curent time < sunset time - 3600 | + 3600
	[ "$VERBOSE" = 1 ] && echo Too early >&2
	false
    #elif [ "$THREE_HOURS_AGO" -gt "$SUNSET_TIME" ] ; then # current time > sunset time + 3*3600 | - 3*3600
	#[ "$VERBOSE" = 1 ] && echo too late... >&2
	#false
    elif [ "$CURRENT_TIME" = "$SUNSET_TIME" ] ; then
	[ "$VERBOSE" = 1 ] && echo just in time >&2
	true
    else
	[ "$VERBOSE" = 1 ] && echo about... >&2
	true
    fi    
}

already_running () {
    if [ -f $LAST_RUN_FILE ] ; then
      LAST_RUN_TIME=$( cat $LAST_RUN_FILE )
      NOW=$( date -u +%s )

      if [ $(( $NOW - $LAST_RUN_TIME )) -lt 7200 ] ; then
         true # probably 
      else
	false # ran and finished
      fi
    else
      false # never heard of
    fi
}

run_dusk () {
    CURRENT_TIME=$(date -u +%s)
    TIME_TO_SUNSET=$(( $SUNSET_TIME - $CURRENT_TIME ))
    date -u +%s > $LAST_RUN_FILE
    if [ "$TIME_TO_SUNSET" -lt 180 ] ; then
	TIME_TO_SUNSET=180
    fi
    [ "$VERBOSE" = "1" ] &&  echo starting dusk to 4000K for light $THE_LIGHT for $TIME_TO_SUNSET seconds >&2
    hue -l $THE_LIGHT transit from ct 153 $BRIGHTNESS ct 250 $BRIGHTNESS -p 10 -s $(( $TIME_TO_SUNSET / 10 ))
    CURRENT_TIME=$(date -u +%s)
    TRANSIT_TIME=$(( $SUNSET_TIME + 3600 - $CURRENT_TIME ))
    if [ "$TRANSIT_TIME" -lt 300 ] ; then
	TRANSIT_TIME=300
    fi
    [ "$VERBOSE" = "1" ] &&  echo starting dusk to 2900K for light $THE_LIGHT for $TRANSIT_TIME seconds >&2
    hue -l $THE_LIGHT transit from ct 250 $BRIGHTNESS ct 344 $BRIGHTNESS -p 10 -s $(( $TRANSIT_TIME / 10 ))
    rm $LAST_RUN_FILE
}

run_evening () {
  [ "$VERBOSE" = "1" ] &&  echo starting evening for light $THE_LIGHT >&2
  date -u +%s > $LAST_RUN_FILE
  hue -l $THE_LIGHT transit from ct 344 $BRIGHTNESS ct 400 150 -p 5 -s 60
  rm $LAST_RUN_FILE
}

run_night () {
  [ "$VERBOSE" = "1" ] &&  echo starting evening for light $THE_LIGHT >&2
  date -u +%s > $LAST_RUN_FILE
  hue -l $THE_LIGHT transit from ct 400 $BRIGHTNESS ct 500 100 -p 5 -s 60
  rm $LAST_RUN_FILE
}

if already_running ; then
    [ "$VERBOSE" = 1 ] && echo the script is already running >&2
    exit 0
fi

check_for_dusk () {

    if ! right_color $THE_LIGHT "${DAYLIGHT_COLOR[@]}"  ; then
	[ "$VERBOSE" = 1 ] && echo The color for dusk is wrong >&2
	return 1
    fi
    
    if ! time_is_right ; then    
	[ "$VERBOSE" = 1 ] && echo NOT NOW >&2
	return 1
    fi
    true
}

check_for_evening () {

    if ! right_color $THE_LIGHT "${EVENING_COLOR[@]}"  ; then
	[ "$VERBOSE" = 1 ] && echo The color for evening is wrong >&2
	return 1
    fi
    
    if [ "$( date +%H%M )" -lt "2200" ] ; then    
	[ "$VERBOSE" = 1 ] && echo NOT NOW >&2
	return 1
    fi
    true
}

check_for_night () {

    if ! right_color $THE_LIGHT "${NIGHT_COLOR[@]}"  ; then
	[ "$VERBOSE" = 1 ] && echo The color for night is wrong >&2
	return 1
    fi
    
    if [ "$( date +%H%M )" -lt "2300" ] ; then    
	[ "$VERBOSE" = 1 ] && echo NOT NOW >&2
	return 1
    fi
    true
}


### everything is OK

[ "$VERBOSE" = 1 ] && echo Brightness $BRIGHTNESS >&2

check_for_dusk && run_dusk &
check_for_evening && run_evening &
check_for_night && run_night &
