#!/bin/bash

# set -vx      # uncomment to enable debugging
# PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
# set -x

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
defSQLFileName='sql-files/Queries.sql'
PROPERTY_FILE='docker-variables.log'
PROP_KEY='inputPath'
INPUT_PATH=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2-`
INPUT_PATH="${INPUT_PATH:-$DEFAULT_INPUT_PATH}"
ynwdir="$(dirname "$PWD")"
PIN_TABLE='sql-files/postal_code_tbl.sql'
BANK_TABLE='sql-files/bank_master_tbl.sql'
BACKUP_FILE="${BACKUP_NAME}-${TODAY}.sql"
SECONDS=0
myversion=$(mysql -h ${MYSQL_HOST} -se "select @@version;")
TDD_CustomLogs_Path="$(dirname "$PWD")/Data/TDD_Logs/"
TDD_Output_path="$(dirname "$(pwd)")/DynamicTDD/Output/"




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
            
        done < <(find "$ynwdir" -wholename "*/$1" -print0)
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
                echo "Populating Database using backup- ${latest}. Please wait"
                
                # mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -e 'ALTER INSTANCE DISABLE INNODB REDO_LOG;'
                if [[ $myversion == 5.7.* ]]; then
                    echo "mysql $myversion"
                    time mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} --compress ${DATABASE_NAME}  < ${latest}
                elif [[ $myversion == 8.* ]]; then
                    echo "mysql $myversion"
                    # time mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} --compression-algorithms=zstd --zstd-compression-level=7 --init-command='ALTER INSTANCE DISABLE INNODB REDO_LOG; SET SESSION FOREIGN_KEY_CHECKS=0;SET UNIQUE_CHECKS=0;' ${DATABASE_NAME} < ${latest}
                    time mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} --compression-algorithms=zstd --zstd-compression-level=7 --init-command='ALTER INSTANCE DISABLE INNODB REDO_LOG;SET SESSION FOREIGN_KEY_CHECKS=0;SET UNIQUE_CHECKS=0;' ${DATABASE_NAME} < ${latest}
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
    
    if [ ! -d "$DB_BACKUP_PATH" ]; then
        echo "$DB_BACKUP_PATH does not exist. Creating it."
        mkdir -p "$DB_BACKUP_PATH"
    fi
    
    createconf
    # createPrePostSqlFiles
    echo -e "\nBacking up Database to - $DB_BACKUP_PATH/${BACKUP_NAME}-${TODAY}.sql"
    time mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} --add-drop-database --opt --databases ${DATABASE_NAME} --result-file="$DB_BACKUP_PATH/${BACKUP_FILE}"
    # cat $DB_BACKUP_PATH/pre.sql $DB_BACKUP_PATH/$BACKUP_FILE $DB_BACKUP_PATH/post.sql > "${DB_BACKUP_PATH}/prepost-${BACKUP_FILE}"
    
    ##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####
    echo -e "\nDeleting backup files older than ${BACKUP_RETAIN_DAYS} days, if exists."
    find "$DB_BACKUP_PATH" -mindepth 1 -type f -mtime +${BACKUP_RETAIN_DAYS} -print -delete
}


checkPincode()
{
    pincount=$(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from postal_code_tbl;")
    if [ ! -z ${pincount} ] && (( ${pincount}>=84629 )); then
        echo "postal_code_tbl count= '$pincount'. postal_code_tbl populated."
    else
        echo "Populating postal_code_tbl encountered error. Please try populating manually using the command."
        echo "mysql -u root -p ${DATABASE_NAME} < ${INPUT_PATH}/$PIN_TABLE"
    fi
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

populateBankMasterTable()
{
    bnkcount=$(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from bank_master_tbl;")
    if [ -z ${bnkcount} ] || [[ ${bnkcount}<=1 ]]; then
        echo "bank_master_tbl count= '$bnkcount'. bank_master_tbl not populated. Populating it using ${INPUT_PATH}/$BANK_TABLE"
        time mysql -f -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} < ${INPUT_PATH}/$BANK_TABLE
        bnkcount=$(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} ${DATABASE_NAME} -se "select count(*) from bank_master_tbl;")
        if [ ! -z ${bnkcount} ] && (( ${bnkcount}>=1310 )); then
            echo "bank_master_tbl count= '$bnkcount'. bank_master_tbl populated."
        else
            echo "Populating bank_master_tbl encountered error. Please try populating manually using the command."
            echo "mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} -u ${MYSQL_USER} -p ${DATABASE_NAME} < ${INPUT_PATH}/$BANK_TABLE"
        fi
            
    else
        echo "bank_master_tbl count= '$bnkcount'. bank_master_tbl already populated."
    fi
}

executeInitialQueries() 
{
    INITIAL_QUERIES="sql-files/initial.sql"  # Set your initial queries file here
    # DATABASE_NAME="ynw"

    # Check if account_tbl is empty
    table_count=$(mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -D "$DATABASE_NAME" -se "SELECT COUNT(*) FROM account_tbl;")

    if [ "$table_count" -eq 0 ]; then
        echo "account_tbl is empty. Executing Queries from ${INPUT_PATH}/$INITIAL_QUERIES."
        if [ -s ${INPUT_PATH}/$INITIAL_QUERIES ]; then
            mysql -f -h $MYSQL_HOST -u ${MYSQL_USER} ${DATABASE_NAME} < ${INPUT_PATH}/$INITIAL_QUERIES
            echo "Queries from ${INPUT_PATH}/$INITIAL_QUERIES executed."
        else
            echo "${INPUT_PATH}/$INITIAL_QUERIES is empty. No initial queries to execute."
        fi
    else
        echo "account_tbl is not empty. No action taken."
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
    # for file in "${TDD_CustomLogs_Path%/}/"*; do echo "Clearing file $(basename $file)"; >$file; done
    for file in "${TDD_CustomLogs_Path%/}/"*; do
        # if [ -s $file ]; then
        if [ "$(basename "$file")" != "aprenumbers.txt" ] && [ -s "$file" ]; then
            echo "Clearing file $(basename $file)"
            >$file
        fi
    done
}


clearTddLogs()
{
    echo "-- clearing logs older than $BACKUP_RETAIN_DAYS days from DynamicTDD/Output" 
    find "$TDD_Output_path" -mtime +$BACKUP_RETAIN_DAYS -type f -print -delete
    find "$TDD_Output_path" -depth  -mtime $BACKUP_RETAIN_DAYS -type f -print -delete
    find "$TDD_Output_path" -mindepth 1 -depth -type d -empty -print -delete
    # find "$TDD_Output_path" -mtime $BACKUP_RETAIN_DAYS -type f -depth -print -delete && find "$TDD_Output_path" -mindepth 1 -depth -type d -empty -print -delete
    
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
            echo "Current time : $(date +"%r")"
            read -p "Would you like to proceed with creating a backup? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                echo -e "\n Checking account_tbl..."
                executeInitialQueries
                echo -e "\n Checking Pincode table..."
                populatePostalCodeTable
                echo -e "\n Checking bank_master_tbl..."
                populateBankMasterTable
                # echo ""
                backup
                clearTddLogs
            else
                echo "Backup operation aborted. To create a backup, rerun the script with $0 --backup and enter 'y' at the prompt."
            fi
            shift
            ;;
    "-p" | "--populate" )
            echo "clearing Redis."
            echo "Current time : $(date +"%r")"
            redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} flushall
            populate
            # populatePostalCodeTable
            # populateBankMasterTable
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


