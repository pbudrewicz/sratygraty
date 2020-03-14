#!/bin/bash

DIR=$( dirname $0 )
. $DIR/user_key
. $DIR/location_data

LIGHT=$1
STATIONS=3
#curl -X GET --header 'Accept: application/json' --header 'Accept-Language: en' --header "apikey: $user_key" "https://airapi.airly.eu/v2/installations/nearest?lat=${lat}&lng=${lon}&maxDistanceKM=5&maxResults=3"|json_pp
#curl -X GET --header 'Accept: application/json' --header 'Accept-Language: en' --header "apikey: $user_key" "https://airapi.airly.eu/v2/installations/6168?lat=${lat}&lng=${lon}&maxDistanceKM=5&maxResults=3"|json_pp
AIR_JSON="$( curl -s -X GET --header 'Accept: application/json' --header 'Accept-Language: en' --header "apikey: $user_key" "https://airapi.airly.eu/v2/measurements/nearest?lat=${lat}&lng=${lon}&maxDistanceKM=5&maxResults=${STATIONS}" | tee /tmp/last-air.json.$LIGHT )"

VALUES=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl count '{current}{values}' )

COLOR=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl get '{current}{indexes}[0]{color}' )
LEVEL=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl get '{current}{indexes}[0]{level}' )
XYCOLOR=$( $DIR/rgb_2_xy.pl $COLOR ) 

echo "LEVEL:$LEVEL:$COLOR:$XYCOLOR"
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
			echo orange;;
		4)
			echo red;;
		*)
			echo violet;;
	esac
}

MAX_LEVEL=0
for val in $( seq 0 $(( $VALUES - 1 )) ) ; do
    NAME[$val]=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl get "{current}{values}[$val]{name}" )
    VALUE[$val]=$( echo $AIR_JSON | $DIR/../scripts/json_select.pl get "{current}{values}[$val]{value}"|sed 's/\.[0-9]*//g' )
    if [ "${NAME[$val]}" = "PM10" ] ; then
	    MAX_LEVEL=$( max "$MAX_LEVEL" $( pm10_level "${VALUE[$val]}" ) )  
    elif [ "${NAME[$val]}" = "PM25" ] ; then
	    MAX_LEVEL=$( max "$MAX_LEVEL" $( pmnon10_level "${VALUE[$val]}" ) )  
    elif [ "${NAME[$val]}" = "PM1" ] ; then
	    MAX_LEVEL=$( max "$MAX_LEVEL" $( pmnon10_level "${VALUE[$val]}" ) )  
    fi 
done
echo LEVEL:$MAX_LEVEL
OVERALL_COLOR=$( level_to_color $MAX_LEVEL )
$DIR/../hue/hue -l $LIGHT pulse $OVERALL_COLOR 254 
$DIR/../hue/hue -l $LIGHT pulse $OVERALL_COLOR 254 
$DIR/../hue/hue -l $LIGHT pulse $OVERALL_COLOR 254 

# curl -X --header 'Accept: application/json' --header 'Accpet-Language: en' --header "apikey: $user_key" "http://api.gios.gov.pl/pjp-api/rest/data/getData/6168"|json_pp
