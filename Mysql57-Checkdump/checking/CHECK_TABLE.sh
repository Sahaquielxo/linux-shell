#!/bin/bash
##################################################################################################################
############################################## Variables #########################################################
##################################################################################################################
START=$(date +%s)											  	##
RED='\033[0;31m'											  	##
GREEN='\033[0;32m'											  	##
NC='\033[0m'												  	##
DT=$(date +"%Y-%m-%d | %T")										  	##
DTD=$(date +"%Y-%m-%d")											  	##
CPUC=$(grep -c processor /proc/cpuinfo)									  	##
##################################################################################################################
##################################################################################################################
##################################################################################################################
> CHECK_LIST

##################################################################################################################
############################################ Code Section ########################################################
##################################################################################################################
														##
#Dump count.													##
#Real Var													##
#TODAY_DUMP_COUNT=$(find /var/dumps -type f -mtime -1 | wc -l)							##
#TODAY_DUMP_FILES=$(find /var/dumps/ -type f -mtime -1)								##
#Test Var													##
TODAY_DUMP_COUNT=$(find /var/dumps -type f | wc -l)								##
		if [ $TODAY_DUMP_COUNT -eq 0 ];									##
                  then echo "$DT | ERROR | Unable to calculate count of dump files!" >> /var/dumpcheck/check.log.$DTD
                       echo -e "${RED}Something wrong! There are no any dump files created today in the directory!$NC"
		  else echo "$DT | SUCCESS | $TODAY_DUMP_COUNT last dump files found" >> /var/dumpcheck/check.log.$DTD
		       echo "Founded $TODAY_DUMP_COUNT dump files"						##
          	fi												##
TODAY_DUMP_FILES=$(find /var/dumps/ -type f | awk -F'/' '{print $4}')						##
for GZFILE in $TODAY_DUMP_FILES											##
  do														##
#CREATE database;												##
	DBNAME=$(zcat /var/dumps/$GZFILE | head -n10 | grep Database | awk '{print $5}')			##
	mysql -utest -ptest -e "CREATE DATABASE ${DBNAME};" 2>/dev/null						##
		if [ $? -eq 0 ];										##
                  then echo "$DT | SUCCESS | Database $DBNAME created" >> /var/dumpcheck/check.log.$DTD		##
		       echo -e "${GREEN}Databse $DBNAME created!$NC"						##
                  else echo "$DT | ERROR | Database $DBNAME create failed!" >> /var/dumpcheck/check.log.$DTD	##
		       echo -e "${RED}Database $DBNAME create failed!"						##
          	fi												##
#IMPORT database;												##
	import_start=$(date +%s)										##
	echo "Import $DBNAME starting, wait please"								##
	pv /var/dumps/$GZFILE | pigz -d -p $CPUC | mysql -utest -ptest $DBNAME 2>/dev/null			##
	import_state=$?												##
	import_finish=$(date +%s)										##
	import_time=$(( $import_finish - $import_start ))							##
		if [ $import_state -eq 0 ];									##
                  then echo "$DT | SUCCESS | Importing in $DBNAME finished in $import_time seconds!" >> /var/dumpcheck/check.log.$DTD
		       echo -e "${GREEN}Success! Database $DBNAME from /var/dumps/${GZFILE} has been restored successfull in $import_time seconds!$NC"
                  else echo "$DT | ERROR | Database $DBNAME create failed in $import_time seconds!" >> /var/dumpcheck/check.log.$DTD
		       echo -e "${RED}Something wrong! Failed to restore database $DBNAME from /var/dumps/${GZFILE}! Script continue to work, this warning you will be able to find in /var/dumpcheck/check.log.$DTD file$NC"							 ##
                fi												##
#Prepare CHECK TABLE %table_name% for $DBNAME									##
	echo "SELECT CONCAT('CHECK TABLE ',dbtb,';') FROM (SELECT CONCAT(table_schema,'.',table_name) dbtb FROM information_schema.tables WHERE table_schema NOT IN ('information_schema','performance_schema','mysql')) A;" | mysql -utest -ptest 2>/dev/null | sed 1d | egrep -v 'CHECK TABLE sys\.*' >> CHECK_LIST
		if [ $? -eq 0 ];										##
       		  then echo "$DT | SUCCESS | CHECK TABLE commands created in /var/checking/CHECK_LIST for every table for ${DBNAME}!" >> /var/dumpcheck/check.log.$DTD														 ##
        	  else echo "$DT | ERROR | CHECK TABLE commands create for $DBNAME failed!" >> /var/dumpcheck/check.log.$DTD
    		fi												##
	while read COMMAND											##
	  do													##
#Read every commain by string from file and execute in MySQL							##
		echo "CHECK TABLE for each table in $DBNAME started.."						##
		CHECK_OUT=$(mysql -utest -ptest -N -B -e "$COMMAND" -t 2>/dev/null)				##
			if [ $? -eq 0 ];									##
        		  then echo "$DT | SUCCESS | $COMMAND success!" >> /var/dumpcheck/check.log.$DTD	##
			       echo -e "${GREEN}${COMMAND} finished successfull!$NC"  				##
        		  else echo "$DT | ERROR | $COMMAND failed!" >> /var/dumpcheck/check.log.$DTD		##
			       echo -e "${RED}${COMMAND} failed!$NC"						##
    			fi											##
#Save CHECK TABLE output in /var/checking/common_dump.check.$DTD						##
		echo "$CHECK_OUT" >> common_dump.check.$DTD							##
    			if [ $? -eq 0 ];									##
        		  then echo "$DT | SUCCESS | $COMMAND output successfully saved in /var/checking/common_dump.check" >> /var/dumpcheck/check.log.$DTD
			       echo -e "${GREEN}${COMMAND} output successfully saved in /var/checking/common_dump.check.${DTD}$NC"
        		  else echo "$DT | ERROR | Can't save $COMMAND output in /var/checking/common_dump.check" >> /var/dumpcheck/check.log.$DTD
			       echo -e "${RED}Can't save $COMMAND output in /var/checking/common_dump.check.${DTD}$NC"
    			fi											##
	  done < CHECK_LIST											##
#Clear check_list												##
	> CHECK_LIST												##
#Looking for failed CHECK TABLE strings in common_dump.check file						##
	echo -e "${GREEN}--------------------------------------------------------------------------------------------------------$NC"
	echo -e "${RED}--------------------------------------------------------------------------------------------------------$NC"
	echo -e "${GREEN}--------------------------------------------------------------------------------------------------------$NC"
	IFFALSE=$(cat common_dump.check.$DTD | grep -v \+ | awk -F'|' '{print $5}' | sed 's/ //g' | grep -v OK) ##
		if [ $? -eq 0 ]											##
  		  then												##
        		TG=$(cat common_dump.check.$DTD | grep -v OK | grep -v \+ | awk -F'|' '{print $2}')	##
        		  for TGc in `cat common_dump.check.$DTD | grep -v OK | grep -v \+ | awk -F'|' '{print $2}'`; do
          			echo -e "${RED}Attention! Table $TGc check failed! Script continue to work, this warning you will be able to find in /var/dumpcheck/check.log.${DTD}$NC"											 ##
          			echo "$DT | ERROR | Attention! Table $TGc check failed! Seems like table corrupted!" >> /var/dumpcheck/check.log.$DTD
        		  done											##
  		  else												##
        		echo -e "${GREEN}All tables have been checked successfully! Don't worry now about your DB-backup of $DBNAME database$NC"
		fi												##
#Lets drop database												##
	echo "We will drop database $DBNAME now, because we needs not for it"					##
	mysql -utest -ptest -e "DROP DATABASE ${DBNAME};" 2>/dev/null						##
	echo "Done. Next dump check incoming.."									##
	sleep 2													##
done														##
#After all iterations, here we go										##
END=$(date +%s)													##
RUNTIME=$(( $END - $START ))											##
FINDATE=$(date '+%d/%m/%y %H:%M:%S')										##
echo "$DT | SUCCESS | Test was running for $RUNTIME seconds, finished at $FINDATE" >> /var/dumpcheck/check.log.$DTD
echo -e "${GREEN}Finished! Test was running for $RUNTIME seconds, finished at ${FINDATE}. Checking log was saved in /var/dumpcheck/check.log.${DTD}$NC"
rm -rf CHECK_LIST												##
##################################################################################################################
##################################################################################################################
##################################################################################################################
