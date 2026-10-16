# Архитектура лаборатории

## Схема сети

```mermaid
graph TB
    subgraph LAB["SOC Home Lab"]
        Kali["🔴 Kali Linux<br/>Атакующий<br/>192.168.206.216"]
        Win11["🪟 Windows 11<br/>Жертва<br/>192.168.202.20"]
        Wazuh["🛡️ Ubuntu (Wazuh)<br/>Wazuh Manager + Indexer + Dashboard<br/>192.168.201.19"]
        SO["🧅 Ubuntu (Security Onion)<br/>Security Onion Standalone<br/>192.168.202.10"]
    end
    
    Kali -->|"Атака<br/>SSH Brute Force"| Wazuh
    Win11 -->|"Логи<br/>Sysmon + 4688 + 4104"| Wazuh
    Win11 -.->|"Сетевой трафик"| SO
    
    style Kali fill:#ff6b6b,stroke:#c92a2a,color:#fff
    style Win11 fill:#4dabf7,stroke:#1864ab,color:#fff
    style Wazuh fill:#51cf66,stroke:#2b8a3e,color:#fff
    style SO fill:#ffd43b,stroke:#e67700,color:#000
```


## Ресурсы VM

| VM | CPU | RAM | Диск |
|----|-----|-----|------|
| Ubuntu (Wazuh) | 4 | 8 ГБ | 226 ГБ |
| Kali | 2 | 4 ГБ | 40 ГБ |
| Windows 11 | 4 | 8 ГБ | 80 ГБ |
| Ubuntu (Security Onion) | 4 | 24 ГБ | 200 ГБ |

## Источники телеметрии

| Источник | Что даёт | Где используется |
|----------|----------|------------------|
| Sysmon EID 1 | Process Create | Правила на процессы |
| Sysmon EID 10 | Process Access | Мониторинг LSASS |
| Sysmon EID 3 | Network Connect | Reverse shell |
| Windows Security 4688 | Process Create | **Основной** источник для детектов |
| PowerShell 4104 | ScriptBlock | AMSI Bypass, обфускация |
| Windows Security 4624/4625 | Logon | Brute force |

## Порты

- **1514/tcp** — Wazuh Agent → Manager.
- **1515/tcp** — Wazuh Enrollment.
- **443/tcp** — Wazuh Dashboard.
- **8220/tcp** — Elastic Fleet (Security Onion).
- **5055/tcp** — Elastic Agent (Security Onion).
