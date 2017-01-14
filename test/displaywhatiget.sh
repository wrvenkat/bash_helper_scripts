#!/bin/bash

set -xv

allbutfirst=${1#?}
printf "Length of string is %s\n" "${#1}"
echo "I got this:" "$1"
