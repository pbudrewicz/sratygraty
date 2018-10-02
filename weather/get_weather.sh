#!/bin/bash 

TEMP=$( getopt -o fhl:sw --long forecast,help,location:,silent,weather -n $0 -- "$@" )

if [ $? != 0 ] ; then echo "Cannot parse options. Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

show_help () {
    echo "
Usage:
   $0 -f -w [-l location] [-s] [-h]
    Options are
      -f|--forecast - show forecast
      -h|--help     - show this help
      -l|--location - show data for this location
      -s|--silent   - run silently
      -w|--weather  - show current weather
"
    exit $1
}

LOCATION="Warsaw,PL"
DATA_TYPE="weather"
SILENT=""

while true ; do
    case "$1" in
        -f|--forecast)
            DATA_TYPE=forecast; shift;;
        -l|--location)
            LOCATION="$2"; shift 2;;
        -h|--help)
            show_help 0;;
        -s|--silent)
            SILENT="-s"; shift;;
        -w|--weather)
            DATA_TYPE=weather; shift ;;
        --) 
            shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done



. $( dirname $0 )/weather.key

curl ${SILENT} -X GET "api.openweathermap.org/data/2.5/${DATA_TYPE}?q=${LOCATION}&mode=json&APPID=$weather_key"

