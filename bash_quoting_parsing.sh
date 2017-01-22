#!/bin/bash


#Test script to test parsing of text in a similar way Bash does to parse the quoted and escape sequence

quoting_parsed_string=
bash_quoting_parse(){

    if [ -z "$1" ]; then
	printf "ERROR: Empty input\n"
	return 1
    fi

    local output_string=
    local input_string=
    local backslash=0
    local d_quote=0
    local s_quote=0
    local char=
    local orig_IFS="$IFS"
    input_string="$1"
    printf "Input string is %s\n" "$input_string"

    IFS=
    while read -r -N 1 char; do
	#printf "Char is:%s\n" "$char"
	
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
	    fi
	    output_string="$output_string""$char"
	    continue
	fi
    done < <(printf "%s" "$input_string")    
    IFS="$orig_IFS"
    #At this point if backslash is 1, then it can only be outside of quotes
    #and as the last character
    if [ "$backslash" -eq 1 ]; then
	printf "ERROR: Expecting new line after \\:%s\n" "$output_string"
	return 1
    fi    
    if [ "$s_quote" -eq 1 ]; then
	printf "ERROR: Expecting ':%s\n" "$output_string"
	return 1
    fi
    if [ "$d_quote" -eq 1 ]; then
	printf "ERROR: Expecting \":%s\n" "$output_string"
	return 1
    fi    
    quoting_parsed_string="$output_string"
    return 0
}

#if bash_quoting_parse "$@"; then    
#    #printf "Output string is:%s\n" "$quoting_parsed_string"
#    exit 0
#else
#    exit $?
#fi
