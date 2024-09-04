#!/bin/bash
# uncomment to enable debugging
# PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
# set -x

LOGFILE="clearlogs-$(date +"%F").txt"
LOGPATH="/logs/$LOGFILE"
m2_path="$HOME/.m2/repository/com/nv"
days="1"
tomcat_pid=$(ps aux | grep '[t]omcat' | awk '{print $2}')
tomcat_log_path="/ebs/apache-tomcat-8.0.36/logs"
. $(dirname "$0")/customlogger.sh $LOGPATH

(

    logheader >> $LOGPATH

    if [[ ! -n "$tomcat_pid" ]]; then
        echo "-- clearing /logs" | addTimestamp
        find /logs/ -mindepth 1 -maxdepth 1 -not -name $LOGFILE -print -delete

        echo "-- clearing /logs gz files" | addTimestamp
        find /logs/ -depth -type f -mtime +$days -name '*.gz' -print -delete && find /logs/ -depth -type f -mtime $days -name '*.gz' -print -delete && find /logs/ -empty -type d -print -delete

        echo "-- clearing tomcat logs" | addTimestamp
        find "$tomcat_log_path/" -mindepth 1 -maxdepth 1 -type f -print -delete

    else
        echo "-- clearing /logs gz files" | addTimestamp
        find /logs/ -depth -type f -mtime +$days -name '*.gz' -print -delete && find /logs/ -depth -type f -mtime $days -name '*.gz' -print -delete && find /logs/ -empty -type d -print -delete

        echo "-- clearing logs older than 1 day from /logs" | addTimestamp
        find /logs/ -type f -mtime $days -print -delete && find /logs/ -empty -type d -print -delete

        echo "-- Rewriting catalina.out with last 1000 lines" | addTimestamp
        echo "$(tail -1000 $tomcat_log_path/catalina.out)" | tee "$tomcat_log_path"/catalina.out > /dev/null

        echo "-- clearing tomcat logs" | addTimestamp
        find "$tomcat_log_path/" -type f -mtime $days -print -delete && find "$tomcat_log_path/" -empty -type d -print -delete
    fi


    # echo "-- clearing log.html from telegram desktop" | addTimestamp
    # find "${HOME}/Downloads/Telegram Desktop/" -mindepth 1 -type f -mtime $days -name log*.html -print -delete

    echo "-- clearing clearlogs" | addTimestamp
    find /logs/ -mindepth 1 -type f -mtime $days -name 'clearlogs-*.txt' -not -name $LOGFILE -print -delete

    echo "-- Clearing .m2" | addTimestamp
    for dir in $m2_path/*; do
        for subdir in $dir/*; do
            newest_subdirectory=$(find "$subdir" -mindepth 1 -type d -printf "%T@ %p\n" | sort -n -r | head -n 1 | awk '{print $2}')
            echo "newest dir is $newest_subdirectory"
            find "$subdir" -mindepth 1 -not -path "$newest_subdirectory/*" -type f -print -delete && find "$subdir" -mindepth 1 -empty -not -path "$newest_subdirectory/*" -type d -print -delete
        done
    done

) 2>&1 | tee -a $LOGPATH
