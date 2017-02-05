#!/bin/bash

TEST_FILE1=bnr_list.conf
TEST_FILE2=bnr_list1.conf
TEST_FILE3=bnr_list2.conf
TEST_FILE4=bnr_list3.conf

TEST_FILE="$TEST_FILE4"

main(){
    printf "Running strict_read test!\n"
    source "../strict_read.sh"
    #A working case
    if strict_read --field='\t,\s' --line="\n" --comment="#" --group='"' --esc < <(cat "$TEST_FILE" | sort); then
	while strict_get; do
	    printf "Line No: %s:\n" "$strict_index"
	    printf "Unparsed line is: %s\n" "$strict_unparsed_line"
	    for index in "${!strict_line[@]}"; do
		local abs_path=
		printf "W%s:%s " "$index" "${strict_line[$index]}"
		if [ "$index" -eq 3 ]; then		
		    value544="${strict_line[$index]}"
		    printf "Value before expansion: %s\n" "$value544"
		    local result=
		    ./../safe_tilde_expansion.sh "$value544" 1
#		    if result=$(./../safe_tilde_expansion.sh "$value544" 1); then
#			local str=
#			local index=1
#			while read str; do
##			    if [ "$index" -eq 3 ]; then
#				printf "Expanded path is %s\n" "$str"
#			    elif [ "$index" -eq 1 ]; then
#				printf "Tilde prefix is %s\n" "$str"
#			    fi
#			    ((index+=1))
#			done < <(echo "$result")
#		    else
#			printf "Expansion failed. Error is:%s\n" "$abs_path"
#		    fi
		fi
	    done
	    printf "\n"
	done
    fi
}

main
