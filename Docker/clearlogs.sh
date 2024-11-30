#!/bin/bash
# uncomment to enable debugging
# PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
# set -x

LOGFILE="clearlogs-$(date +"%F").txt"
LOG_DIR="/logs" 
LOGPATH="$LOG_DIR/$LOGFILE"
m2_path="$HOME/.m2/repository/com/nv"
days="1"
tomcat_pid=$(ps aux | grep '[t]omcat' | awk '{print $2}')
tomcat_log_path="/ebs/apache-tomcat-8.0.36/logs"
LINES=100
. $(dirname "$0")/customlogger.sh $LOGPATH

(

    logheader >> $LOGPATH

    if [[ -z "$tomcat_pid" ]]; then
        echo "Tomcat is not running"
        echo "-- clearing /logs" | addTimestamp
        rm -rf /logs/*

        echo "-- clearing tomcat logs" | addTimestamp
        rm -rf ${tomcat_path}/logs/*

    else
        echo "Tomcat is running"
        echo "-- clearing /logs gz files" | addTimestamp
        find $LOG_DIR/ -depth -type f -mtime +$days -name '*.gz' -print -delete && find $LOG_DIR/ -depth -type f -mtime $days -name '*.gz' -print -delete && find $LOG_DIR/ -empty -type d -print -delete

        echo "-- clearing logs older than 1 day from /logs" | addTimestamp
        find $LOG_DIR/ -type f -mtime $days -print -delete && find $LOG_DIR/ -empty -type d -print -delete

        echo "-- Rewriting catalina.out with last 100 lines" | addTimestamp
        tail -100 "$tomcat_log_path/catalina.out" | tee "$tomcat_log_path/catalina.out" > /dev/null

        # echo "-- Rewriting app.log with last 100 lines" | addTimestamp
        # tail -100 "$LOG_DIR/app.log" | tee "$LOG_DIR/app.log" > /dev/null

        for file in "$LOG_DIR"/*.log
        do
            # Check if the file exists and is a regular file
            echo $file
            if [ -f "$file" ]; then
                echo "inside if for $file"
                # Get the last 100 lines and write back to the file
                echo "-- Rewriting $file with last 100 lines" | addTimestamp
                tail -n 100 "$file" > "$file.tmp" && mv "$file.tmp" "$file"
                echo "Truncated $file to the last 100 lines."
            fi
        done

        echo "-- clearing tomcat logs" | addTimestamp
        find "$tomcat_log_path/" -type f -mtime $days -print -delete && find "$tomcat_log_path/" -empty -type d -print -delete
    fi


    # echo "-- clearing log.html from telegram desktop" | addTimestamp
    # find "${HOME}/Downloads/Telegram Desktop/" -mindepth 1 -type f -mtime $days -name log*.html -print -delete

    echo "-- clearing "$(pwd)"/logs" | addTimestamp
    rm -rf "$(pwd)"/logs/*

    echo "-- clearing clearlogs" | addTimestamp
    find $LOG_DIR/ -mindepth 1 -type f -mtime $days -name 'clearlogs-*.txt' -not -name $LOGFILE -print -delete

    echo "-- Clearing .m2" | addTimestamp
    for dir in $m2_path/*; do
        for subdir in $dir/*; do
            newest_subdirectory=$(find "$subdir" -mindepth 1 -type d -printf "%T@ %p\n" | sort -n -r | head -n 1 | awk '{print $2}')
            echo "newest dir is $newest_subdirectory"
            find "$subdir" -mindepth 1 -not -path "$newest_subdirectory/*" -type f -print -delete && find "$subdir" -mindepth 1 -empty -not -path "$newest_subdirectory/*" -type d -print -delete
        done
    done

) 2>&1 | tee -a $LOGPATH
