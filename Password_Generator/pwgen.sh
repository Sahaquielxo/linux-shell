#!/bin/bash

# Check only password_generator() function and code after. This shit belongs to my directories and server names.
#WORKDIR=$(pwd)
WORKDIR=/home/ansible/.passwords
cd ../webops/ansible
git pull
cd $WORKDIR
cat ../webops/ansible/inventory.ini | grep -v '\[' | grep -v "^$" | grep -v ^# | grep ansible_host | awk -F= '{print $2}' > .hosts
cat ../webops/ansible/inventory.ini | grep -v '\[' | grep -v "^$" | grep -v ^# | grep -v msk-docker2 | grep -v ansible_host | grep -v ansible-adm | grep -v portal | sort | uniq >> .hosts

password_generator () {
  PAGE=0
  while [ $PAGE -eq 0 ]
  do
    PAGE=$(($RANDOM % 12))
  done

  SIMCOUNT=$(curl -s http://www.fullbooks.com/Crime-and-Punishment${PAGE}.html | sed 's/<br>/ /g' | tr '\n' ' ' | sed 's/\r//g' | wc -c 2>/dev/null)
  CUTB=3000 
  CUTF=$(($SIMCOUNT - 3000))

  STRING=$(curl -s http://www.fullbooks.com/Crime-and-Punishment${PAGE}.html | sed 's/<br>/ /g' | tr '\n' ' ' | sed 's/\r//g' | cut -c ${CUTB}-${CUTF} 2>/dev/null)

  STRINGLENGTH=$(echo $STRING | wc -c)

  SHUF=$(shuf -i 1-$STRINGLENGTH -n 1)
  SHUFF=$(($SHUF + 25))
  PASS=$(echo $STRING | cut -c ${SHUF}-${SHUFF} | sed -e 's/^[^ ]*\(.*\)$/\1/' | sed 's/[^ ]*$//' | sed 's/ //g' | sed 's/e/E/g;s/t/T/g;s/a/A/g')

  echo $PASS > $WORKDIR/password_$i
}

NOWDATE=$(date +%d-%m-%Y)
EXPDATE=$(date -d "+7 days" +%d-%m-%Y)

echo -e "Today is $NOWDATE" > msg
echo -e "Passwords will expire at $EXPDATE" >> msg
echo -e " " >> msg

for i in `cat .hosts`
do
  while [ `cat password_$i 2>/dev/null | wc -c` -lt 15 ]
  do
	echo "Generating password for $i ..."  
	password_generator $i
  done
  HOST=$i
  PASS=$(cat password_$i)
  echo -e "$HOST    ----    $PASS" >> msg
done

#Script placed in ansible-adm server. so we need this "kostyl" to generate password on the server itself.
i=ansible-adm
password_generator $i

APASS=$(cat password_ansible-adm)
echo -e "ansible-adm    ----    $APASS" >> msg
sudo su -c "echo \"$APASS\" | passwd root --stdin" root

echo -e "#!/bin/bash" > passwordchange.sh
echo -e "sudo su" >> passwordchange.sh
echo -e "cat password_* | passwd root --stdin" >> passwordchange.sh

for k in `ls | grep password_`
do
  echo "For $k ..."
  SSH_HOST=$(echo $k | awk -F_ '{print $2}')
  scp -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null passwordchange.sh $k $SSH_HOST:~/
  echo "sudo su -c ' bash passwordchange.sh' root" | ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $SSH_HOST
done

(echo "Subject: Root Password Weekly Changer"; cat msg;) | sendmail test_mail@gmail.com 

for n in `ls | grep -v pwgen.sh`; do rm -rf $n; done
