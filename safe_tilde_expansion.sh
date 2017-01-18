#!/bin/bash

#This function safely expands the provided path
#accepts the string to be intyerpreted as a file path and perform an expansion on
#prints empty if for some reason expansion fails
#the final path is saved in the variable safe_file_path

safe_expand_file_path(){
    if [ -z "$1" ]; then
	printf ""
	return 0
    fi

    printf "Received value is %s\n" "$1"
    local safe_file_path=
    local expanded_path=
    local char=
    local output_string=
    local input_string=
    local tilde_prefix=
    local backslash=0
    local d_quote=0
    local s_quote=0
    local escaping=0
    local tilde_spotted=0
    local word_index=0

    #this is done to prevent read ignoring leading and trailing IFS characters
    local orig_IFS="$IFS"
    IFS=
    #perform a quoting parse while trying to identify the tilde prefix if present
    while read -r -N 1 char; do
	((word_index+=1))
	#handle s_quote states
	if [ "$s_quote" -eq 1 ]; then
	    if [ "$char" != "'" ]; then
		output_string="$output_string""$char"
		continue
	    elif [ "$char" == "'" ]; then
		s_quote=0
		continue
	    fi
	fi

	#handle d_quote states
	#d_quote state 1 of 5
	if [ "$d_quote" -eq 1 ]; then
	    if [ "$char" != '"' ]; then
		#d_quote state 3 of 5
		if [ "$backslash" -eq 0 ]; then
		    if [ "$char" == '"' ]; then
			d_quote=0
			continue
		    elif [ "$char" == '\' ]; then
			backslash=1
			continue;
		    else
			output_string="$output_string""$char"
			continue
		    fi
		elif [ "$backslash" -eq 1 ]; then
		    #d_quote state 4 of 5
		    if [ "$char" == '\' ]; then
			output_string="$output_string"\\
			backslash=0
			continue
		    elif [ "$char" == '"' ]; then
			output_string="$output_string"'"'
			backslash=0
			continue
		    elif [ "$char" == '`' ]; then
			output_string="$output_string"'`'
			backslash=0
			continue
		    else
			output_string="$output_string"'\'"$char"
			backslash=0
			continue
		    fi
		fi
		#d_quote state 2 of 5
	    elif [ "$char" == '"' ]; then
		if [ "$backslash" -eq 0 ]; then
		    d_quote=0
		    continue
		elif [ "$backslash" -eq 1 ]; then
		    output_string="$output_string"'"'
		    backslash=0
		    continue
		fi
	    fi
	fi

	#handle char is \ states
	if [ "$char" == '\' ]; then
	    if [ "$backslash" -eq 1 ]; then
		output_string="$output_string"\\
		backslash=0
		continue
	    elif [ "$backslash" -eq 0 ]; then		
		escaping=1
		backslash=1
		continue
	    fi
	fi

	#handle char == ' states
	if [ "$char" == "'" ]; then
	    if [ "$backslash" -eq 1 ]; then
		output_string="$output_string""'"
		backslash=0
		continue
	    elif [ "$backslash" -eq 0 ]; then
		escaping=1
		s_quote=1
		continue
	    fi
	fi

	#handle char == " states
	if [ "$char" == '"' ]; then
	    if [ "$backslash" -eq 1 ]; then
		output_string="$output_string"'"'
		backslash=0
		continue
	    elif [ "$backslash" -eq 0 ]; then
		d_quote=1
		continue
	    fi
	fi

	#if it is anyother character except for space or tab
	if [ "$char" == ' ' ] || [ "$char" == $'\t' ] ||\
	       [ "$char" == $'\n' ] || [ "$char" == $'\r' ]; then
	    if [ "$backslash" -eq 0 ]; then
		break
	    else
		output_string="$output_string""$char"
		backslash=0
		continue
	    fi
	else
	    if [ "$backslash" -eq 1 ]; then
		backslash=0
		output_string="$output_string""$char"
		continue
	    else
		#if we encounter an unquoted tilde at the beginning of a word,
		#we mark as tilde spotted
		if [ "$char" == '~' ] && [ "$word_index" -eq 1 ]; then
		    tilde_spotted=1
		#if we're seeing the first unquoted forward slash - /, then,
		#if nothing was escaped so far, and if we did spot a tilde as the
		#beginning of the string, then have a tilde-prefix to expand
		elif [ "$char" == '/' ] || [ "$char" == ':' ]; then
		    if [ "$tilde_spotted" -eq 1 ] && [ "$escaping" -eq 0 ]; then
			tilde_prefix="$output_string"
			output_string=
		    #there's no use parsing further, since we're at the end of a tilde-prefix
		    #if it was present, it should've been by this time and since it isn't, we quit
		    else
			exit 1
		    fi
		fi
		#if any other char, we just record it
		output_string="$output_string""$char"
		continue
	    fi	    
	fi
    done < <(printf "%s" "$1")
    #restore the IFS
    IFS="$orig_IFS"
    #At this point if backslash is 1, then it can only be outside of quotes
    #and as the last character
    if [ "$backslash" -eq 1 ]; then
	printf "ERROR: Expecting new line after \\:%s\n" "$output_string"
	exit 1
    fi    
    if [ "$s_quote" -eq 1 ]; then
	printf "ERROR: Expecing ':%s\n" "$output_string"
	exit 1
    fi
    if [ "$d_quote" -eq 1 ]; then
	printf "ERROR: Expecing \":%s\n" "$output_string"
	exit 1
    fi
    #if we've gotten this far with a non-empty tilde-prefix, then
    #we must have a compelling case for a tilde-prefix
    if [ -z "$tilde_prefix" ]; then
	exit 1
    fi
    printf "Tilde Prefix for expansion is %s\n" "$tilde_prefix"
    #Perform eval
    if eval expanded_path=$tilde_prefix; then
	safe_file_path="$expanded_path""$output_string"
	printf "%s" "$safe_file_path"
    fi

    return 0
}

safe_expand_file_path "$@"
exit $?
