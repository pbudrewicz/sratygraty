
. user.key

for light in 1 2 3 ; do
        curl -X PUT -d '{"1":"040000FFFF00003333000033330000FFFFFFFFFF"}' http://$bridge_ip/api/$user_key/lights/$light/pointsymbol  # blue fast
done

curl -X PUT -d '{"symbolselection":"01010C010101020103010401050106010701080109010A010B010C","duration":4000}' http://$bridge_ip/api/$user_key/groups/3/transmitsymbol

