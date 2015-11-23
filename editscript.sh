#!/bin/bash
#

function checkArgs {
	if [ $# -eq 1 ] || [ $# -eq 3 ] || [ $# -eq 5 ]; then
		case $# in
			1)
				existFile $1
			;;
			3)
				existFile $3 $1 $2
			;;
			*)
				existFile $5 $1 $2 $3 $4
			;;
		esac
	else
		echo "Usage { editscript.sh [-D|--description "script description"] [-A|--author "script author"] /path/to/somefile }"
	fi
}

function existFile {
	if [[ -e "$1" ]]; then
		if [[ `cat /tmp/ok.sh | wc -l` -gt 0 && `head -n 1 "$1" | grep -c "\#\!\/bin\/bash"` -eq 1 ]]; then
			while [ "$?" -eq 0 ]; do
				editFile $1
			done
		else
			exit 3
		fi
	else
		touchFile $@
	fi
}

function touchFile {
	touch $1
	filePath=$1
	shift
	while [ $# -gt 0 ]; do
		if [[ "$1" == "-D" || "$1" == "--description" ]]; then
			des=$2
			shift 2
		fi

		if [[ "$1" == "-A" || "$1" == "--author" ]]; then
			aut=$2
			shift 2
		fi
	done
	des=${des:="script description"}
	aut=${aut:="script author"}
	#echo "" > $filePath
	echo "#!/bin/bash" >> $filePath
	echo "# Description: $des" >> $filePath
	echo "# Author: $aut" >> $filePath
	echo "#" >> $filePath
# cat << EOF
# #!/bin/bash
# # Description: script "$des"
# # Author: script "$aut"
# EOF   ???
}

function editFile {
	vim + "$1"
	bash -n "$1" &> /dev/null
	if [ $? -eq 0 ]; then
		chmod +x "$1"
		exit 0
	else
		read -p "bash is wrong , is continue ? y / n : " option
		[[ "$option" == "y" ]] && return 0 || exit 2
	fi
}


checkArgs $@
