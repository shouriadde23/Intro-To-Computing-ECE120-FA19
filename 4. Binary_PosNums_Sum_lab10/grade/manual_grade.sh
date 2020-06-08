#!/bin/bash

# Manually grades students' submissions. Ignores students that do not have a 
# working copy of the lab. It then opens in gedit students' answers in file
# '{lab_bin}', then opens the '{gradefile}'. If the student asked for
# regrade request, regrade file is open as well.
# If optional argument '{regrade}' matches first characters of pattern "regrade"
# then only students that asked for regrade will be opened.
#
# Usage: manual_grade.sh roster [regrade]

function main {
    # File config defines variable 'svnpath'
    # If the first command succeeds the second will never be executed
    source ../../scripts/config || { echo >&2 "Please cd into the directory first"; exit 1; }
    lab=lab10
    solutions=solution.txt

    # Check if help was requested
    if [ "$1" = "help" ]
    then
        give_help
    fi

    # Check if number of arguments is correct
    if [[ $# -ne 1 && $# -ne 2 ]]; then 
        echo Usage: $0 roster [regrade]
        exit
    fi

    # Check if second argument is correct
    if [[ $# -eq 2 && regrade != "$2"* ]]
    then
        echo "Argument not recognized: \"$2\""
        echo "Usage: $0 roster_file [regrade]"
        exit
    fi

    if [[ $# -eq 1 ]]
    then
        regrade=no
    else
        regrade=$2
    fi

    # Parse arguments
    roster=${svnpath}/_rosters/$1.txt

    # Check for valid roster file
    if [ ! -f ${roster} ]
    then
        echo "Invalid file: \"${roster}\""
        exit
    fi

    echo "Running grading script for ${lab} in ${svnpath}"

    for student in `cat $roster`
    do
        # Check student has a directory, otherwise continue to next student
        if [ ! -d ${svnpath}/${student}/${lab} ]
        then
            continue;
        fi

        lab_bin=${svnpath}/${student}/${lab}/${lab}.bin
        gradefile=${svnpath}/${student}/${lab}/grade.txt
        regradefile=${svnpath}/${student}/${lab}/regrade.txt

        # Only open available files
        if [ -f ${gradefile} ]
        then
            if [ -f ${regradefile} ]
            then
                gedit ${regradefile} ${lab_bin} ${gradefile}
            else
                if [[ "${regrade}" != r* ]]
                then
                    gedit ${lab_bin} ${gradefile}
                else
                    continue
                fi
            fi
        fi
    done
}

function give_help {
    # More info on: http://en.wikipedia.org/wiki/Here_document#Unix-Shells
    # E.g: http://stackoverflow.com/questions/2500436/how-does-cat-eof-work-in-bash
    # This type of redirection instructs the shell to read input from the 
    # current source until a line containing only 'delimiter' (with no trailing 
    # blanks) is seen.
    #
    # All of the lines read up to that point are then used as the standard input
    # for a command.
    #
    # The format of here-documents is:
    #
    #          <<[-]delimiter
    #                  here-document
    #          delimiter
    #
    # If the redirection operator is <<-, then all leading tab characters are 
    # stripped from input lines and the line containing delimiter. This allows 
    # here-documents within shell scripts to be indented in a natural fashion.
cat <<- EOF
# Manually grades students' submissions. Ignores students that do not have a 
# working copy of the lab. It then opens in gedit students' answers in file
# '{lab_bin}', then opens the '{gradefile}'. If the student asked for
# regrade request, regrade file is open as well.
# If optional argument '{regrade}' matches first characters of pattern "regrade"
# then only students that asked for regrade will be opened.
#
# Usage: manual_grade.sh roster [regrade]
EOF
    exit
}

# By passing "$@" to main() you can access the command-line arguments $1, $2, 
# et al just as you normally would
main "$@"

