hue=0

while true ; do
  ./set_color.sh $1 hue 100 $hue 
  hue=$(( ( $hue + 1000 ) % 65000 ))
done
