#!/usr/bin/env bash

/usr/local/bin/mongodb-metrics.sh | curl --data-binary @- http://127.0.0.1:9091/metrics/job/mongodump/instance/$HOSTNAME
for buckets in $(aws s3 ls --endpoint-url=https://xxx | awk '{print $NF}')
do
	echo "BN 1" | curl --data-binary @- http://127.0.0.1:9091/metrics/job/$buckets/instance/$HOSTNAME
done
