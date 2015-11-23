#!/bin/bash
#

function main {
	while true; do
		read -p "Enter you option: " option
		[ "$option" == "quit" ] && exit
		which --skip-alias "$option" &> /dev/null && copycmd;copylib || echo "noting lib"; continue
	done
}

function copycmd {
	if [ $? -eq 0 ]; then
		local result=`which --skip-alias "$option"`
	    mydirname=`dirname "$result"`
		[ ! -d "/mnt/sysroot$mydirname" ] && mkdir "/mnt/sysroot$mydirname"
		[ ! -e "/mnt/sysroot$result" ] && cp "$result" "/mnt/sysroot$result"
	fi
}

function copylib {
	if [ $? -eq 0 ]; then
		local result=`which --skip-alias "$option"`
		for i in `ldd "$result" | grep -o "/[^[:space:]]\{1,\}"`; do
			mylibname=`dirname "$i"`
			[ ! -d "/mnt/sysroot$mylibname" ] && mkdir "/mnt/sysroot$mylibname"
			[ ! -e "/mnt/sysroot$i" ] && cp "$i" "/mnt/sysroot$i"
		done
	fi
	echo "${option}  copy complete !"
}

main
