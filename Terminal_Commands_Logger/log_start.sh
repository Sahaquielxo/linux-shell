#!/bin/bash

while [ 1 ]
do
        for PIDs in `ps awwux | grep [p]ts | grep bash | grep -v lets | grep -v log_start | grep -v grep | awk '{print $2}'`
	do
		PTS=$(ps awwux | grep "${PIDs}" | grep -v grep | awk '{print $7}')
		if [ -f /tmp/bash_log.${PIDs} ]
		then
			sleep 1
		else
			touch /tmp/bash_log.${PIDs}
			/bin/bash /root/lets.sh $PIDs >> /tmp/bash_log.${PIDs} &
		fi
	
#		tr -cd '\11\12\15\40-\176' < /tmp/x_bash_log.${PIDs} | sed 's/\]0;//g' | sed 's/\[C//g' > /tmp/bash_log.${PIDs}
	done
	for IFEMPTY in `find /tmp/ -type f -name 'bash_log*' -mmin +600`
	do
		if [ `cat "${IFEMPTY}" | grep -v "\'" | wc -c` -lt 2 ]
		then
			rm -rf "${IFEMPTY}"
		else
			sleep 1
		fi
	done

done
