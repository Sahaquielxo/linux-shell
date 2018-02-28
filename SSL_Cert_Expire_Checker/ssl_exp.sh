#!/bin/bash

if [ -d /etc/nginx/ssl/ ]
then
	CERT_DIR=/etc/nginx/ssl/
else
	echo -e "Directory /etc/nginx/ssl/ not found.\nSpecify your directory with ssl certs, please:"
	read CERT_DIR
fi

echo "Looking for *.pem files in ${CERT_DIR}..."
certs=( $(find "${CERT_DIR}" -type f -name '*.pem' 2>/dev/null) )
if [ "${#certs[@]}" -eq 0 ]
then
	echo "Are you sure, ${CERT_DIR} is correctly directory? I can't find any certificates there."
	exit 1
else
	echo -e "There are "${#certs[@]}" certs: $(echo "${certs[@]}" | tr ' ' '\n').\nTell me, what should I check? (Copy and paste full path)"
fi

read CERT_PATH
if [ -f "${CERT_PATH}" ]
then
	echo "Checking ${CERT_PATH} certificate..."
	# 'date' can convert openssl expire date out of the box
	EXP_DATE=$(date -d "$(openssl x509 -enddate -noout -in "${CERT_PATH}" | awk -F= '{print $NF}')" +%s)
	CUR_DATE=$(date +%s)
	echo "Certificate will expire in $(echo $((($CUR_DATE-$EXP_DATE)/86400)) | tr -d -) days"
	# How the hell abs works with $((..)) :(
	# printf "%s %d %s\n" "Certificate will expire in" "$(( abs $(echo $((($CUR_DATE-$EXP_DATE)/86400))) ))" "days"
else
	echo "Are you sure, I have copied and pasted path correctly? I can't find file ${CERT_PATH}"
	exit 1
fi

