# Развёртывание

## 1. Wazuh (Ubuntu)

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
sudo systemctl status wazuh-manager
