#!/bin/bash

main_menu() {
    echo -e "Main menu\n"
    echo -e "1. Browse ERRORS"
    echo -e "2. Browse WARNINGS"
    echo -e "3. EXIT"
}

handle_main_menu() {
    case $choice in
        [1])
        attention="ERROR"
        ;;
        [2])
        attention="WARNING"
        ;;
        *)
        exit 0
        ;;
    esac
}

handle_type() {
    IFS=$'\n' read -d '' -r -a LIST < workingdir/type/$choice
    echo $choice
    i=0
    size=${#LIST[@]}
    echo "$size"

    less workingdir/reports/${LIST[0]}
    while [ 1 -eq 1 ]; do
        read dir
        if [ "$dir" = "n" ]; then
            (( i++ ))
            if [ $i -eq $size ]; then (( i-- )); fi
        elif [ "$dir" = "p" ]; then
            (( i-- ))
            if [ $i -eq -1 ]; then (( i++ )); fi
        elif [ "$dir" = "q" ]; then
            break
        fi
        
        v=${LIST[$i]}
        less workingdir/reports/$v
    done
}

while [ 1 -eq 1 ]; do
    main_menu
    read choice
    handle_main_menu
    cat workingdir/attention/${attention}_type
    read choice
    handle_type
done