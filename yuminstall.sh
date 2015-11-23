#!/bin/bash
#

if [ `yum repolist all | grep "enabled" | wc -l` -eq 0 ]; then
	exit 4
fi

if [ `id -u` -ne 0 ]; then
	exit 3
fi

sum=0
while true; do
	read -p "请输入包名: " package

	if [[ "$package" == "quit" ]]; then
		num=`yum list | grep "@" | wc -l`
		echo "本地总有:$num个包 本次共安装:$sum个包" 
		exit 0
	fi

	yum -y install $package &> /dev/null

	if [ $? -eq 0 ]; then
		echo "right"
		let sum+=1
	else
		echo "wrong"
		continue
	fi
done
