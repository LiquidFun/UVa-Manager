#!/bin/bash

problems="$(find-problem $1)"

# Check if problem doesn't match any problems
if [[ -z "$problems" ]]; then
    show "${RED}ERROR${WHITE}: Your problem description \"${GREEN}$1${WHITE}\" does not match any problems"
    exit 1
fi

problem_count="$(echo "$problems" | wc -l)"
problem_dir="$(echo "$problems" | head -n 1)"
problem_arr=()

# Check if problem matches more than 1 problem
if [[ $problem_count -gt 1 ]]; then
    show "Your problem description \"${GREEN}$1${WHITE}\" matches ${BLUE}$problem_count${WHITE} problems!"
    # echo "$(echo "$problems" | nl -s '. ' | \grep --color=always j)"
    index=1
    while read line; do
        problem_arr+=("$line")
        printf "\t${BLUE}%4d${WHITE}.\t${YELLOW}%s${WHITE}\n" $index $(basename "$line")
        ((index+=1))
    done <<< "$problems"
    show "Enter [${BLUE}1${WHITE}-${BLUE}$problem_count${WHITE}] to choose a problem or '${GREEN}q${WHITE}' to quit: "
    read num
    if (( 1 <= $num && $num <= $problem_count )); then
        problem_dir="${problem_arr[(($num-1))]}"
    else
        show "Quitting (wrong input ${BLUE}$num${WHITE})"
        exit 1
    fi
fi

# Make sure it's actually the problem directory (unnecessary since find-problem now only gives problems)
# might be removed
# while [[ -n "$problem_dir" && ! "$(basename $problem_dir)" =~ [0-9]*-.* && ! "$problem_dir" =~ .|/ ]]; do
#     echo $problem_dir
#     problem_dir=$(dirname $problem_dir)
# done    

# Check if such a problem actually exists
problem_num=$(echo "$(basename $problem_dir)" | \grep -o "[0-9]*")
if [[ -z $problem_num ]]; then
    show "${RED}ERROR${WHITE}: Cannot find problem with that name"
    exit 1
fi
if ! [[ -d "$problem_dir"/$KUERZEL ]]; then
    mkdir "$problem_dir"/$KUERZEL
fi

# Go to the KUERZEL directory and open the files if $EDITOR is set
cd "$problem_dir/$KUERZEL"
if [[ -n $EDITOR ]]; then
    if [[ -z $(\ls .) ]]; then
        # dir="$problem_dir"/$KUERZEL/$problem_num
        # TODO implement array for files to open
        $EDITOR "$problem_num".cpp "$problem_num".py
    else
        $EDITOR *.cpp *.py
    fi
else
    show 'ERROR: Your $EDITOR Variable is not set!'
fi
