#!/bin/bash
v="NF 1"
for x in $v
do
	f=$(find /etc/ -maxdepth 1 -type f -name "?a*"|xargs du -scb|awk "{print \$${x}}")
	echo $f|tr ' ' '\n'|sed '/^.\{1,4\}$/d'|grep -v total
done
