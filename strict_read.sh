#!/bin/bash

# strict_read.sh
# This script implements the following functionality
#1. Reads input from a stream and breaks it up into lines based on a line de-limiting character. If unspecified, the default character is a newline.
#2. Groups the line read into words based on a grouping character. All characters specified between matching grouping character are taken literally. The grouping character can be escaped within this bounds using '\'. The escape character '\' can itself be escaped by having it prefixed by another '\'. If unspecified, the default value is ' (a single quote).
#3. Separates the grouped strings into words based on field separtation character(s). By default, the field separators are the whitespace characters, except for the newline characters. More than one character can be specified by separating the characters by ','. ',' and '\' can be escaped by prefixing them with '\'.
#4. 2. and 3. occur at the same time, L->R, based on which character(s) from 2. or 3. comes first.
#5. This functionality happens in two phases. First, the input is read and some initial parsing is done and the input stored in an array by the strict_read function. Then, when the strict_read is called, the parsed array is output per line and the result stored in the strict_line array, where each element in the array is a word.

#Determines if the escape character that is provided in input should be retianed or removed
#by default it is removed, just like an expansion. But, it can be useful when the read group
#word is used directly as part of a double-quoted context.
#As the last line indicates, this would be of great help when the grouping character is "
PRESERVE_ESCAPE_CHAR=0

display_strict_read_help_message(){
    printf "Description:\n------------\n\t1. Reads input from a stream and breaks it up into lines based on a line de-limiting character. If unspecified, the default character is a newline. \n\t2. Groups the line read into words based on a grouping character. All characters specified between matching grouping character are taken literally. The grouping character can be escaped within this bounds using '\\\'. The escape character '\\\' can itself be escaped by having it prefixed by another '\\\'. If unspecified, the default value is ' (a single quote).\n\t3. Separates the grouped strings into words based on field separtation character(s). By default, the field separators are the whitespace characters, except for the newline characters. More than one character can be specified by separating the characters by ','. ',' and '\\\' can be escaped by prefixing them with '\\\'.\n\t4. 2. and 3. occur at the same time, L->R, based on which character(s) from 2. or 3. comes first.\n\t5. This functionality happens in two phases. First, the input is read and some initial parsing is done and the input stored in an array by the strict_read function. Then, when the strict_read is called, the parsed array is output per line and the result stored in the strict_line array, where each element in the array is a word.\n\t6. To use this functionality, the strict_read.sh file has to be sourced in and then the functions strict_read and strict_get called.\n\nUsage:\n------\n\tsource strict_read.sh\n\tstrict_read arguments < <input-stream>\n\tstrict_get\n\nGlobal Variables\n----------------\n\tstrict_index\t\t- Holds the line number of the current line in the source stream.\n\tstrict_line\t\t- An array. Each element in this array corresponds to a word in a line.\n\tstrict_unparsed_line\t- Holds the current unparsed line.\n\nExample Usage\n-----------\n\tsource strict_read.sh\n\tstrict_read --field='\\\\t,\\s,\\,' --line='\"' --group=\":\" < input\n\twhile strict_get; do\n\t\tprintf \"Line No: %%s\\\\n\" \"\$strict_index\"\n\t\tprintf \"Unparsed line is: %%s\\\\n\" \"\$strict_unparsed_line\"\n\t\tfor index2 in \"\${!strict_line[@]}\"; do\n\t\t\tprintf \"W%%s:%%s \" \"\$index2\" \"\${strict_line[$index2]}\"\n\t\tdone\n\t\tprintf \"\\\\n\"\n\tdone\n\nArguments\n---------\n\t-h\t\t\t\t\t- Display this message and quit.\n\t--comment=<comment-char>\t\t- Optional option. The character that when provided is used as a commenting character. Any text that appears after this character is ignored until the end-of-line. If it appears inside a group, it is taken literally.\n\t--group=<grouping_character>\t\t- The character to be used for grouping. If specified, requires an argument. Default value is \".\n\t--line=<line_separation_character>\t- The line separation character. If specified, requires an argument. Default value is \\\\n.\n\t--field=<field_separation_characters>\t- The comma separated characters that is used to spearate input into words. ',' can be escaped using '\\' and '\\\' can be escaped using '\\\'. If specifed, requires a character or a list of characters. Default value is set to \\\\t.\n\n\tThe strict_read populates the strict_array array with each line, starting form the first line. Since, strict_read preserves read input for the program running time, calling strict_get repeatedly wraps around the last line to the first. The line currently available can be obtained from strict_line array. The total number of lines present in the input is the largest number that is presented by strict_line_count after all the input has been parsed into lines. Calling strict_get before any input has been read results in an empty strict_line array.\n\nLimitations\n-----------\n\tSince this file has to be sourced in to be made use of, the strict_read call cannot be nested with other strict_read calls or any other functions that use strict_read call. The functionality cannot be deferred to a sub-shell since it relies on global variables to provide the result of parsing.\n"
}

print_no_slash_message(){
    printf "A '\\\\' can't be part of any of the special characters except when used as an escape character.\n"
}

clean_strict_read_str=
#removes the escape chars from the provided input and saves it in clean_strict_read_str
#takes two arguments,
# 1 - the input
remove_group_escape_char(){    
    if [ -z "$1" ]; then
	return 1;
    fi

    #printf "\nReceived value is %s\n" "$1"
    clean_strict_read_str=
    local char=
    local word=
    local word_index=0
    local entered_group=0
    local old_index=
    local escape_slash=0
    local preserve_escape_char="$2"
    
    #this is done to prevent read ignoring leading and trailing IFS characters
    local orig_IFS="$IFS"
    IFS=
    while read -r -N 1 char; do
	#printf "Char is %s\n" "$char"
	if [ "$char" == "\\" ]; then
	    if [ "$escape_slash" -eq 1 ]; then
		word="$word""\\"
		escape_slash=0
	    else
		escape_slash=1
	    fi
	elif is_grouping_char "$char"; then
	    if [ "$escape_slash" -eq 1 ]; then
		word="$word""$group_char"
		escape_slash=0
	    else
		word="$word""$char"
	    fi
	else
	    if [ "$escape_slash" -eq 1 ]; then
		escape_slash=0;
		word="$word""\\"
	    fi
	    word="$word""$char"
	fi	    
    done < <(printf "%s" "$1")   
    #restore the IFS
    IFS="$orig_IFS"

    #printf "Word is %s\n" "$word"
    clean_strict_read_str="$word"
    return 0
}

actual_ascii_value12char=
#returns the actual character for the provided sequence that is escaped with \
#returns ASCII literal for newline characters
#accepts one argument - the string to be looked up
get_ascii_char(){
    if [ -z "$1" ]; then
	return 1
    fi

    #printf "Received escape value is %s\n" "$1"
    actual_ascii_value12char=
    if [ "$1" == "\n" ]; then
	actual_ascii_value12char=$'\n'
    elif [ "$1" == "\s" ]; then
	actual_ascii_value12char=' '
    elif [ "$1" == "\t" ]; then
	actual_ascii_value12char=$'\t'
    elif [ "$1" == "\\\\" ]; then
	actual_ascii_value12char="\\"
    else
	return 1
    fi
    return 0
}


#print's the strict_array
print_strict_lines(){
    local index=
    for index in "${!strict_array[@]}"; do
	printf "Line: %s : %s\n" "$index" "${strict_array[$index]}"
    done
}

#returns true if the character passed is a EOL char specified
is_EOL_char (){
    if [ -z "$1" ]; then
	return 1
    fi

    #if the EOL is either \r or \n, then we need to check for both
    if [ "$line_char" == $'\n' ] || [ "$line_char" == $'\r' ]; then
	if [ "$1" == $'\n' ] || [ "$1" == $'\r' ]; then
	    return 0
	else
	    return 1
	fi
    elif [ "$line_char" == "$1" ]; then
	return 0
    else
	return 1
    fi
}

#parse EOL char
parse_EOL_char (){
    if [ -z "$1" ]; then
	return 1;
    fi

    local char=
    local escaped_char=
    local saw_slash=0
    local index=0
    local orig_IFS="$IFS"
    IFS=
    while read -r -N 1 char; do
	if [ "$index" -gt 1 ]; then
	    return 1
	fi
	if [ "$saw_slash" -eq 1 ]; then
	    escaped_char="$escaped_char""$char"
	    if get_ascii_char "$escaped_char"; then
		char="$actual_ascii_value12char"
	    else
		char="$escaped_char"
	    fi

	    line_char="$char"
	    ((index+=1))
	    saw_slash=0
	    escaped_char=
	else
	    if [ "$char" == '\' ]; then
		saw_slash=1
		escaped_char="\\"
	    else
		line_char="$char"
		((index+=1))
	    fi
	fi
    done < <(printf "%s" "$1")
    IFS="$orig_IFS"

    if [ "$line_char" == '\' ]; then
	print_no_slash_message
	return 1
    fi    
    return 0
}


#returns true if the character passed is a EOL char specified
is_grouping_char (){
    if [ -z "$1" ]; then
	return 1
    fi

    if [ "$1" == "$group_char" ]; then
	return 0
    fi
    return 1
}

parse_grouping_char (){
    if [ -z "$1" ]; then
	return 1;
    fi

    local char=
    local escaped_char=
    local saw_slash=0
    local index=0
    local orig_IFS="$IFS"
    IFS=
    while read -r -N 1 char; do
	if [ "$index" -gt 1 ]; then
	    return 1
	fi
	if [ "$saw_slash" -eq 1 ]; then
	    escaped_char="$escaped_char""$char"
	    if get_ascii_char "$escaped_char"; then
		char="$actual_ascii_value12char"
	    else
		char="$escaped_char"
	    fi

	    group_char="$char"
	    ((index+=1))
	    saw_slash=0
	    escaped_char=
	else
	    if [ "$char" == '\' ]; then
		saw_slash=1
		escaped_char="\\"
	    else
		group_char="$char"
		((index+=1))
	    fi
	fi
    done < <(printf "%s" "$1")
    IFS="$orig_IFS"

    if [ "$group_char" == '\' ]; then
	print_no_slash_message
	return 1
    fi
    return 0
}

#returns true if the character passed is a EOL char specified
is_field_char (){
    if [ -z "$1" ]; then
	return 1
    fi

    local index=
    local comp_char=
    for index in "${!field_char_array[@]}"; do
	if [ "$1" == "${field_char_array[$index]}" ]; then	    
	    return 0
	fi
    done

    return 1
}

declare -a field_char_array
#this function splits the field separator list into an array
#can only separate the typical \t or \n and not any UNICODE
#http://wiki.bash-hackers.org/syntax/quoting#ansi_c_like_strings
get_field_char_array(){

    if [ -z "$1" ]; then
	return 0;
    fi

    local error_msg="Incorrect format for specifiying field characters. A ',' that is a field character must be escaped by a backslash and/or all field characters specified must be comma separated."
    local char=
    local escaped_char=
    local escape_slash=0
    local saw_comma=0
    local recorded_char_count=0
    local recorded_char=
    local index=0
    local orig_IFS="$IFS"
    IFS=
    while read -r -N 1 char; do
	#printf "char is %s\n" "$char"

	#Handle backslash states - 1 of 1
	if [ "$char" == '\' ]; then
	    if [ "$escape_slash" -eq 0 ]; then
		escape_slash=1
		recorded_char="$recorded_char""$char"
		continue
	    elif [ "$escape_slash" -eq 1 ]; then
		escape_slash=0
		recorded_char="$recorded_char""$char"
		if get_ascii_char "$recorded_char"; then
		    recorded_char="$actual_ascii_value12char"
		fi
		#printf "ASCII char is %s--\n" "$recorded_char"
		field_char_array[$index]="$recorded_char"
		((index+=1))
		recorded_char_count=1
		recorded_char=
		saw_comma=0
		continue
	    fi
	fi

	#Handle comma states
	if [ "$char" == ',' ]; then
	    #Handle comma state - 1 of 2
	    if [ "$escape_slash" -eq 1 ]; then
		escape_slash=0
		recorded_char="$recorded_char""$char"
		if get_ascii_char "$recorded_char"; then
		    recorded_char="$actual_ascii_value12char"
		fi
		field_char_array[$index]="$recorded_char"
		((index+=1))
		recorded_char_count=1
		recorded_char=
		continue
	    elif [ "$escape_slash" -eq 0 ]; then
		#Handle comma state - 2 of 2
		if [ "$recorded_char_count" -gt 0 ]; then
		    saw_comma=1
		    continue
		elif [ "$recorded_char_count" -le 0 ]; then
		    printf "%s\n" "$error_msg"
		    return 1
		fi
	    fi
	fi

	#anyother character
	#Handle general state - 1 of 3
	if [ "$saw_comma" -eq 0 ] && [ "$recorded_char_count" -le 0 ]; then	    
	    if [ "$escape_slash" -eq 1 ]; then
		escape_slash=0
		recorded_char="$recorded_char""$char"
		if get_ascii_char "$recorded_char"; then
		    recorded_char="$actual_ascii_value12char"
		fi
		#printf "ASCII char is %s--\n" "$recorded_char"
		field_char_array[$index]="$recorded_char"
		((index+=1))
		recorded_char_count=1
		recorded_char=
		continue
	    else
		recorded_char="$char"
		field_char_array[$index]="$recorded_char"
		((index+=1))
		recorded_char_count=1
		recorded_char=
		continue
	    fi
	#Handle general state - 2 of 3 (seen a character but the next is not comma separated)
	elif [ "$saw_comma" -eq 0 ] && [ "$recorded_char_count" -ge 1 ]; then
	    printf "%s\n" "$error_msg"
	    return 1
	#Handle general state - 3 of 3
	elif [ "$saw_comma" -eq 1 ]; then
	    saw_comma=0
	    if [ "$escape_slash" -eq 1 ]; then
		escape_slash=0
		recorded_char="$recorded_char""$char"
		if get_ascii_char "$recorded_char"; then
		    recorded_char="$actual_ascii_value12char"
		fi
		#printf "ASCII char is %s--\n" "$recorded_char"
		field_char_array[$index]="$recorded_char"
		((index+=1))
		recorded_char_count=1
		recorded_char=
		continue
	    else
		recorded_char="$char"
		field_char_array[$index]="$recorded_char"
		((index+=1))
		recorded_char_count=1
		recorded_char=
		continue
	    fi
	fi	
    done < <(printf "%s" "$1")
    #if there seems to be more to be read, but none specified
    if [ "$saw_comma" -eq 1 ]; then
	printf "%s\n" "$error_msg"
	return 1
    fi
    IFS="$orig_IFS"

    index=0
    char=
    while [ $index -lt ${#field_char_array[*]} ]; do	
	char="${field_char_array[$index]}"
	#printf "char is %s\n" "$char"
	if [ "$char" == '\' ]; then
	    print_no_slash_message
	    return 1
	fi
	((index+=1))
    done
    return 0
}


#prints the field_characters in a comma separated format with , escaped
print_field_char_array(){
    local index=0
    local char=
    while [ $index -lt ${#field_char_array[*]} ]; do	
	char="${field_char_array[$index]}"
	if [ "$char" == ',' ]; then
	    printf '\'
	fi
	printf "%s" "$char"
	if [ $((index+1)) -lt ${#field_char_array[*]} ]; then
	   printf ","
	fi
	((index+=1))
    done
    printf "\n"
}


#parse comment
parse_comment_char (){
    if [ -z "$1" ]; then
	return 1;
    fi

    local index=0
    local orig_IFS="$IFS"
    IFS=
    while read -r -N 1 char; do
	if [ "$index" -gt 1 ]; then
	    printf "Please provide only one value for comment character.\n"
	    return 1
	fi
	((index+=1))
    done < <(printf "%s" "$1")
    IFS="$orig_IFS"

    orig_IFS="$IFS"
    IFS=
    while read -r -N 1 char; do
    if [ "$char" == '\' ]; then
	print_no_slash_message
	return 1
    fi
    done < <(printf "%s" "$1")
    IFS="$orig_IFS"
    
    return 0
}

#returns true if the char given is a comment char
is_comment_char(){
    if [ -z "$1" ]; then
	return 1
    fi

    #if the comment_char is empty, then any char is not a comment char
    if [ -n "$comment_char" ] && [ "$1" == "$comment_char" ]; then
	return 0
    fi
    
    return 1
}

#remove leading and trailing '
# accepts one arg, which is the value
no_singlequotes_value12=
remove_single_quotes() {
    if [ -z "$1" ]; then
	return 1;
    fi

    no_singlequotes_value12="$1"
    #remove leading and trailing '
    if [ -n "$no_singlequotes_value12" ]; then
	temp="${no_singlequotes_value12#\'}"
	temp="${temp%\'}"
        no_singlequotes_value12="$temp"	
    fi

    return 0;
}

#checks for overlap in the separation characters
#return true when no overlap
check_overlap(){
    local no_overlap=1
    
    #1 - check if the EOL is the same as the grouping char
    if [ "$no_overlap" -eq 1 ] && ! is_grouping_char "$line_char"; then
	no_overlap=1
    else
	no_overlap=0
    fi

    #2 - check if EOL char is in the field_chars array
    if [ "$no_overlap" -eq 1 ] && ! is_field_char "$line_char"; then
	no_overlap=1
    else
	no_overlap=0
    fi

    #3 - check if grouping char is in the field_chars array
    if [ "$no_overlap" -eq 1 ] && ! is_field_char "$group_char"; then
	no_overlap=1
    else
	no_overlap=0
    fi

    #we only check for comment char overlap when there is already no overlap
    #and when the comment_char is not empty. Otherwise, the status quo is fine
    #if [ "$no_overlap" -eq 1 ] && [ -n "$comment_char" ]; then
    
    #4 - check if comment char is a EOL char
    if [ "$no_overlap" -eq 1 ] && ! is_EOL_char "$comment_char"; then
	no_overlap=1
    else
	no_overlap=0
    fi
    
    #5 - check if comment char is in the field_chars array
    if [ "$no_overlap" -eq 1 ] && ! is_field_char "$comment_char"; then
	no_overlap=1
    else
	no_overlap=0
    fi
    
    #6 - check if grouping char is a grouping char	
    if [ "$no_overlap" -eq 1 ] && ! is_grouping_char "$comment_char"; then
	no_overlap=1
    else
	no_overlap=0
    fi
        
    if [ "$no_overlap" -eq 0 ]; then
	printf "There shouldn't be any overlap between the separation characters!\n"
	return 1
    fi

    return 0
}


declare -a strict_array
declare -a strict_line
#contains the raw input read terminated at the provided EOL value
strict_unparsed_line=
line_char=
group_char=
comment_char=

strict_read(){

    local args="$@"
    
    if [ -z "$args" ]; then
	printf "Please use -h or --help to find more information\n"
	#display_strict_read_help_message
	return 1
    fi

    #reset the global variables so as to clear away previous values
    PRESERVE_ESCAPE_CHAR=0
    unset strict_array
    declare -a -g strict_array
    unset field_char_array
    declare -a -g field_char_array
    line_char=
    group_char=
    field_chars=    

    local parsed_args=$(getopt -o h -l line:,group:,field:,comment:,esc,help -n 'strict_read' -- "$@" 2>&1)

    #echo "$parsed_args"
    
    #an ugly way of finding if the parsing of the arguments went through successfully
    local line_count=$(echo "$parsed_args" | wc -l)
    local index=1

    #if we have more than 1 line then one must be the failure
    if [ $line_count -gt 1 ] || [ -z "$parsed_args" ]; then
	if [ $line_count -gt 1 ]; then
	    while read line; do
		if [ $index -eq 1 ]; then
		    printf "%s\n" "$line"
		    ((index+=1))
		    break
		fi
	    done < <(echo "$parsed_args")
	else
	    printf "Invalid arguments received. Use -h or --help to see usage.\n"
	fi
	return 1
    fi
    
    #remove leading space(s).
    local new_args=
    index=1

    for i in $parsed_args; do
	if [ $index -eq 1 ]; then
	    new_args=$i
	    ((index+=1))
	else
	    new_args+=" $i"
	fi
    done

    parsed_args="$new_args"
    set -- $parsed_args

    while [ -n "$1" ]; do
	#printf "\$1 is %s " "$1"
	#printf "\$2 is %s\n" "$2"
	case "$1" in
	    -h | --help) display_strict_read_help_message; return 0;;
	    --line) line_char="$2"; shift 2;;
	    --group) group_char="$2"; shift 2;;
	    --field) field_chars="$2"; shift 2;;
	    --comment) comment_char="$2"; shift 2;;
	    --esc) PRESERVE_ESCAPE_CHAR=1; shift;;
	    --) shift ;;
	    *) printf "Invalid arguments received. Use -h or --help to see usage.\n"; return 1;;
	esac
    done

    #LINE
    if [ -z "$line_char" ]; then
	line_char="\n"
    else
	if remove_single_quotes "$line_char"; then
	    line_char="$no_singlequotes_value12"
	fi
	# get the unescaped version of this character for grouping
	if ! parse_EOL_char "$line_char"; then
	    exit 1
	fi	
    fi
    #printf "End of line char is %s\n" "$line_char"
    
    #GROUP
    if [ -z "$group_char" ]; then
	group_char="'"
    else
	if remove_single_quotes "$group_char"; then
	    group_char="$no_singlequotes_value12"
	fi
	# get the unescaped version of this character for grouping
	if ! parse_grouping_char "$group_char"; then
	    exit 1
	fi
    fi
    #printf "Grouping char is %s\n" "$group_char"

    #FIELD
    if [ -z "$field_chars" ]; then
	field_chars="\t, "
    fi
    #printf "field_chars is %s\n" "$field_chars"
    if remove_single_quotes "$field_chars"; then
	field_chars="$no_singlequotes_value12"
    fi
    
    if ! get_field_char_array "$field_chars"; then
	exit 1
    fi
    #printf "Field separator characters are,\n"
    #print_field_char_array

    #COMMENT
    if [ -n "$comment_char" ]; then
	if remove_single_quotes "$comment_char"; then
	    comment_char="$no_singlequotes_value12"
	    if ! parse_comment_char "$comment_char"; then
		exit 1
	    fi
	fi
    fi
    #printf "Comment char is %s\n" "$comment_char"

    #check for any overlap between the provided characters
    if ! check_overlap; then
	return 1;
    fi

    #create the line array
    local char=
    local line=
    index=0
    local entered_group=0
    local escape_slash=0
    local entered_comment=0
    
    #this is done so that no leading or trailing spaces is left out
    local orig_IFS="$IFS"
    IFS=
    #read raw, non-delimited input one character at a time
    while read -r -N 1 char; do
	#printf "Char is:%s " "$char"
	#printf "Line is:%s" "$line"
	
	#Handle comment state - 1 of 2
	if [ "$entered_comment" -eq 1 ] && ! is_EOL_char "$char"; then
	    continue;
	fi
	#Handle comment state - 2 of 2
	if is_comment_char "$char"; then
	    escape_slash=0
	    if [ "$entered_group" -eq 1 ]; then
		line="$line""$char"
		continue;
	    elif [ "$entered_group" -eq 0 ]; then
		entered_comment=1;
		continue;
	    fi
	fi

	#Handle escape backslash
	if [ "$char" == "\\" ]; then
	    if [ "$escape_slash" -eq 1 ]; then
		#we set 1 for escape_slash because it might be to escape the next char
		escape_slash=1
		line="$line""$char"
		continue
	    elif [ "$escape_slash" -eq 0 ]; then
		escape_slash=1
		line="$line""$char"
		continue
	    fi	    
	fi

	#Handle grouping states
	if is_grouping_char "$char"; then
	    #Handle grouping state - 1 of 2
	    if [ "$escape_slash" -eq 1 ]; then
		escape_slash=0
		line="$line""$char"
		continue;
	    elif [ "$escape_slash" -eq 0 ]; then
		#Handle grouping state - 2 of 2
		if [ "$entered_group" -eq 1 ]; then
		    entered_group=0
		    line="$line""$char"
		    continue;
		elif [ "$entered_group" -eq 0 ]; then
		    entered_group=1
		    line="$line""$char"
		    continue;
		fi		
	    fi
	fi

	#Handle EOL states
	if is_EOL_char "$char"; then
	    escape_slash=0
	    #Handle EOL state - 1 of 2
	    if [ "$entered_comment" -eq 0 ]; then
		#Handle EOL states - 2 of 2
		if [ "$entered_group" -eq 1 ]; then
		    line="$line""$char"
		    continue;
		elif [ "$entered_group" -eq 0 ]; then
		    #record a line
		    #printf "Line is %s\n" "$line"
		    if [ -n "$line" ]; then
			strict_array[$index]="$line"
			char=
			line=
			((index+=1))
			continue;
		    fi
		fi
	    elif [ "$entered_comment" -eq 1 ]; then
		char=
		line=
		entered_comment=0
		continue;
	    fi
	fi

	#if it is anyother character
	escape_slash=0
	line="$line""$char"
    done
    #we add whatever we received if the grouping is complete and we've reached the end of input
    if [ "$entered_group" -eq 0 ]; then
	if [ -n "$line" ]; then
	    printf "Line is %s\n" "$line"
	    strict_array[$index]="$line"
	    char=
	    line=
	    ((index+=1))
	fi
    else
	printf "PARSE ERROR: Group not closed for line:\n%s\n" "$line"
	#we restore the IFS
	IFS="$orig_IFS"
	return 1
    fi
    #we restore the IFS
    IFS="$orig_IFS"
    #reset the strict_index so that we can start reading
    #after something new has been read in by strict_read
    strict_index=-1

    return 0
    #print_strict_lines
}

#reads through the strict_array and parses the line and populates the strict_result array with
#elements that are individual elements based on the L->R parsing of the line and separating them
#based on the field/grouping characters
#the next line can be obtained from strict_line given that strict_get returns true
#strict_index indicates the current line in the strict_line
strict_index=-1
strict_get(){
    if [ -z "${!strict_array[*]}" ]; then
	return 1
    fi

    #we increment the strict_index only after the call so as to have
    #it hold the current line's index.
    ((strict_index+=1))    
    local line="${strict_array[$strict_index]}"
    if [ -z "$line" ]; then
	return 1;
    fi
    unset strict_line
    declare -a -g strict_line
    unset strict_unparsed_line
    declare -g strict_unparsed_line="$line"
    local char=
    local word=
    local word_index=0
    local entered_group=0
    local old_index=
    local escape_slash=0
    
    #this is done to prevent read ignoring leading and trailing IFS characters
    local orig_IFS="$IFS"
    IFS=
    #read raw input one character at a time
    while read -r -N 1 char; do
	#printf "Char is %s\n" "$char"
	#handle states when inside a group
	if [ "$entered_group" -eq 1 ]; then
	    if is_grouping_char "$char"; then
		if [ "$escape_slash" -eq 1 ]; then
		    if [ "$PRESERVE_ESCAPE_CHAR" -eq 1 ]; then
			word="$word"'\'
		    fi
		    word="$word""$char"
		    escape_slash=0
		    continue
		elif [ "$escape_slash" -eq 0 ]; then
		    if [ "$PRESERVE_ESCAPE_CHAR" -eq 1 ]; then
			word="$word""$char"
		    fi
		    if [ -n "$word" ]; then
			strict_line["$word_index"]="$word"
			word=
			#printf "Word is %s\n" "${strict_line[$word_index]}"
			((word_index+=1))
		    fi
		    entered_group=0
		    continue
		fi
	    else
		if [ "$escape_slash" -eq 1 ]; then
		    if [ "$char" == '\' ] ||\
			   [ "$PRESERVE_ESCAPE_CHAR" -eq 1 ]; then
			word="$word"'\'
		    fi
		    escape_slash=0
		    word="$word""$char"
		    continue
		else
		    if [ "$char" == '\' ]; then
			escape_slash=1
			continue
		    fi
		    word="$word""$char"
		    continue
		fi
	    fi
	fi

	#if we're outside a group, see what state we need to be in or just continue parsing
	#if the char is a field char
	if is_field_char "$char"; then
	    if [ -n "$word" ]; then
		strict_line["$word_index"]="$word"
		word=
		#printf "Word is %s\n" "${strict_line[$word_index]}"
		((word_index+=1))
	    fi
	    continue
	fi

	#if the char is a grouping char
	if is_grouping_char "$char"; then
	    if [ "$escape_slash" -eq 1 ]; then
		if [ "$PRESERVE_ESCAPE_CHAR" -eq 1 ]; then
		    word="$word"'\'			
		fi
		word="$word""$char"
		escape_slash=0
		continue
	    else
		if [ "$PRESERVE_ESCAPE_CHAR" -eq 1 ]; then
		    word="$word"'"'
		fi
		entered_group=1
		continue
	    fi
	fi

	#when char is \
	if [ "$char" == '\' ]; then
	    if [ "$escape_slash" -eq 1 ]; then
		if [ "$PRESERVE_ESCAPE_CHAR" -eq 1 ]; then
		    word="$word"'\'			
		fi
		word="$word""$char"
		escape_slash=0
		continue
	    else
		escape_slash=1
		continue
	    fi
	fi

	#when it is just another char
	if [ "$escape_slash" -eq 1 ]; then
	    if [ "$PRESERVE_ESCAPE_CHAR" -eq 1 ]; then
		word="$word"'\'			
	    fi
	    word="$word""$char"
	    escape_slash=0
	    continue
	else
	    word="$word""$char"
	    continue
	fi
    done < <(printf "%s" "$line")

    #if none of the separation characters were encountered, then we just add what was gathered
    #as an element to the array
    if [ -n "$word" ]; then
	strict_line["$word_index"]="$word"
	word=
	((word_index+=1))
    fi
    #restore the IFS
    IFS="$orig_IFS"
    return 0
}

#strict_read "$@"

#Example Usage
#source ../test/safe-tilde-expansion.sh
#strict_read "$@"
#while strict_get; do
#    printf "Line No: %s:\n" "$strict_index"
#    printf "Unparsed line is: %s\n" "$strict_unparsed_line"
#    for index in "${!strict_line[@]}"; do
#	printf "W%s:%s " "$index" "${strict_line[$index]}"
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
#    done
#    printf "\n"
#done
