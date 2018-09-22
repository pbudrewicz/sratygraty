hue=0

while true ; do
  ./set_color.sh $1 hue 100 $hue 200
  hue=$(( ( $hue + 10000 ) % 65000 ))
  sleep 1
done
