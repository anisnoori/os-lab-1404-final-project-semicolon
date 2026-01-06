#!/bin/bash

# sys-mon - System CPU and RAM Monitor

INTERVAL=2
TOP_N=10
ALERT_CPU=0
ALERT_RAM=0

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interval) INTERVAL="$2"; shift 2 ;;
        -t|--top) TOP_N="$2"; shift 2 ;;
        -a|--alert) ALERT_CPU="$2"; ALERT_RAM="$3"; shift 3 ;;
        -h|--help) echo "Usage: sys-mon [-i seconds] [-t N] [-a cpu% ram%]"; exit 0 ;;
        *) shift ;;
    esac
done

monitor() {
    clear
    echo "=== System Monitor - $(date) ==="
    
    # CPU usage
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo "CPU Usage: $CPU%"

    # RAM
    FREE_OUTPUT=$(free -m)
    TOTAL=$(echo "$FREE_OUTPUT" | awk '/Mem:/ {print $2}')
    USED=$(echo "$FREE_OUTPUT" | awk '/Mem:/ {print $3}')
    FREE=$(echo "$FREE_OUTPUT" | awk '/Mem:/ {print $4}')
    PERCENT=$((100 * USED / TOTAL))
    echo "RAM: ${USED}MB / ${TOTAL}MB (${PERCENT}%)"

    # Alerts
    if (( $(echo "$CPU > $ALERT_CPU" | bc -l 2>/dev/null || echo 0) )) || (( PERCENT > ALERT_RAM )); then
        echo "  ALERT: High resource usage!"
    fi

    echo -e "\nTop $TOP_N processes by CPU:"
    ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n $((TOP_N + 1))

    echo -e "\nTop $TOP_N processes by RAM:"
    ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head -n $((TOP_N + 1))
}

if [[ $INTERVAL -gt 0 ]]; then
    while true; do
        monitor
        sleep $INTERVAL
    done
else
    monitor
fi
