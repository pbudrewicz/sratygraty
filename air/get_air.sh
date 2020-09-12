#!/bin/bash

TEMP=$( getopt -o hil:snvpr --long help,iso,light:,silent,num,verbose,pm,refresh -n $0 -- "$@" )

if [ $? != 0 ] ; then echo "Cannot parse options. Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

show_help () {
    echo "
Usage:
   $0 [-l light] [-s] [-h] [-r] [-v]
    Options are
      -i|--iso      - show iso code for color
      -n|--num
      -h|--help     - show this help
      -l|--light    - blink hue light
      -p|--pm       - show max PM
      -r|--refresh  - refresh cache
      -v|--verbose  - run verbosely
      -s|--silent   - run silently
"
    exit $1
}

DIR=$( dirname $0 )
. $DIR/user_key
. $DIR/location_data

TMP_AIR_FILE=/tmp/last-air.json.$$
AIR_DATA_CACHE=/tmp/air_data_cache
LIGHT=""
STATIONS=3
SHOW_PM=""
REFRESH=0
NUM=0
#curl -X GET --header 'Accept: application/json' --header 'Accept-Language: en' --header "apikey: $user_key" "https://airapi.airly.eu/v2/installations/nearest?lat=${lat}&lng=${lon}&maxDistanceKM=5&maxResults=3"|json_pp
#curl -X GET --header 'Accept: application/json' --header 'Accept-Language: en' --header "apikey: $user_key" "https://airapi.airly.eu/v2/installations/6168?lat=${lat}&lng=${lon}&maxDistanceKM=5&maxResults=3"|json_pp

ISO_COLOR=""

while true ; do
    case "$1" in
        -l|--light)
            LIGHTS="$LIGHTS $2"; shift 2;;
        -h|--help)
            show_help 0;;
        -p|--pm)
	    SHOW_PM=1;
	    shift
            ;;
        -i|--iso)
	    ISO_COLOR=1;
	    shift
            ;;
	-n|--num)
	    NUM=1;
	    shift
	    ;;
	-r|--refresh)
	    REFRESH=1; shift
	    ;;
        -s|--silent)
            SILENT="-s"; shift;;
        -v|--verbose)
            VERBOSE=1 ; VERBOSITY="-v" ; shift ;;
        --) 
            shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

get_json () {
    
	AIR_JSON="$( curl $SILENT -X GET --header 'Accept: application/json' --header 'Accept-Language: en' --header "apikey: $user_key" "https://airapi.airly.eu/v2/measurements/nearest?lat=${lat}&lng=${lon}&maxDistanceKM=5&maxResults=${STATIONS}" )" # | tee $TMP_AIR_FILE )"
    echo $AIR_JSON| json_pp -t null    
}

get_air_data () {
    
    if [ "$REFRESH" = "1" ] ;  then        
	
	TRIES=0
	
	while [ $TRIES -lt 5 ] && ! get_json ; do
	    sleep 5
	    TRIES=$(( $TRIES + 1 ))
	done
	
	if [ $TRIES -ge 5 ] ; then
	    echo Couldnt get air status >&2
	    exit 13
	else
	    echo "$AIR_JSON" > $AIR_DATA_CACHE
	fi
    else
	AIR_JSON="$( cat $AIR_DATA_CACHE )"
    fi
    
}

get_air_data

VALUES=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl count '{current}{values}' )

COLOR=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl get '{current}{indexes}[0]{color}' )
LEVEL=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl get '{current}{indexes}[0]{level}' )
XYCOLOR=$( $DIR/rgb_2_xy.pl $COLOR ) 

# $DIR/../hue/hue -l $LIGHT pulse xy $XYCOLOR 254 
# $DIR/../hue/hue -l $LIGHT pulse xy $XYCOLOR 254 
# $DIR/../hue/hue -l $LIGHT pulse xy $XYCOLOR 254 
# exit 0 

pmnon10_level () {
  if [ "$1" -ge "76" ] ; then
	  echo 4; 
  elif [ "$1" -ge "36" ] ; then
	  echo 3;
  elif [ "$1" -ge "16" ] ; then
	  echo 2;
  else
	  echo 1
  fi
}

pm10_level () {
  if [ "$1" -ge "151" ] ; then
	  echo 4; 
  elif [ "$1" -ge "81" ] ; then
	  echo 3;
  elif [ "$1" -ge "31" ] ; then
	  echo 2;
  else
	  echo 1
  fi
}

max () {
  if [ "$1" -gt "$2" ] ; then
	  echo "$1"
  else
	  echo "$2"
  fi
}

level_to_color () {
	case $1 in
		1)
			echo cyan;;
		2)
			echo green;;
		3)
			echo yellow;;
		4)
			echo red;;
		*)
			echo violet;;
	esac
}

MAX_LEVEL=0
MAX_PM=PMOK
for val in $( seq 0 $(( $VALUES - 1 )) ) ; do
    NAME[$val]=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl get "{current}{values}[$val]{name}" )
    VALUE[$val]=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl get "{current}{values}[$val]{value}"|sed 's/\.[0-9]*//g' )
    [ "$VERBOSE" = "1" ] && echo -n "${NAME[$val]}=${VALUE[$val]} "
    if [ "${NAME[$val]}" = "PM10" ] ; then
	MAX_LEVEL=$( max "$MAX_LEVEL" $( pm10_level "${VALUE[$val]}" ) )
	MAX_PM=PM10
	MAX_VAL=${VALUE[$val]}
    elif [ "${NAME[$val]}" = "PM25" ] ; then
	MAX_LEVEL=$( max "$MAX_LEVEL" $( pmnon10_level "${VALUE[$val]}" ) )
	MAX_PM=PM25
	MAX_VAL=${VALUE[$val]}
    elif [ "${NAME[$val]}" = "PM1" ] ; then
	MAX_LEVEL=$( max "$MAX_LEVEL" $( pmnon10_level "${VALUE[$val]}" ) )
	MAX_PM=PM01
	MAX_VAL=${VALUE[$val]}
    fi 
done
# echo
[ "$VERBOSE" = "1" ] && echo LEVEL:$MAX_LEVEL
OVERALL_COLOR=$( level_to_color $MAX_LEVEL )

if [ "$LIGHTS" != "" ] ; then
    
    for i in $( seq 1 $MAX_LEVEL ) ; do
	for LIGHT in $LIGHTS ; do
	    $DIR/../hue/hue -l $LIGHT pulse $OVERALL_COLOR 254 -p 1 &
	done
	wait
	sleep 0.5
    done

fi

if [ "$ISO_COLOR" != "" ] ; then
    case "$OVERALL_COLOR" in
	cyan)	   
	    echo -e "\e[36m$MAX_PM\e[0m";;
	yellow)
	    echo -e "\e[33m$MAX_PM\e[0m";;
	green)
	    echo -e "\e[32m$MAX_PM\e[0m";;
	red)
	    echo -e "\e[31m$MAX_PM\e[0m";;
	*)
	    echo -e "\e[35m$MAX_PM\e[0m";;
    esac
fi
	
if [ "$SHOW_PM" != "" ] ; then
    echo $MAX_PM $MAX_LEVEL
fi

if [ "$NUM" = "1" ] ; then
    echo $MAX_PM $MAX_VAL
fi
	
# [ "$VERBOSE" = "1" ] && echo "LEVEL:$LEVEL:$COLOR:$XYCOLOR:$MAX_LEVEL"

# curl -X --header 'Accept: application/json' --header 'Accpet-Language: en' --header "apikey: $user_key" "http://api.gios.gov.pl/pjp-api/rest/data/getData/6168"|json_pp
