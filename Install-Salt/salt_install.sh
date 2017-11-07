#!/bin/bash

tolower() {
LOWER=`echo ${1} | tr [A-Z] [a-z]`
echo $LOWER
}

if_args() {
if [ -z $1 ]
then echo "You must specify an argument after this script name." 
     echo "Please, run script correctly: either for server install, or for minion install" 
     echo "Usage: $0 master/ $0 minion"
     exit 1
else
    if [ $# -gt 1 ]
    then echo "You must specify only one argument after this script name."
    echo "Please, run script correctly." 
    echo "Usage: $0 master/ $0 minion"
    exit 1
    else to_install=`tolower $1`
    fi
fi
}

get_OS_name() {
if [[ `cat /etc/centos-release` ]]
then return 2
else 
  if [ `grep -ic Ubuntu /etc/issue` -ne 0 ]
  then return 3
  else
    if [ `grep -ic Debian /etc/issue` -ne 0 ]
    then return 4
    fi
  fi
fi
}

centos_install() {
#Check if master os minion install
yum -y install https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm
#Installing salt master and components.
yum -y install salt-${to_install} salt-ssh salt-syndic salt-cloud salt-api
#Enable service on start
systemctl enable salt-${to_install}
#Optional restart
systemctl restart salt-${to_install}
}

ubuntu_install() {
apt-get -y install salt-api salt-cloud salt-${to_install} salt-ssh salt-syndic
systemctl enable salt-${to_install}
systemctl restart salt-${to_install}
}

debian_install() {
wget -O - https://repo.saltstack.com/apt/debian/9/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
deb http://repo.saltstack.com/apt/debian/9/amd64/latest stretch main
apt-get update

apt-get install salt-${to_install} salt-ssh salt-syndic salt-cloud salt-api
systemctl enable salt-${to_install}
systemctl restart salt-${to_install}
}

if_args $@
get_OS_name

case "$?" in
  2) centos_install;;
  3) ubuntu_install;;
  4) debian_install;;
  *) echo "Please, use this script only on CentOS/Ubuntu or Debian machines.";;
esac
