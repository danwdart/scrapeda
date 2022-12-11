#!/bin/bash
# Script to rip DeviantART user's deviations Use like "dauser.sh [username]"
if [ "" = "$2" ]
then
    dA=`wget -O-  "http://backend.deviantart.com/rss.xml?q=gallery%3A$1+sort%3Atime&type=deviation"`
else
    dA=`wget -O- "$2"`
fi

echo $dA | xmlstarlet sel -T -t -v //media:content/@url | xargs wget

NEXT=`echo $dA | xmlstarlet sel -T -t -v "//atom:link[@rel='next']/@href"`
if [ "" != "$NEXT" ]
then
    $0 $1 $NEXT
else
    echo Done
fi
