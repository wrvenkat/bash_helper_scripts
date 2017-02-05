#!/bin/bash

source ../logger.sh

printf "\$\$ is %s\n" "$$"
printf "\$0 is %s\n" "$0"
printf "\$_ is %s\n" "$_"
printf "BASH_SOURCE[0] is %s\n" "${BASH_SOURCE[0]}"

source_test(){
    #declare -p FUNCNAME
    for index1 in "${!FUNCNAME[@]}"; do
	printf "Function \"%s\" is from the file:%s\n" "${FUNCNAME[$index1]}" "${BASH_SOURCE[$index1]}"
    done
}

source_test
