#!/bin/bash

# Applies penalty for late submission. Lab is worth 30 points, and it can be 
# submitted up to 48 hours late. Penalty is prorrated for this interval of time
# Add student to ${late_roster} and create a ${lategrade} file that needs to be 
# accounted when manually grading submissions
#
# 'deadline' needs to be in the following format: "2015-04-20 19:00:00"
#
# Usage: late_submissions.sh roster_file deadline

function main {
    # File config defines variable 'svnpath'
    # If the first command succeeds the second will never be executed
    source ../../scripts/config || { echo >&2 "Please cd into the directory first"; exit 1; }
    lab=lab11
    late_roster=${lab}_late.txt

    # Check if help was requested
    if [ "$1" = "help" ]
    then
        give_help
    fi

    # Check if number of arguments is correct
    if [ $# -ne 2 ]; then 
        echo Usage: $0 roster_file deadline
        exit
    fi

    # Parse arguments
    roster=${svnpath}/_rosters/$1.txt
    # ${deadline} will store seconds since 1970-01-01 00:00:00 UTC
    deadline=$(date -d "$2" +%s)

    # Check for valid roster file
    if [ ! -f ${roster} ]
    then
        echo "Invalid file: \"${roster}\""
        exit
    fi

    # Make sure late roster is cleared
    if [ -f ${late_roster} ]
    then
        rm ${late_roster}
    fi

    echo "Running grading script for ${lab} in ${svnpath}"

    for student in `cat $roster` 
    do
        echo "${student}"

        lategrade=${svnpath}/${student}/${lab}/late.txt
        program=${svnpath}/${student}/${lab}/${lab}.bin

        # Show lastest entry of svn log for ${program}, strip unnecessary lines
        log_result=`svn log -l 1 ${program}  | grep "|"`

        # Parse log_result
        student=`echo ${log_result} | awk '{print $3}'`
        day=`echo ${log_result} | awk '{print $5}'`
        hour=`echo ${log_result} | awk '{print $6}'`

        # ${submission} will store seconds since 1970-01-01 00:00:00 UTC
        submission=`date -d"${day} ${hour}" +%s`

        # Total seconds late
        difference=$((${submission}-${deadline}))

        if [ "${difference}" -gt "0" ]
        then
            # Student can be up to 48 hours late, homework is worth 30 points
            # Tell bc to use only two decimal digits (scale=2)
            penalty=`echo "scale=2; (${difference} * 30.0) / (3600.0 * 48.0)" | bc`
            echo ${student} ${day} ${hour} ${difference} ${penalty}

            # Add student to late roster and create a ${lategrade} file that 
            # needs to be accounted when manually grading submission
            echo ${student} >> ${late_roster}
            echo "Last submission: $day $hour" > ${lategrade}
            echo "Late Penalty: $penalty/30" >> ${lategrade}
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
# Applies penalty for late submission. Lab is worth 30 points, and it can be 
# submitted up to 48 hours late. Penalty is prorrated for this interval of time
# Add student to ${late_roster} and create a ${lategrade} file that needs to be 
# accounted when manually grading submissions
#
# 'deadline' needs to be in the following format: "2015-04-20 19:00:00"
#
# Usage: late_submissions.sh roster_file deadline
EOF
    exit
}

# By passing "$@" to main() you can access the command-line arguments $1, $2, 
# et al just as you normally would
main "$@"

