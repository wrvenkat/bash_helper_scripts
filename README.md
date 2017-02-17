## Description ##
  This repository contains some helpful bash scripts that provide a particular functionality. Some of the scripts can be used without being sourced while others need to be sourced in.
  
## Getting started ##
  This section describes each individual script.

### logger.sh  ###
  A small logging utility that can log error messages and non-error messages. Messages marked for error are prefixed by ERROR: and by default logged to the file error.log and to STDERR. Messages marked as informational are prefixed as INFO: and logged to STDIN. An optional file path can be provided which is used to override the default error.log to log error messages. All messages are prefixed with a timestamp.  
  The script can be either sourced or invoked. When sourced, the script outputs a series of * before the first message for that runtime session is logged to the file.
  * **Usage**
``` bash
<logger.sh | log_msg> [options] [-m=<message>|--msg=<message>]
	
Options:
 -h | --help - display this help message and exit.
 -c | --nocolour - do not colour the log prefix.
 -t | --notime - no time stamp in the log prefix.
 -e | --err - the current message is an error. All messages are not error by default.
 -n | --nolog - do not log the message to the log file. All messages are logged by default.
 -l=<path> | --logfile=<path> - use the provided file path as the log file. By default, the file is error.log
 -m=[message] | --msg=[message] - the optional message information to be logged. An empty message causes a new line to be output.
```
	  
### strict_read.sh ###
  This utility script provides bash's `read` type functionality. This utlity script reads a file and splits it into *lines*, ignoring *comments*. Within a line, the utlity separates text based on *fields* and combines based on *groups*. Each of the distinguishing types are individually configurable as follows,
  * **lines** - by default, the line splitting character is new line characters - CR and LF.
  * **comments** - by default, the commenting character is #. Part of the line (as identified above) that begins with this character is ignored unless the character is *grouped*.
  * **group** - a group is the text within an opening and closing *grouping* character. By default, this *grouping* character is a single quote. Any text except the grouping char is grouped together and is taken literally. The grouping character must be escaped by a backslash if specified within enclosing *grouping* characters.
  * **field** - texts are separated by any of the comma separated field characters. By default, these are tab `\t` and space. If a comma needs to be part of the field separation character set, it needs to be backslash escaped.
  * There can be **NO** overlap between any of these characters.
  * This script needs to be sourced in the target script that intends to use it.
  * **Arguments**
	  * --line - the line character. By default CR and LF.
	  * --group - grouping character. By default is '.
	  * --field - field separation characters. By default is tab and space.
	  * --comment - commenting character. By default is #.
	  * --esc - Preserve the escape character when reading grouped text. By default doesn't retain the escape character.
	  * -h | --help - display the help message and quit.
  * **Working**
	* The file is passed to `strict_read` function specifying the arguments.
	* If the read is successful, the parsed data can be obtained by calling the `strict_get` function repeatedly. It returns true as long as there is a line. Repeated calling causes it to start from the first line.
	* The index of the current line is specified by the variable `strict_index`.
	* An unparsed version of the current line is also present in the variable `strict_unparsed_line`.
	* The array, `strict_line` holds all the *words* of the *current* line that were separated by fields and grouped by the grouping character.
  * **Example Usage**	
``` bash
	if ! source bash_helper_scripts/safe-tilde-expansion.sh; then
		echo "Failed to source in safe-tilde-expansion.sh"
		exit 1
	fi
	#Reads lines (text terminated by unquoted new-line) and ignores lines beginning with #
	#words are those that are separated by field characters tab and space and grouped wthing double
	#quotes
	if strict_read --field="\t,\s" --group='"' --line="\n" --comment="#" < afile; then
		while strict_get; do
			printf "Line No: %s:\n" "$strict_index"
			printf "Unparsed line is: %s\n" "$strict_unparsed_line"
			for index in "${!strict_line[@]}"; do
				printf "Word:%s:%s " "$index" "${strict_line[$index]}"
			done
			printf "\n"
		done
	fi
```

###  safe_tilde_expansion.sh###
  * This utility script tries to perform a *safe*, possilbe tilde expansion of the given string and outputs the result.
  * Accepts bash quoted string.
  * Returns 0 on successful tilde-expansion and outputs the expanded path; 1 when an error or no expansion occurs.
  * **Arguments**
	  * arg1 - The string to be considered for a tilde expansion.
  * **Example**  
  	  `./safe_tilde_expansion "rm rf/asda/asdasd"` outputs, `rm rf/asda/asdasd`  
	  `./safe_tilde_expansion ~user/asda/asdasd` outputs, `/home/user/asda/asdasd`  
	  And when a folder by the name `~$(eval "test\'``();@%)` exists,  
	  `./safe_tilde_expansion '~'\$\(eval\ \"test\\\'\``\(\)\;@%\)/` outputs, `~$(eval "test\'\'();@%)`  

### bash_quoting_parsing.sh  ###
  A small logging utility that performs bash's [quoting](https://www.gnu.org/software/bash/manual/bash.html#Quoting) (the first 3 bullets) parsing. There is no expansion of values like $ inside double quotes.
  * This script is intended to be sourced and not invoked.
  * Accepts the string as an argument to the function `bash_quoting_parse`.
  * If successful, returns 0 with the parsed string in the variable `quoting_parsed_string`.
  * Returns 1 with an error message on failure.

## Versioning ##
The master branch holds the latest stable. The dev branch holds the latest unstable. The test branch holds the test files and is a submodule of the dev branch.
  
## LICENSE ##

[GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)
	
