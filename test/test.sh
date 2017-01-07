#!/bin/bash

main(){
    printf "Running strict_read test!\n"
    source "../strict_read.sh"
    #A working case
    if strict_read --field='\t,\s' --line="\n" --comment="#" --group='"' < <(cat bnr_list.conf | sort); then
    #Test case for improper escape
    #    if strict_read --field='$,\,@' --line='\n' --comment="#" --group='"' < <(cat bnr_list.conf | sort); then
    #Test case for incorrect start field char
    #    if strict_read --field=',\\,@' --line='\n' --comment="#" --group='"' < <(cat bnr_list.conf | sort); then
    #Test case for incorrect format for after-first field char
    #    if strict_read --field='\,,\\,@' --line='\n' --comment="#" --group='"' < <(cat bnr_list.conf | sort); then
    #Test case for more than one char in same field char place (not separated by comma)    
    #if strict_read --field='\,,\\a,@' --line='\n' --comment="#" --group='"' < <(cat bnr_list.conf | sort); then
    #Test case for backslash as part of field char
    #if strict_read --field='\\,\s' --line="\n" --comment="#" --group='\\' < <(cat bnr_list.conf | sort); then
    #Test case for backslash as part of comment char
    #if strict_read --field='\t,\s' --line="\n" --comment="\\" --group='"' < <(cat bnr_list.conf | sort); then
    #Test case for more than 1 char for comment char
    #if strict_read --field='\t,\s' --line="\n" --comment="123" --group='"' < <(cat bnr_list.conf | sort); then
	#strict_read "$@"
	while strict_get; do
	    printf "Line No: %s:\n" "$strict_index"
	    printf "Unparsed line is: %s\n" "$strict_unparsed_line"
	    for index in "${!strict_line[@]}"; do
		printf "W%s:%s " "$index" "${strict_line[$index]}"
		#	if [ "$index" -eq 3 ]; then
		#	    if remove_group_escape_char "${strict_line[$index]}" 0; then
		#		printf "Clean string is %s\n" "$clean_strict_read_str"
		#	    #	    fi
		#	    value544="${strict_line[$index]}"
		#	    if remove_group_escape_char "${strict_line[$index]}"; then
		#		value544="$clean_strict_read_str"
		#	    fi
		#	    safe_expand_file_path "$value544"
		#	    :
		#	fi
	    done
	    printf "\n"
	done
    fi
}

main

#strict_read --field='\t,\s,:' --line="\n" --comment="#" --group='"' < config1.txt
#while strict_get; do
#    printf "Line: %s:\n" "$index1"
#    for index2 in "${!strict_line[@]}"; do
#	printf "W%s:%s " "$index2" "${strict_line[$index2]}"
#    done
#    printf "\n"
#    ((index1+=1))
#done
