#!/bin/bash

#To test single_quotes_wrap.sh and see if it is necessary and examine how bash handles

TEST_FILE1=single_quotes_wrap_test_data

TEST_FILE="$TEST_FILE1"
aline=

source ../singlequotes_wrap_unwrap.sh
while read aline; do
    printf "Line is %s\n" "$aline"
    if wrap_unwrap_singlequotes 1 "$aline"; then
	./call1.sh "$output_string"
    fi
done < "$TEST_FILE"
