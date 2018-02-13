#!/bin/sh

pass_mes()
{
    read -sp 'Password: ' passvar
    echo $passvar           
}

password_verify()
{
    pass_ver=$(dscl /Search -authonly skull $typo 2>&1 | grep -i Authentication | awk '{print $1$5}')
        if [ "$pass_ver" == "Authenticationfailed." ]; then
            echo "Wrong_Password"
        else 
            echo "Correct_Password"
        fi
}

funtion_cancle()
{
        us_output=$(pass_mes)
            if [ "$us_output" == "User_Cancel" ]; then
                echo "User_Cancel"
            else
                echo "$us_output"
            fi
}


funtion_final_output()
{
    typo=$(funtion_cancle)
        if [ "$typo" == "User_Cancel" ]; then
	    ret="User_Cancel"
            echo "${ret}"
        elif [ -z $typo ]; then
	    ret="empty"
            echo "${ret}"
        else
            if [ "$(password_verify)" == "Correct_Password" ]; then
		ret="WORKING_SKULL"
                echo "${ret} ${typo}"
            else
                #echo "Wrong_Password"
		ret="NOT_WORKING_SULL"
                echo "${ret}"
            fi  
        fi      
}

retry_funtion()
{
    echo "****Wrong Password Typed****"
}

cancel_funtion()
{
    echo "***User Cancled ***"
}


############## Script start ##################

echo "Script start"

while read -r ret typo
do
    case    $ret in
        "NOT_WORKING_SKULL") retry_funtion
        ;;
        "empty") retry_funtion
        ;;
        "User_Cancel") cancel_funtion exit
        ;;
        "WORKING_SKULL") break
        ;;
    esac
done < <(echo $(funtion_final_output))

echo "User password is= $typo"

echo "Continue script using password $typo"

