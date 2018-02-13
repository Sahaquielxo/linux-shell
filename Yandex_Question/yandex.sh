#!/usr/bin/env bash

result_filename="result.txt"
touch "${result_filename}"

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
echo "# Поиск 5ти пользователей, отправивших наибольшее количество данных" >> "${result_filename}"
echo "Решение2" >> "${result_filename}"
echo "Top 5 users sent max data:"
echo "${output_array[@]}" | tr ' ' '\n' | sort -t':' -n -k2 -r | head -n5 | awk -F':' '{print $1}' | tee -a "${result_filename}"
echo "" >> "${result_filename}"
rm -f column_parsed_shkib.csv
}

top_users_max_requests() {
	echo "# Поиск 5ти пользователей, сгенерировавших наибольшее количество запросов" >> "${result_filename}"
	echo "Решение1" >> "${result_filename}"
	echo "Top 5 users:"
	users=( $(get_src_users) )
	for ((i=0; i<5; i++))
	do
		echo "${users[i]}" | tee -a "${result_filename}"
	done
echo "" >> "${result_filename}"
}

regular_by_src_user() {
	echo "# Поиск регулярных запросов (запросов выполняющихся периодически) по полю src_user" >> "${result_filename}"
	echo "Решение3" >> "${result_filename}"
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
				echo "${possible_result[@]}" | tr ' ' '\n' | sort -t',' -k7 | tee -a "${result_filename}"
			fi
		done
	done
rm -f column_parsed_shkib.csv
echo "" >> "${result_filename}"
}

regular_by_src_ip() {
	echo "# Поиск регулярных запросов (запросов выполняющихся периодически) по полю src_ip" >> "${result_filename}"
	echo "Решение4" >> "${result_filename}"
	ip=$2
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
                                echo "${possible_result[@]}" | tr ' ' '\n' | sort -t',' -k7 | tee -a "${result_filename}"
                        fi
                done
        done
rm -f column_parsed_shkib.csv
echo "" >> "${result_filename}"
}

if [ $# -eq 2 ]
then
	echo "1. ==========================================="
	top_users_max_requests
	echo "2. ==========================================="
	top_users_max_data
	echo "3. ==========================================="
        regular_by_src_user $1
        echo "4. ==========================================="
        regular_by_src_ip $2
else
	echo "I can not execute 3rd and 4th function! You must pass any src_user and src_ip as script arguments"
	echo "Example: ${0} c15cf96d9b56740c974661d209ef44f7 1ddc2b40eee61ab2783073ebd50a0254"
	echo "First argument -- src_user; Second argument -- src_ip."
	exit 42
fi
