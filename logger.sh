#!/bin/bash

#possbile scopes,
#0 - make colour optional
#1 - make logger invokeable and sourceable
#2 - replace function arguments with command-line arguments
#3 - support logall - log both INFO and ERROR messages to file
#4 - support custom file option replacing default file

LOG_FIRST_RUN=0
ERROR_LOG_FILE=error.log

#error logger function
#accepts 3 arguments. 1-level, 2-error/message, 3-step/line
#1-level can be 0-INFO, 1-ERROR
#3-step/line number can be optional. This is because, not always do we have a line number to
#report error on.
log_error() {
    if [ -n "$1" ]; then
	if [ -n "$4" ]; then
	    ERROR_LOG_FILE="$4"
	else
	    ERROR_LOG_FILE=error.log
	fi
	
	if [ "$1" -eq 0 ]; then
	    if [ -n "$3" ]; then
		printf "[\e[92m INFO\e[39m]::%s:: Line-%s: %s\n" "$(date)" "$3" "$2"
	    else
		printf "[\e[92m INFO\e[39m]::%s:: %s\n" "$(date)" "$2"
	    fi
	elif [ "$1" -eq 1 ]; then
	    if [ -n "$3" ]; then
   		printf "[\e[91mERROR\e[39m]::%s:: Line-%s: %s\n" "$(date)" "$3" "$2" 1>&2
		printf "[ERROR]: Line-%s::%s:: %s\n" "$(date)" "$3" "$2" >> "$ERROR_LOG_FILE"
	    else
		printf "[\e[91mERROR\e[39m]::%s:: %s\n" "$(date)" "$2" 1>&2
		printf "[ERROR]::%s:: %s\n" "$(date)" "$2" >> "$ERROR_LOG_FILE"
	    fi
	fi
    fi
}
