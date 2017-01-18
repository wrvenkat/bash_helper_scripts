#!/bin/bash

#Test for bash_quoting_parsing.sh
#Reads test data from bash_quoting_parsing_test_data and calls bash_quoting_parsing.sh

TEST_FILE=bash_quoting_parsing_test_data

test_function(){

    local testdata=
    source ../bash_quoting_parsing.sh
    while read testdata; do
	printf "TestData is: %s\n" "$testdata"
	if bash_quoting_parse "$testdata"; then
	    printf "Quoting parsed value is:%s\n\n" "$quoting_parsed_string"
	fi
    done < "$TEST_FILE"
}

test_function
