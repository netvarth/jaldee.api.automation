#!/bin/bash
#title          :cleardb.sh
#description    :This script drops the ynw database and then restores it from a backup .sql file
#author         :Archana Gopi
#usage          :./cleardb.sh

# set -x
# PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

if [[ "$(< /proc/sys/kernel/osrelease)" == *Microsoft ]]; then 
    echo "Ubuntu on Windows"
    MYSQL_HOST='127.0.0.1'
    REDIS_HOST='127.0.0.1'
    
else 
    echo "native Linux"
    MYSQL_HOST='localhost'
    REDIS_HOST='127.0.0.1'
fi

Workspace="$(basename "$(dirname "$(dirname "$PWD")")")"
default_BACKUP_PATH="$(dirname "${PWD%*/*/*}")/backup/dbbackup/JD/$Workspace"
# MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='root'
DefaultDB_NAME='ynw'
TODAY=`date +"%d%b%y%H%M"`
MYSQL_PASSWORD='netvarth'
readonly  default_BACKUP_PATH MYSQL_HOST MYSQL_PORT MYSQL_USER DefaultDB_NAME MYSQL_PASSWORD
INPUT_LOC="$(dirname "$PWD")/DynamicTDD"
NUM_FILE='numbers.txt'
PAN_FILE='pan.txt'
TIME_FILE='time.txt'
VAR_DIR='varfiles'
CUR_LOC="$(pwd)"
ENV_FILES="env*.list"
maxlogsize="`echo '1024 * 1024'|bc`"
# maxlogsize="141258"
logbackdate=`date +"%F"`
cnffile='.my.cnf'
logdate=`date +"%F %r"`
log_retain_days=5
preLogFileName='ynw-preRestore.log'
postLogFileName='ynw-postRestore.log'
SECONDS=0
myversion=$(mysql -h ${MYSQL_HOST} -se "select @@version;")



usage()
{
    echo -e "usage:\n"
    echo -e "To display this information:\n"
    echo -e "$0 -h | $0 --help \n\n"
    echo -e "To backup database:\n"
    echo -e "$0 -b | $0 --backup \n\n"
    echo -e "To clear database:\n"
    echo -e "$0"
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

archiveAndDeleteLog()
{
  DB_BACKUP_PATH="$1"
  dlfiles=$(ls -l "${DB_BACKUP_PATH}/Log/${preLogFileName}"* | wc -l)
  rlfiles=$(ls -l "${DB_BACKUP_PATH}/Log/${postLogFileName}"* | wc -l)
    
    for file in "${DB_BACKUP_PATH}/Log"/*; do
    if [ -f "$file" ]; then
        filename=$(echo ${file#$DB_BACKUP_PATH/Log/})
        if [ "$filename" = "$preLogFileName" ] || [ "$filename" = "$postLogFileName" ]; then
            logfilesize=$(stat -c%s "$file")
            # logfilesize=`ls -lad "${file}" | awk '{print $5}'`
            if [ ${logfilesize} -gt ${maxlogsize} ]; then
                mv "$file" "$file-$logbackdate"
                touch "$file"
            fi
        fi
    fi
    done
    
    # logdeldate=`date +"%F" --date="${log_retain_days} days ago"`
    if [ $dlfiles -ge 2 ]; then
      log_file_count=$(find "${DB_BACKUP_PATH}/Log" -mindepth 1 -type f -name "$preLogFileName*" -mtime +${log_retain_days} -print | wc -l)
      if [[ $log_file_count -gt 0 ]]; then
          echo -e "\n $log_file_count $preLogFileName files older than ${log_retain_days} days found. Deleting them.\n"
          find "${DB_BACKUP_PATH}/Log" -mindepth 1 -type f -name "$preLogFileName*" -mtime +${log_retain_days} -print -delete
      else
          echo -e "\nNo $preLogFileName files older than ${log_retain_days} days found.\n"
      fi
      # if [ -a "$DB_BACKUP_PATH/test/Log/$preLogFileName-${logdeldate}" ]; then
      #         echo -e "\nDeleting log backup - ${DB_BACKUP_PATH}/Log/$preLogFileName-${logdeldate}"
      #         rm -f "${DB_BACKUP_PATH}/Log/$preLogFileName-${logdeldate}"
      # fi
    fi

    if [ $rlfiles -ge 2 ]; then
      log_file_count=$(find "${DB_BACKUP_PATH}/Log" -mindepth 1 -type f -name "$postLogFileName*" -mtime +${log_retain_days} -print | wc -l)
      if [[ $log_file_count -gt 0 ]]; then
          echo -e "\n $log_file_count $postLogFileName files older than ${log_retain_days} days found. Deleting them.\n"
          find "${DB_BACKUP_PATH}/Log" -mindepth 1 -type f -name "$postLogFileName*" -mtime +${log_retain_days} -print -delete
      else
          echo -e "\nNo $postLogFileName files older than ${log_retain_days} days found.\n"
      fi
      # if [ -a "$DB_BACKUP_PATH/test/Log/$postLogFileName-${logdeldate}" ]; then
      #         echo -e "\nDeleting log backup - ${DB_BACKUP_PATH}/Log/$postLogFileName-${logdeldate}"
      #         rm -f "${DB_BACKUP_PATH}/Log/$postLogFileName-${logdeldate}"
      # fi
    fi
}

backup()
{
    # read -e -p "Enter Backup Location [$default_BACKUP_PATH]: " outputPath
    DB_BACKUP_PATH="${outputPath:-$default_BACKUP_PATH}"
    
    if [ ! -d $DB_BACKUP_PATH ]; then
        echo "$DB_BACKUP_PATH does not exist. Creating it."
        mkdir -p ${DB_BACKUP_PATH}/Log/
    fi
    # read -e -p "Enter Backup Name [$DefaultDB_NAME]: " DB_NAME
    DATABASE_NAME="${DB_NAME:-$DefaultDB_NAME}"
    createconf
    echo -e "\nBacking up Database to - ${DB_BACKUP_PATH}/${DATABASE_NAME}-${TODAY}.sql"
    # mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} ${DefaultDB_NAME} > ${DB_BACKUP_PATH}/${DATABASE_NAME}-${TODAY}.sql
    mysqldump -h ${MYSQL_HOST} -P ${MYSQL_PORT} ${DefaultDB_NAME} --result-file=${DB_BACKUP_PATH}/${DATABASE_NAME}-${TODAY}.sql
    
}

Logdb()
{
  # echo "Log File is $1"
  LogFile="$1"
  echo -e "\nLogging Database Data before restoring db in - ${default_BACKUP_PATH}/Log/$LogFile"
  echo -e "\n------------------------------------------------------------------------------$logdate------------------------------------------------------------------------------------\n" >> "${default_BACKUP_PATH}/Log/$LogFile"
  for i in $(mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} ${DefaultDB_NAME} -e 'SHOW TABLES' | grep -v "Tables_in" | awk '{print $1}'); do echo "TABLE: $i"; mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} ynw -e "show create table $i"; done > "${default_BACKUP_PATH}/Log/$LogFile"
  echo -e "\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n" >> "${default_BACKUP_PATH}/Log/$LogFile"
}

clear()
{
  if [[ ! -d "${default_BACKUP_PATH}/Log/" ]];then
     mkdir -p "${default_BACKUP_PATH}/Log/"
  fi
  touch -a "${default_BACKUP_PATH}/Log/$preLogFileName" "${default_BACKUP_PATH}/Log/$postLogFileName"

  createconf
  # Logdb "$preLogFileName"

  for file in "$default_BACKUP_PATH"/*; do
    if [ -f "$file" ]; then 
      [[ $file -nt $latest ]] && latest=$file
    fi
  done
  # latest_file=$(echo ${latest#$DB_BACKUP_PATH/})

  if [ -a "${latest}" ]; then
    echo "Restoring database ${latest} . Please wait"
    # mysql -e "CREATE DATABASE ${DefaultDB_NAME}"
    # mysql ${DefaultDB_NAME} < ${latest}
    # mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} < ${latest}
    if [[ $myversion == 5.7.* ]]; then
        echo "mysql $myversion"
        time mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} --compress ${DefaultDB_NAME} < ${latest}
    elif [[ $myversion == 8.0.* ]]; then
        echo "mysql $myversion"
        time mysql -h ${MYSQL_HOST} -P ${MYSQL_PORT} --compression-algorithms=zstd --zstd-compression-level=7 ${DefaultDB_NAME} < ${latest}
    fi
    echo "done"
  else
    echo "$latest does not exist."
  fi

  # Logdb "$postLogFileName"

  # archiveAndDeleteLog ${default_BACKUP_PATH}

  echo -n "" > "${INPUT_LOC%/}/$NUM_FILE"
  echo -n "" > "${INPUT_LOC%/}/$PAN_FILE"
  echo -n "" > "${INPUT_LOC%/}/$TIME_FILE"
  rm -rf "${INPUT_LOC%/}/$VAR_DIR"/*
  #  rm  "${CUR_LOC%/}"/env*.list

}
 
# Check if this script is being invoked with sudo command.
if [[ $EUID -eq 0 ]]; then
    echo -e "\nPlease run this script without sudo\n"
    echo -e "Eg: $0 \n"
    exit 1
fi

# if [[ $EUID -ne 0 ]]; then
#     echo -e "\nPlease run this script with sudo\n"
#     echo -e "Eg: sudo $0 \n"
#     exit 1
# fi

if [ "$1" != "" ]; then
  case $1 in
      "-b" | "--backup" )
              backup
              shift
              ;;
      "-h" | "--help" )
              usage
              shift
              ;;
      * )                     
              usage
              exit 1
              ;;
  esac
  shift
else
  clear
fi
 
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."