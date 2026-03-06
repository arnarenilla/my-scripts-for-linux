#!/bin/bash

# Check if arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <process_name> <cpu_threshold> <memory_threshold>"
    echo "Example: $0 nginx 50 30"
    exit 1
fi

process_name="$1"
cpu_threshold="$2"
memory_threshold="$3"

process_monitor() {

    # Find PID(s)
    pids=$(pgrep -f "$process_name")

    if [ -z "$pids" ]; then
        echo "[$(date)] Process '$process_name' not found."
        return
    fi

    for pid in $pids
    do
        cpu_usage=$(ps -p "$pid" -o %cpu= | awk '{print $1}')
        memory_usage=$(ps -p "$pid" -o %mem= | awk '{print $1}')

        cpu_exceeded=$(echo "$cpu_usage > $cpu_threshold" | bc)
        memory_exceeded=$(echo "$memory_usage > $memory_threshold" | bc)

        if [ "$cpu_exceeded" -eq 1 ]; then
            echo "[$(date)] ALERT: CPU usage of '$process_name' (PID $pid) is high: ${cpu_usage}%"
        fi

        if [ "$memory_exceeded" -eq 1 ]; then
            echo "[$(date)] ALERT: Memory usage of '$process_name' (PID $pid) is high: ${memory_usage}%"
        fi
    done
}

# Monitor loop
while true
do
    process_monitor
    sleep 60
done
