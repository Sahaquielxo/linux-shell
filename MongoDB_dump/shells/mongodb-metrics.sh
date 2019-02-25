#!/usr/bin/env bash

# Default value is 0
buckets_count=0
dump_dize=0
dump_files=0
last_bucket_createDate_timestamp=0
dump_duration=0

# Variables
starttime=$(date +%s)
curdate=$(date +%Y-%m-%d)
curhost=$(hostname)
pattern="${curdate}--${curhost}"
buckets_arr=( $(aws s3 ls --endpoint-url=https://xxx | awk '{print $NF}') )
last_bucket_name=$(aws s3api list-buckets --endpoint-url=https://xxx | jq '.Buckets'[].Name | sort | grep $(hostname) | tail -n1 | sed 's/"//g')
last_bucket_createDate=$(aws s3 ls --endpoint-url=https://xxx | grep $(hostname) | sort -k3 | tail -n1 | awk '{print $1"T"$2}')
#last_bucket_createDate=$(aws s3api list-buckets --endpoint-url=https://xxx | jq '.Buckets'[].CreationDate | sort | tail -n1 | sed 's/"//g')
last_file_createDate=$(aws s3api list-objects --bucket ${last_bucket_name} --endpoint-url=https://xxx --query "[(Contents[].LastModified)][-1][-1]" | sed 's/"//g')
endpointurl=$(echo "--endpoint-url=https://xxx")

# Metrics
buckets_count=$(aws s3 ls "${endpointurl}" | grep $(hostname) | wc -l)
dump_dize=$(aws s3api list-objects --bucket "${last_bucket_name}" --query "[sum(Contents[].Size), length(Contents[])]" --endpoint-url=https://xxx | jq .[0])
dump_files=$(aws s3api list-objects --bucket "${last_bucket_name}" --query "[sum(Contents[].Size), length(Contents[])]" --endpoint-url=https://xxx | jq .[1])
last_bucket_createDate_timestamp=$(date -d "${last_bucket_createDate}" "+%s")
last_file_createDate_timestamp=$(date -d "${last_file_createDate}" "+%s")
dump_duration=$((${last_file_createDate_timestamp} - ${last_bucket_createDate_timestamp}))

echo "CRM_Buckets_Count ${buckets_count}"
echo "CRM_Last_Bucket_Size ${dump_dize}"
echo "CRM_Last_Bucket_Files_Count ${dump_files}"
echo "CRM_Last_Bucket_Create_Date_Timestamp ${last_bucket_createDate_timestamp}"
echo "CRM_Last_Mongodump_Duration ${dump_duration}"
