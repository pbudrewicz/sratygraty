#!/bin/bash 

TEMP=$( getopt -o dfghi:L:l:rsvw --long data,forecast,glimpse,help,id,light:,location:,refresh,silent,verebose,weather -n $0 -- "$@" )

if [ $? != 0 ] ; then echo "Cannot parse options. Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

show_help () {
    echo "
Usage:
   $0  (-f|-w)[-d][-D DATE][-i ID][-L LOCATION][-l #][-r][-s][-h]
    Options are
      -d|--data     - grab data only
      -D|--date     - show data for DATE
      -f|--forecast - show forecast
      -g|--glimpse  - glimpse only - leave light as it was
      -h|--help     - show this help
      -i|--id       - show data for city with this ID
      -L|--location - show data for this LOCATION
      -l|--light    - use light number # (can be used many times)
      -r|--refresh  - refresh data before show
      -s|--silent   - run silently (no curl feedback)
      -w|--weather  - show current weather
"
    exit $1
}

LOCATION="Warsaw,PL"
DATA_TYPE="weather"
SHOW_TYPE="forecast"
SILENT=""
ID=756135
LIGHTS="3" # funny, isn't it?
THE_DAY=$( date +%Y-%m-%d )
GLIMPSE=0
VERBOSE=0
VERBOSITY=""
PATH=$PATH:~/sratygraty/scripts:~/sratygraty/hue:~/sratygraty/weather
DATA_CACHE=/tmp/weather_fun_info.dat
DIR=$( dirname $0 )

. $DIR/../hue/colors.sh
. $DIR/weather.key

feedback () {
    if [ "$VERBOSE" -gt "0" ] ; then
        echo "$@" 1>&2
    fi
}

weather () {
    json_select.pl "$@" < $DATA_CACHE
}

deb () {
  : echo "$@" >&2
}

C_from_K () {
  echo "$1" - 273.15 | bc
}	

is_the_day () {
    if [ "$1" = "$THE_DAY" ] ; then
        return 0
    else
        return 1
    fi
}


while true ; do
    case "$1" in
        -d|--data)
            SHOW_TYPE=data # #TODO: rethink
            REFRESH=1; shift ;;
        -D|--date)
            THE_DAY=$( date --date "$2" +%Y-%m-%d )
            shift 2;;
        -f|--forecast)
            DATA_TYPE=forecast; shift;;
        -g|--glimpse)
            GLIMPSE=1; shift ;;
        -L|--location)
            LOCATION="$2"; shift 2
            MODE=location;;
        -l|--light)
            LIGHTS="$LIGHTS $2"; shift 2;;
        -h|--help)
            show_help 0;;
        -i|--id)
	    ID="$2"; shift 2
            MODE=id;;
        -r|--refresh)
            REFRESH=1; shift ;;
        -s|--silent)
            SILENT="-s"; shift;;
        -v|--verbose)
            VERBOSE=1 ; VERBOSITY="-v" ; shift ;;
        -w|--weather)
            DATA_TYPE=weather; shift ;;
        --) 
            shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

show_condition () {

    case $condition in
        Rain)
            sleep 1
            feedback ...raining...
            hue -l $light pulse xy $BLUE_COLOR 100 -p 0.5 $VERBOSITY
            ;;
        Snow)
	    sleep 1
	    feedback ...snowing...
	    hue -l $light pulse xy $WHITE_COLOR 200 -p 0.5 $VERBOSITY
            ;;
        Mist)
	    sleep 1
	    feedback ...fog...
	    hue -l $light pulse xy $WHITE_COLOR 1 -p 0.5  $VERBOSITY
            ;;
    esac
}


forecast_show () {
    light=$1
    SAVED_COLOR=$( hue get color $light )
    hue -l $light set color xy 0.35 0.35 1  $VERBOSITY
    feedback Showing data for lat:$( weather show '{city}{coord}{lat}' ) lon:$( weather show '{city}{coord}{lon}' )
    sleep 3
    
    MAX_TEMP=-50
    MAX_DATE=""
    CAST_COUNT=$( weather count '{list}' )
    for i in $(seq 0 $(( $CAST_COUNT - 1 )) ) ; do
        temperature=$( weather get "{list}[$i]{main}{temp}" )
        T=$( C_from_K $temperature )

        date=$( weather get "{list}[$i]{dt_txt}" )
        if ! is_the_day $date ; then continue ; fi 

        COLOR=$( temp2color.sh $T)
        hue -l $light set color xy $COLOR 200 $VERBOSITY
        sleep 1

        CONDITION_COUNT=$( weather count "{list}[$i]{weather}" )
        for c in $(seq 0 $(( $CONDITION_COUNT - 1 )) ) ; do
            condition=$( weather get "{list}[$i]{weather}[$c]{main}" ) 
            show_condition $condition
            feedback $date $condition $T 
        done
        #hue -l 3 alert 
        #    sleep 1
        if [ "$( echo "$T > $MAX_TEMP"|bc)" = "1" ] ; then
	    MAX_TEMP=$T
	    MAX_DATE=$date
        fi	
    done
    feedback MAX T = $MAX_TEMP at $MAX_DATE
    hue -l $light set color xy $( temp2color.sh $MAX_TEMP ) 200 $VERBOSITY
    sleep 1
    if [ "$GLIMPSE" = "1" ] ; then
        hue -l $light set color $SAVED_COLOR $VERBOSITY
    fi
    
}

weather_show () {
    :
}



if [ "$REFRESH" = "1" ] ; then
    case  $MODE in 
        location)
            curl ${SILENT} -X GET "api.openweathermap.org/data/2.5/${DATA_TYPE}?q=${LOCATION}&mode=json&APPID=$weather_key" 
            ;;
        id)
            curl ${SILENT} -X GET "api.openweathermap.org/data/2.5/${DATA_TYPE}?id=${ID}&mode=json&APPID=$weather_key"
            ;;
        *)
            curl ${SILENT} -X GET "api.openweathermap.org/data/2.5/${DATA_TYPE}?lat=50.333673&lon=22.972408&mode=json&APPID=$weather_key"
            ;;
    esac > $DATA_CACHE
fi 

case $SHOW_TYPE in 
    forecast)
        for light in $LIGHTS ; do
            forecast_show $light &
        done
	wait
        ;;
    data)
        cat $DATA_CACHE
        ;;
    weather)
        weather_show
        ;;
esac
