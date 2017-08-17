#!/bin/bash

#Will remove unused images, when there are no containers based in this image in the system
for i in `docker images -q` 
do 
  imgcont=`docker ps -af "ancestor=$i" | sed '1d' | awk '{print $NF}'`
  if [ `docker ps -af "ancestor=$i" | sed '1d' | wc -l` -eq 0 ] 
  then 
	echo "Image "$i" is unsued. We will remove it now"
	 docker rmi "$i"
   else
	 echo "Image "$i" is used in "$imgcont" container, skip"
  fi 
done
