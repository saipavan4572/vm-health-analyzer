#!/usr/bin/env bash

# Ubuntu VM Health Checker
# Usage:
#   ./vm_health.sh
#   ./vm_health.sh explain
#   ./vm_health.sh --help

set -u

THRESHOLD=60

usage() {
    echo "Usage: $0 [explain|--help]"
    echo
    echo "Checks Ubuntu VM health based on CPU, memory, and disk utilization."
    echo "Healthy means all three metrics are below ${THRESHOLD}% utilization."
    echo "If any metric is ${THRESHOLD}% or higher, the VM is reported as Not healthy."
    echo
    echo "Examples:"
    echo "  ./vm_health.sh"
    echo "  ./vm_health.sh explain"
}

get_cpu_utilization() {
    # Read the initial CPU snapshot (skip the 'cpu' label)
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))
    prev_idle=$((idle + iowait))

    sleep 1

    # Read the second CPU snapshot (skip the 'cpu' label)
    read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    total=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))
    idle_total=$((idle + iowait))

    total_diff=$((total - prev_total))
    idle_diff=$((idle_total - prev_idle))

    if [ "$total_diff" -eq 0 ]; then
        echo 0
        return
    fi

    cpu_usage=$((100 * (total_diff - idle_diff) / total_diff))
    echo "$cpu_usage"
}

get_memory_utilization() {
    mem_total=$(free -m | awk '/^Mem:/ {print $2}')
    mem_used=$(free -m | awk '/^Mem:/ {print $3}')

    mem_total=${mem_total:-0}
    mem_used=${mem_used:-0}

    if [ "$mem_total" -eq 0 ]; then
        echo 0
        return
    fi

    echo $(((mem_used * 100) / mem_total))
}

get_disk_utilization() {
    disk_usage=$(df -P / | awk 'NR==2 {print $5}' | tr -d '%')
    disk_usage=${disk_usage:-0}
    echo "$disk_usage"
}

explain_status() {
    local cpu="$1"
    local mem="$2"
    local disk="$3"
    local status="$4"

    echo "Health Status: $status"
    echo
    echo "Explanation:"
    echo "------------"

    if [ "$cpu" -ge "$THRESHOLD" ]; then
        echo "- CPU utilization is ${cpu}% (>= ${THRESHOLD}%), which makes the VM Not healthy."
    else
        echo "- CPU utilization is ${cpu}% (< ${THRESHOLD}%), which keeps the VM in a healthy state."
    fi

    if [ "$mem" -ge "$THRESHOLD" ]; then
        echo "- Memory utilization is ${mem}% (>= ${THRESHOLD}%), which makes the VM Not healthy."
    else
        echo "- Memory utilization is ${mem}% (< ${THRESHOLD}%), which keeps the VM in a healthy state."
    fi

    if [ "$disk" -ge "$THRESHOLD" ]; then
        echo "- Disk utilization is ${disk}% (>= ${THRESHOLD}%), which makes the VM Not healthy."
    else
        echo "- Disk utilization is ${disk}% (< ${THRESHOLD}%), which keeps the VM in a healthy state."
    fi

    echo
    if [ "$status" = "Healthy" ]; then
        echo "Overall: The VM is healthy because all three resource metrics are below ${THRESHOLD}% utilization."
    else
        echo "Overall: The VM is Not healthy because at least one metric has reached or exceeded ${THRESHOLD}% utilization."
    fi
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
fi

if [ "${1:-}" != "" ] && [ "${1:-}" != "explain" ]; then
    echo "Invalid argument: $1"
    usage
    exit 1
fi

cpu_usage=$(get_cpu_utilization)
memory_usage=$(get_memory_utilization)
disk_usage=$(get_disk_utilization)

cpu_usage=${cpu_usage:-0}
memory_usage=${memory_usage:-0}
disk_usage=${disk_usage:-0}

status="Healthy"

if [ "$cpu_usage" -ge "$THRESHOLD" ] || [ "$memory_usage" -ge "$THRESHOLD" ] || [ "$disk_usage" -ge "$THRESHOLD" ]; then
    status="Not healthy"
fi

echo "VM Health Status: $status"
echo "CPU utilization: ${cpu_usage}%"
echo "Memory utilization: ${memory_usage}%"
echo "Disk utilization: ${disk_usage}%"

if [ "${1:-}" = "explain" ]; then
    echo
    explain_status "$cpu_usage" "$memory_usage" "$disk_usage" "$status"
fi

exit 0
