#!/bin/bash

printf "*********Before Sourcing*********\n"

./../logger.sh

./../logger.sh -h

./../logger.sh --help

msg="message! and error2.log file"

./../logger.sh --msg='Non-sourced message!' --logfile=error2.log

./../logger.sh --msg="" --logfile=error2.log

./../logger.sh -m"info messge"

./../logger.sh -m"Info: No colour1!" -nc

./../logger.sh -m"Info: No colour2!" --nocolour

./../logger.sh --msg="Info: No time!" --notime

./../logger.sh --msg="Info: No colour and no time!" --nocolour --notime

./../logger.sh -m"info messge with line no1" -l 10

./../logger.sh -m"info messge with line no2" --line=10

./../logger.sh -m"Info: No colour with line no1!" -nc -l 10

./../logger.sh -m"Info: No colour with line no2!" --nocolour --line=10

./../logger.sh --msg="Info: No time with with line no!" --notime --line=16

./../logger.sh --msg="Info: No colour and no time with line no!" --nocolour --notime -l:10

./../logger.sh -m"Error messge" -e

./../logger.sh -m"Error: No colour1!" -nc --err

./../logger.sh -m"Error: No colour2!" --nocolour --err

./../logger.sh --msg="Error: No time!" --notime --err

./../logger.sh --msg="Error: No colour and no time!" --nocolour --notime -e

./../logger.sh -m"Error messge with line no1" -l 10  --err

./../logger.sh -m"Error messge with line no2" --line=10 -e

./../logger.sh -m"Error: No colour with line no1!" -nc -l 10 -e

./../logger.sh -m"Error: No colour with line no2!" --nocolour --line=10 --err

./../logger.sh --msg="Error: No time with with line no!" --notime --line=16 -e

./../logger.sh --msg="Error: No colour and no time with line no!" --nocolour --notime -l 10 --err

source ../logger.sh
printf "\n**********After Sourcing*********\n"

log_msg

log_msg -h

log_msg --help

log_msg --msg="message! and error2.log file" --logfile=error2.log

log_msg --msg= --logfile=error2.log

log_msg -m"info messge"

log_msg -m"Info: No colour1!" -nc

log_msg -m"Info: No colour2!" --nocolour

log_msg --msg="Info: No time!" --notime

log_msg --msg="Info: No colour and no time!" --nocolour --notime

log_msg -m"info messge with line no1" -l 10

log_msg -m"info messge with line no2" --line=10

log_msg -m"Info: No colour with line no1!" -nc -l 10

log_msg -m"Info: No colour with line no2!" --nocolour --line=10

log_msg --msg="Info: No time with with line no!" --notime --line=16

log_msg --msg="Info: No colour and no time with line no!" --nocolour --notime -l:10

log_msg -m"Error messge" -e

log_msg -m"Error: No colour1!" -nc --err

log_msg -m"Error: No colour2!" --nocolour --err

log_msg --msg="Error: No time!" --notime --err

log_msg --msg="Error: No colour and no time!" --nocolour --notime -e

log_msg -m"Error messge with line no1" -l 10  --err

log_msg -m"Error messge with line no2" --line=10 -e

log_msg -m"Error: No colour with line no1!" -nc -l 10 -e

log_msg -m"Error: No colour with line no2!" --nocolour --line=10 --err

log_msg --msg="Error: No time with with line no!" --notime --line=16 -e

log_msg --msg="Error: No colour and no time with line no!" --nocolour --notime -l 10 --err


#old test cases
#with line no
#log_error 0 "msg" 23
#log_error 1 "err" 39

#without line no
#log_error 0 "msg"
#log_error 1 "err"

#empty lines
#log_error 0 ""
#log_error 1 ""

#with file arg supplied
#log_error 0 "" "" "error2.log"
#log_error 1 "" "" "error2.log"
