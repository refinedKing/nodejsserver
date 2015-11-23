#!/bin/bash
#

students=('aa' 'bb' 'cc' 'dd' 'ee' 'ff' 'gg' 'hh' 'ii')
skip=()
function main {
	for (( i = 0; i < $1; i++ )); do
		let aa=($RANDOM%${#students[*]})
		# 校验前后两个数字是否相等
		# if [ $i -ne 1 ] && [ ${students[$aa]} == ${skip[$i-1]} ]; then
		# 	set i--
		# 	continue
		# fi
		let aa-1
		skip[$i]=${students[$aa]}
		unset students[$aa]
	done
	echo ${skip[*]}
}

main $1

students=('aa' 'bb' 'cc' 'dd' 'ee' 'ff' 'gg' 'hh' 'ii')
skip=()
flag=0
function main {
	for (( i = 0; i < $1; i++ )); do
		let aa=($RANDOM%${#students[*]})

		for (( j = 0; j < ${#skip[*]}; j++ )); do
			if [ ${students[$aa]} == ${skip[$j]} ]; then
				let i--
				flag=1
				break
			fi
			flag=0
		done

		if [ $flag -eq 0 ]; then
			skip[$i]=${students[$aa]}
		fi
	done
	echo ${skip[*]}
}

main $1
