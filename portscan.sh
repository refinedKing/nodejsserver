#!/bin/bash
#
trap 'echo you hit Ctrl-C/Ctrl-\, now exiting..; exit' SIGINT
portlist="172.16."

function scan {
	for x in {0..255}; do
		for y in {1..254}; do
			ping -c 1 -w 1 $portlist.$x.$y &> /dev/null
			if [ $? -eq 0 ]; then
				echo "$?   $portlist$x$y" >> ~/result.txt
			fi
		done
	done
}

# 并行 ping
function scanparallel {
	for x in {0..255}; do
	(
		ping -c 1 -w 1 $portlist.0.$x &> /dev/null
		if [ $? -eq 0 ]; then
			echo "$?   $portlist0.$x" >> ~/result.txt
		fi
	)&
	done
	wait
}

scan
