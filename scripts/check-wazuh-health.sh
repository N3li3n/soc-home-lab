#!/bin/bash
# check-wazuh-health.sh
# Проверка здоровья Wazuh Manager и агентов.

echo "=== Wazuh Manager ==="
sudo systemctl status wazuh-manager --no-pager | head -5

echo ""
echo "=== Wazuh Indexer ==="
sudo systemctl status wazuh-indexer --no-pager | head -5

echo ""
echo "=== Wazuh Dashboard ==="
sudo systemctl status wazuh-dashboard --no-pager | head -5

echo ""
echo "=== Agents (online) ==="
sudo /var/ossec/bin/agent_control -l | grep -i "active"

echo ""
echo "=== Alerts count (last 24h) ==="
sudo grep -c "$(date '+%Y-%m-%d')" /var/ossec/logs/alerts/alerts.json

echo ""
echo "=== Disk usage ==="
df -h / | tail -1
