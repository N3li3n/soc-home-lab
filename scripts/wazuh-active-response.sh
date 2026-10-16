#!/bin/bash
# wazuh-active-response.sh
# Скрипт для Active Response — блокировка IP через iptables.
# Используется в Wazuh для автоматической блокировки атакующих IP.

ACTION=$1
USER=$2
IP=$3
TIMEOUT=$4

LOG_FILE="/var/ossec/logs/active-responses.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> $LOG_FILE
}

case $ACTION in
    add)
        log "Blocking IP: $IP for $TIMEOUT seconds"
        iptables -I INPUT -s $IP -j DROP
        ;;
    delete)
        log "Unblocking IP: $IP"
        iptables -D INPUT -s $IP -j DROP
        ;;
    *)
        log "Unknown action: $ACTION"
        exit 1
        ;;
esac

exit 0
