#!/bin/bash

#Testing the new singlequotes_wrap

str1=\'"\"hello                world\""
./displaywhatiget.sh "$str1"

str="$str1"

if ! source ../singlequotes_wrap_unwrap.sh; then
    printf "ERROR: Sourcing in singlequotes_wrap_unwrap.sh"
    exit 1
fi

#wrap and unwrap input value
if wrap_unwrap_singlequotes 1 "$str"; then
    printf "Wrapped text is:%s\n" "$output_string"
    str="$output_string"

    if wrap_unwrap_singlequotes 0 "$str"; then
	printf "Unwrapped text is:%s\n" "$output_string"
    fi
fi
