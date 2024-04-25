# !/bin/bash
# set -vx      # uncomment to enable debugging
# OR
# set -x      # uncomment to enable debugging
# PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }' # uncomment to enable debugging
# exec >> /logs/jtacheck.log 2>&1

defaultEnv="dev"
defaultParallelContainers="1"
defaultPSeries="1110000001"
defaultCSeries="1710000001"
defaultBSeries="1910000001"
defaultPUserCount="260"
defaultCUserCount="40"
defaultBCount="160"
defaultPemail="d_p"
defaultCemail="d_c"
defaultBemail="d_b"
defaultBSPemail="d_bsp"
defaultDynSignUp="no"
defaultSuitePath="TDD" 
defaulttimeFlag="False"
userpass="netvarth"
NUM_FILE='numbers.txt'
PAN_FILE='pan.txt'
TIME_FILE='time.txt'
VAR_DIR='varfiles'
BASE_DIR="$(dirname "${PWD%*/*/*}")"
# CONF_DIR="$(find $BASE_DIR -type d -name "ynwconf" -print0 2>/dev/null | tr -d '\0')"


# Shows usage of the script. used when this script is run without a parameter.
usage()
{
    echo -e "usage: $0 {-env | --environment  [dev | jenkins | scale] } | {-c | --container-count [VALUE] } | {-i | --interactive } | {-na | --noAPre } | [-h | --help]"
    echo -e "\n"
    echo -e "\n[-env | --environment]- runs docker in the specified environment. \nExample usage: $0 -env dev" 
    echo -e "\n[-c | --container-count] - sets the number of parallel containers.\nExample usage: $0  --TDD -c 2"
    echo -e "\n[-i | --interactive] - enables setting the env, input location, and output location interactively. This option overrides the environment set using -env option. \nExample usage: $0 -i"
    echo -e "\n[-na | --noAPre] - sets the APre flag to false. Give this option with the -env option if you don't want to run APre. \nExample usage: $0 -env dev -na"
    echo -e "\n[--APre] - Runs APre. Example usage: $0 --APre"
    echo -e "\n[--TDD] - Runs TDD. Example usage: $0 --TDD"
    echo -e "\n[--TDDSE] - Runs TDDSE. Example usage: $0 --TDDSE"
    echo -e "\n[--SA] - Runs SA. Example usage: $0 --SA"
    echo -e "\n[--Time] - Runs Time. Example usage: $0 --Time"
    echo -e "\n[--Basics | --basics] - Runs Basic functionalities Resources like login and signup. Example usage: $0 --Basics"
    echo -e "\n[ --JBQueue | --jbqueue] - Runs Queue and Waitlist based resources. Example usage: $0 --JBQueue"
    echo -e "\n[--JBAppointment | --jbappointment] - Runs Schedule and appointment based resources. Example usage: $0 --JBAppointment"
    echo -e "\n[--JBOrder | --jborder] - Runs Catalog and Order based resources. Example usage: $0  --JBOrder"
    echo -e "\n[--LendingCRM | --lendingcrm] - Runs Lending CRM (cdl and lms) resources. Example usage: $0 --LendingCRM"
    echo -e "\n[--JaldeePay | --jaldeepay] - Runs Billing and Payment resources. Example usage: $0 --JaldeePay"
    echo -e "\n[--JCloudAPI | --jcloudapi] - Runs Jaldee Cloud Platform API Resource. Example usage: $0 --JCloudAPI"
    echo -e "\n[--Communications | --communications | --comms] - Runs Jaldee Communication Resource. Example usage: $0 --Communications"
    echo -e "\n[--Reports | --reports] - Runs Reports Resource. Example usage: $0 --Reports"
    echo -e "\n[--Analytics | --analytics] - Runs Reports Resource. Example usage: $0 --Analytics"
    echo -e "\n[-cpu] - Runs Basics, JBQueue, JBAppointment, JBOrder, JaldeePay, Communications, Reports & LendingCRM. Example usage: $0 -cpu"
    echo -e "\n[-h | --help] - displays this help message."
    echo -e "\n Examples: $0 -env dev -na -c 2  ---> runs entire tdd, without provider/consumer signup(APre), in the development environment, in 2 docker containers"
    echo -e "\n Examples: $0 -cpu -c 2  ---> runs Provider, Consumer and User, in 2 docker containers"
    echo -e "\n Examples: $0 -cpu  ---> Runs Basics, JBQueue, JBAppointment, JBOrder, JaldeePay, Communications, Reports & LendingCRM in singe docker container"
    echo -e "\n Examples: $0 -i ---> runs this script in interactive mode"
}

# Shows usage of the script. used when this script is run without a parameter.
checkInputArgs()
{
    if [[ "$*" == *"--APre"* ]] && [[ "$*" == *"--noAPre"* ]]; then
        echo "You can't run --APre and --noAPre together. Please run --noAPre with --env or --APre alone."
        usage
        # echo "Run $0 without parameters for usage."
    # else
    #     echo "NO"
    fi
}

# Shows usage of the script. used when this script is run without a parameter.
checkSysType()
{
    # cat /proc/sys/kernel/osrelease >> $LogFileName
	if [[ "$(< /proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ]]; then 
        LogFileName='/mnt/d/LOGS/jtacheck.log'
        echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/sys/kernel/osrelease check - WSL" | tee -a $LogFileName
        echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] Ubuntu on Windows- Windows Subsystem for Linux"
        cat /etc/resolv.conf | grep nameserver | cut -d' ' -f 2
        MYSQL_HOST="$(hostname).local"
        CONF_DIR='/mnt/d/ebs/ynwconf'
        
        # CONF_DIR="$(find $BASE_DIR -type d -name "ynwconf" -print0 2>/dev/null | tr -d '\0')"
    else 
        LogFileName='/logs/jtacheck.log'
        echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/sys/kernel/osrelease check - Ubuntu" | tee -a $LogFileName
        echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] native Linux"
        MYSQL_HOST='localhost'
        CONF_DIR='/ebs/ynwconf'
        
    fi
    # cat /proc/sys/kernel/osrelease >> $LogFileName
    cat /proc/sys/kernel/osrelease | tee -a $LogFileName
    # uname -r >> $LogFileName
    # uname -a >> $LogFileName
    # if [[ $(uname -r | grep -iE 'Microsoft|Windows') ]]; then
    #     echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] uname check" >> $LogFileName
    #     echo "Bash is running on WSL" >> $LogFileName
    # else
    #     echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] uname check" >> $LogFileName
    #     echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] native Linux" >> $LogFileName
    # fi
    # cat /proc/version >> $LogFileName
    # if grep -qi microsoft /proc/version; then
    #     echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/version check" >> $LogFileName
    #     echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] Ubuntu on Windows- Windows Subsystem for Linux" >> $LogFileName
    # else
    #     echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/version check" >> $LogFileName
    #     echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] native Linux" >> $LogFileName
    # fi
    # if [[ $(lscpu | grep -iE 'Microsoft|Windows') ]]; then
    #     echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] lscpu check" >> $LogFileName
    #     echo "Bash is running on WSL" >> $LogFileName
    # else
    #     echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] lscpu check" >> $LogFileName
    #     echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] native Linux" >> $LogFileName
    # fi
    # if [[ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]]; then
    #     echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/sys/fs/binfmt_misc/WSLInterop check" >> $LogFileName
    #     echo "Windows Subsystem for Linux" >> $LogFileName
    # else
    #     echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/sys/fs/binfmt_misc/WSLInterop check" >> $LogFileName
    #     echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] native Linux" >> $LogFileName
    # fi
}

# Sets default environment to dev for develpment, jenkins for jenkins server or scale for scale server
setEnvironment()
{
    local i=1 
    if [ "$1" = "-env" ] || ["$1" = "--environment"]; then
        local j=$((i+1))
        env=${!j}
    fi
    setDefaults $env
}

# Set default input/output paths
setPaths()
{
    defaultDockerPath="$(pwd)"
    defaultInputPath="$(dirname "$defaultDockerPath")/DynamicTDD"
    defaultDataPath="$(dirname "$defaultDockerPath")/Data"
    defaultOutputPath="$defaultInputPath/Output"
    defaultSuitePath="$defaultInputPath/"
    Workspace="$(basename "$(dirname "$(dirname "$defaultDockerPath")")")"
    DB_BACKUP_PATH="$BASE_DIR/backup/dbbackup/JD/$Workspace"
    # Workspace="$(basename "$(dirname "$(dirname "$PWD")")")"
    # defaultInputPath="$(dirname "$(pwd)")/DynamicTDD"
    # defaultDockerPath="$(dirname "$(pwd)")/Docker"
}

# Set values for environment, input, output and suite variables
setPathVariables()
{
    tddEnv="${env:-$defaultEnv}"
    inputPath="${inputPath:-$defaultInputPath}"
    outputPath="${outputPath:-$defaultOutputPath}"
    suitePath="${suitePath:-$defaultSuitePath}"
    key="${key:-1}"
    parallelContainers="${parallelContainers:-$defaultParallelContainers}"
}

# Create missing paths specified as parameter
# $1 generally output of $? from ifExists
# $2 specifies whether to create dir with(1) or without(0) asking user
# $3 dir to create
createDir()
{
    if [ "$1" -eq 1 ] && [ "$2" = "0" ] && [ ! -d "$3" ]; then
        mkdir -p "$3"
        echo " Created Directory $3 "
    elif [ "$1" -eq 1 ] && [ "$2" = "1" ] && [ ! -d "$3" ]; then
        read -p "The given path does not exist. would you like to create it? (y/n): " reply
        if [ "$reply" = "y" ] || [ "$reply" = "yes" ] ;then
            mkdir -p "$3"
            echo " Created Directory $3 "
        elif [ "$reply" = "n" ] || [ "$reply" = "no" ] ;then
            echo "Directory does not exist. cannot continue."
            exit 3
        fi
    else
        return 0
    fi
}

# Set Default values based on environment selected
setDefaults()
{
    case $1 in
        dev)
            env="dev"
            setPaths
            key=1
            ;;
        jenkins)
            env="jenkins"
            setPaths
            key=2
            ;;
        test)
            env="test"
            setPaths
            key=3
            ;;
        scale)
            env="scale"
            setPaths
            key=4
            ;;
        *)
            echo "Invalid Option."
            echo "Please select between [dev | jenkins | scale]"
            exit 4
            ;;
    esac
    ifExists "$defaultInputPath"
    if [ "$?" -eq 1 ]; then
        echo "Default Input Location does not exist. Please run $0 -i for interactive session."
        exit 3
    fi
    ifExists "$defaultOutputPath"
    createDir $? 0 "$defaultOutputPath"

    tddEnv="${env:-$defaultEnv}"
    setPathVariables
    setSuite
    ifExists "$DB_BACKUP_PATH"
    createDir $? 0 "$DB_BACKUP_PATH"
    # dynSignUp="${dynSignUp:-$defaultDynSignUp}"
    # timeFlag="${timeFlag:-$defaulttimeFlag}"
    dynSignUp="yes"
    timeFlag="True"
    setCounts
}

# check if file or directory passed as parameter exists
ifExists()
{
    case "$1" in 
        "~/"*)
            locPath="${HOME}/${1#"~/"}"
    esac

    if [ -d "$1" ] || [ -f "$1" ]; then
        return 0
    elif [ -d "$locPath" ] || [ -f "$locPath" ]; then
        return 0
    else
        return 1
    fi
}

# Read what suite to run from user
readSuite()
{
    while true; do
        read -e -p "Enter Test Suite to run. [$defaultSuitePath]: " -i "$defaultSuitePath" suitePath
        suitePath="${suitePath:-$defaultSuitePath}"
        ifExists "$suitePath"
        r=$?
        if [ "$r" -eq 1 ];then
            echo "Location does not exist. Please enter an existing location."
        else
            break
        fi
    done
}

# Change default env, input and output locations and container count based on user preference
readLocation ()
{
    read -e -p "Enter Environment [$defaultEnv]: " env
    if  [ "$defaultEnv" != "$env" ] && [ "$env" != "" ] ;then
        setDefaults $env
    else
        setPaths
    fi

    while true; do
        read -e -p "Enter Input Location [$defaultInputPath]: " inputPath
        inputPath="${inputPath:-$defaultInputPath}"
        ifExists "$inputPath"
        if [ "$?" -eq 1 ];then
            echo "Location does not exist. Please enter an existing location."
        else
            break
        fi
    done

    read -e -p "Enter Output Location [$defaultOutputPath]: " outputPath
    outputPath="${outputPath:-$defaultOutputPath}"
    ifExists "$outputPath"
    if [ "$?" -eq 1 ];then
        echo "Provided Location does not exist. Creating it."
    fi
    createDir $? 1 "$outputPath"

    read -e -p "Enter Number of parallel containers [$defaultParallelContainers]: " parallelContainers
    parallelContainers="${parallelContainers:-$defaultParallelContainers}"

    readSuite
 
}

# Set default phone number and count for provider, consumer and branch
setCounts()
{
    pusercount=$defaultPUserCount
    pseries=$defaultPSeries
    cusercount=$defaultCUserCount
    cseries=$defaultCSeries
    bcount=$defaultBCount
    bseries=$defaultBSeries
}

#Set container count if -c is specified
setContainerCount()
{
    local i=1 
    if [ "$1" = "-c" ] || ["$1" = "--container-count"]
        then
            local j=$((i+1))
            parallelContainers=${!j}
        fi
    parallelContainers="${parallelContainers:-$defaultParallelContainers}"
}

# Set the suite to be run and the suite base
setSuite()
{
    suitePath="${suitePath%/}"
    suite=$(echo ${suitePath#$defaultInputPath/})
    suitebase="$(cut -d'/' -f 1 <<< ${suite})"
    # echo "suitebase= $suitebase"
}

# Set provider count and phone number if default value requires change
setProviderCount()
{
    local ok=0
    read -p "Enter number of providers required per container[$defaultPUserCount]: " pusercount
    pusercount="${pusercount:-$defaultPUserCount}"

    # while [ $ok = 0 ] && [ $pdc != 1 ]
    while [ $ok = 0 ]
    do
    read -p "Enter phone number series for provider signup [$defaultPSeries]: " pseries
    pseries="${pseries:-$defaultPSeries}"
    
    if [ ${#pseries} -gt 10 ] || [ ${#pseries} -lt 10 ]
    then
        echo "Phone number requires 10 digits"
    else
        ok=1
    fi
    done
}

# Set consumer count and phone number if default value requires change
setConsumerCount()
{
    local ok=0
    read -p "Enter number of consumers required per container[$defaultCUserCount]: " cusercount
    cusercount="${cusercount:-$defaultCUserCount}"

    # while [ $ok = 0 ] && [ $pdc != 1 ]
    while [ $ok = 0 ]
    do
    read -p "Enter phone number series for consumer signup[$defaultCSeries]: " cseries
    cseries="${cseries:-$defaultCSeries}"
    if [ ${#cseries} -gt 10 ] || [ ${#cseries} -lt 10 ]
    then
        echo "Phone number requires 10 digits"
    else
        ok=1
    fi
    done
    
}

# Set Branch count and phone number if default value requires change
setBranchCount()
{
    local ok=0
    read -p "Enter number of branches required per container[$defaultBCount]: " bcount
    bcount="${bcount:-$defaultBCount}"
    while [ $ok = 0 ]
    do
    read -p "Enter phone number series for branch signup [$defaultBSeries]: " bseries
    bseries="${bseries:-$defaultBSeries}"
    
    if [ ${#bseries} -gt 10 ] || [ ${#bseries} -lt 10 ]
    then
        echo "Phone number requires 10 digits"
    else
        ok=1
    fi
    done
}

# if suite specified is APre, check if provider, consumer or Branch signup has been specified seperately
checkSignup()
{
    if [ "$suite" == "APre/DynamicProviderSignup.robot" ]; then
        setProviderCount
        cusercount=$defaultCUserCount
        cseries=$defaultCSeries
        bcount=$defaultBCount
        bseries=$defaultBSeries

    elif [ "$suite" == "APre/Dynamic Consumer Signup.robot" ]; then
        setConsumerCount
        pusercount=$defaultPUserCount
        pseries=$defaultPSeries
        bcount=$defaultBCount
        bseries=$defaultBSeries

    elif [ "$suite" == "APre/DynamicCorporateSignUp.robot" ]; then
        setProviderCount
        setBranchCount
        cusercount=$defaultCUserCount
        cseries=$defaultCSeries
    
    elif [ "$suite" == "APre/DynamicBranchSignup.robot" ]; then
        setBranchCount
        pusercount=$defaultPUserCount
        pseries=$defaultPSeries
        cusercount=$defaultCUserCount
        cseries=$defaultCSeries

    else
        setProviderCount
        setConsumerCount
        setBranchCount
    
    fi
    clearFiles

}

# Set variable file depending on environment specified
selectVarFile ()
{
    if [ $key -eq 1 ]
    then
        echo -e "VARFILE=VariablesForLocalServer" >> $1
    elif [ $key -eq 2 ];then
        echo -e "VARFILE=VariablesForJenkins" >> $1
    elif [ $key -eq 3 ];then
        echo -e "VARFILE=VariablesForTest" >> $1
    elif [ $key -eq 4 ];then
        echo -e "VARFILE=VariablesForScale" >> $1
    fi
}

# set environment variables for docker container.
setEnvVariables ()
{
    [ -z "$2" ] && local id="01" || local id="$2"
    if [ $1 -eq 1 ]
    then
        
        echo -e "NUM_PSERIES=$pseries\nNUM_CSERIES=$cseries\nNUM_BSERIES=$bseries\nPUSER_COUNT=$pusercount\nCUSER_COUNT=$cusercount\nBRANCH_COUNT=$bcount\nP_EMAIL=$pemail\nC_EMAIL=$cemail\nB_EMAIL=$bemail\nB_SPEMAIL=$bspemail\nENV_KEY=$key\nSUITE="$suite"\nSIGN_UP=$dynSignUp\nTIMEFLAG="$timeFlag"\nFULL_RUN=$full\nMAIN=$mainres" > env$c.list
        if [ "$id" -gt "9" ];then
            echo -e "CONTAINER_ID=$id" >> env$id.list
        else
            echo -e "CONTAINER_ID=0$id" >> env$id.list
        fi
        # echo -e "CONTAINER_ID=0$c\nNUM_PSERIES=$pseries\nPUSER_COUNT=$pusercount\nNUM_CSERIES=$cseries\nCUSER_COUNT=$cusercount\nBRANCH_COUNT=$bcount\nNUM_BSERIES=$bseries\nP_EMAIL=$pemail\nC_EMAIL=$cemail\nB_EMAIL=$bemail\nB_SPEMAIL=$bspemail\nENV_KEY=$key\nSUITE="$suite"\nSIGN_UP=$dynSignUp\ntimeFlag="$timeFlag"" > env$c.list

        selectVarFile env$id.list
        
    else
        
        echo -e "NUM_PSERIES=$pseries\nNUM_CSERIES=$cseries\nNUM_BSERIES=$bseries\nPUSER_COUNT=$pusercount\nCUSER_COUNT=$cusercount\nBRANCH_COUNT=$bcount\nP_EMAIL=$defaultPemail\nC_EMAIL=$defaultCemail\nB_EMAIL=$defaultBemail\nB_SPEMAIL=$defaultBSPemail\nCONTAINER_ID=$id\nENV_KEY=$key\nSUITE="$suite"\nSIGN_UP=$dynSignUp\nTIMEFLAG="$timeFlag"\nFULL_RUN=$full\nMAIN=$mainres" > env.list
        selectVarFile env.list
    fi
    spdataimport=$(grep "spdataimport.notification.sms" /ebs/apache-tomcat-8.0.36/conf/ynwsuperadmin.properties | cut -d'=' -f2 )
    echo -e "spdataimport=${spdataimport}" > $inputPath/$VAR_DIR/properties.py

}


populatePostalCodeTable()
{
    pincount=$(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from postal_code_tbl;")
    if [ -z ${pincount} ] || [[ ${pincount}<=1 ]]; then
        # if [[ ${pincount}<=1 ]]; then
        echo "Pincode table count= '$pincount'. Pincode table not populated. Populating it using ${INPUT_PATH}/$PIN_TABLE"
        mysql -f -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} < ${inputPath}/$PIN_TABLE
        checkPincode
            
    else
        echo "Pincode table count= '$pincount'. Pincode table already populated."
    fi

}

checkPincode()
{
    pincount=$(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from postal_code_tbl;")
    if [ ! -z ${pincount} ] && (( ${pincount}>=84629 )); then
        echo "Pincode table count= '$pincount'. Pincode table populated."
    else
        echo "Populating pincode table encountered error. Please try populating manually using the command."
        echo "mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p ${DATABASE_NAME} < ${inputPath}/$PIN_TABLE"
    fi
}

populateBankMasterTable()
{
    bnkcount=$(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from bank_master_tbl;")
    if [ -z ${bnkcount} ] || [[ ${bnkcount}<=1 ]]; then
        echo "Bank master table count= '$bnkcount'. Bank master table not populated. Populating it using ${INPUT_PATH}/$BANK_TABLE"
        mysql -f -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} < ${INPUT_PATH}/$BANK_TABLE
        bnkcount=$(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from bank_master_tbl;")
        if [ ! -z ${bnkcount} ] && (( ${bnkcount}>=1310 )); then
            echo "Bank master table count= '$bnkcount'. Bank master table populated."
        else
            echo "Populating Bank master table encountered error. Please try populating manually using the command."
            echo "mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p ${DATABASE_NAME} < ${INPUT_PATH}/$BANK_TABLE"
        fi
            
    else
        echo "Bank master table count= '$bnkcount'. Bank master table already populated."
    fi

}


# Take backup of database if provider/consumer/Branch signup is required. delete database backup older than 15 days.
dbBackup ()
{
    mkdir -p "$DB_BACKUP_PATH/Log/"
    local -r MYSQL_USER='root'
    local -r DATABASE_NAME='ynw'
    local -r MYSQL_PORT='3306'
    local -r MYSQL_PASSWORD='netvarth'
    local -r TODAY=`date +"%d%b%y%H%M"`
    local -r BACKUP_RETAIN_DAYS=5
    local -r maxlogsize="`echo '1024 * 1024'|bc`"
    local -r logbackdate=`date +"%F"`
    local -r cnffile='.my.cnf'
    local -r logdate=`date +"%F %r"`
    local -r log_retain_days=2
    local -r logFileName='ynw-backup.log'
    local -r SQLFileName='Queries.sql'
    local -r PIN_TABLE='pincode_table.sql'
    local -r BANK_TABLE='bank_master_tbl.sql'
    local -r BACKUP_FILE="${DATABASE_NAME}autobk-${TODAY}.sql"
    INPUT_PATH="${INPUT_PATH:-$defaultInputPath}"


    if [ ! -e "$HOME/$cnffile" ]; then
        touch "$HOME/$cnffile" 
        cat > "$HOME/$cnffile" << eof
        [client]
        user="$MYSQL_USER"
        password="$MYSQL_PASSWORD"
eof
    fi

    #Populate the postal code table
    populatePostalCodeTable

    #Populate the Bank Master Table
    populateBankMasterTable
    
    #Run queries from Queries.sql
    # mysql -fv -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} < ${inputPath}/$SQLFileName
    # mysql -f -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} < ${inputPath}/$SQLFileName

    echo -e "\nLogging Database Data before backup in - $DB_BACKUP_PATH/Log/$logFileName"
    echo -e "\n------------------------------------------------------------------------------$logdate------------------------------------------------------------------------------------\n" >> "$DB_BACKUP_PATH/Log/$logFileName"
    for i in $(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} ${DATABASE_NAME} -e 'SHOW TABLES' | grep -v "Tables_in" | awk '{print $1}'); do echo "TABLE: $i"; mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} ${DATABASE_NAME} -e "show create table $i"; echo -e "\n"; done >> "$DB_BACKUP_PATH/Log/$logFileName"
    echo -e "\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n" >> "$DB_BACKUP_PATH/Log/$logFileName"

    echo -e "\nBacking up Database to - $DB_BACKUP_PATH/${DATABASE_NAME}-${TODAY}.sql"
    mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} --add-drop-database --databases ${DATABASE_NAME} --result-file="$DB_BACKUP_PATH/${BACKUP_FILE}" 
    if [ $? -eq 0 ]; then
        echo "Database backup completed successfully"
    else
        echo "Error found during backup"
        exit 5
    fi

    if [ ! -z "$DB_BACKUP_PATH" ]; then
        backup_file_count=$(find "$DB_BACKUP_PATH" -mindepth 1 -type f -mtime +${BACKUP_RETAIN_DAYS} -print | wc -l)
        if [[ $backup_file_count -gt 0 ]]; then
            echo -e "\n $backup_file_count Backup files older than ${BACKUP_RETAIN_DAYS} days found. Deleting them.\n"
            find "$DB_BACKUP_PATH" -mindepth 1 -type f -mtime +${BACKUP_RETAIN_DAYS} -print -delete
        else
            echo -e "\nNo backup files older than ${BACKUP_RETAIN_DAYS} days found.\n"
        fi
    fi
    
    for file in "$DB_BACKUP_PATH/Log"/*; do
    if [ -f "$file" ]; then
        filename=$(echo ${file#$DB_BACKUP_PATH/Log/})
        if [ "$filename" = "$logFileName" ]; then
            logfilesize=$(stat -c%s "$file")
            if [ ${logfilesize} -gt ${maxlogsize} ]; then
                mv "$file" "$file-$logbackdate"
                touch "$file"
            fi
        fi
    fi
    done

    numfiles=$(ls -l "$DB_BACKUP_PATH/Log/${logFileName}"* | wc -l)
    if [ $numfiles -ge 2 ]; then
        log_file_count=$(find "$DB_BACKUP_PATH/Log" -name "${logFileName}"* -mindepth 1 -type f -mtime +${log_retain_days} -print | wc -l)
        if [[ $log_file_count -gt 0 ]]; then
            echo -e "\n $log_file_count Backup Log files older than ${log_retain_days} days found. Deleting them.\n"
            find "$DB_BACKUP_PATH/Log" -name "${logFileName}"* -mindepth 1 -type f -mtime +${log_retain_days} -print -delete
        else
            echo -e "\nNo backup log files older than ${log_retain_days} days found.\n"
        fi

    fi
}

# Set host user and ip as environment variable for docker container
setUserAndIP()
{
    local -r user="${SUDO_USER:-$USER}"
    local -r hostip=$(hostname  -I | cut -f1 -d' ')
    if [ $1 -eq 1 ]
    then
    echo -e "USERNAME=$user\nIP_ADDRESS=$hostip\nSSHPASS=$userpass" >> env$c.list
    else
    echo -e "USERNAME=$user\nIP_ADDRESS=$hostip\nSSHPASS=$userpass" >> env.list
    fi
}

# Turn date and time sync with ntp server off, if parameter passed is 0 and on, if parameter passed is 1
setDateTimeSync()
{
    is_installed="$(which sshd)"
    if [ -z "$is_installed" ]; then
        echo -e "openssh-server not installed. Please install it using the command: \n sudo apt install openssh-server"
        exit 6
    fi

    status="$(timedatectl status | grep systemd-timesyncd.service | cut -d" " -f3)"
    # echo "systemd-timesyncd.service status= $status"
    if [ -z "$status" ]; then
        status="$(timedatectl status | grep 'NTP\ service' | awk -F " " '{print $3}')"
    fi
    if [ $key -eq 1 ] && [ "$timeFlag" == "True" ] && [[ "$status" == "yes" || "$status" == "active" ]] && [ "$1" == "0" ]
    then
        timedatectl set-ntp 0
    elif [ $key -eq 1 ] && [[ "$status" == "no" || "$status" == "inactive" ]] && [ "$1" == "1" ] ;then
        timedatectl set-ntp 1
    elif [ $key -eq 2 ];then
        echo -e "Time and Date change not set for Jenkins environment"
    elif [ $key -eq 3 ];then
        echo -e "Time and Date change not set for Test environment"
    elif [ $key -eq 4 ];then
        echo -e "Time and Date change not set for Scale environment"
    fi
}

clearFiles()
{
    # echo -n "" > "$inputPath/$PAN_FILE"
    # echo -n "" > "$inputPath/$TIME_FILE"
    echo -n > "$inputPath/$PAN_FILE"
    echo -n > "$inputPath/$TIME_FILE"
}


variablelogs()
{
    # echo $#
    if [ "$#" -eq 3 ]; then
        local l="$3"
    fi
    echo -e "------Docker Mapping------\n"> docker-variables$l.log
    echo -e "network=host\n/ebs/ynwconf=$CONF_DIR\n/ebs/TDD=$1\n/ebs/TDD/varfiles=$1/varfiles/$l\n/ebs/TDD_Output=$2\nenv-file=env$l.list" >> docker-variables$l.log
    echo -e "\n------Variables------">> docker-variables$l.log
    echo -e "\ntimeFlag=$timeFlag\ndynSignUp=$dynSignUp">> docker-variables$l.log
    echo -e "\ninputPath=$1\noutputPath=$2\ndockerPath=$defaultDockerPath">> docker-variables$l.log
    echo -e "\nBASE_DIR=$BASE_DIR\n">> docker-variables$l.log
    echo -e "\nproperty file=$inputPath/$VAR_DIR/properties.py" >>docker-variables$l.log
}



#-------------------Main Body--------------------------------------

# Check if this script is being invoked with sudo command.
if [[ $EUID -eq 0 ]]; then
    echo -e "\nPlease run this script without sudo\n"
    echo -e "Eg: $0 \n"
    exit 1
fi

# If no parameters are passed with this script show usage.
if [ "$*" = ""  ]; then
    usage
    exit 2
fi

# check if --APre and --noAPre parameters are used together.
checkInputArgs $@
checkSysType


# set default values passed as parameters from command line with this script
while [ "$1" != "" ]; do 
    case $1 in
        "-env" | "--environment" ) 
                setEnvironment $@
                shift
                full="True"
                echo "Environment set as $env. Using all default values for $env environment"
            ;;
        "-c" | "--container-count")
                setContainerCount $@
                shift
                echo "Number of parallel containers set to $defaultParallelContainers"
            ;;
        "-na" | "--noAPre")
                dynSignUp="no"
                shift
                echo "APre Flag set as no. APre wont run."
            ;;
        "--APre" | "--apre")
                suite="APre"
                setPaths
                setPathVariables
                setCounts
                dbBackup
                clearFiles
                shift
                echo "Run APre."
            ;;
        "--TDDSE")
                suite="TDDSE"
                setPaths
                setPathVariables
                shift
                echo "Run TDDSE."
            ;;
        "--SA")
                suite="SA"
                setPaths
                setPathVariables
                shift
                echo "Run SA."
            ;;
        "--Time")
                suite="Time"
                setPaths
                setPathVariables
                timeFlag="True"
                shift
                echo "Run Time."
            ;;
        "--Basics" | "--basics")
                suite="Basics"
                setPaths
                setPathVariables
                shift
                echo "Run Basics."
            ;;
        "--JBQueue" | "--jbqueue")
                suite="JBQueue"
                setPaths
                setPathVariables
                shift
                echo "Run JBQueue."
            ;;
        "--JBAppointment" | "--jbappointment")
                suite="JBAppointment"
                setPaths
                setPathVariables
                shift
                echo "Run JBAppointment."
            ;;
        "--JBOrder" | "--jborder")
                suite="JBOrder"
                setPaths
                setPathVariables
                shift
                echo "Run JBOrder."
            ;;
        "--LendingCRM" | "--lendingcrm")
                suite="LendingCRM"
                setPaths
                setPathVariables
                shift
                echo "Run LendingCRM."
            ;;
        "--JaldeePay" | "--jaldeepay")
                suite="JaldeePay"
                setPaths
                setPathVariables
                shift
                echo "Run JaldeePay."
            ;;
        "--JCloudAPI" | "--jcloudapi")
                suite="JCloudAPI"
                setPaths
                setPathVariables
                shift
                echo "Run JCloudAPI."
            ;;
        "--Communications" | "--communications" | "--comms")
                suite="Communications"
                setPaths
                setPathVariables
                shift
                echo "Run Communications."
            ;;
        "--Reports" | "--reports")
                suite="Reports"
                setPaths
                setPathVariables
                shift
                echo "Run Reports."
            ;;
        "--Analytics" | "--analytics")
                suite="Analytics"
                setPaths
                setPathVariables
                shift
                echo "Run Analytics."
            ;;
        "-i" | "--interactive" )    
                interactive=1
                full="False"
                echo "----------------------------------------------------------------------"
                echo -e "\t\t\tInteractive Mode"
                echo "----------------------------------------------------------------------"
            ;;
        "-cpu" ) 
                setPaths
                setPathVariables
                mainres="True"
                shift
                echo "Running Basics, Bookings, CRM, JPay, Comms & Reports Resources."
            ;;
        "--Provider" | "--provider")
                suite="Provider"
                setPaths
                setPathVariables
                shift
                echo "Run Provider."
            ;;
        "--Consumer" | "--consumer")
                suite="Consumer"
                setPaths
                setPathVariables
                shift
                echo "Run Consumer."
            ;;
        "--User" | "--user")
                suite="User"
                setPaths
                setPathVariables
                shift
                echo "Run User."
            ;;
        "--Partner" | "--partner")
                suite="Partner"
                setPaths
                setPathVariables
                shift
                echo "Run Partner."
            ;;
        "-h" | "--help" )           
                usage
                exit 2
            ;;
        * )                     
                usage
                exit 2
            ;;
    esac
    shift
done


# if one of the command line parameters passed is -i, this portion will run.
if  [ "$interactive" == 1 ]; then
    setPaths
    setPathVariables
    while true; do
        echo "The default environment is $tddEnv ."
        read -e -p "would you like to change default environment values?[yes/no]: " -i "no" ans
        ans=$(echo $ans | tr '[:upper:]' '[:lower:]')
        if [ "$ans" == "y" ] || [ "$ans" == "yes" ];then
            readLocation
            break
        elif [ "$ans" == "n" ] || [ "$ans" == "no" ]; then
            readSuite
            break
        else
            echo "Please provide your answer as yes or no"
        fi
    done
    setSuite
    
    if [ "$suitebase" != "APre" ] ; then
        read -e -p "Run dynamic provider and consumer signup?[$defaultDynSignUp]: " -i "no" dynSignUp
        dynSignUp="${dynSignUp:-$defaultDynSignUp}"
        dynSignUp=$(echo $dynSignUp | tr '[:upper:]' '[:lower:]')
        timeFlag="${timeFlag:-$defaulttimeFlag}"
    elif [ "$suitebase" == "APre" ]; then
        dynSignUp="yes"
        timeFlag="${timeFlag:-$defaulttimeFlag}"
    elif [ "$suitebase" == "Time" ]; then
        timeFlag="True"
        dynSignUp="${dynSignUp:-$defaultDynSignUp}"
    fi
    
    if  [ "$dynSignUp" == "yes" ]; then
        read -e -p "would you like to change default count/phone numbers?[yes/no]: " -i "no" ans
        ans=$(echo $ans | tr '[:upper:]' '[:lower:]')
        if [ "$ans" == "y" ] || [ "$ans" == "yes" ];then
            checkSignup
            # break
        elif [ "$ans" == "n" ] || [ "$ans" == "no" ]; then
            setCounts
            # break
        else
            echo "Please provide your answer as yes or no"
        fi
        # echo "Runs dbbackup and clearfiles here"
        dbBackup
        clearFiles   
    else
        setCounts
    fi
    
else
    setCounts
    # echo "Runs dbbackup and clearfiles here"
    if  [ "$dynSignUp" == "yes" ]; then
        dbBackup
    fi
    clearFiles
fi

# If parallel containers count specified is more than 1, then run multiple containers.
if [ "$parallelContainers" -gt "1" ]; then
    
    c=00
    while [ "$c" -lt "$parallelContainers" ]
    do
        ((c = c + 01))
        newoutputPath="${outputPath%/}/$c"
        createDir 1 0 "$newoutputPath"
        createDir 1 0 "$inputPath/$VAR_DIR/$c"
        if [ $c != 1 ]
        then 
            timeFlag="False"
        fi

        ((pseries = pseries + 10000))
        ((cseries = cseries + 10000))
        ((bseries = bseries + 10000))
        pemail="d$c""_p"
        cemail="d$c""_c"
        bemail="d$c""_b"
        bspemail="d$c""_bsp"
        setEnvVariables 1 "$c"
        setUserAndIP 1
        variablelogs "$inputPath" "$newoutputPath" "$c"

        if [[ "$(< /proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ]]; then 
            echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/sys/kernel/osrelease check - WSL" >> $LogFileName
            echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] Ubuntu on Windows- Windows Subsystem for Linux"
            winInputPath=$(wslpath -w "$inputPath")
            winOutputPath=$(wslpath -w "$newoutputPath")
            winDockerPath=$(wslpath -w "$defaultDockerPath")
            winDataPath="$(wslpath -w "$defaultDataPath")"
            winConfPath=$(wslpath -w "$CONF_DIR")
            echo -e "SYSTEM_ENV=Microsoft WSL" >> env$c.list
            time docker run --rm --network="host" -v $winConfPath:/ebs/ynwconf -v "$winInputPath:/ebs/TDD" -v "$winInputPath/$VAR_DIR/$c:/ebs/TDD/varfiles" -v "$winOutputPath:/ebs/TDD_Output" -v "$winDockerPath/config:/ebs/conf" -v "$winDataPath/$c:/ebs/data" -u $(id -u ${USER}):$(id -g ${USER}) --env-file env$c.list jaldeetdd &
            
        else 
            echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/sys/kernel/osrelease check - Ubuntu" >> $LogFileName
            echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] native Linux"
            echo -e "SYSTEM_ENV=LINUX" >> env$c.list
            time docker run --rm --network="host" -v $CONF_DIR:/ebs/ynwconf -v "$inputPath:/ebs/TDD" -v "$inputPath/$VAR_DIR/$c:/ebs/TDD/varfiles" -v "$newoutputPath:/ebs/TDD_Output" -v "$defaultDockerPath/config:/ebs/conf" -v "$defaultDataPath/$c:/ebs/data" -u $(id -u ${USER}):$(id -g ${USER}) --env-file env$c.list jaldeetdd &
        fi
        
    done
    
    cnum=$(docker ps --filter "status=running" | wc -l)
    cnum=$(($cnum + 0))
    while [ $cnum -gt 2 ]
    do
        cnum=$(docker ps --filter "status=running" | wc -l)
        sleep 30s
    done
    setDateTimeSync 0
    while [ $cnum -gt 1 ]
    do
        cnum=$(docker ps --filter "status=running" | wc -l)
        sleep 20s
    done
    setDateTimeSync 1
    echo "" > "$inputPath/$TIME_FILE"
    
else
    createDir 1 0 "$outputPath"
    createDir 1 0 "$inputPath/$VAR_DIR/"
    createDir 1 0 "$inputPath/$VAR_DIR/"
    if  [ "$timeFlag" == "True" ]; then
        setDateTimeSync 0
        echo "Ready" > "$inputPath/$TIME_FILE"
    fi
    setEnvVariables 0
    setUserAndIP 0
    variablelogs "$inputPath" "$outputPath"
    if [[ "$(< /proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ]]; then 
        echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/sys/kernel/osrelease check - WSL" >> $LogFileName
        echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] Ubuntu on Windows- Windows Subsystem for Linux"
        echo -e "SYSTEM_ENV=Microsoft WSL" >> env.list
        time docker run --rm --network="host" -v "${CONF_DIR}:/ebs/ynwconf/:ro" -v "${inputPath}:/ebs/TDD"  -v "${inputPath}/$VAR_DIR:/ebs/TDD/varfiles" -v "$outputPath:/ebs/TDD_Output" -v "${defaultDockerPath}/config:/ebs/conf:ro" -v "$defaultDataPath:/ebs/data" -u $(id -u ${USER}):$(id -g ${USER}) --env-file env.list jaldeetdd
        # setDateTimeSync 1
        # echo -n > "$inputPath/$TIME_FILE"
    else 
        echo  "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] /proc/sys/kernel/osrelease check - Ubuntu" >> $LogFileName
        echo "[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO] native Linux"
        echo -e "SYSTEM_ENV=LINUX" >> env.list
        time docker run --rm --network="host" -v $CONF_DIR:/ebs/ynwconf/:ro -v "$inputPath:/ebs/TDD"  -v "$inputPath/$VAR_DIR:/ebs/TDD/varfiles" -v "$outputPath:/ebs/TDD_Output" -v "$defaultDockerPath/config:/ebs/conf:ro" -v "$defaultDataPath:/ebs/data" -u $(id -u ${USER}):$(id -g ${USER}) --env-file env.list jaldeetdd   
        # setDateTimeSync 1
        # echo -n > "$inputPath/$TIME_FILE"
    fi
    setDateTimeSync 1
    echo -n > "$inputPath/$TIME_FILE"

fi