#!/bin/bash

get_src_users() {
	src_users=( $(sed '1d' shkib.csv | awk -F',' '{print $2}' | sort | uniq -c | sort -nr | sed '1d' | awk '{print $NF}') )
	echo "${src_users[@]}"
}

top_users_max_data() {
	output_array=()
	users=( $(get_src_users) )
	for ((i=0; i<"${#users[@]}"; i++))
	do
		echo "Runns ${i} of ${#users[@]} iteration.."
		summ=$(awk -F',' -v src_user="${users[i]}" '{if ($2==src_user) printf $8"+"}' shkib.csv | sed 's/.$//g') 
#		summ=$(grep "${users[i]}" shkib.csv | awk -F',' '{print $8}' | tr '\n' '+' | sed 's/.$//g')
		result=$(($summ))
		add_to_array="${users[i]}:${result}"
		output_array+=(${add_to_array})
	done
echo "Top 5 users sent max data:"
echo "${output_array[@]}" | tr ' ' '\n' | sort -t':' -n -k2 -r | head -n5 | awk -F':' '{print $1}'
}

top_users_max_requests() {
	echo "Top 5 users:"
	users=( $(get_src_users) )
	for ((i=0; i<5; i++))
	do
		echo "${users[i]}"
	done
}

#regular_by_src_user() {
#	users=( $(get_src_users) )
#	for ((i=0; i<"${#users[@]}"; i++))
#	do
#


#}
echo "1. ==========================================="
top_users_max_requests
echo "2. ==========================================="
top_users_max_data
echo "3. ==========================================="
