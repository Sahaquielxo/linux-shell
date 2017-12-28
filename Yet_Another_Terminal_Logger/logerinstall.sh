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

# Check if setLD_PRE.sh in /usr/local/bin directory.
setldinusrlocalbin() {
[ -f /usr/local/bin/setLD_PRE.sh ]
}

# Check if envfile for pam_env.so exists.
envfileexists() {
[ -f /etc/bashpreloadenvfile ]
}

# Check if ld.c and Makefile exist in current directory.
candmakefile() {
[ -f ld.c -a -f Makefile ]
}

# Check if /etc/security/pam_env.conf file exists.
pamenvfile() { 
[ -f /etc/pam.d/login -a -f /etc/pam.d/sshd -a -f /etc/pam.d/sudo-i ]
}

# Check if pam.d files already contains environment variable LD_PRELOAD.
pamenvfileready() {
[ $(grep -c bashpreloadenvfile /etc/pam.d/login) -gt 0 -a $(grep -c bashpreloadenvfile /etc/pam.d/sshd) -gt 0 -a $(grep -c bashpreloadenvfile /etc/pam.d/sudo-i) -gt 0 -a $(grep -c bashpreloadenvfile /etc/pam.d/sudo) -gt 0 ]
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
	echo "Moving bashpreloadenvfile in /etc ..."
	if [ -f bashpreloadenvfile ]
	then
		mv bashpreloadenvfile /etc/
		echo -e "${GREEN}[OK]${DEFAULT}"
	else
		echo -e "${RED}[Error]${DEFAULT}"
		echo "File missed in repo. Check it, or create and add in repository file bashpreloadenvfile contents:"
		echo "LD_PRELOAD=\"/usr/local/bin/bashpreload.so\""
		echo -e "LD_PRELOAD=\"/usr/local/bin/bashpreload.so\"" > bashpreloadenvfile
		cp bashpreloadenvfile /usr/local/bin/
	fi
	echo "Looking for /etc/pam.d/login, /etc/pam.d/sudo, /etc/pam.d/sudo-i and /etc/pam.d/sshd files ..."
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
			echo "Define LD_PRELOAD in /etc/pam.d/login ..."
			replaceline=$(cat /etc/pam.d/login | head -n3 | tail -n1)
			sed -i "s/${replaceline}/auth       required     pam_env.so envfile=\/etc\/bashpreloadenvfile\n${replaceline}/g" /etc/pam.d/login && echo -e "${GREEN}[OK]${DEFAULT}"
			echo "Define LD_PRELOAD in /etc/pam.d/sudo-i ..."
			replaceline=$(cat /etc/pam.d/sudo-i | head -n1)
			sed -i "s/${replaceline}/${replaceline}\nauth       required     pam_env.so envfile=\/etc\/bashpreloadenvfile/g" /etc/pam.d/sudo-i && echo -e "${GREEN}[OK]${DEFAULT}"
			echo "Define LD_PRELOAD in /etc/pam.d/sudo ..."
			replaceline=$(cat /etc/pam.d/sudo | head -n4 | tail -n1)
			sed -i "s/${replaceline}/${replaceline}\nsession    optional     pam_exec.so \/usr\/local\/bin\/setLD_PRE.sh\nsession    optional     pam_env.so envfile=\/etc\/bashpreloadenvfile/g" /etc/pam.d/sudo && echo -e "${GREEN}[OK]${DEFAULT}"
			echo "Define LD_PRELOAD in /etc/pam.d/sshd ..."
			replaceline=$(cat /etc/pam.d/sshd | head -n1)
			sed -i "s/${replaceline}/${replaceline}\nauth       required     pam_env.so envfile=\/etc\/bashpreloadenvfile/g" /etc/pam.d/sshd && \
			echo -e "${GREEN}[OK]${DEFAULT}"; echo "Reload ..." && longlines && fmain
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
			make && {
				echo -e "${GREEN}[OK]${DEFAULT}"; echo "Compiled successfully"; echo "Reload ..."; longlines; fmain
		       	} || { 
				echo -e "${RED}[Failed]${DEFAULT}"; echo "Compilation failed, exit now ..."; exit 255
			     }
		else
			echo -e "${RED}[Error]${DEFAULT}"
			echo "ld.c or Makefile not found."
			echo "Please, check:"
			echo "1) Files ld.c and Makefile exists."
			echo "2) They are in the same with loginstall.sh file directory"
			exit 255
		fi
	fi
fi

}
fmain

# Final steps.

echo "Final step: Unset variable for another programs ..."
echo '[ $LD_PRELOAD ] && unset LD_PRELOAD' > /etc/profile.d/unsetLD_PRE.sh
echo -e "${GREEN}[Finished]${DEFAULT}"

echo "Checking if /usr/local/bin/setLD_PRE.sh exists ..."
setldinusrlocalbin
if [ $? -eq 0 ]
then
	echo -e "${GREEN}[OK]${DEFAULT}"
	echo "Finished."
else
	echo -e "${YELLOW}[Warning]${DEFAULT}"
	echo "FIle not found. Copying it from the repository ..."
	cp setLD_PRE.sh /usr/local/bin/ && chmod +x /usr/local/bin/setLD_PRE.sh
	echo -e "${GREEN}[OK]${DEFAULT}"
	echo "Finished."
fi
