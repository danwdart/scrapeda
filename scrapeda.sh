#!/usr/bin/env nix-shell
#! nix-shell -p xmlstarlet -i bash

usage() {
    echo "Usage: $0 [favs|user] [directory|name|default] SEARCH"
    exit 1
}

main() {
    ACTION=$1
    SORT=$2
    SEARCH=$3
    NEXT=$4
    URL=""

    case $SORT in
        directory)
            ;;
        author)
            ;;
        default)
            ;;
        *)
            usage
            ;;
    esac

    if [[ "" == "$SEARCH" ]]
    then
        usage
    fi


    case $ACTION in
        favs)
            URL="http://backend.deviantart.com/rss.xml?q=favby%3A$SEARCH+sort%3Atime&type=deviation"
            ;;

        user)
            URL="http://backend.deviantart.com/rss.xml?q=gallery%3A$SEARCH+sort%3Atime&type=deviation"
            ;;
        "")
            usage
            ;;
        *)
            usage
            ;;
    esac


    if [ "" == "$NEXT" ]
    then
        dA=$(wget -O- "$URL")
    else
        dA=$(wget -O- "$NEXT")
    fi

    case $SORT in
        directory)
            echo "$dA" | xmlstarlet sel -t \
                -m "//item" \
                -o "wget -P" \
                -v "./media:credit[1]" \
                -o "/ '" \
                -v "./media:content/@url" \
                -o "'" \
                -n  | sh
            ;;

        author)
            echo "$dA" | xmlstarlet sel -t \
                -m "//item" \
                -o "wget -O\"" \
                -v "./media:credit[1]" \
                -o " - " \
                -v "./media:title" \
                -o "\" " \
                -v "./media:content/@url" \
                -n | sh
            ;;

        default)
            echo "$dA" | xmlstarlet sel -T -t -v //media:content/@url > urls
            wget --content-disposition -i urls
            rm urls

            ;;
        *)
            usage
            ;;
    esac

    echo "Renaming..."
    find -name "*\?*" | sed 's/\(\(.*\)?.*\)/mv \1 \2/g' | sh
    echo "Renamed."

    NEXT=$(echo "$dA" | xmlstarlet sel -T -t -v "//atom:link[@rel='next']/@href")
    
    if [ "" != "$NEXT" ]
    then
        main "$ACTION" "$SORT" "$SEARCH" "$NEXT&token=AAAAAAAAA"
    else
        echo Done
    fi
}

main $1 $2 $3 $4