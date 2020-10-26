#!/bin/sh

# -|-- ------------------------------------------------------------------ --|-
# -|--                           Program Tester                           --|-
# -|-- ------------------------------------------------------------------ --|-

# Takes a filename as input, compiles it if needed, then runs test cases on it.
# These test cases need to be named A, B, C... etc.  The ground truths need to
# be named A1, B1, C1... etc. It will then show you whether your result 
# matches these ground truths.  No file extensions! Although feel free to
# modify it.  Supports Python, C and C++ right now.

# Additionally implement a quick way to run it with your editor/desktop
# environment. I use a vim mapping: 
# nnoremap <CR> :w<CR>:!/absolute/file/location/ProgramTester.sh %<CR>

# Compile c++ and c if needed
extension=${1##*.}
if [[ $extension == cpp ]]; then
    g++ -O2 -std=c++11 $1
elif [[ $extension == c ]]; then
    gcc -O2 -ansi $1
fi

# Get full path for finding the test case directory
full_path="$1"
if [[ $1 != /* ]]; then
    full_path="$PWD/$1"
fi

# echo "$1"
# echo $full_path

problem_dir=$(dirname $(dirname "$full_path"))
test_case_dir="$problem_dir/test-cases/" 


for test_file_name in $(\ls $test_case_dir | \grep -E "^t[0-9]+in\.txt$"); do
    file=$test_case_dir/$test_file_name
    if [[ -e $file ]]; then

        # Print problem name
        problem_name=$(echo $(basename $problem_dir) | sed "s/[-_]/ /g")
        echo -e "    ┌${BLUE}$problem_name${WHITE}"

        # Print dividing line
        echo -n "────┤"
        echo -n -e "${YELLOW}$test_file_name${WHITE}├"
        for i in $(seq $(($(tput cols) - 6 - ${#test_file_name}))); do
            echo -n "─"
        done
        echo ""

        # Run with current test
        resFile=$(echo "${test_file_name}" | sed "s/in\.txt$/res\.txt/")
        if [[ $extension == cpp ]]; then
            echo -e "$(./a.out < $file)" > $resFile
        elif [[ $extension == c ]]; then
            echo -e "$(./a.out < $file)" > $resFile
        elif [[ $extension == py ]]; then
            echo -e "$(python3 $1 < $file)" > $resFile
        fi

        # Depending if there is the results file use it as comparison file
        outFile=$(echo "${file}" | sed "s/in\.txt$/out\.txt/")
        if [[ -e $outFile ]]; then
            echo -e "$(nl $outFile)" > "tmp1"
        else
            echo -e "No results file! Input instead:" > "tmp1"
            cat "${file}" >> "tmp1"
        fi

        # Show the difference between the two files
        echo -e "$(nl $resFile)" > "tmp2"
        if [[ -n $RED ]]; then
            colordiff --report-identical-files --side-by-side tmp1 tmp2
        else
            diff --report-identical-files --side-by-side tmp1 tmp2
        fi
        echo -e $output

        # Delete tmp files
        if [[ -e tmp1 ]]; then
            rm tmp1
        fi
        if [[ -e tmp2 ]]; then
            rm tmp2
        fi
    fi
done
for i in $(seq $(tput cols)); do
    echo -n "─"
done
