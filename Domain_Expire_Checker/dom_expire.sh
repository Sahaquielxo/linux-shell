#!/bin/bash 

# Location of system binaries
AWK=$(which awk)
WHOIS=$(which whois)
DATE="/bin/date"

# Place to stash temporary files
WHOIS_TMP="/var/tmp/whois.$$"

date2julian() 
{
    if [ "${1}" != "" ] && [ "${2}" != ""  ] && [ "${3}" != "" ]
    then
         ## Since leap years add aday at the end of February, 
         ## calculations are done from 1 March 0000 (a fictional year)
         d2j_tmpmonth=$((12 * ${3} + ${1} - 3))
        
         ## If it is not yet March, the year is changed to the previous year
         d2j_tmpyear=$(( ${d2j_tmpmonth} / 12))
        
         ## The number of days from 1 March 0000 is calculated
         ## and the number of days from 1 Jan. 4713BC is added 
         echo $(( (734 * ${d2j_tmpmonth} + 15) / 24 -  2 * ${d2j_tmpyear} + ${d2j_tmpyear}/4
                       - ${d2j_tmpyear}/100 + ${d2j_tmpyear}/400 + $1 + 1721119 ))
    else
          echo 0
    fi
}

#############################################################################
# Purpose: Convert a string month into an integer representation
# Arguments:
#   $1 -> Month name (e.g., Sep)
#############################################################################
getmonth() 
{
	LOWER=$(tolower $1)
              
       case ${LOWER} in
             jan|01) echo 1 ;;
             feb|02) echo 2 ;;
             mar|03) echo 3 ;;
             apr|04) echo 4 ;;
             may|05) echo 5 ;;
             jun|06) echo 6 ;;
             jul|07) echo 7 ;;
             aug|08) echo 8 ;;
             sep|09) echo 9 ;;
             oct|10) echo 10 ;;
             nov|11) echo 11 ;;
             dec|12) echo 12 ;;
               *) echo  0 ;;
       esac
}

#############################################################################
# Purpose: Calculate the number of seconds between two dates
# Arguments:
#   $1 -> Date #1
#   $2 -> Date #2
#############################################################################
date_diff() 
{
        if [ "${1}" != "" ] &&  [ "${2}" != "" ]
        then
                echo $(expr ${2} - ${1})
        else
                echo 0
        fi
}

##################################################################
# Purpose: Converts a string to lower case
# Arguments:
#   $1 -> String to convert to lower case
##################################################################
tolower() 
{
	LOWER=$(echo ${1} | tr [A-Z] [a-z])
     	echo $LOWER
}

##################################################################
# Purpose: Access whois data to grab the registrar and expiration date
# Arguments:
#   $1 -> Domain to check
##################################################################
check_domain_status() 
{
    # Save the domain since set will trip up the ordering
    DOMAIN=$(echo "${1}" | idn)
    TLD=$(echo "${DOMAIN}" | cut -f2,3 -d '.')
    case "${TLD}" in
	moscow) 
	  whois -h whois.nic.moscow "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
	;;
	xn--80adxhks) 
	  whois -h whois.nic.xn--80adxhks "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
	;;
	pro)    
	  whois -h whois.afilias.net "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
	;;
	group)  
	  whois -h whois.donuts.co "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
	;;
	com.ru) 
	  whois -h whois.nic.ru "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
	;;
	spb.ru)
	  whois -h whois.nic.ru "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
        ;;
	tatar)
	  whois -h whois.nic.tatar "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
	;;
	life)
	  whois -h whois.donuts.co "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
	;;
	auction)
	  whois -h whois.unitedtld.com "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
        ;;
	xn--plai)
	  whois -h whois.tcinet.ru "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
        ;;
	biz)
	  whois -h whois.biz "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
        ;;
	co.jp)  
	  whois "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(echo "Japan Domain")
	;;
	photo)
	  whois -h whois.uniregistry.net "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
        ;;
	*)	
	  whois "${DOMAIN}" > ${WHOIS_TMP}
	  REGISTRAR=$(cat ${WHOIS_TMP} | ${AWK} -F: '/(R|r)egistrar:/ && $2 != ""  { REGISTRAR=$2 } END { print REGISTRAR }')
	;;
    esac
	 
    # If the Registrar is NULL, then we didn't get any data
    if [ "${REGISTRAR}" = "" ]
    then
        prints "$DOMAIN" "Unknown" "Unknown" "Unknown" "Unknown"
        return
    fi

    # The whois Expiration data should resemble teh following: "Expiration Date: 09-may-2008"
    if [ $(cat ${WHOIS_TMP} | grep -c "CO.JP") -ne 0 ]
    then
	    DOMAINDATE=$(cat ${WHOIS_TMP} | grep "Connected (" | awk -F'(' '{print $2}' | sed 's/)//g;s/\//-/g')
    else
	    DOMAINDATE=$(cat ${WHOIS_TMP} | ${AWK} '/paid-till|Expiry/ { print $NF}' | sed 's/T.*//g;s/\./-/g;s/\//-/g')
	    if [ $(echo "${DOMAINDATE}" | wc -c) -lt 7 ]
    	    then
		    DOMAINDATE=$(cat ${WHOIS_TMP} | ${AWK} -F'                      ' '/paid-till|Expir/ { print $NF}' | awk '{print $NF "-" $2 "-" $3}')
		    if [ $(echo "${DOMAINDATE}" | grep -c Date) -eq 1 ]
		    then
		  	    DOMAINDATE=$(cat ${WHOIS_TMP} | ${AWK} -F'                      ' '/paid-till|Expir/ { print $NF}' | awk -F':' '{print $2 }' | awk '{print $1}' | awk -F'-' '{print $3 "-" $2 "-" $1}')
		    fi
    	    fi
    fi
    # Whois data should be in the following format: "13-feb-2006"
    IFS="-"
    set -- ${DOMAINDATE}
    MONTH=$(getmonth ${2})
    IFS=""

    # Convert the date to seconds, and get the diff between NOW and the expiration date
    DOMAINJULIAN=$(date2julian ${MONTH} ${3#0} ${1})
    DOMAINDIFF=$(date_diff ${NOWJULIAN} ${DOMAINJULIAN})

    if [ ${DOMAINDIFF} -lt 0 ]
    then
           prints ${DOMAIN} "Expired" "${DOMAINDATE}" "${DOMAINDIFF}" ${REGISTRAR}

    elif [ ${DOMAINDIFF} -lt 30 ]
    then
           prints ${DOMAIN} "Expiring" "${DOMAINDATE}" "${DOMAINDIFF}" "${REGISTRAR}"
     else
           prints ${DOMAIN} "Valid" "${DOMAINDATE}"  "${DOMAINDIFF}" "${REGISTRAR}"
     fi
}

####################################################
# Purpose: Print a heading with the relevant columns
# Arguments:
#   None
####################################################
print_heading()
{
                printf "\n%-35s %-17s %-8s %-11s %-5s\n" "Domain" "Registrar" "Status" "Expires" "Days Left"
                echo "----------------------------------- ----------------- -------- ----------- ---------"
}

#####################################################################
# Purpose: Print a line with the expiraton interval
# Arguments:
#   $1 -> Domain
#   $2 -> Status of domain (e.g., expired or valid)
#   $3 -> Date when domain will expire
#   $4 -> Days left until the domain will expire
#   $5 -> Domain registrar
#####################################################################
prints()
{
            MIN_DATE=$(echo $3 | ${AWK} '{ print $1, $2, $4 }')
	    ALERT_STRING=`echo "will expire LESS then in 30 days"`
	    JUST_STRING=`echo "DOMAIN WILL EXPIRE IN $4 DAYS"`
	if [ "$4" == "Unknown" ]
	then
	  printf "%-35s %-17s\n" "$1    Does not exists"
	else
	    if [ "$4" -lt "30" ]
	    then
#		printf "%-35s %-17s\n" "$1"    "$ALERT_STRING"
		echo "$1 $ALERT_STRING"
	    fi
	fi
}

##########################################
# Purpose: Describe how the script works
# Arguments:
#   None
##########################################
usage()
{
        echo "Usage: $0 [ -h ]"
        echo "          {[ -d domain_namee ]} || { -f domainfile}"
        echo ""
        echo "  -d domain        : Domain to analyze (interactive mode)"
        echo "  -f domain file   : File with a list of domains"
        echo "  -h               : Print this screen"
        echo ""
}

### Evaluate the options passed on the command line
while getopts ae:f:hd:s:qx: option
do
        case "${option}"
        in
                d) DOMAIN=${OPTARG};;
                f) SERVERFILE=$OPTARG;;
                \?) usage
                    exit 1;;
        esac
done

### Check to see if the whois binary exists
if [ ! -f ${WHOIS} ]
then
        echo "ERROR: The whois binary does not exist in ${WHOIS} ."
        echo "  FIX: Please modify the \$WHOIS variable in the program header."
        exit 1
fi

### Check to make sure a date utility is available
if [ ! -f ${DATE} ]
then
        echo "ERROR: The date binary does not exist in ${DATE} ."
        echo "  FIX: Please modify the \$DATE variable in the program header."
        exit 1
fi

### Baseline the dates so we have something to compare to
MONTH=$(${DATE} "+%m")
DAY=$(${DATE} "+%d")
YEAR=$(${DATE} "+%Y")
NOWJULIAN=$(date2julian ${MONTH#0} ${DAY#0} ${YEAR})

### Touch the files prior to using them
touch ${WHOIS_TMP}

### If a HOST and PORT were passed on the cmdline, use those values
if [ "${DOMAIN}" != "" ]
then
#Uncomment it if you want table-like output
#        print_heading
        check_domain_status "${DOMAIN}"
### If a file and a "-a" are passed on the command line, check all
### of the domains in the file to see if they are about to expire
elif [ -f "${SERVERFILE}" ]
then
#        print_heading
        while read DOMAIN
        do
                check_domain_status "${DOMAIN}"

        done < ${SERVERFILE}

### There was an error, so print a detailed usage message and exit
else
        usage
        exit 1
fi

### Remove the temporary files
rm -f ${WHOIS_TMP}

### Exit with a success indicator
exit 0
