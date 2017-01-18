#!/bin/bash

printf "Call1 received %s\n" "$1"
./call2.sh "$1"
