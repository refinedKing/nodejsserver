#!/bin/bash
#

# 冒泡
skip=()
function main {
	for (( i = 0; i < $1; i++ )); do
		let aa=($RANDOM%50)
		skip[$i]=$aa
	done
	echo "原数据 : ${skip[*]}"
	BubbleSort $1
	echo "排序后 : ${skip[*]}"
}

function BubbleSort {
	for (( i = 0; i < $1; i++ )); do
		for (( j = i + 1; j < $1; j++ )) do
			if [ ${skip[i]} -gt ${skip[j]} ]; then
				swap $i $j
			fi
		done
	done
}

function swap {
	temp=${skip[$1]};
	skip[$1]=${skip[$2]};
	skip[$2]=$temp;
}

main $1

# 快排
skip=()
function main {
	for (( i = 0; i < $1; i++ )); do
		let aa=($RANDOM%50)
		skip[$i]=$aa
	done
	echo "原数据 : ${skip[*]}"
	QSort 0 ${#skip[*]}
	echo "排序后 : ${skip[*]}"
}

function QSort {
	pivot=0
	if [ $1 -lt $2 ]; then
		Partion $1 $2
		pivot=$?
		let temppivot1=$pivot-1
		let temppivot2=$pivot+1
		QSort $1 $temppivot1
		QSort $temppivot2 $2
	fi
}

function Partion {
	low=$1
	high=$2
	pivotkey=${skip[low]}

	while [ $low -lt $high ]; do
		while [[ $low -lt $high && ${skip[high]} -ge $pivotkey ]]; do
			let high--
		done
		swap $low $high
		while [[ $low -lt $high && ${skip[low]} -le $pivotkey ]]; do
			let low++
		done
		swap $low $high
	done
	return $low
}

main $1
