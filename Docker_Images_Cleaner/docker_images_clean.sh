#!/bin/bash

#Will remove unused images, when there are no containers based in this image in the system
#img_size=0
for i in $(docker images -q)
do 
	imgcont=$(docker ps -af "ancestor=$i" | sed '1d' | awk '{print $NF}')
	if [ $(docker ps -af "ancestor=$i" | sed '1d' | wc -l) -eq 0 ] 
  	then 
		echo "Image "${i}" is unsued. We will remove it now"
#		Can show you totall size of the deleted images. Uncomment, if you need.
#		img_size_new=$(docker images | grep "$i" | awk '{print $NF}' | sed -r 's/[A-Za-z]//g')
# 		img_size=$(($img_size + $img_size_new))
		docker rmi "${i}"
   	else
	 	echo "Image "${i}" is used in "${imgcont}" container, skip"
  	fi 
done

#if [ "$img_size" -gt 0 ]
#then
#	echo "After unused images delete, you have ${img_size}MB more free space on your disk"
#fi
