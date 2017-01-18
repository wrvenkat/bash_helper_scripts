#!/bin/bash

main(){
    printf "Running strict_read test!\n"
    source "../strict_read.sh"    
    #A working case
    if strict_read --field='\t,\s' --line="\n" --comment="#" --group='"' < <(cat bnr_list.conf | sort); then
	while strict_get; do
	    printf "Line No: %s:\n" "$strict_index"
	    printf "Unparsed line is: %s\n" "$strict_unparsed_line"
	    for index in "${!strict_line[@]}"; do
		local abs_path=
		printf "W%s:%s " "$index" "${strict_line[$index]}"
		if [ "$index" -eq 3 ]; then		
		    value544="${strict_line[$index]}"
		    printf "Value before expansion: %s\n" "$value544"
		    if abs_path=$(./../safe-tilde-expansion.sh "$value544"); then
			printf "Expanded path is %s\n" "$abs_path"
		    else
			printf "Expansion failed. Error is:%s\n" "$abs_path"
		    fi
		fi
	    done
	    printf "\n"
	done
    fi
}

main
