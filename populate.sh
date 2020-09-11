#!/bin/bash
if [ ! -d "workingdir" ]; then mkdir workingdir || exit 1; fi
cd workingdir || exit 1


#*************** GET REQUIRED LIST OF COMMITS *******************

# get commits in second and not in first
if [ ! -f commit_list_in5.8_and_not5.7 ]; then
    echo -e "\nAggregating commits"
    git log v5.8 ^v5.7 --no-merges --format="%H" > commit_list_in5.8_and_not5.7
else
    echo -e "\nFILE_EXISTS: commit_list_in5.8_and_not5.7"
fi

#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




# ***************************************************************
# BELOW WE RUN SCRIPT checkpatch.pl ON ALL COMMITS
# ***************************************************************

cd .. || exit 1

if [ ! -f "workingdir/checkpatch_result" ]; then
    echo -e "Running script on commits"
    scripts/checkpatch.pl -g v5.7..v5.8 --terse --show-types | grep -o "[a-z0-9]*:[0-9]*: [A-Z_]*:[A-Z0-9_]*" > workingdir/checkpatch_result
else
    echo -e "\nFILE_EXISTS: workingdir/checkpatch_result"
fi


# ***************************************************************
# BELOW WE COLLECT COUNT FROM REPORTS
# ***************************************************************
cd workingdir || exit 1

if [ ! -d "attention" ]; then mkdir attention || exit 1; fi
if [ ! -d "type" ]; then mkdir type || exit 1; fi

rm attention/*
rm type/*

echo -e "\nGenerating reports..."
while read line; do
    # echo $line
    commit=$(echo $line | awk -F'[: ]' '{print $1}')
    attention=$(echo $line | awk -F'[: ]' '{print $4}')
    type=$(echo $line | awk -F'[: ]' '{print $5}')

    if [ ! "$commit" = "$(touch attention/$attention && tail -n 1 attention/$attention)" ]; then
        echo $commit >> "attention/$attention"
    fi

    if [ ! "$commit" = "$(touch type/$type && tail -n 1 type/$type)" ]; then
        echo $commit >> "type/$type"
    fi

    if [ ! "$commit" = "$(touch attention/${attention}_type && tail -n 1 attention/${attention}_type)" ]; then
        echo $type >> "attention/${attention}_type"
    fi
done < checkpatch_result

sort attention/WARNING_type > temp
uniq temp > attention/WARNING_type

sort attention/ERROR_type  > temp
uniq temp > attention/ERROR_type

sort attention/CHECK_type > temp
uniq temp > attention/CHECK_type
rm temp

# ***************************************************************
# BELOW WE COLLECT STATS FROM REPORTS
# ***************************************************************
CHKPTCH=( "$(cat checkpatch_result)" )
if [ ! -f "stats" ]; then
    echo -e "\nCollecting statistics"
    echo -e "Total ERRORS:\t$(echo "$CHKPTCH" | grep ERROR: -c)" >> stats
    echo -e "Total WARNINGS:\t$(echo "$CHKPTCH" | grep WARNING: -c)" >> stats
    echo -e "Total CHECKS:\t$(echo "$CHKPTCH" | grep CHECK: -c)" >> stats
    echo "" >> stats

    echo -e "Type of ERRORS:\t\t$(cat attention/ERROR_type | wc -l)" >> stats
    echo -e "Type of WARNINGS:\t$(cat attention/WARNING_type | wc -l)" >> stats
    echo -e "Type of CHECKS:\t\t$(cat attention/CHECK_type | wc -l)" >> stats
    echo "" >> stats

    printf '\t%-15s %-15s %-40s\n' "OCCURRENCES" "COMMITS" "TYPE" >> stats
    VAL=$( for f in $(ls -1 "type/"); do \
            printf '\t%-15s %-15s %-40s\n' "$(echo "$CHKPTCH" | grep $f -c)" "$(cat type/$f | wc -l)" "$f"; \
        done )
    echo "$VAL" | sort -n >> stats
else
    echo -e "\nOld statistics found"
fi