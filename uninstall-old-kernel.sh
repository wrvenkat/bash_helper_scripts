#!/bin/bash

# This script uninstalls all old-kernels installed in a Debian/Ubuntu system, keepin only the last two kernels
# Needs to be run as su/sudo

count=$(dpkg --list | grep -e ii[[:space:]]*linux-image.* | wc -l)
count=$(((count/2)-2))
first=''
kernelver=''
index=1
presentkernel1=''
presentkernel2=''

# sanity check
if [ $count -gt 0 ]
then
   printf "There are %s older kernels to be uninstalled\n" "$count"
else
   printf "There are no older kernels! You already only have the latest two kernels installed!\n"
   exit 0 
fi

count=$((count+2))
sudo dpkg --list &> /dev/null

while read first kernelver rest
do
    if [ $index -gt $count ]
    then
       break
    fi

    if [ $index -eq $((count-1)) ]
    then
	presentkernel1="$kernelver"
	index=$((index+1))
	continue
    elif [ $index -eq $count ]
    then
	presentkernel2="$kernelver"
	index=$((index+1))
	continue
    fi
    printf "Uninstalling kernel version: %s ....\n" "$kernelver"
    $(yes | sudo apt-get remove $kernelver &> /dev/null)
    if [ $? -ne 0 ]
    then
       printf "Removal of kernel %s failed!\n" "$kernelver"
       exit 1
    fi
    index=$((index+1))
done < <(dpkg --list | grep -e ii[[:space:]]*linux-image.*)

printf "All older kernels uninstalled...\nUpdating Grub....\n"
printf "Present kernels are\n%s\n%s\n" "$presentkernel1" "$presentkernel2"
$( sudo update-grub2 &> /dev/null )
printf "Done\n"

