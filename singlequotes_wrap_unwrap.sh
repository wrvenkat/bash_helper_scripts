#!/bin/bash

#This utility is used to wrap a given input in single-quotes so that it can be passed on to other scripts without bash performing expansion on it
#This utility also unwraps such a string enclosed in single-quotes for use further.

#The input is a string on which Bash's quoting apply (The first three entries of https://www.gnu.org/software/bash/manual/bash.html#Quoting)
#The output is a string that is single-quoted so that bash doesn't

#This utility needs to be sourced in the target script because, the string that needs to be wrapped or unwrapped because it will be subject to any possible expansion when it is passed to this script if it is invoked.

input_string=
output_string=

#wraps the input_String in single quotes to prevent expansion in CLI usage
singlequotes_wrap(){

    local orig_IFS="$IFS"
    IFS=
    while read -r -N 1 char; do
	case "$char" in
	    "'" ) output_string="$output_string"\\\'; continue;;
	    "\\" ) output_string="$output_string"\'\\\'; continue;;
	    * ) output_string="$output_string"\'"$char"\'; continue;;
	esac
    done < <(printf "%s" "$input_string")
    IFS="$orig_IFS"
    return 0
}

#unwraps a single quotes enclosed string that is from singlequotes_wrap to the actual string
singlequotes_unwrap(){

    local char=
    local s_quote=0
    local backslash=0
    local orig_IFS="$IFS"
    IFS=
    while read -r -N 1 char; do
	#printf "Char is %s\n" "$char"
	
	if [ "$char" == "'" ]; then
	    if [ "$backslash" -eq 0 ]; then
		if [ "$s_quote" -eq 1 ]; then
		    s_quote=0; continue;
		elif [ "$s_quote" -eq 0 ]; then
		    s_quote=1; continue;
		fi
	    elif [ "$backslash" -eq 1 ]; then
		output_string="$output_string"\';
		backslash=0; continue;
	    fi
	fi

	if [ "$char" == '\' ]; then
	    if [ "$s_quote" -eq 1 ]; then
		output_string="$output_string"\\
		s_quote=0; continue;
	    elif [ "$s_quote" -eq 0 ]; then
		backslash=1; continue;
	    fi
	fi

	if [ "$s_quote" -eq  1 ]; then
	    output_string="$output_string""$char"; continue;
	else
	    printf "ERROR: Incorrect format\n"
	    return 1
	fi
    done < <(printf "%s" "$input_string")
    IFS="$orig_IFS"
    return 0
}

wrap_unwrap_singlequotes(){    
    if [ -z "$1" ] || [ -z "$2" ]; then
	printf "Incorrect arguments specified.\n"
	return 1
    fi

    if [ "$1" -ne 1 ] && [ "$1" -ne 0 ]; then
	printf "ERROR: Incorrect first argument."
	return 1
    fi

    input_string="$2"
    output_string=

    if [ "$1" -eq 1 ]; then
	singlequotes_wrap
	return $?
    elif [ "$1" -eq 0 ]; then
	singlequotes_unwrap
	return $?
    fi
}

#wrap_unwrap_singlequotes "$@"
