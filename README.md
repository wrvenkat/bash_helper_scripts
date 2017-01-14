## Description ##
  This repository contains some helpful bash scripts that provide a particular functionality. Some of the scripts can be used without being sourced while others need to be sourced in.
  
## Getting started ##
  This section describes each individual script.
  
### singlequotes_wrap_unwrap.sh ###
  * This utility script wraps and unwraps a given text in singlequotes so that it can be used in CLI escaping Bash's expansion of the enclosed text.
  * Example, lets say the text `\'\"hello world\"` needs to be passed to another command without bash expanding on it. It would be done as,  
``` bash  
	var=\'\"hello world\"
	if source singlequotes_wrap_unwrap.sh; then
		#wrap in singlequotes
		if wrap_unwrap_singlequotes 1 "$str"; then
			printf "Wrapped text is:%s\n" "$output_string"
			cmd_tool "$output_string"
		fi
		
		#unwrap singlequoted text
		str="$2"
		if wrap_unwrap_singlequotes 0 "$str"; then
			printf "Unwrapped text is:%s\n" "$output_string"
		fi
	fi
```
  * This utility needs to be sourced in. The wrapped or unwrapped text is available in the `output_String` variable.
  * The function to call is `wrap_unwrap_singlequotes` which takes two arguments,
	* Arg1 - 0 or 1, 0 to unwrap and 1 to wrap.
	* Arg2 - the text to be wrapped or unwrapped.

### logger.sh  ###
  A small logging utility that can log error messages and non-error messages. Messages marked for error are prefixed by ERROR: and by default logged to the file error.log and to STDERR. Messages marked as informational are prefixed as INFO: and logged to STDIN. An optional file path can be provided which is used to override the default error.log to log error messages. Messages logged to a file are prefixed with a timestamp.
  * **Arguments**
	  * arg1 - the level. 0 - for informational and 1 - for error.
	  * arg2 - the message.
	  * arg3 - optional line no.
	  
### strict_read.sh ###
  This utility script provides bash's `read` type functionality. This utlity reads a file and splits it into *lines*, ignoring *comments*. Within a line, the utlity combines text based on *fields* and *groups*. Each of the distinguishing types are individually configurable as follows,
  * **lines** - by default, the line splitting character is new line characters - CR and LF.
  * **comments** - by default, the commenting character is #. Part of the line that begins with this character is ignored unless the character is *grouped*.
  * **group** - a group is the text within an opening and closing *grouping* character. By default, this *grouping* character is a single quote. Any text except the grouping char is grouped together and is taken literally. The grouping character must be escaped by a backslash if specified within enclosing *grouping* characters.
  * **field** - text can also be separated by any of field comma separated characters. By default, these are tab `\t` and space ( ). If a comma needs to be part of the field separation character set, it needs to be backslash escaped.
  * There can be **NO** overlap between any of these characters.
  * This script needs to be sourced in the script that intends to use it.
  * **Arguments**
	  * --line - the line character. By default CR and LF.
	  * --group - grouping character. By default is '.
	  * --field - field separation characters. By default is tab and space.
	  * --comment - commenting character. By default is #.
	  * --esc - Preserve the escape character when reading grouped text. By default doesn't retain the escape character.
	  * -h | --help - display the help message and quit.
  * **Usage**
	* The file is passed to `strict_read` function specifying the arguments.
	* If the read is successful, the parsed data can be obtained by calling the `strict_get` function repeatedly. It returns true as long as there is a line. Calling after returning true causes it to start from the first line.
	* The index of the current line is specifiied by the variable `strict_index`.
	* An unparsed version of the current line (it should be remembered that the input has already parsed for *lines*) is also present at the variable `strict_unparsed_line`.
	* The array, `strict_line` holds all the *words* of the *current* line that were separated by fields and grouped by the grouping character.
  * **Example**	
``` bash
	source ../bash_helper_scripts/safe-tilde-expansion.sh
	strict_read --field="\t,\s" --group='"' --line="\n" --comment="#" < afile
	while strict_get; do
		printf "Line No: %s:\n" "$strict_index"
		printf "Unparsed line is: %s\n" "$strict_unparsed_line"
		for index in "${!strict_line[@]}"; do
			printf "Word:%s:%s " "$index" "${strict_line[$index]}"
		done
		printf "\n"
	done
```

###  safe_tilde_expansion.sh###
  * This utility tries to perform a *safe*, possilbe tilde expansion of the given string, considering it as a file path and outputs the result. The result is the same as the input if there was no expansion performed. Otherwise, a tilde expanded string is output.
  * This utility is designed to be sourced in to be used and not be invoked. This is because, invoking the script would involve providing the string to be expanded as an argument. This argument unless properly quoted, will result in bash trying to expand which can be dangerous and not desired.
  * The safe_tilde_expand function, 
      * returns 0 if a tilde expansion was attempted and the `safe_file_path` contains the expanded file path.
      * returns 1 if it was deemed that no expansion needed to be done on the input string.
  * **Arguments**
	  * arg1 - The string to be considered for a tilde expansion.
  * **Example**  
  	  `./safe_tilde_expansion "rm rf/asda/asdasd"` outputs, `rm rf/asda/asdasd`  
	  `./safe_tilde_expansion \~user/asda/asdasd` outputs, `/home/user/asda/asdasd`  
	  `./safe_tilde_expansion '~'user/asda/asdasd` outputs, `/home/user/asda/asdasd`  
	  And when a folder by the name `~$(eval "test\'``();@%)` exists,
	  `./safe_tilde_expansion ~\$\(eval\ \"test\\\'\``\(\)\;@%\)/` outputs, `~$(eval "test\'\'();@%)`  
	  
## Versioning ##
  Stable versions are available from the stable branch.
  
## LICENSE ##

[GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)
	
