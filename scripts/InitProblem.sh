#!/bin/bash

# Give the problem number in uva as the single argument
# Script downloads the problem pdf, creates the problem directory, extracts the test cases
# ../config.sh needs to be set up (use ../config.sh.example as guide)

addToGit() {
    for file in "$@"; do
        show "Added ${MAGENTA}$(basename "$file")${WHITE} to git"
        git add "$file"
    done
}

if [[ $# -eq 0 ]]; then
    show "${RED}ERROR${WHITE}: No arguments supplied" >&2
    exit 1
fi

if ! [[ $1 =~ ^[0-9]+$ ]]; then
    show "${RED}ERROR${WHITE}: $1 is not a number" >&2
    exit 1
fi

show "Downloading ${YELLOW}$1.pdf${WHITE}"
curl -s https://onlinejudge.org/external/$(($1 / 100))/$1.pdf --output $UVA_HOME/$1.pdf
if ! [[ -f "$UVA_HOME/$1.pdf" ]]; then
    show "${RED}ERROR${WHITE}: Could not find ${YELLOW}$1.pdf${WHITE}" >&2
    exit 1
fi
pdftext=$(pdftotext -raw -nopgbrk -eol "unix" $UVA_HOME/$1.pdf -)
# TODO FILTER PAGE BREAK

# Determine problem directory, if it already has one then use it
problem_dir=$(\ls -d $UVA_HOME/*/ | xargs -n1 basename | \grep ^$1)
if [[ -d $UVA_HOME/$problem_dir.* ]]; then
    show "Problem ${BLUE}$1${WHITE} already has problem directory ${YELLOW}$problem_dir${WHITE}. [y/n] to use this directory; quit otherwise"
    read cont
    if [[ $cont != 'y' ]]; then
        show "Quitting"
        exit 1
    fi
else
    problem_dir=$(echo "$pdftext" | head -1 | sed "s/ /-/" | sed "s/ /_/g")
fi


# Create the problem directory
if ! [[ -d $UVA_HOME/$problem_dir ]]; then
    mkdir $UVA_HOME/$problem_dir
fi

# Move pdf to correct location if there is no pdf
if [[ -z $(\ls "$UVA_HOME/$problem_dir" | \grep "\.pdf") ]]; then
    mv "$UVA_HOME/$1.pdf" "$UVA_HOME/$problem_dir/$1.pdf"
    addToGit "$UVA_HOME/$problem_dir/$1.pdf"
else
    show "PDF already exists for problem ${BLUE}$1${WHITE}"
    rm "$UVA_HOME/$1.pdf"
fi

test_case_dir="$UVA_HOME/$problem_dir/test-cases/"

# Create the test cases
show "Creating test cases"
if ! [[ -d "$test_case_dir" ]]; then
    mkdir "$test_case_dir"
fi
python3 $(dirname $0)/MakeTestsFromProblemText.py "$test_case_dir/" "$(echo "$pdftext" | sed -n '/^Sample Input$/,//p' | \grep -v '^Universidad de Valladolid OJ.*$' )"

# TODO Download test cases from uDebug

# Add test cases to git
for file in $(\ls "$test_case_dir/"); do
    addToGit "$test_case_dir/$file"
done

