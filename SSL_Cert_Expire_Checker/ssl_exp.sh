#!/bin/bash

if [ -d /etc/nginx/ssl/ ]
then
	CERT_DIR=/etc/nginx/ssl/
else
	echo -e "Directory /etc/nginx/ssl/ not found.\nSpecify your directory with ssl certs, please:"
	read CERT_DIR
fi

certs=( $(find "${CERT_DIR}" -type f -name '*.pem') )
echo "${certs[@]}"

if [ $# -eq 0 ]
then
	echo -e "You must specify certificate name as variable.\nDefault path to the certs' directory is /etc/nginx/ssl/.\nIf yours is another, pass full path as variable"
	echo -e "\nUsage: \n$0 cert.pem\n$0 /etc/ssl/cert.pem"
	exit 1
fi
[ -f /etc/nginx/ssl/$1 ] && \
	CERT_PATH=/etc/nginx/ssl/$1 || \
	CERT_PATH=$1
# 'date' can convert openssl expire date out of the box
echo "${CERT_PATH}"
EXP_DATE=$(date -d "$(openssl x509 -enddate -noout -in "${CERT_PATH}" | awk -F= '{print $NF}')" +%s)
CUR_DATE=$(date +%s)

echo "Certificate will expire in $(echo $((($CUR_DATE-$EXP_DATE)/86400)) | tr -d -) days"

# How the hell abs works with $((..)) :(
printf "%s %d %s\n" "Certificate will expire in" "$(( abs $(echo $((($CUR_DATE-$EXP_DATE)/86400))) ))" "days"

