#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DEFAULT='\033[0m'

# Check if bashpreload.so exists in current directory.
libinworkdir() {
[ -f bashpreload.so ]
}

# Check if bashpreload.so exists in /usr/local/bin directory.
libinusrlocalbin() {
[ -f /usr/local/bin/bashpreload.so ]
}

# Check if envfile for pam_env.so exists.
envfileexists() {
[ -f /usr/local/bin/bashpreloadenvfile ]
}

# Check if ld.c and Makefile exist in current directory.
candmakefile() {
[ -f ld.c -a -f Makefile ]
}

# Check if /etc/security/pam_env.conf file exists.
pamenvfile() { 
[ -f /etc/pam.d/login -a -f /etc/pam.d/sshd ]
}

# Check if pam.d files already contains environment variable LD_PRELOAD.
pamenvfileready() {
[ $(grep -c bashpreload.so /etc/pam.d/login) -gt 0 -a $(grep -c bashpreloadenvfile /etc/pam.d/sshd) -gt 0 ]
}

# Echo long lines
longlines() {
echo -e "---------------------------------------------------------------------------------------------------"
}

# Main script
fmain() {
echo ""
echo "Looking for /usr/local/bin/bashpreload.so ..."
libinusrlocalbin
if [ $? -eq 0 ]
then
	echo -e "${GREEN}[OK]${DEFAULT}"
	echo "Moving bashpreloadenvfile in /usr/local/bin/ ..."
	if [ -f bashpreloadenvfile ]
	then
		mv bashpreloadenvfile /usr/local/bin/
		echo -e "${GREEN}[OK]${DEFAULT}"
	else
		echo -e "${RED}[Error]${DEFAULT}"
		echo "File missed in repo. Check it, or create and add in repository file bashpreloadenvfile contents:"
		echo "LD_PRELOAD=\"/usr/local/bin/bashpreload.so\""
		echo -e "LD_PRELOAD=\"/usr/local/bin/bashpreload.so\"" > bashpreloadenvfile
		cp bashpreloadenvfile /usr/local/bin/
	fi
	echo "Looking for /etc/pam.d/login and /etc/pam.d/sshd files ..."
	pamenvfile
	if [ $? -eq 0 ]
	then
		echo -e "${GREEN}[OK]${DEFAULT}"
		echo "Check if LD_PRELOAD set as environment variable ..."
		pamenvfileready
		if [ $? -eq 0 ]
		then
			echo -e "${GREEN}[OK]${DEFAULT}"
			echo "Everything is ready. Bye-bye."
		else
			echo -e "${YELLOW}[Warning]${DEFAULT}"
			echo "LD_PRELOAD variable is not defined. Script will do it, and reload after that"
#			echo -e 'LD_PRELOAD     DEFAULT=        OVERRIDE="/usr/local/bin/bashpreload.so"' >> /etc/security/pam_env.conf && \
			replaceline=$(cat /etc/pam.d/login | head -n3 | tail -n1)
			sed -i "s/${replaceline}/auth       required     pam_env.so envfile=\/usr\/local\/bin\/bashpreload.so\n${replaceline}/g" /etc/pam.d/login
			replaceline=$(cat /etc/pam.d/sshd | head -n1)
			sed -i "s/${replaceline}/${replaceline}\nauth       required     pam_env.so envfile=\/usr\/local\/bin\/bashpreloadenvfile/g" /etc/pam.d/sshd && \
			echo "Reload ..." && longlines && fmain
		fi
	else
		echo -e "${RED}[Error]${DEFAULT}"
		echo "File /etc/pam.d/login or /etc/pam.d/sshd does not exists"
	fi
else
	echo -e "${YELLOW}[Warning]${DEFAULT}"
	echo "File /usr/local/bin/bashpreload.so not found."
	echo "Trying to find this file in current directory ..."
	libinworkdir
	if [ $? -eq 0 ]
	then
		echo -e "${GREEN}[OK]${DEFAULT}"
		echo "Moving bashpreload.so file in /usr/local/bin ..."
		mv bashpreload.so /usr/local/bin/ && \
		echo -e "${GREEN}[OK]${DEFAULT}"; echo "Reload ..."; longlines; fmain
	else
		echo -e "${YELLOW}[Warning]${DEFAULT}"
		echo "File bashpreload.so not found."
		echo "Trying to compile the file with ld.c ..."
		candmakefile
		if [ $? -eq 0 ]
		then
			make && \
			echo -e "${GREEN}[OK]${DEFAULT}"; echo "Compiled successfully"; echo "Reload ..."; longlines; fmain 
		else
			echo -e "${RED}[Error]${DEFAULT}"
			echo "ld.c or Makefile not found."
			echo "Please, check:"
			echo "1) Files ld.c and Makefile exists."
			echo "2) They are in the same with loginstall.sh file directory"
		fi
	fi
fi

echo "Final step: Unset variable for another programs ..."
echo '[ $LD_PRELOAD ] && unset LD_PRELOAD' > /etc/profile.d/unsetLD_PRE.sh
echo -e "${GREEN}[Finished]${DEFAULT}"

}
fmain
