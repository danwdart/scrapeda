#!/bin/bash
# Script to rip DeviantART favourites for a user and download them into directories named after each deviation's author.
if [ "" = "$2" ]
then
    dA=`wget -O-  "http://backend.deviantart.com/rss.xml?q=favby%3A$1+sort%3Atime&type=deviation"`
else
    dA=`wget -O- "$2"`
fi
 
echo $dA | xmlstarlet sel -t \
     -m "//item" \
     -o "wget -P" \
     -v "./media:credit[1]" \
     -o "/ '" \
     -v "./media:content/@url" \
     -o "'" \
     -n  | sh
 
NEXT=`echo $dA | xmlstarlet sel -T -t -v "//atom:link[@rel='next']/@href"`
if [ "" != "$NEXT" ]
then
    $0 $1 $NEXT
else
    echo Done
fi
