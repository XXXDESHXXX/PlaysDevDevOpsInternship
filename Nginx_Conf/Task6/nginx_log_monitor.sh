#!/bin/bash

LOG_FILE="/var/www/task3/html/logfile1.log"
SECOND_LOG_FILE="/var/www/task3/html/logfile2.log"
LOG_FILE_5XX="/var/www/task3/html/logfile5xx.log"
LOG_FILE_4XX="/var/www/task3/html/logfile4xx.log"
MAX_SIZE=30

while true
do
	tail -n 100 /var/log/nginx/access.log | awk '$9 ~ /^5[0-9][0-9]$/ {print $0}' >> "$LOG_FILE_5XX"
	tail -n 100 /var/log/nginx/access.log | awk '$9 ~ /^4[0-9][0-9]$/ {print $0}' >> "$LOG_FILE_4XX"
	tail -n 100 /var/log/nginx/access.log | sed -n '/GET/p'  | awk '{print $0}' >> "$LOG_FILE"
	FILE_SIZE=$(du -k "$LOG_FILE" | cut -f1)
	if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
		LINE_COUNT=$(wc -l < "$LOG_FILE")
		echo  "Log file cleaned $(date '+%Y-%m-%d %H:%M:%S'), $LINE_COUNT entries removed" >> "$SECOND_LOG_FILE"
		> "$LOG_FILE"
	fi
	
	sleep 5
done
