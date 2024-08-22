#!/bin/bash
# Author: Archana Gopi

# Description: This script provides functions to use for logging. to called in another script

# usage in script files:
# . $(dirname "$0")/customlogger.sh
# LogFileName="/logs/LogFileName-$(date +"%F").txt"
# logheader >> $LogFileName
# ok "Ok message here."
# info "info message here. "
# try "try message here."
# warning "warning message here. "
# failed "failed reason here."
# die "error message here before exiting script. "

#Script goes here:
#---------------------------------------------------------------------------------------------

# uncomment to enable debugging
# PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
# set -x

LogFileName=$1

addTimestamp()
{
    awk '{print strftime("[%d-%m-%Y %H:%M:%S %Z]:"), $0}' $1
}

logheader()
{
echo "========================================================="
# echo "$(date): ${0##*/}"
echo "$(date): ${0}"
echo "========================================================="
}

ok() {
  echo -e "OK. $*" | addTimestamp | tee -a -i $LogFileName
}

info() {
  echo -e "INFO: $*" | addTimestamp | tee -a -i $LogFileName
}

try() {
  local action=$*
  echo -e "Trying to $action ... " | addTimestamp | tee -a -i $LogFileName
}

warning() {
  local reason=$*
  echo -e "WARNING: $reason" | addTimestamp | tee -a -i $LogFileName
}

failed() {
  local reason=$*
  echo -e "FAILED: $reason" | addTimestamp | tee -a -i $LogFileName
}

tryin() {
  local action=$*
  echo -e "Trying in $action ... " | addTimestamp | tee -a -i $LogFileName
}

tried() {
  local action=$*
  echo -e "Tried in $action ... " | addTimestamp | tee -a -i $LogFileName
}

error() {
  local reason=$*
  echo -e "ERROR: $reason" | addTimestamp | tee -a -i $LogFileName
}

die() {
  local reason=$*
  echo -e "ERROR: $reason" | addTimestamp | tee -a -i $LogFileName
  echo -e "Exiting with error code 1" | addTimestamp | tee -a -i $LogFileName
  exit 1
}