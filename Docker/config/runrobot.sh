#!/bin/bash

# set -vx      # uncomment to enable debugging
# OR uncomment following lines to enable debugging
# PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
# set -x      

MYSQL_USER='root'
DATABASE_NAME='ynw'
MYSQL_PASSWORD='netvarth'
cnffile='.my.cnf'
SQL_FILE='Queries.sql'
PINCODE_FILE='postal_code_tbl.sql'
BANK_FILE='bank_master_tbl.sql'
BACKUP_FILE="APreDB-$(date +"%d%b%y%H%M").sql"
DB_BACKUP_PATH="TDD/APreBackup"
# DB_HOST='127.0.0.1'
REDIS_HOST='127.0.0.1'
tddpath="TDD/${SUITE}"
var="$(cut -d'/' -f 1 <<< ${SUITE})"
Log_DIR=${SUITE%%.*}
# ssh-keyscan -H $IP_ADDRESS >> ~/.ssh/known_hosts
# echo "===================================================================================================="
# uname -vr
# echo "------------------------"
# date
# echo "------------------------"
# whoami
# echo "------------------------"
# who
# echo "------------------------"
# echo $USER
# echo "------------------------"
# echo $HOME
# echo "------------------------"
# ls -ld ${HOME}/.ssh
# echo "------------------------"
# ls -ld /ebs
# echo "------------------------"
# ls -ld $HOME
# echo "------------------------"
# ls -l /ebs
# echo "------------------------"
# ls -Al $HOME
# echo "------------------------"
# pwd
# echo "===================================================================================================="
echo -e "Host * \n\t StrictHostKeyChecking no" > ${HOME}/.ssh/config

cp /ebs/conf/VariablesFor*.py /ebs/

if [[ "$(< /proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ]]; then 
    echo "Ubuntu on Windows"
    cat /etc/resolv.conf | grep nameserver | cut -d' ' -f 2
    # DB_HOST='host.docker.internal'
    DB_HOST="$(hostname).local"
    # sed -i /ebs/VariablesForLocalServer.py -e 's/localhost:8080/host.docker.internal:8080/g'
    sed -i /ebs/VariablesForLocalServer.py -e "s/localhost:8080/$DB_HOST:8080/g"
else 
    echo "native Linux"
    DB_HOST='127.0.0.1'
    # DB_HOST='host.docker.internal'
fi



runAPre()
{
    echo "Running $2"
    # pabot --processes 3 --outputdir TDD_Output/signuplog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    robot --outputdir TDD_Output/signuplog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # echo "APre Done. Executing Queries from $SQL_FILE"
    echo "APre Done."
}

runTDD()
{
    echo "Running $2"
    mkdir -p "TDD_Output/tddlog/$Log_DIR"
    pabot --processes 5 --outputdir "TDD_Output/tddlog/$Log_DIR" --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runSE()
{
    echo "Running $2"
    robot --outputdir TDD_Output/SELog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runSA()
{
    echo "Running $2"
    robot --outputdir TDD_Output/SALog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runTime()
{
    echo "Running $2"
    robot --outputdir TDD_Output/timeLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT  --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runBasics()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/BasicsLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runJBQueue()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/JBQueueLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runJBAppointment()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/JBAppointmentLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runJBOrder()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/JBOrderLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runLendingCRM()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/LendingCRMLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runPay()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/JaldeePayLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runAPI()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/APIlog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runComms()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/CommsLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runReports()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/ReportsLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runAnalytics()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/AnalyticsLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runProvider()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/ProviderLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runConsumer()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/ConsumerLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runUser()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/UserLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

runPartner()
{
    echo "Running $2"
    pabot --processes 5 --outputdir TDD_Output/PartnerLog --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
    # robot --outputdir TDD_Output/tddreport --variable PUSERNAME:$NUM_PSERIES --variable provider_count:$PUSER_COUNT --variable CUSERNAME:$NUM_CSERIES --variable consumer_count:$CUSER_COUNT --variable P_Email:$P_EMAIL --variable C_Email:$C_EMAIL --variable Container_id:$CONTAINER_ID --variablefile $1 "$2"
}

fullRun()
{
    echo "Running all JTA Resources"
    if [ "${SIGN_UP}" == "yes" ]; then
        populatePostalCodeTable
        populateBankMasterTable
        runAPre $1 TDD/APre
        execQueries
        backupDB
    fi
    runAPI $1 TDD/JCloudAPI
    runBasics $1 TDD/Basics
    runJBQueue $1 TDD/JBQueue
    runJBAppointment $1 TDD/JBAppointment
    runJBOrder $1 TDD/JBOrder
    runPay $1 TDD/JaldeePay
    runComms $1 TDD/Communications
    runReports $1 TDD/Reports
    runLendingCRM $1 TDD/LendingCRM
    runAnalytics $1 TDD/Analytics
    runSE $1 TDD/TDDSE
    runSA $1 TDD/SA
    runTime $1 TDD/Time

}

mainRun()
{
    echo "Running Basics, Bookings, CRM, JPay, Comms & Reports Resources"
    
    runBasics $1 TDD/Basics
    runJBQueue $1 TDD/JBQueue
    runJBAppointment $1 TDD/JBAppointment
    runJBOrder $1 TDD/JBOrder
    runPay $1 TDD/JaldeePay
    runComms $1 TDD/Communications
    runReports $1 TDD/Reports
    runLendingCRM $1 TDD/LendingCRM
    
}

populatePostalCodeTable()
{
    pincount=$(mysql -h $DB_HOST -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from postal_code_tbl;")
    if [ -z ${pincount} ] || [[ $pincount -le 1 ]]; then
        echo "Pincode table count= '$pincount'. Pincode table not populated. Populating it using TDD/$PINCODE_FILE"
        mysql -f -h $DB_HOST -u ${MYSQL_USER} ${DATABASE_NAME} < TDD/$PINCODE_FILE
        checkPincode
            
    else
        echo "Pincode table count= '$pincount'. Pincode table already populated."
    fi

}

checkPincode()
{
    pincount=$(mysql -h $DB_HOST -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from postal_code_tbl;")
    if [ ! -z ${pincount} ] && (( ${pincount}>=84629 )); then
        echo "Pincode table count= '$pincount'. Pincode table populated."
    else
        echo "Populating pincode table encountered error. Please try populating manually using the command."
        echo "mysql -u root -p ynw < DynamicTDD/$PINCODE_FILE"
    fi
}

populateBankMasterTable()
{
    bnkcount=$(mysql -h ${DB_HOST} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from bank_master_tbl;")
    if [ -z ${bnkcount} ] || [[ ${bnkcount}<=1 ]]; then
        echo "Bank master table count= '$bnkcount'. Bank master table not populated. Populating it using TDD/$BANK_FILE"
        mysql -f -h ${DB_HOST} -u ${MYSQL_USER} ${DATABASE_NAME} < TDD/$BANK_FILE
        bnkcount=$(mysql -h ${DB_HOST} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from bank_master_tbl;")
        if [ ! -z ${bnkcount} ] && (( ${bnkcount}>=1310 )); then
            echo "Bank master table count= '$bnkcount'. Bank master table populated."
        else
            echo "Populating Bank master table encountered error. Please try populating manually using the command."
            echo "mysql -h ${DB_HOST} -u ${MYSQL_USER} -p ${DATABASE_NAME} < DynamicTDD/$BANK_FILE"
        fi
            
    else
        echo "Bank master table count= '$bnkcount'. Bank master table already populated."
    fi

}

execQueries()
{
    if [ -s TDD/$SQL_FILE ]; then
        echo "Executing Queries from DynamicTDD/$SQL_FILE."
        # mysql -fv -h $DB_HOST -u ${MYSQL_USER} ${DATABASE_NAME} < TDD/$SQL_FILE
        mysql -f -h $DB_HOST -u ${MYSQL_USER} ${DATABASE_NAME} < TDD/$SQL_FILE
    else
        echo "DynamicTDD/$SQL_FILE is empty. No queries to execute."
    fi
}

backupDB()
{
    if [ ! -d "$DB_BACKUP_PATH" ]; then
        echo "$DB_BACKUP_PATH does not exist. Creating it."
        mkdir "$DB_BACKUP_PATH"
    fi
    mysqldump -h ${DB_HOST} -u ${MYSQL_USER} --opt --databases ${DATABASE_NAME} --result-file="${DB_BACKUP_PATH}/${BACKUP_FILE}"
    echo " APre populated ynw backed up to ${DB_BACKUP_PATH}/${BACKUP_FILE} "
}

if [ ! -e "TDD/$SQL_FILE" ]; then
    echo "$SQL_FILE not found."
fi

if [ ! -e "$HOME/$cnffile" ]; then
        touch "$HOME/$cnffile" 
        cat > "$HOME/$cnffile" << eof
        [client]
        user="$MYSQL_USER"
        password="$MYSQL_PASSWORD"
eof
fi


case $ENV_KEY in
2 )
    echo "Executing case 2- jenkins"
    redis-cli -h $REDIS_HOST -p 6379 flushdb
    populatePostalCodeTable
    # execQueries

    if [ "${var}" != "APre" ] && [ "$SIGN_UP" == "yes" ]; then
        echo "Executing case *- Jenkins- Signup flag APre"
        runAPre VariablesForJenkins.py TDD/APre
        execQueries
    fi

    if [ "$FULL_RUN" == "True" ]; then
        echo "Executing case *- Jenkins- FULL_RUN"
        fullRun VariablesForJenkins.py
    elif [ "${MAIN}" == "True" ]; then
        echo "Executing case *- Jenkins- MAIN"
        mainRun VariablesForJenkins.py
    elif [ "${var}" == "APre" ]; then
        echo "Executing case *- Jenkins- APre"
        if [[ $SUITE == *.robot ]]; then 
            echo "Running $SUITE" 
            runAPre VariablesForJenkins.py "$tddpath"
        else 
            echo "Running APre Resource" 
            runAPre VariablesForJenkins.py "$tddpath"
            execQueries
        fi
    elif [ "${var}" == "TDD" ]; then
        echo "Executing case *- Jenkins- TDD"
        runTDD VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "Basics" ]; then
        echo "Executing case *- Jenkins- Basics"
        runBasics VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "JBOrder" ]; then
        echo "Executing case *- Jenkins- JBOrder"
        runJBOrder VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "JBQueue" ]; then
        echo "Executing case *- Jenkins- JBQueue"
        runJBQueue VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "JBAppointment" ]; then
        echo "Executing case *- Jenkins- JBAppointment"
        runJBAppointment VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "LendingCRM" ]; then
        echo "Executing case *- Jenkins- LendingCRM"
        runLendingCRM VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "JaldeePay" ]; then
        echo "Executing case *- Jenkins- JaldeePay"
        runPay VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "JCloudAPI" ]; then
        echo "Executing case *- Jenkins- JCloudAPI"
        runAPI VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "Communications" ]; then
        echo "Executing case *- Jenkins- Communications"
        runComms VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "Reports" ]; then
        echo "Executing case *- Jenkins- Reports"
        runReports VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "Analytics" ]; then
        echo "Executing case *- Jenkins- Analytics"
        runAnalytics VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "TDDSE" ]; then
        echo "Executing case *- Jenkins- TDDSE"
        runSE VariablesForJenkins.py "$tddpath"
    elif  [ "${var}" == "SA" ]; then
        echo "Executing case *- Jenkins- SA"
        runSA VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "Time" ]; then
        echo "Executing case *- Jenkins- Time"
        runTime VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "Provider" ]; then
        echo "Executing case *- Jenkins- Provider"
        runProvider VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "Consumer" ]; then
        echo "Executing case *- Jenkins- Consumer"
        runConsumer VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "User" ]; then
        echo "Executing case *- Jenkins- User"
        runUser VariablesForJenkins.py "$tddpath"
    elif [ "${var}" == "Partner" ]; then
        echo "Executing case *- Jenkins- Partner"
        runPartner VariablesForJenkins.py "$tddpath"
    fi

    if [ "${var}" != "Time" ] && [ "$TIMEFLAG" == "True"  ] && [ -f TDD/time.txt ]; then
        echo "TDD & SA Complete. Checking if Time is Ready"
        value=$(cat TDD/time.txt)
        echo "$value"
        if [ "$value" == "Ready"  ]; then
            echo "Executing case *- Jenkins- TIMEFLAG"
            runTime VariablesForJenkins.py TDD/Time
            echo "" > TDD/time.txt
        fi
    fi
    ;;
3 )
    echo "Executing case 3- Test"

    if [ "${var}" != "APre" ] && [ "$SIGN_UP" == "yes" ]; then
        echo "Executing case *- Test- Signup flag APre"
        runAPre VariablesForTest.py TDD/APre
    fi

    if [ "$FULL_RUN" == "True" ]; then
        echo "Executing case *- Test- FULL_RUN"
        fullRun VariablesForTest.py
    elif [ "${MAIN}" == "True" ]; then
        echo "Executing case *- Test- MAIN"
        mainRun VariablesForTest.py
    elif [ "${var}" == "APre" ]; then
        echo "Executing case *- Test- APre"
        
        if [[ $SUITE == *.robot ]]; then 
            echo "Running $SUITE" 
            runAPre VariablesForTest.py "$tddpath"
        else 
            echo "Running APre Resource" 
            runAPre VariablesForTest.py "$tddpath"
            
        fi
    elif [ "${var}" == "TDD" ]; then
        echo "Executing case *- Test- TDD"
        runTDD VariablesForTest.py "$tddpath"
    elif [ "${var}" == "Basics" ]; then
        echo "Executing case *- Test- Basics"
        runBasics VariablesForTest.py "$tddpath"
    elif [ "${var}" == "JBQueue" ]; then
        echo "Executing case *- Test- JBQueue"
        runJBQueue VariablesForTest.py "$tddpath"
    elif [ "${var}" == "JBAppointment" ]; then
        echo "Executing case *- Test- JBAppointment"
        runJBAppointment VariablesForTest.py "$tddpath"
    elif [ "${var}" == "JBOrder" ]; then
        echo "Executing case *- Test- JBOrder"
        runJBOrder VariablesForTest.py "$tddpath"
    elif [ "${var}" == "LendingCRM" ]; then
        echo "Executing case *- Test- LendingCRM"
        runLendingCRM VariablesForTest.py "$tddpath"
    elif [ "${var}" == "JaldeePay" ]; then
        echo "Executing case *- Test- JaldeePay"
        runPay VariablesForTest.py "$tddpath"
    elif [ "${var}" == "Communications" ]; then
        echo "Executing case *- Test- Communications"
        runComms VariablesForTest.py "$tddpath"
    elif [ "${var}" == "JCloudAPI" ]; then
        echo "Executing case *- Test- JCloudAPI"
        runAPI VariablesForTest.py "$tddpath"
    elif [ "${var}" == "Reports" ]; then
        echo "Executing case *- Test- Reports"
        runReports VariablesForTest.py "$tddpath"
    elif [ "${var}" == "Analytics" ]; then
        echo "Executing case *- Test- Analytics"
        runAnalytics VariablesForTest.py "$tddpath"
    elif [ "${var}" == "TDDSE" ]; then
        echo "Executing case *- Test- TDDSE"
        runSE VariablesForTest.py "$tddpath"
    elif  [ "${var}" == "SA" ]; then
        echo "Executing case *- Test- SA"
        runSA VariablesForTest.py "$tddpath"
    
    fi    
    ;;
4 )
    echo "Executing case 3- scale"
    # redis-cli flushdb
    # populatePostalCodeTable
    # execQueries

    if [ "${var}" != "APre" ] && [ "$SIGN_UP" == "yes" ]; then
        echo "Executing case *- Scale- Signup flag APre"
        runAPre VariablesForScale.py TDD/APre
        # execQueries
    fi

    if [ "$FULL_RUN" == "True" ]; then
        echo "Executing case *- Scale- FULL_RUN"
        fullRun VariablesForScale.py
    elif [ "${MAIN}" == "True" ]; then
        echo "Executing case *- Scale- MAIN"
        mainRun VariablesForScale.py
    elif [ "${var}" == "APre" ]; then
        echo "Executing case *- Scale- APre"
        # runAPre VariablesForScale.py "$tddpath"
        # execQueries
        if [[ $SUITE == *.robot ]]; then 
            echo "Running $SUITE" 
            runAPre VariablesForScale.py "$tddpath"
        else 
            echo "Running APre Resource" 
            runAPre VariablesForScale.py "$tddpath"
            # execQueries
        fi
    elif [ "${var}" == "TDD" ]; then
        echo "Executing case *- Scale- TDD"
        runTDD VariablesForScale.py "$tddpath"
    elif [ "${var}" == "Basics" ]; then
        echo "Executing case *- Scale- Basics"
        runBasics VariablesForScale.py "$tddpath"
    elif [ "${var}" == "JBQueue" ]; then
        echo "Executing case *- Scale- JBQueue"
        runJBQueue VariablesForScale.py "$tddpath"
    elif [ "${var}" == "JBAppointment" ]; then
        echo "Executing case *- Scale- JBAppointment"
        runJBAppointment VariablesForScale.py "$tddpath"
    elif [ "${var}" == "JBOrder" ]; then
        echo "Executing case *- Scale- JBOrder"
        runJBOrder VariablesForScale.py "$tddpath"
    elif [ "${var}" == "LendingCRM" ]; then
        echo "Executing case *- Scale- LendingCRM"
        runLendingCRM VariablesForScale.py "$tddpath"
    elif [ "${var}" == "JaldeePay" ]; then
        echo "Executing case *- Scale- JaldeePay"
        runPay VariablesForScale.py "$tddpath"
    elif [ "${var}" == "Communications" ]; then
        echo "Executing case *- Scale- Communications"
        runComms VariablesForScale.py "$tddpath"
    elif [ "${var}" == "JCloudAPI" ]; then
        echo "Executing case *- Scale- JCloudAPI"
        runAPI VariablesForScale.py "$tddpath"
    elif [ "${var}" == "Reports" ]; then
        echo "Executing case *- Scale- Reports"
        runReports VariablesForScale.py "$tddpath"
    elif [ "${var}" == "Analytics" ]; then
        echo "Executing case *- Scale- Analytics"
        runAnalytics VariablesForScale.py "$tddpath"
    elif [ "${var}" == "TDDSE" ]; then
        echo "Executing case *- Scale- TDDSE"
        runSE VariablesForScale.py "$tddpath"
    elif  [ "${var}" == "SA" ]; then
        echo "Executing case *- Scale- SA"
        runSA VariablesForScale.py "$tddpath"
    # elif [ "${var}" == "Time" ]; then
    #     echo "Executing case *- Scale- Time"
    #     runTime VariablesForScale.py "$tddpath"
    fi

    # if [ "${var}" != "Time" ] && [ "$TIMEFLAG" == "True"  ] && [ -f TDD/time.txt ]; then
    #     echo "TDD & SA Complete. Checking if Time is Ready"
    #     value=$(cat TDD/time.txt)
    #     echo "$value"
    #     if [ "$value" == "Ready"  ]; then
    #         echo "Executing case *- Scale- TIMEFLAG"
    #         runTime VariablesForScale.py TDD/Time
    #         echo "" > TDD/time.txt
    #     fi
    # fi    
    ;;
* )
    echo "Executing case *- local"
    # redis-cli -h $REDIS_HOST -p 6379 flushdb
    populatePostalCodeTable
    # execQueries
    # if [ "$FULL_RUN" == "True" ]; then
    #     fullRun VariablesForLocalServer.py
    # fi
    
    if [ "${var}" != "APre" ] && [ "$SIGN_UP" == "yes" ]; then
        echo "Executing case *- local- Signup flag APre"
        runAPre VariablesForLocalServer.py TDD/APre
        execQueries
        backupDB
    fi

    if [ "$FULL_RUN" == "True" ]; then
        echo "Executing case *- local- FULL_RUN"
        fullRun VariablesForLocalServer.py
    elif [ "${MAIN}" == "True" ]; then
        echo "Executing case *- local- MAIN"
        mainRun VariablesForLocalServer.py
    elif [ "${var}" == "APre" ]; then
        echo "Executing case *- local- APre"
        # runAPre VariablesForLocalServer.py "$tddpath"
        # execQueries
        if [[ $SUITE == *.robot ]]; then 
            echo "Running $SUITE" 
            runAPre VariablesForLocalServer.py "$tddpath"
        else 
            echo "Running APre Resource" 
            runAPre VariablesForLocalServer.py "$tddpath"
            execQueries
        fi
    elif [ "${var}" == "TDD" ]; then
        echo "Executing case *- local- TDD"
        runTDD VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "Basics" ]; then
        echo "Executing case *- local- Basics"
        runBasics VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "JBQueue" ]; then
        echo "Executing case *- local- JBQueue"
        runJBQueue VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "JBAppointment" ]; then
        echo "Executing case *- local- JBAppointment"
        runJBAppointment VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "JBOrder" ]; then
        echo "Executing case *- local- JBOrder"
        runJBOrder VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "LendingCRM" ]; then
        echo "Executing case *- local- LendingCRM"
        runLendingCRM VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "JaldeePay" ]; then
        echo "Executing case *- local- JaldeePay"
        runPay VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "Communications" ]; then
        echo "Executing case *- local- Communications"
        runComms VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "Reports" ]; then
        echo "Executing case *- local- Reports"
        runReports VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "JCloudAPI" ]; then
        echo "Executing case *- local- JCloudAPI"
        runAPI VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "Analytics" ]; then
        echo "Executing case *- local- Analytics"
        runAnalytics VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "TDDSE" ]; then
        echo "Executing case *- local- TDDSE"
        runSE VariablesForLocalServer.py "$tddpath"
    elif  [ "${var}" == "SA" ]; then
        echo "Executing case *- local- SA"
        runSA VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "Time" ]; then
        echo "Executing case *- local- Time"
        runTime VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "Provider" ]; then
        echo "Executing case *- local- Provider"
        runProvider VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "Consumer" ]; then
        echo "Executing case *- local- Consumer"
        runConsumer VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "User" ]; then
        echo "Executing case *- local- User"
        runUser VariablesForLocalServer.py "$tddpath"
    elif [ "${var}" == "Partner" ]; then
        echo "Executing case *- local- Partner"
        runPartner VariablesForLocalServer.py "$tddpath"
    fi

    if [ "${var}" != "Time" ] && [ "$TIMEFLAG" == "True"  ] && [ -f TDD/time.txt ]; then
        echo "TDD & SA Complete. Checking if Time is Ready"
        value=$(cat TDD/time.txt)
        echo "$value"
        if [ "$value" == "Ready"  ]; then
            echo "Executing case *- local- TIMEFLAG"
            runTime VariablesForLocalServer.py TDD/Time
            echo "" > TDD/time.txt
        fi
    fi
    ;;
esac
