#!/bin/bash

printf "Call2 received %s\n" "$1"
./call3.sh "$1"
