#!/bin/bash

source ../logger.sh

#with line no
log_error 0 "msg" 23
log_error 1 "err" 39

#without line no
log_error 0 "msg"
log_error 1 "err"

#empty lines
log_error 0 ""
log_error 1 ""

#with file arg supplied
log_error 0 "" "" "error2.log"
log_error 1 "" "" "error2.log"
