##  Цель

Собрать полноценный SOC-стенд для практики:
- Развёртывание и настройка SIEM (Wazuh, Security Onion).
- Написание правил детектирования (Sigma, Wazuh, Elastic).
- Симуляция атак и анализ алертов.
- Threat hunting и Incident Response.
- **Purple Team: поиск слепых зон и их закрытие.**

##  Featured Case: Blind Spots (Purple Team Assessment)

Я запустил продвинутые атаки против своей же лаборатории — и **некоторые не детектировались**. Вот как я нашёл и закрыл слепые зоны:

| Атака | Детект | Слепая зона | Фикс |
|-------|--------|-------------|------|
| LSASS Dump (ProcDump) | ❌ | Sysmon EID 10 не создаёт алерты | Правила `100710`, `100711` (EID 4688) |
| LSASS Dump (comsvcs.dll) | ❌ | Обход через rundll32 | Правило `100711` |
| AMSI Bypass | ❌ | Sysmon молчит, 4104 не собирался | Правило `100800` (EID 4104) |
| LOLBin (mshta.exe) | ❌ | Нет правил на LOLBins | Правила `100900`–`100903` (EID 4688) |

**Результат:** после фиксов все 4 атаки детектируются. [Полный разбор](./threat-hunting/blind-spots.md).

##  Архитектура

| VM | Роль | IP | ОС |
|----|------|-----|-----|
| Ubuntu (Wazuh) | Wazuh Manager + Indexer + Dashboard | 192.168.201.19 | Ubuntu 24.04 |
| Kali | Атакующая машина | 192.168.206.216 | Kali Linux |
| Windows 11 | Жертва (домен evilcorp.local) | 192.168.202.20 | Windows 11 |
| Ubuntu (Security Onion) | Security Onion Standalone | 192.168.202.10 | Security Onion 3.3.0 |

##  Сценарии

### 1. SSH Brute Force (T1110)
- **Атака:** Hydra с Kali на Ubuntu.
- **Детект:** правила `100100`, `100101`.
- **Реакция:** Active Response (`firewall-drop`).

### 2. Mimikatz / LSASS Access (T1003.001)
- **Атака:** Atomic Red Team `T1003.001`.
- **Детект:** встроенное правило `92900`, кастомные `100710`, `100711`.

### 3. AMSI Bypass (T1562.001)
- **Атака:** `[Ref].Assembly.GetType('AmsiUtils')...`.
- **Детект:** правило `100800` (EID 4104).

### 4. LOLBin (T1218.005)
- **Атака:** `mshta.exe javascript:alert('test')`.
- **Детект:** правила `100900`–`100903` (EID 4688).

### 5. Создание пользователя (T1136.001)
- **Атака:** `net user hacker /add`.
- **Детект:** встроенное правило `60109`.

### 6. Добавление в админы (T1098)
- **Атака:** `net localgroup Administrators hacker /add`.
- **Детект:** встроенное правило `4732`.

 Клонировать репозиторий:
   ```bash
   git clone https://github.com/N3li3n/soc-home-lab.git
