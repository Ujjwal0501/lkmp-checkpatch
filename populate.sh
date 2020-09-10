#!/bin/bash
if [ ! -d "workingdir" ]; then mkdir workingdir || exit 1; fi
cd workingdir || exit 1

if [ ! -d "commit_lists" ]; then mkdir commit_lists || exit 1; fi
cd commit_lists || exit 1

# get commits in first
if [ ! -f commit_list_in_5.7 ]; then
    git log v5.7 --oneline --no-merges --format="%H" > commit_list_in_5.7
else
    echo -e "\nFILE_EXISTS: commit_list_in_5.7"
fi

# get commits in second
if [ ! -f commit_list_in_5.8 ]; then
    git log v5.8 --oneline --no-merges --format="%H" > commit_list_in_5.8
else
    echo -e "\nFILE_EXISTS: commit_list_in_5.8"
fi


#*************** GET REQUIRED LIST OF COMMITS *******************

# get commits in second and not in first
if [ ! -f commit_list_in5.8_and_not5.7 ]; then
    git log v5.8 ^v5.7 --oneline --no-merges --format="%H" > commit_list_in5.8_and_not5.7
else
    echo -e "\nFILE_EXISTS: commit_list_in5.8_and_not5.7"
fi

#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


# sort commit_list_in_5.7 > sorted1
# sort commit_list_in5.8_and_not5.7 > sorted2
# sort commit_list_in_5.8 > sorted3

# echo -e "\nThe common commits in '5.7' and '5.8 ^5.7' are:"
# comm -1 -2 sorted1 sorted2
# # line 17 should print nothing

# C=$(comm -1 -2 sorted2 sorted3 | wc -l)
# D=$(cat sorted2 | wc -l)

# if [ "$C" = "" ]; then
#     echo -e "\nNothing common in '5.8' and '5.8 ^5.7'. Exiting..."
#     exit 1
# elif [ $C -eq $D ]; then
#     echo -e "\n'5.8' and '5.8 ^5.7' are correct lists"
# fi


# ***************************************************************
# BELOW WE RUN SCRIPT checkpatch.pl ON ALL COMMITS
# ***************************************************************
cd .. || exit 1
if [ ! -d "reports" ]; then mkdir reports || exit 1; fi
cd .. || exit 1

if [ ! -f "workingdir/checkpatch_result" ]; then
    scripts/checkpatch.pl -g v5.7..v5.8 --terse --show-types | grep -o "[a-z0-9]*:[0-9]*: [A-Z_]*:[A-Z0-9_]*" > workingdir/checkpatch_result
else
    echo -e "\nFILE_EXISTS: workingdir/checkpatch_result"
fi


# ***************************************************************
# BELOW WE COLLECT STATS FROM REPORTS
# ***************************************************************
# cd workingdir || exit 1
# if [ -f "collecting_stats" ]; then rm "collecting_stats"; fi
# if [ -f "stats" ]; then rm "stats"; fi

# for j in $LIST; do
#     cat reports/$j | grep "^[A-Z:_]*" -oh | grep ":" | cut -f 2- -d ':' >> collecting_stats
# done


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
    commit=$(echo $line | awk -F'[: ]' '{print 7}')
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


# ***************************************************************
# BELOW WE COLLECT STATS FROM REPORTS
# ***************************************************************
CHKPTCH=( "$(cat checkpatch_result)" )
if [ ! -f "stats" ]; then
    echo -e "Total ERRORS:\t$(echo "$CHKPTCH" | grep ERROR: -c)" >> stats
    echo -e "Total WARNINGS:\t$(echo "$CHKPTCH" | grep WARNING: -c)" >> stats
    echo -e "Total CHECKS:\t$(echo "$CHKPTCH" | grep CHECK: -c)" >> stats
    echo "" >> stats

    echo -e "Type of ERRORS:\t$(cat attention/ERROR_type | wc -l)" >> stats
    echo -e "Type of ERRORS:\t$(cat attention/WARNING_type | wc -l)" >> stats
    echo -e "Type of ERRORS:\t$(cat attention/CHECK_type | wc -l)" >> stats
    echo "" >> stats

    printf '\t%-40s %-15s %-15s\n' "TYPE" "OCCURRENCES" "COMMITS" >> stats
    for f in $(ls -1 "type/"); do
        printf '\t%-40s %-15s %-15s\n' "$f" "$(echo "$CHKPTCH" | grep $f -c)" "$(cat type/$f | wc -l)" >> stats
    done
else
    echo -e "\nOld statistics found"
fi