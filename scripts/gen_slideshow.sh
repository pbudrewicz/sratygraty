#!/bin/bash


PDIR=/usb/photo
SDIR=/var/lib/minidlna/photo/slides
COUNT=1000
DIRCNT=100
PERDIR=7
DIRLIST=/tmp/dirs$$.lst
LISTFILE=/tmp/photo$$.lst

mount /usb

if ! [ -d $PDIR ] ; then
    echo No photo directory in $PDIR
    exit
fi

cd $PDIR || exit 13

echo Refreshing $SDIR...
if [ -d $SDIR ] ; then
    if [ -f $SDIR/prev.cnt ] ; then
	prev_size="-s $( cat $SDIR/prev.cnt )"
    fi
    rm -f $SDIR/*
else
    mkdir $SDIR
fi

select_dirs () {
    DIRFILE=/tmp/cnt$$.file
    find $@ -iname '*.jpg'  | perl -ple 's|/[^/]+$||'  |
	pv -N 'dir list generation' -peabrl $prev_size > $DIRFILE
    < $DIRFILE wc -l > $SDIR/prev.cnt 
    while [ -s $DIRFILE ] ; do
	#	wc -l $DIRFILE >&2
	NEXTDIR="$( < $DIRFILE sort -R|head -1 )"
	< $DIRFILE grep -v "$NEXTDIR" | sponge $DIRFILE
	echo "$NEXTDIR"
    done
    rm $DIRFILE
}

mkcomment () {
	photo="$1"
	pdate=$( exiftool -createdate "$photo"|perl -ne 'print "`$1" if m/\d\d(\d\d):\d\d:\d\d/' )
	year=$( exiftool -createdate "$photo"|perl -ne 'print "$1-$2-$3" if m/(\d\d\d\d):(\d\d):(\d\d)/' )
	dirbasename="$( basename "$( dirname "$photo" )"|perl -pe 's|posprzatane/dobre/[^/]+/?||; s|WIP2?/([^/]+/?)?||;' )"
	pathname="$( dirname "$photo"|perl -pe 's|^'$PDIR'||;s|posprzatane/dobre/[^/]+/?||; s|WIP2?/[^/]+/?||;' )"
	if [ "$pdate" = "" ] ; then
		pdate=$( echo "$pathname" | perl -ne 'print  "`$1" if m/\d\d(\d\d)(\d{2}(\d{2})?)?/' )
	fi
	if [[ "$pathname" =~ '^[/ 0-9]+$' ]] ; then
		pdate=""
	fi
	comment=$(echo "$pathname" | perl -pe 's|^([\d ]+[-/]?)+||; s|/|, |g;' ) # remove leading numbers in dirname and replace slash with comma
	if [[ "$comment" =~ , ]] ; then
          	echo $(echo $comment | perl -pe 's/^([^,]*),(.*)$/$1'$pdate',$2/ ' ) # insert year before last commaa
        elif [[ "$comment" == "" ]] ; then
		echo $year
	else # or at the end if there is no comma in the comment
		echo $comment$pdate
	fi
	
}

draw_text_string () {
    TEXT="$1"
    bcolor="$2"
    tcolor="$3"
    x="$4"
    y="$5"
    for i in -2 0 2 ; do
	for j in -2 0 2 ; do
	    echo -n "-fill '$bcolor' -draw 'text $(( $x + $i )),$(( $y + $j )) \"$TEXT\"' "
	done
    done
    echo -n "-fill '$tcolor' -draw 'text $x,$y \"$TEXT\"' "
}

echo Generating slideshow...
echo
# we get directories actually containing photos (take dirs of actual photos)
# and select up to PERDIR photos from each and take first COUNT from it.
NUM=1
select_dirs  posprzatane/dobre/ WIP* | while read directory ; do
    ls "$directory"/*.[jJ][pP][gG] | sort -R | head -$PERDIR | sort |
	while read photo ; do
	    echo $NUM $photo
	    NUM=$(( $NUM + 1 ))
	done
done | head -$COUNT | #pv -N 'photo list generation' -peabrl -$COUNT > $LISTFILE
    #NUM=1
    # we take each photo from list, resize and impose comment on ot
    # cat $LISTFILE |
    while read num photo ; do
	num=$NUM ; NUM=$(( $NUM + 1 )) # <-this very line makes slideshow random instead of chronological
	COMMENT=$( mkcomment "$photo" )
	#echo $photo '->' $COMMENT
	#	printf "convert -auto-orient -resize 1920x1080 -quality 99 -pointsize 22 -fill '#000000' -draw 'text 17,27 \"%s\"' -fill '#000000' -draw 'text 13,27 \"%s\"' -fill '#000000' -draw 'text 17,23 \"%s\"' -fill '#000000' -draw 'text 13,23 \"%s\"' -fill '#ffffff' -draw 'text 15,25 \"%s\"' \"%s\" \"%s/%08d-%s\"     \\n " "$COMMENT" "$COMMENT" "$COMMENT" "$COMMENT"  "$COMMENT" "$photo" "$SDIR" $num "$( echo $( basename "$( dirname "$photo" )")-$( basename "$photo" ) | tr ' /' '__' )"|bash
	#echo "$( draw_text_string "$COMMENT" '#000000' '#ffffff' 15 25 )" 
	printf "convert -auto-orient -resize 1920x1080 -quality 99 -pointsize 23 %s \"%s\" \"%s/%08d-%s\"     \\n " "$( draw_text_string "$COMMENT" '#000000' '#ccff00' 15 25 )"  "$photo" "$SDIR" $num "$( echo $( basename "$( dirname "$photo" )")-$( basename "$photo" ) | tr ' /' '__' )"|bash
	echo .
    done | pv -N 'photo conversion' -peabrl -s $COUNT  > /dev/null

cd /
umount /usb

