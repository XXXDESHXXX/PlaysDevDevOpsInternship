#!/bin/bash

while :
do
  # cpuUsage=$(mpstat 1 1 | awk '/Average:/ { print 100 - $NF }')
  cpuUsage=$(top -bn1 | awk '/Cpu/ { print $2}')
  memUsage=$(free -m | awk '/Mem/{print $3}')

  echo "<html><head><meta http-equiv='refresh' content='1'></head><body>" > /var/www/task3/html/status/status.html
  echo "<h1>System Status</h1>" >> /var/www/task3/html/status/status.html
  echo "<p>CPU Usage: $cpuUsage%</p>" >> /var/www/task3/html/status/status.html
  echo "<p>Memory Usage: $memUsage MB</p>" >> /var/www/task3/html/status/status.html
  echo "<hr>" >> /var/www/task3/html/status/status.html
  echo "</body></html>" >> /var/www/task3/html/status/status.html

  sleep 1
done
