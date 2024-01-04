#!/bin/bash

# set -vx      # uncomment to enable debugging
# PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
# set -x

# MYSQL_HOST='localhost'
# uname -r
# cat /proc/version
# if grep -qi microsoft /proc/version; then
#   echo "Ubuntu on Windows"
# else
#   echo "native Linux"
# fi
# cat /proc/sys/kernel/osrelease
if [[ "$(< /proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ]]; then 
    echo "Ubuntu on Windows"
	# host_ip=$(cat /etc/resolv.conf| grep nameserver | cut -d " " -f 2)
    MYSQL_HOST="$(hostname).local"
    REDIS_HOST="$(cat /etc/resolv.conf| grep nameserver | cut -d " " -f 2)"
    
else 
    echo "native Linux"
    MYSQL_HOST='localhost'
    REDIS_HOST='127.0.0.1'
fi
MYSQL_PORT='3306'
MYSQL_USER='root'
DATABASE_NAME='ynw'
MYSQL_PASSWORD='netvarth'
REDIS_PORT='6379'
Workspace="$(basename "$(dirname "$(dirname "$PWD")")")"
DB_BACKUP_PATH="$(dirname "${PWD%*/*/*}")/backup/tddDB/JD/$Workspace"
readonly DB_BACKUP_PATH MYSQL_PORT MYSQL_USER DATABASE_NAME MYSQL_PASSWORD
TODAY=`date +"%d%b%y%H%M"`
BACKUP_RETAIN_DAYS=10
BACKUP_NAME="populated${DATABASE_NAME}"
cnffile='.my.cnf'
DEFAULT_INPUT_PATH="$(dirname "$(pwd)")/DynamicTDD"
defSQLFileName='Queries.sql'
PROPERTY_FILE='docker-variables.log'
PROP_KEY='inputPath'
INPUT_PATH=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2-`
INPUT_PATH="${INPUT_PATH:-$DEFAULT_INPUT_PATH}"
ynwdir="$(dirname "$PWD")"
PIN_TABLE='pincode_table.sql'
BANK_TABLE='bank_master_tbl.sql'
BACKUP_FILE="${BACKUP_NAME}-${TODAY}.sql"
SECONDS=0
myversion=$(mysql -h ${MYSQL_HOST} -se "select @@version;")
TDD_Logs_Path='$(dirname "$PWD")/DynamicTDD/TDD_Logs/'



usage()
{
    echo -e "usage:\n"
    echo -e "To backup populated database:\n"
    echo -e "$0 -b \n\n"
    echo -e "To populate the database:\n"
    echo -e "$0 -p"
}

createconf()
{
  if [ ! -e "$HOME/$cnffile" ]; then
        touch "$HOME/$cnffile" 
        cat > "$HOME/$cnffile" << eof
        [client]
        user="$MYSQL_USER"
        password="$MYSQL_PASSWORD"
eof
    fi
}

findsqlfile()
{
    if [ "${1: -4}" == ".sql" ]; then
        while IFS= read -r -d '' file; do
            # single filename is in $file
            # echo "$file"
            SQL_FILE="$file"
            
        done < <(find "$ynwdir" -name "$1" -print0)
    else
        echo "Please specify a sql file as your 2nd argument."
    fi
}

populate()
{
    if [ -d "$DB_BACKUP_PATH" ]; then
        if [ "$(ls -A $DB_BACKUP_PATH)" ]; then
            for file in "$DB_BACKUP_PATH"/*; do
                [[ $file -nt $latest && $file != "$DB_BACKUP_PATH"/pre.sql && $file != "$DB_BACKUP_PATH"/post.sql && $file == *.sql ]] && latest=$file
            done
            # latest_file=$(echo ${latest#$DB_BACKUP_PATH/})
            if [ -a "${latest}" ]; then
                createconf
                # echo "Dropping Database ${DATABASE_NAME}."
                # mysql -se "drop database $DATABASE_NAME ;"
                # echo "Creating Database ${DATABASE_NAME}."
                # mysql -se "create database $DATABASE_NAME ;"
                echo "Populating Database using backup- ${latest}. Please wait"
                # time mysql --compress --max_allowed_packet=32M ${DATABASE_NAME} < ${latest}
                # mysql --compress --max_allowed_packet=32M ${DATABASE_NAME} < ${latest}
                # mysql --compress --max_allowed_packet=1G < ${latest}
                # time mysql --compression-algorithms=zstd --zstd-compression-level=7 ${DATABASE_NAME} < ${latest}
                if [[ $myversion == 5.7.* ]]; then
                    echo "mysql $myversion"
                    time mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} --compress ${DATABASE_NAME} < ${latest}
                elif [[ $myversion == 8.0.* ]]; then
                    echo "mysql $myversion"
                    time mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} --compression-algorithms=zstd --zstd-compression-level=7 ${DATABASE_NAME} < ${latest}
                fi
                # cat pre.sql ${latest} post.sql | mysql --max_allowed_packet=16M ${DATABASE_NAME}
                echo "done"
            else
                echo "$latest does not exist."
            fi
        else
        echo "Empty directory $DB_BACKUP_PATH. Please run, $0 , with the -b or --backup option after populating database to take a backup."
        usage
        fi
    else
        echo "$DB_BACKUP_PATH does not exist. Please run, $0 , with the -b or --backup option after populating database to take a backup."
    fi
}

backup()
{
    # mysql -fv -u ${MYSQL_USER} ${DATABASE_NAME} < $SQL_FILE
    # mysql -f -u ${MYSQL_USER} ${DATABASE_NAME} < $SQL_FILE
    
    if [ ! -d "$DB_BACKUP_PATH" ]; then
        echo "$DB_BACKUP_PATH does not exist. Creating it."
        mkdir -p "$DB_BACKUP_PATH"
    fi
    
    createconf
    # createPrePostSqlFiles
    echo -e "\nBacking up Database to - $DB_BACKUP_PATH/${BACKUP_NAME}-${TODAY}.sql"
    # mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} --disable-keys  --quick --databases ${DATABASE_NAME} > "${DB_BACKUP_PATH}/${BACKUP_FILE}"
    # mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} --no-autocommit --skip-add-locks --disable-keys --add-drop-database --skip-add-drop-table --quick --dump-date --databases ${DATABASE_NAME} --result-file="${DB_BACKUP_PATH}/${BACKUP_FILE}"
    # mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} --opt --no-autocommit --databases ${DATABASE_NAME} --result-file="${DB_BACKUP_PATH}/${BACKUP_FILE}"
    # mysqlpump --databases ${DATABASE_NAME} --result-file="${DB_BACKUP_PATH}/${BACKUP_FILE}"
    mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} --opt --databases ${DATABASE_NAME} --result-file="$DB_BACKUP_PATH/${BACKUP_FILE}"
    # cat $DB_BACKUP_PATH/pre.sql $DB_BACKUP_PATH/$BACKUP_FILE $DB_BACKUP_PATH/post.sql > "${DB_BACKUP_PATH}/prepost-${BACKUP_FILE}"
    
    ##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####
    echo -e "\nDeleting backup files older than ${BACKUP_RETAIN_DAYS} days, if exists."
    find "$DB_BACKUP_PATH" -mindepth 1 -type f -mtime +${BACKUP_RETAIN_DAYS} -print -delete
}

populatePostalCodeTable()
{
    pincount=$(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from postal_code_tbl;")
    if [ -z ${pincount} ] || [[ ${pincount}<=1 ]]; then
        echo "Pincode table count= '$pincount'. Pincode table not populated. Populating it using ${INPUT_PATH}/$PIN_TABLE"
        mysql -f -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} < ${INPUT_PATH}/$PIN_TABLE
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
        echo "mysql -u root -p ${DATABASE_NAME} < ${INPUT_PATH}/$PIN_TABLE"
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

createPrePostSqlFiles()
{
    if [ ! -e "$DB_BACKUP_PATH/pre.sql" ]; then
        touch "$DB_BACKUP_PATH/pre.sql" 
        cat > "$DB_BACKUP_PATH/pre.sql" << eof
        SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, AUTOCOMMIT = 0;
        SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS = 0;
        SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;
eof
    else 
        touch "$DB_BACKUP_PATH/pre.sql"
    fi
    if [ ! -e "$DB_BACKUP_PATH/post.sql" ]; then
        touch "$DB_BACKUP_PATH/post.sql" 
        cat > "$DB_BACKUP_PATH/post.sql" << eof
        SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
        SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
        SET AUTOCOMMIT = @OLD_AUTOCOMMIT;
        COMMIT;
eof
    else 
        touch "$DB_BACKUP_PATH/post.sql"
    fi
}

clearfiles()
{
    for file in "${TDD_Logs_Path%/}/"*; do >$file; done
}


# Check if this script is being invoked with sudo command.
if [[ $EUID -eq 0 ]]; then
    echo -e "\nPlease run this script without sudo\n"
    echo -e "Eg: $0 \n"
    exit 1
fi

# echo $#

if [ $# -lt 2 ]; then
    findsqlfile $defSQLFileName
elif [ $# -eq 2 ]; then
    findsqlfile $2
fi

# SQL_FILE="${SQL_FILE:-$defSQLFileName}"
# echo "SQL file specified is $SQL_FILE"

# if [ "$1" != "" ]; then
case $1 in
    "-b" | "--backup" )
            now=$(date +"%r")
            echo "Current time : $now"
            populatePostalCodeTable
            populateBankMasterTable
            backup
            shift
            ;;
    "-p" | "--populate" )
            echo "clearing Redis."
            now=$(date +"%r")
            echo "Current time : $now"
            redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} flushall
            populate
            populatePostalCodeTable
            populateBankMasterTable
            echo "clearing files in TDD_Logs."
            clearfiles
            shift
            ;;
    * )                     
            usage
            exit 1
            ;;
esac
shift

# fi

# echo "Time is $SECONDS"
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."


