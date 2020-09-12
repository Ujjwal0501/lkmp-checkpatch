#!/bin/bash
if [ ! -d "workingdir" ]; then mkdir workingdir || exit 1; fi
cd workingdir || exit 1


#*************** GET REQUIRED LIST OF COMMITS *******************

# get commits in second and not in first
collect_commits () {
    if [ ! -f commit_list_in5.8_and_not5.7 ]; then
        echo -e "\nAggregating commits"
        git log v5.8 ^v5.7 --no-merges --format="%H" > commit_list_in5.8_and_not5.7
    else
        echo -e "\nFILE_EXISTS: commit_list_in5.8_and_not5.7"
    fi
}

#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx




# ***************************************************************
# BELOW WE RUN SCRIPT checkpatch.pl ON ALL COMMITS
# ***************************************************************

run_script () {
    cd .. || exit 1

    if [ ! -f "workingdir/checkpatch_result" ]; then
        echo -e "Running script on commits"
        scripts/checkpatch.pl -g v5.7..v5.8 --terse --show-types > workingdir/checkpatch_result
    else
        echo -e "\nFILE_EXISTS: workingdir/checkpatch_result"
    fi

    cd workingdir || exit 1
}

run_script_sequential () {
    if [ ! -d "reports" ]; then mkdir || exit 1; fi
    if [ ! -f "commit_list_in5.8_and_not5.7" ]; then collect_commits; fi
    cd .. || exit 1

    echo -e "Running script sequentially on commits"
    while read line; do
        scripts/checkpatch.pl -g $line --show-types > workingdir/reports/$line
    done < workingdir/commit_list_in5.8_and_not5.7

    cd workingdir || exit 1
}

run_script_no_merges () {
    cd .. || exit 1

    T=$(cat workingdir/commit_list_in5.8_and_not5.7)
    if [ ! -f "workingdir/checkpatch_result" ]; then
        echo -e "Running script on commits no-merges"
        scripts/checkpatch.pl -g $T --terse --show-types > workingdir/checkpatch_result
    else
        echo -e "\nFILE_EXISTS: workingdir/checkpatch_result"
    fi

    cd workingdir || exit 1
}

trim_script_result() {
    if [ ! -f "checkpatch_result" ]; then run_script; fi

    cat checkpatch_result | grep -o "[a-z0-9]*:[0-9]*: [A-Z_]*:[A-Z0-9_]*" > checkpatch_result_trimmed
}


# ***************************************************************
# BELOW WE CATEGORISE COMMITS FROM ERRORS
# ***************************************************************
generate_report() {
    if [ ! -d "attention" ]; then mkdir attention || exit 1; fi
    if [ ! -d "type" ]; then mkdir type || exit 1; fi
    if [ ! -f "checkpatch_result_trimmed" ]; then trim_script_result; fi

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
    done < checkpatch_result_trimmed

    sort attention/WARNING_type > temp
    uniq temp > attention/WARNING_type

    sort attention/ERROR_type  > temp
    uniq temp > attention/ERROR_type

    sort attention/CHECK_type > temp
    uniq temp > attention/CHECK_type
    rm temp
}

# ***************************************************************
# BELOW WE GENERATE STATS FROM REPORTS
# ***************************************************************
collect_stats() {
    if [ ! -f "checkpatch_result_trimmed" ]; then trim_script_result; fi
    CHKPTCH=( "$(cat checkpatch_result_trimmed)" )

    if [ ! -f "stats" ]; then
        echo -e "\nCollecting statistics"

        echo "$CHKPTCH" | cut -f 2- -d ' ' | grep "ERROR" | sort | uniq -c | less | sort -nr >> stats
        echo "" >> stats
        echo "$CHKPTCH" | cut -f 2- -d ' ' | grep "WARNING" | sort | uniq -c | less | sort -nr >> stats
        echo "" >> stats
        echo "$CHKPTCH" | cut -f 2- -d ' ' | grep "CHECK" | sort | uniq -c | less | sort -nr >> stats
        echo "" >> stats
        echo "" >> stats

        printf '\t%-15s %-15s %-40s\n' "OCCURRENCES" "COMMITS" "TYPE" >> stats
        VAL=$( for f in $(ls -1 "type/"); do \
                printf '\t%-15s %-15s %-40s\n' "$(echo "$CHKPTCH" | grep $f -c)" "$(cat type/$f | wc -l)" "$f"; \
            done )
        echo "$VAL" | sort -nr >> stats
        echo "" >> stats
        echo "" >> stats
        
        echo -e "Total ERRORS:\t$(echo "$CHKPTCH" | grep ERROR: -c)" >> stats
        echo -e "Total WARNINGS:\t$(echo "$CHKPTCH" | grep WARNING: -c)" >> stats
        echo -e "Total CHECKS:\t$(echo "$CHKPTCH" | grep CHECK: -c)" >> stats
        echo "" >> stats

        echo -e "Type of ERRORS:\t\t$(cat attention/ERROR_type | wc -l)" >> stats
        echo -e "Type of WARNINGS:\t$(cat attention/WARNING_type | wc -l)" >> stats
        echo -e "Type of CHECKS:\t\t$(cat attention/CHECK_type | wc -l)" >> stats
        echo "" >> stats
    else
        echo -e "\nOld statistics found"
    fi
}

collect_commits
#trim_script_result
#generate_report
collect_stats