#!/bin/bash

BACKSPACE='\10\33[K'
BACKSPACE_EMPTY='\7'
BACKSLASH='\\'
QUOTE="\'"
DOUBLE_QUOUTE='\"'
LARROW='\10'
RARROW='\33[C'
#APPOSTRO="'\`'"
BACKSPACE_='\\33\[1P'
#LOGDATE=`date '+%Y/%m/%d %H:%M:%S'`
BADBIN='\\33\]'

while read -r line
do
	NOBINline=$(echo "${line}" | strings)	
	CURRENT_PWD_OF_PID=$(readlink -f /proc/${1}/cwd)
	USER_OF_PID=$(cat /proc/${1}/environ | strings | tr '.' ' ' | grep USER | awk -F= '{print $2}')
	HOSTNAME_OF_PID=`hostname -a`
	STR_TO_REMOVE=$(printf "${USER_OF_PID}""@""${HOSTNAME_OF_PID}"":""${CURRENT_PWD_OF_PID}")
	parsed_line=$(echo "${NOBINline}" | perl -nale 'print $1 if ~/\"(.*)\"/gi')
	if [ "${parsed_line}" == "\n" ]
	then
		parsed_line="{{ENTER}}"
	fi
	output_line=''
	inchar_line=''
	postinchar_line=''
		inchar_line=$(printf "${parsed_line}")
		if [ "${inchar_line}" == "{{ENTER}}" ]
		then
			echo ""
		else
		output_line=$(printf "${output_line}""${inchar_line}")
		fi
	if [ "${output_line}" != "${CURRENT_PWD_OF_PID}" -a "${output_line}" != "${STR_TO_REMOVE}" -a `echo "${NOBINline}" | grep -c "${BADBIN}"` -eq 0 ]
	then
		printf "${output_line}"
	fi
done < <(sudo strace -e trace=write -s1000 -p $1 2>/dev/stdout)
