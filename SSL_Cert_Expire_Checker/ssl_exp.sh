#!/bin/bash

# One day I'll create variable to pass the path to cert with it. But not today.
CERT_EXP_DATE=$(openssl x509 -enddate -noout -in /etc/nginx/ssl/cert_2017.pem | awk -F= '{print $NF}')

CERT_EXP_MONTH=$(echo "${CERT_EXP_DATE}" | awk '{print $1}')
CERT_EXP_DAY=$(echo "${CERT_EXP_DATE}" | awk '{print $2}')
CERT_EXP_YEAR=$(echo "${CERT_EXP_DATE}" | awk '{print $4}')
CERT_EXP_TIME=$(echo "${CERT_EXP_DATE}" | awk '{print $3}')

CURRENT_UNIXTIME=$(date +"%s")

	case ${CERT_EXP_MONTH} in
             Jan|01) CERT_EXP_MONTH_CONV=01 ;;
             Feb|02) CERT_EXP_MONTH_CONV=02 ;;
             Mar|03) CERT_EXP_MONTH_CONV=03 ;;
             Apr|04) CERT_EXP_MONTH_CONV=04 ;;
             May|05) CERT_EXP_MONTH_CONV=05 ;;
             Jun|06) CERT_EXP_MONTH_CONV=06 ;;
             Jul|07) CERT_EXP_MONTH_CONV=07 ;;
             Aug|08) CERT_EXP_MONTH_CONV=08 ;;
             Sep|09) CERT_EXP_MONTH_CONV=09 ;;
             Oct|10) CERT_EXP_MONTH_CONV=10 ;;
             Nov|11) CERT_EXP_MONTH_CONV=11 ;;
             Dec|12) CERT_EXP_MONTH_CONV=12 ;;
               *) CERT_EXP_MONTH_CONV=0 ;;
       esac



CERT_EXP_DATE_FORMAT=$(echo ""${CERT_EXP_MONTH_CONV}"/"${CERT_EXP_DAY}"/"${CERT_EXP_YEAR}" "${CERT_EXP_TIME}"")

EXP_UNIXTIME=$(date --date="${CERT_EXP_DATE_FORMAT}" +"%s")
DIFF_UNIXTIME=$(($EXP_UNIXTIME - $CURRENT_UNIXTIME))
FOUNDED_TIME=$(($DIFF_UNIXTIME/86400))

echo "${FOUNDED_TIME}"
