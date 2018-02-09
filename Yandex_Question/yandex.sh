#!/usr/bin/env bash

get_src_users() {
	src_users=( $(sed '1d' shkib.csv | awk -F',' '{print $2}' | sort | uniq -c | sort -nr | sed '1d' | awk '{print $NF}') )
	echo "${src_users[@]}"
}

top_users_max_data() {
	output_array=()
	users=( $(get_src_users) )
	cut -d',' -f '2,8' shkib.csv > column_parsed_shkib.csv
	for ((i=0; i<"${#users[@]}"; i++))
	do
		summ=$(grep "${users[i]}" column_parsed_shkib.csv | awk -F',' '{printf $2"+"}' | sed 's/.$//g')
		result=$(($summ))
		add_to_array="${users[i]}:${result}"
		output_array+=(${add_to_array})
	done
echo "Top 5 users sent max data:"
echo "${output_array[@]}" | tr ' ' '\n' | sort -t':' -n -k2 -r | head -n5 | awk -F':' '{print $1}'
rm -f column_parsed_shkib.csv
}

top_users_max_requests() {
	echo "Top 5 users:"
	users=( $(get_src_users) )
	for ((i=0; i<5; i++))
	do
		echo "${users[i]}"
	done
}

regular_by_src_user() {
	user=$1
	cut -d',' -f '2,6-8' shkib.csv > column_parsed_shkib.csv
	dest_port_array=( $(grep "${user}" column_parsed_shkib.csv | awk -F',' '{print $3}' | sort | uniq -c | sort -rn | awk '{if ($1!=1) print $NF}' | grep -wv 0) )
	for ((i=0; i<"${#dest_port_array[@]}"; i++))
	do
		input_bytes_array=( $(grep "${user}" column_parsed_shkib.csv | grep -w "${dest_port_array[i]}" | awk -F',' '{print $3}' | sort | uniq -c | sort -rn | awk '{if ($1!=1) print $NF}') )
		for ((j=0; j<"${#input_bytes_array[@]}"; j++))
		do
			possible_result=( $(awk -F',' -v user_src="${user}" -v dest_port="${dest_port_array[i]}" -v input_bytes="${input_bytes_array[j]}" '($2 == user_src) && ($7 == dest_port) && ($8 == input_bytes) {print $0}' shkib.csv) )
			if [ $(echo "${#possible_result[@]}") -gt 1 ]
			then
				echo "${possible_result[@]}" | tr ' ' '\n' | sort -t',' -k7
			fi
		done
	done
rm -f column_parsed_shkib.csv
}

regular_by_src_ip() {
	ip=$1 
	cut -d',' -f '3,6-8' shkib.csv > column_parsed_shkib.csv
	dest_port_array=( $(grep "${ip}" column_parsed_shkib.csv | awk -F',' '{print $3}' | sort | uniq -c | sort -rn | awk '{if ($1!=1) print $NF}' | grep -wv 0) )
        for ((i=0; i<"${#dest_port_array[@]}"; i++))
        do
                input_bytes_array=( $(grep "${ip}" column_parsed_shkib.csv | grep -w "${dest_port_array[i]}" | awk -F',' '{print $3}' | sort | uniq -c | sort -rn | awk '{if ($1!=1) print $NF}') )
                for ((j=0; j<"${#input_bytes_array[@]}"; j++))
                do
                        possible_result=( $(awk -F',' -v ip_src="${ip}" -v dest_port="${dest_port_array[i]}" -v input_bytes="${input_bytes_array[j]}" '($2 == ip) && ($7 == dest_port) && ($8 == input_bytes) {print $0}' shkib.csv) )
                        if [ $(echo "${#possible_result[@]}") -gt 1 ]
                        then
                                echo "${possible_result[@]}" | tr ' ' '\n' | sort -t',' -k7
                        fi
                done
        done
rm -f column_parsed_shkib.csv

}
echo "1. ==========================================="
top_users_max_requests
echo "2. ==========================================="
top_users_max_data
echo "3. ==========================================="
echo "Input the value from 'src_user' to get the string from log-file"
printf "src_user: "
read src_user
regular_by_src_user $src_user
echo "4. ==========================================="
echo "Input the value from 'src_ip' to get the string from log-file"
printf "src_ip: "
read src_ip
regular_by_src_ip $src_ip
