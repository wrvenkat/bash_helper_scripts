#!/bin/bash

LOG_FIRST_RUN=0
ERROR_LOG_FILE=error.log


#error logger function
#accepts 3 arguments. 1-level, 2-error/message, 3-step/line
#1-level can be 0-INFO, 1-ERROR
#3-step/line number can be optional. This is because, not always do we have a line number to
#report error on.
log_error () {
    if [ -n "$1" ] && [ -n "$2" ]; then
	if [ "$1" -eq 0 ]; then
	    if [ -n "$3" ]; then
		printf "INFO: %s\t%s\n" "$3" "$2"
	    else
		printf "INFO: %s\n" "$2"
	    fi
	elif [ "$1" -eq 1 ]; then
	    #if this is the first run, then we add a time stamp
	    if [ "$LOG_FIRST_RUN" -eq 0 ]; then
		local val1=$(date)
		printf "%s\n" "$val1" 2>> "$ERROR_LOG_FILE" 1>&2 
		((LOG_FIRST_RUN+=1))
	    fi
	    if [ -n "$3" ]; then
   		printf "ERROR: Line-%s\t%s\n" "$3" "$2" | tee -a "$ERROR_LOG_FILE" 1>&2
	    else
		printf "ERROR: %s\n" "$2" | tee -a "$ERROR_LOG_FILE" 1>&2
	    fi
	fi
    fi
}
