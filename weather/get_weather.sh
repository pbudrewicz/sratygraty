#!/bin/bash 

. $( dirname $0 )/weather.key

curl -s -X GET "api.openweathermap.org/data/2.5/weather?q=london,uk&mode=json&APPID=$weather_key"
#curl -s -X GET "api.openweathermap.org/data/2.5/forecast?q=london,uk&mode=json&APPID=$weather_key"
