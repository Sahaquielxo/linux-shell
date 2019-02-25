#!/usr/bin/env bash

# Init Variables
starttime=$(date +%s)
curdate=$(date +%Y-%m-%d)
curhost=$(hostname)
pattern="${curdate}--${curhost}"
endpointurl=$(echo "--endpoint-url=https://xxx")
logfile="/var/log/mongodb-dump/dump-log-${curdate}.log"
mongo_directory='/var/lib/mongo'

# Functions
log ()
{
        echo "[INFO] [$(date '+%Y-%m-%d %H:%M:%S')] $1" >> ${logfile}
}

log "$0 init process started."

stage_group=( host1 host2 )
prod_group=( host3 host4 )

isstage=0
isprod=0

if [[ "${stage_group[@]}" =~ "${HOSTNAME}" ]] 
then 
	isstage=1
	log "${HOSTNAME} is in stage environment."
else 
	isprod=1
	log "${HOSTNAME} is in prod environment."
fi

if [ ${isstage} -eq 1 ]
then
	if [ "$HOSTNAME" = "$(mongo --quiet --eval "rs.isMaster().primary" | awk -F':' '{print $1}')" ]
	then
		log "${HOSTNAME} is primary. Bye."
		exit 300
	fi
else
	if [ "$HOSTNAME" = "$(mongo --quiet -urootadmin -piddqdforever --authenticationDatabase=admin --eval "rs.isMaster().primary" | awk -F':' '{print $1}')" ]
	then 
		log "${HOSTNAME} is primary. Bye."
		exit 300
	fi
fi

# Other Variables
# Buckets count, must be less or equal 3.
buckets_count=$(aws s3 ls "${endpointurl}" | wc -l)
# The eldest bucket name, must be removed
if [ ${buckets_count} -ge 4 ]
then
	remove_bucket=$(aws s3 ls "${endpointurl}" | grep $(date +%Y-%m-%d --date="3 days ago")--${curhost}--mongodb--bucket | awk '{print $NF}')
else
	remove_bucket=""
fi
# New bucket name
new_bucket="${pattern}--mongodb--bucket"
# Directory for snapshot mounting
snapshot_directory="/${pattern}--mongodb--snapshot"
# Directory for s3 bucket mounting
s3_directory="/${pattern}--s3--bucket"
mongo_device=$(mount | grep ${mongo_directory} | awk '{print $1}')
mongo_size=$(du -sch ${mongo_directory} | awk '{print $1}' | tail -n1 | sed 's/G//g')
snapshot_size=$((${mongo_size} + 10))
snapshot_name="${pattern}--mongodb--snapshot"
s3_chunk_name="mongodb_tar_chunk_"


### Start ###

log "$0 main process started."

# Make directories
if [ ! -d $"{snapshot_directory}" ]
then
	log "Creating ${snapshot_directory}.."
	mkdir ${snapshot_directory}
fi

# Delete old data in the old bucket
if [ ${buckets_count} -ge 4 ]
then
	log "Old bucket: ${remove_bucket}"
	log "Removing old bucket ${remove_bucket}.."

	for object in $(aws s3 ls s3://${remove_bucket} ${endpointurl} | awk '{print $NF}')
	do
		log "Removing ${object} from ${remove_bucket}.."
		aws s3 rm s3://${remove_bucket}/${object} ${endpointurl} &>> ${logfile}
	done
	log "Removing ${remove_bucket}.."
	aws s3 rb s3://${remove_bucket} ${endpointurl} &>> ${logfile}
fi

# Create new bucket
log "Creating new bucket ${new_bucket}.."
aws s3 mb s3://${new_bucket} ${endpointurl} &>> ${logfile}

# Mount bucket

# Stop mongodb and create snapshot
log "Stopping mongodb.."
systemctl stop mongod
log "Creating snapshot ${snapshot_name} with ${snapshot_size}G size.."
lvcreate --name ${snapshot_name} --size ${snapshot_size}G --snapshot ${mongo_device}
log "Starting mongodb.."
# Start mongodb and mount snapshot
systemctl start mongod
log "Mounting snapshot ${snapshot_name} on ${snapshot_directory}.."
mount -o nouuid /dev/vg00/${snapshot_name} ${snapshot_directory}

# Creating data directory dump
log "MongoDB data directory will be dumped right now."
tar -cvf - ${snapshot_directory}/data/* | split -d -b 100M -a 10 - ${s3_chunk_name} --filter="aws s3 cp - s3://${new_bucket}/\$FILE --endpoint-url=https://xxx" &>> ${logfile}
if [ $? -ne 0 ]
then
	log "[CRITICAL] Something wrong, mongoDB dump was not uploaded on the S3 storage"
else
	log "MongoDB data directory has been sent to the s3 bucket ${new_bucket}."
fi

# Umount s3 storage and snapshot
log "Unmount ${s3_directory}.."
umount ${s3_directory}
log "Unmount ${snapshot_directory}.."
umount ${snapshot_directory}

# Delete snapshot
log "Deleting snapshot.."
lvremove --yes /dev/vg00/${snapshot_name}

# Delete directories
if [ -d "${snapshot_directory}" ]
then
	rm -rf "${snapshot_directory}"
fi

finishtime=$(date +%s)
worktime=$(($finishtime - starttime))
log "Good bye. MongoDB dump has been created in ${worktime} seconds."
