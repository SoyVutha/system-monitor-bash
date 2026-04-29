#!/bin/bash

# ── Get Running Processes ────────────────────────
get_running_process() {
    printf "\nGet Running Processes: \n\n"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head
}

# ── Get Top Processes ────────────────────────────
get_top_process() {
    echo "TOP PROCESS START"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -3
    echo "TOP PROCESS END"
}

# ── Get CPU Usage ────────────────────────────────
get_cpu() {
    local idle1 idle2 idle_diff total_diff cpu_usage
    local user nice system idle iowait irq softirq steal guest guest_nice cpu

    read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    idle1=$((idle + iowait))
    t1=$((user + nice + system + idle + iowait + irq + softirq + steal))

    sleep 1

    read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    idle2=$((idle + iowait))
    t2=$((user + nice + system + idle + iowait + irq + softirq + steal))

    idle_diff=$((idle2 - idle1))
    total_diff=$((t2 - t1))

    cpu_usage=$(awk "BEGIN {printf \"%.1f\", (1 - $idle_diff/$total_diff) * 100}")

    echo "CPU Usage: $cpu_usage %"

    if awk "BEGIN {exit !($cpu_usage > 80)}"; then
        echo "CPU_ALERT=WARNING: CPU usage is ${cpu_usage}% - above 80%!"
    else
        echo "CPU_ALERT=WORKING FINE"
    fi
}

# ── Get Memory Usage ─────────────────────────────
get_memory() {
    local total available used
    local total_mb used_mb free_mb memory_pct

    total=$(grep '^MemTotal:' /proc/meminfo | awk '{print $2}')
    available=$(grep '^MemAvailable:' /proc/meminfo | awk '{print $2}')
    used=$((total - available))

    total_mb=$((total / 1024))
    used_mb=$((used / 1024))
    free_mb=$((available / 1024))
    memory_pct=$(awk "BEGIN {printf \"%.1f\", ($used / $total) * 100}")

    echo "TOTAL MEMORY  = $total_mb MB"
    echo "USED MEMORY   = $used_mb MB"
    echo "FREE MEMORY   = $free_mb MB"
    echo "MEMORY USAGE  = $memory_pct %"

    if awk "BEGIN {exit !($memory_pct > 85)}"; then
        echo "MEM_ALERT=WARNING: Memory at ${memory_pct}% — above 85%!"
    else
        echo "MEM_ALERT=WORKING FINE"
    fi
}

# ── Get Disk Usage ───────────────────────────────
get_disk() {
    echo "Available disk usage: "
    df -h -x tmpfs -x devtmpfs | awk 'NR==1 || $1 ~ /^\// {
        printf "  %-25s %6s used of %6s (%s)\n", $6, $3, $2, $5
    }'

    local over_limit
    over_limit=$(df -x tmpfs -x devtmpfs | awk 'NR>1 {
        gsub(/%/, "", $5)
        if ($5+0 > 90) print $6 " at " $5 "%"
    }')

    printf "\n"
    if [ -n "$over_limit" ]; then
        echo "DISK_ALERT=WARNING: $over_limit"
    else
        echo "DISK_ALERT=WORKING FINE"
    fi
}

# ── Get Network Stats ────────────────────────────
get_network() {
    local iface rx1 rx2 tx1 tx2 rx_kbps tx_kbps

    iface=$(ip route | awk '/^default/{print $5; exit}')
    rx1=$(grep "$iface" /proc/net/dev | awk '{print $2}')
    tx1=$(grep "$iface" /proc/net/dev | awk '{print $10}')

    sleep 1

    rx2=$(grep "$iface" /proc/net/dev | awk '{print $2}')
    tx2=$(grep "$iface" /proc/net/dev | awk '{print $10}')

    rx_kbps=$(awk "BEGIN {printf \"%.2f\", ($rx2 - $rx1) / 1024}")
    tx_kbps=$(awk "BEGIN {printf \"%.2f\", ($tx2 - $tx1) / 1024}")

    echo "NET_IFACE=$iface"
    echo "NET_RX_KBps=$rx_kbps"
    echo "NET_TX_KBps=$tx_kbps"
}

# ── Collect All ──────────────────────────────────
collect_all() {
    get_cpu
    get_memory
    get_disk
    get_top_process
    get_network
}

# ── Only runs if executed directly ───────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    get_running_process
    printf "\n"
    get_top_process
    printf "\n"
    get_cpu
    printf "\n"
    get_memory
    printf "\n"
    get_disk
    printf "\n"
    get_network
fi
