# Scripts

Вспомогательные скрипты для SOC Home Lab.

## Список скриптов

| Скрипт | Назначение | Язык |
|--------|------------|------|
| `simulate-lsass-access.ps1` | Симуляция доступа к LSASS (альтернатива ProcDump) | PowerShell |
| `wazuh-active-response.sh` | Active Response — блокировка IP через iptables | Bash |
| `check-wazuh-health.sh` | Проверка здоровья Wazuh Manager + агентов | Bash |

## Использование

### simulate-lsass-access.ps1
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\simulate-lsass-access.ps1

wazuh-active-response.sh
Копируется в /var/ossec/active-response/bin/ на Wazuh Manager.

check-wazuh-health.sh
chmod +x check-wazuh-health.sh
./check-wazuh-health.sh


