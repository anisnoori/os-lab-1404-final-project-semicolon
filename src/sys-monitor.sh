


#!/bin/bash

# sys-monitor - System Resource Monitor (CPU & RAM)
# Anis Noori - OS Lab Final Project 1404

INTERVAL=2
TOP_N=10
ALERT_CPU=0
ALERT_RAM=0

# پردازش گزینه‌ها
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interval) INTERVAL="$2"; shift 2 ;;
        -t|--top) TOP_N="$2"; shift 2 ;;
        -a|--alert) ALERT_CPU="$2"; ALERT_RAM="$3"; shift 3 ;;
        -h|--help)
            echo "استفاده: sys-monitor [-i ثانیه] [-t تعداد] [-a cpu% ram%]"
            echo "مثال: sys-monitor -i 3 -t 5 -a 80 90"
            exit 0
            ;;
        *) echo "گزینه ناشناخته: $1" >&2; exit 1 ;;
    esac
done

monitor() {
    clear
    echo "=============================================="
    echo "     Sys-Monitor - مانیتور CPU و RAM"
    echo "     $(date +"%Y/%m/%d - %H:%M:%S")"
    echo "=============================================="

    # مصرف CPU
    CPU_IDLE=$(top -bn1 | grep '%Cpu(s)' | awk '{print $8}' | cut -d. -f1)
    CPU_USAGE=$((100 - CPU_IDLE))
    echo "مصرف CPU: ${CPU_USAGE}%"

    # مصرف RAM
    read TOTAL USED <<< $(free -m | awk '/^Mem:/ {print $2, $3}')
    PERCENT=$((100 * USED / TOTAL))
    echo "RAM: ${USED} MB / ${TOTAL} MB  (${PERCENT}%)"

    # هشدار
    if (( ALERT_CPU > 0 || ALERT_RAM > 0 )); then
        if (( CPU_USAGE > ALERT_CPU || PERCENT > ALERT_RAM )); then
            echo "⚠️  هشدار: مصرف منابع بالا!"
        fi
    fi

    echo -e "\n--- $TOP_N پروسس پرمصرف CPU ---"
    ps -eo pid,user,cmd,%cpu --sort=-%cpu | head -n $((TOP_N + 1))

    echo -e "\n--- $TOP_N پروسس پرمصرف RAM ---"
    ps -eo pid,user,cmd,%mem --sort=-%mem | head -n $((TOP_N + 1))

    echo -e "\nبرای خروج Ctrl+C بزنید"
}

while true; do
    monitor
    sleep $INTERVAL
done