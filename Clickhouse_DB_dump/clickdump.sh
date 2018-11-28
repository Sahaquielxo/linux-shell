#!/usr/bin/env bash

dbs=( $(clickhouse-client $@ --query="show databases") )
dbs=$( "${dbs[@]/default}" )
for db in ${dbs[@]}
do
	partitions=( $(clickhouse-client $@ --query="SELECT partition, table, database FROM system.parts WHERE active AND database = '$db'" | awk '{print $1}') )
	echo "There are ${#partitions[@]} partitions in db ${db}"
	echo "Dumping db ${db}..."
	tablenames=( $(clickhouse-client $@ --query="SELECT partition, table, database FROM system.parts WHERE active AND database = '$db'" | awk '{print $2}') )
	databases=( $(clickhouse-client $@ --query="SELECT partition, table, database FROM system.parts WHERE active AND database = '$db'" | awk '{print $3}') )

	for ((i=0; i<${#partitions[@]}; i++))
	do
		clickhouse-client $@ --query="ALTER TABLE ${databases[$i]}.${tablenames[$i]} FREEZE PARTITION '${partitions[$i]}'"
#       	echo "ALTER TABLE ${databases[$i]}.${tablenames[$i]} FREEZE PARTITION '${partitions[$i]}'"
	done
	echo "Dumping db ${db} finished!"

done
