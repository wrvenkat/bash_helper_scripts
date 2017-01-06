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
  * **Example**  
	```bash
	source ../test/safe-tilde-expansion.sh
	strict_read "$@"
	while strict_get; do
		printf "Line No: %s:\n" "$strict_index"
		printf "Unparsed line is: %s\n" "$strict_unparsed_line"
		for index in "${!strict_line[@]}"; do
			printf "W%s:%s " "$index" "${strict_line[$index]}"
			if [ "$index" -eq 3 ]; then
				if remove_group_escape_char "${strict_line[$index]}" 0; then
					printf "Clean string is %s\n" "$clean_strict_read_str"
				fi
				value544="${strict_line[$index]}"
				if remove_group_escape_char "${strict_line[$index]}"; then
					value544="$clean_strict_read_str"
				fi
				safe_expand_file_path "$value544"
				:
			fi
		done
		printf "\n"
	done```
  
#### Conventions and guidelines for creating an install script####
  * An install script that installs software `foo-bar` *should* be named as `foo-bar-install.sh` and a corresponding entry added to the [ibnr-conf](https://github.com/wrvenkat/ibnr-conf) config file.
  * An install script *should* always exit with a value - 0 for no error and 1 for failure. This exit value is used by the install script to determine if the installation was successfuly or not.
  * An install script *should* never leave any background process and should always be blocking. This is because, once an install script exits, bnr's install script looks for an exit value to determine whether the operation was successful or not. Locking any resource or leaving background processes can interfere with other install scripts.
  * An install script *should* carry out all of the steps in installation without any user intervention. (Ex: accepting a license agreement, typing a password). This should be handled by the install script itself as install scripts executed inside a sub-shell and the user can't interact with the running script.
  * All messages output by the install script to STDIN or STDERR is retained by bnr's install script for use in logging. Hence, additional error messages are encouraged and there needn't be any separate logging at the script level.
  * It is strongly recommended to test the scripts on a fresh install of the Ubuntu version it is intended to work in.
  
## Versioning ##
  Stable versions are organized along the lines of Ubuntu's version number. Ex: 16.04 etc.
  
## LICENSE ##

[GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)
