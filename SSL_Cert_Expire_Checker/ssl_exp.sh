#!/bin/bash

# 'date' can convert openssl expire date out of the box
EXP_DATE=$(date -d "$(openssl x509 -enddate -noout -in /etc/nginx/ssl/cert_2017.pem | awk -F= '{print $NF}')" +%s)
CUR_DATE=$(date +%s)


echo "Certificate will expire in $((($CUR_DATE-$EXP_DATE)/86400)) days"
