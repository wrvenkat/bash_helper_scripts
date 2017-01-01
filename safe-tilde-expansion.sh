#!/bin/bash

#This function safely expands the provided path
#accepts the string to be intyerpreted as a file path and perform an expansion on
#prints empty if for some reason expansion fails
#the final path is saved in the variable safe_file_path
safe_file_path=
safe_expand_file_path(){
    if [ -z "$1" ]; then
	printf ""
	return 0
    fi

    #printf "Received value is %s\n" "$1"
    local expanded_path=
    local quotes=0
    local char=
    local word=
    local index=0
    local space=0
    local unquoted_slash=0
    local unquoted_tilde=0
    local expand_safely=0
    local tilde_prefix=
    local append_the_rest=0
    local rest_word=
    safe_file_path=

    #this is done to prevent read ignoring leading and trailing IFS characters
    local orig_IFS="$IFS"
    IFS=
    #identify the tilde prefix if present
    while read -r -N 1 char; do
	#printf "Char is %s\n" "$char"
	if [ "$append_the_rest" -eq 1 ]; then
	    rest_word="$rest_word""$char"
	    continue;
	fi
	if [ "$char" == "~" ]; then
	    if [ "$quotes" -eq 0 ]; then
		unquoted_tilde=1;
	    fi
	elif [ "$char" == "\"" ]; then
	    if [ "$quotes" -eq 0 ]; then
		quotes=1;
	    else
		quotes=0;
	    fi
	elif [ "$char" == " " ]; then
	    space=1
	elif [ "$char" == "/" ]; then
	    if [ "$quotes" -eq 0 ]; then
		unquoted_slash=1
	    fi
	fi
	word="$word""$char"
	if [ "$space" -eq 1 ] || [ "$unquoted_slash" -eq 1 ]; then
	    append_the_rest=1
	fi
    done < <(printf "%s" "$1")
    #restore the IFS
    IFS="$orig_IFS"
    
    #printf "Variables are Space:%s UnquotedSlash:%s UnquotedTilde:%s\n" "$space" "$unquoted_slash" "$unquoted_tilde"
    if [ "$space" -eq 0 ] && [ "$unquoted_tilde" -eq 1 ]; then
	expand_safely=1
	tilde_prefix="$word"
	#printf "Possilbe tilde-prefix is %s\n" "$tilde_prefix"
    fi

    if [ "$expand_safely" -eq 0 ]; then
	safe_file_path="$1"
	#printf "The file path is %s\n" "$safe_file_path"
	return 0
    fi

    #we string/file encode the path of file to be expanded
    #which means escaping  \, `, $, " and ! with a backslash
    #once this done, we escape the backslash so that they are
    #present when eval is run
    #then we enclose the whole string in a double-quotes
    #escaped string i.e \"<string>\"
    local char=
    local word=
    local index=0

    #Layer 1 assessments
    #this is done to prevent read ignoring leading and trailing IFS characters
    local orig_IFS="$IFS"
    IFS=
    #identify the tilde prefix if present
    while read -r -N 1 char; do
	#printf "Char is %s\n" "$char"
	if [ "$char" == "\\" ]; then
	    word="$word""\\\\"
	elif [ "$char" == "\`" ]; then
	    word="$word""\\\`"
	elif [ "$char" == "\$" ]; then
	    word="$word""\\\$"
	elif [ "$char" == "\"" ]; then
	    word="$word""\\\""
	#elif [ "$char" == "!" ]; then
	    #word="$word""\\\!"
	else
	    word="$word""$char"
	fi
    done < <(printf "%s" "$tilde_prefix")
    #word="\\\"""$word""\\\""
    #restore the IFS
    IFS="$orig_IFS"
    
    #printf "Tilde Prefix for expansion is %s\n" "$word"
    #Perform eval
    if eval expanded_path=$word; then
	safe_file_path="$expanded_path""$rest_word"
	#printf "Expanded Path is %s\n" "$safe_file_path"
    fi
}
