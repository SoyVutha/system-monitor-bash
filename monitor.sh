#!/bin/bash
set -euo pipefail

# ── Placeholders — remove when Person A finishes data.sh ──
get_cpu()    { echo "45"; }
get_memory() { echo "62"; }
get_disk()   { echo "78"; }

# ── Colors ──────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Log File ─────────────────────────────────────
LOG_FILE="system_monitor.log"

# ── Dashboard ───────────────────────────────────
show_dashboard() {
    clear
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}║    SYSTEM MONITOR DASHBOARD      ║${RESET}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════╝${RESET}"
    echo ""
    CPU=$(get_cpu)
    MEM=$(get_memory)
    DISK=$(get_disk)
    echo -e "${BOLD}  CPU Usage   :${RESET}  ${GREEN}${CPU}%${RESET}"
    echo -e "${BOLD}  Memory Usage:${RESET}  ${YELLOW}${MEM}%${RESET}"
    echo -e "${BOLD}  Disk Usage  :${RESET}  ${RED}${DISK}%${RESET}"
    echo ""
    echo "──────────────────────────────────"
}

# ── Auto Refresh ─────────────────────────────────
auto_refresh() {
    while true; do
        show_dashboard
        echo -e "${CYAN}  Auto-refreshing every 3 seconds...${RESET}"
        echo -e "${YELLOW}  Press Ctrl+C to go back to menu${RESET}"
        sleep 3
    done
}

# ── Log Action ───────────────────────────────────
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ── Log Viewer ───────────────────────────────────
show_logs() {
    clear
    echo -e "${YELLOW}${BOLD}═══ Recent Logs ═══${RESET}"
    echo ""
    if [[ -f "$LOG_FILE" ]]; then
        tail -20 "$LOG_FILE"
    else
        echo "  No logs found yet."
    fi
    echo ""
    echo "──────────────────────────────────"
}

# ── Menu ────────────────────────────────────────
show_menu() {
    echo -e "${CYAN}${BOLD}  System Monitor v1.0${RESET}"
    echo "─────────────────────────────"
    echo -e "${BOLD}Select an option:${RESET}"
    echo "  1) Show Dashboard"
    echo "  2) Auto Refresh"
    echo "  3) View Logs"
    echo "  4) Exit"
    echo ""
    read -rp "Enter choice [1-4]: " choice
}

# ── Main Loop ───────────────────────────────────
main() {
    while true; do
        clear
        show_menu

        case $choice in
            1)
                show_dashboard
                log_action "User viewed dashboard"
                read -rp "Press Enter to continue..."
                ;;
            2)
                log_action "User started auto-refresh"
                auto_refresh
                ;;
            3)
                show_logs
                log_action "User viewed logs"
                read -rp "Press Enter to continue..."
                ;;
            4)
                echo -e "${GREEN}Goodbye!${RESET}"
                log_action "User exited"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Try again.${RESET}"
                sleep 1
                ;;
        esac
    done
}

main
