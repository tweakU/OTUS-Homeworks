#!/bin/bash
echo -e "PID\tSTATE\tCOMMAND"
for pid in /proc/[0-9]*; do
    if [ -f "$pid/stat" ]; then
        stat_info=$(cat "$pid/stat")
        pid_value=$(echo "$stat_info" | awk '{print $1}')
        state=$(echo "$stat_info" | awk '{print $3}')
        command=$(echo "$stat_info" | awk '{print $2}')
        echo -e "$pid_value\t$state\t$command"
    fi
done
