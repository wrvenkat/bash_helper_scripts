## Description ##
  This repository contains some helpful bash scripts that provide a particular functionality. Some of the scripts can be used without being sourced while others need to be sourced in.
  
## Getting started ##
  This section describes each individual script.
  
### logger.sh  ###
  A small logging utility that can log error messages and non-error messages. Messages marked for error are prefixed by ERROR: and by default logged to the file error.log and to STDERR. Messages marked as informational are prefixed as INFO: and logged to STDIN. An optional file path can be provided which is used to override the default error.log to log error messages. Messages logged to a file are prefixed with a timestamp.
  * **Arguments**
	  * arg1 - the level. 0 - for informational and 1 - for error.
	  * arg2 - the message.
	  * arg3 - optional line no.
	  
### strict_read.sh ###
  This utility script provides bash's `read` type functionality. This utlity reads a file and splits it into *lines*, ignoring *comments*. Within a line, the utlity combines text based on *fields* and *groups*. Each of the distinguishing types are individually configurable as follows,
  * **lines** - by default, the line splitting character is new line charcters - CR and LF.
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
	* asdasdasdas
  * **Example**
	```bash
	source ../bash_helper_scripts/safe-tilde-expansion.sh
	strict_read "$@"
	while strict_get; do
		printf "Line No: %s:\n" "$strict_index"
		printf "Unparsed line is: %s\n" "$strict_unparsed_line"
		for index in "${!strict_line[@]}"; do
			printf "W%s:%s " "$index" "${strict_line[$index]}"
		done
		printf "\n"
	done```
