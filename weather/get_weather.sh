#!/bin/bash 

TEMP=$( getopt -o fhi:l:sw --long forecast,help,id,location:,silent,weather -n $0 -- "$@" )

if [ $? != 0 ] ; then echo "Cannot parse options. Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

show_help () {
    echo "
Usage:
   $0 -f -w [-l location] [-s] [-h]
    Options are
      -f|--forecast - show forecast
      -h|--help     - show this help
      -i|--id       - show data for city with this id
      -l|--location - show data for this location
      -s|--silent   - run silently
      -w|--weather  - show current weather
"
    exit $1
}

LOCATION="Warsaw,PL"
DATA_TYPE="weather"
SILENT=""
ID=756135

while true ; do
    case "$1" in
        -f|--forecast)
            DATA_TYPE=forecast; shift;;
        -l|--location)
            LOCATION="$2"; shift 2
            MODE=location;;
        -h|--help)
            show_help 0;;
        -i|--id)
	    ID="$2"; shift 2
            MODE=id;;
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

if [ "$MODE" = "location" ] ; then
  curl ${SILENT} -X GET "api.openweathermap.org/data/2.5/${DATA_TYPE}?q=${LOCATION}&mode=json&APPID=$weather_key"
elif [ "$MODE" = "id" ] ; then
  curl ${SILENT} -X GET "api.openweathermap.org/data/2.5/${DATA_TYPE}?id=${ID}&mode=json&APPID=$weather_key"
else
  curl ${SILENT} -X GET "api.openweathermap.org/data/2.5/${DATA_TYPE}?lat=50.333673&lon=22.972408&mode=json&APPID=$weather_key"
fi

