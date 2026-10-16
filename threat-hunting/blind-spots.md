# Blind Spots: Reverse Shell (T1059.001)

## Проблема: Event ID 3 (Network Connect)

**Цель**: детектировать reverse shell через Sysmon EID 3 + PowerShell (правило `100703`).

**Симптом**: правило `100703` **не срабатывает**, хотя:
- Sysmon пишет EID 3 в Event Viewer.
- Wazuh-агент читает канал Sysmon.
- В `archives.json` **есть** 13 событий EID 3.

**Что проверено**:
- `win.system.eventID: 3` в дашборде — **пусто** (но в архиве есть).
- `rule.id:92101` — **пусто** (родительское правило не срабатывает).
- `61605` — уровень 0 (не создаёт алерт).

**Причина**: `if_matched_sid>92101` требует, чтобы `92101` сработал 2 раза за 30 секунд. Но `92101` **не срабатывает** на EID 3 от PowerShell (только на определённые Network Connect).

**Решение**: использовать `100601` (Sigma T1059.001) для детектирования reverse shell через `DownloadString`/`IEX`. Это **надёжнее** и **не требует** EID 3.

**Вывод**: не все Event ID Sysmon доходят до дашборда, даже если они есть в архиве. Для критичных детектов **всегда проверяйте** доставку через `archives.json`.



# Blind Spot 1: Sysmon EID 10 не создаёт алерты в Wazuh

## Проблема
- **Sysmon EID 10** (Process Access) **доходит** до `archives.json`, но **не** создаёт **алерты** в `alerts.json`.
- **Правила** `100710`/`100720` (на `win.eventdata.targetImage`/`sourceImage`) **не срабатывают**.

## Слепая зона
- **Sysmon eventchannel** — **не создаёт** **алерты** **в** **дашборде**.
- **Очередь** **агента** **не** **проблема** — **событие** **есть** **в** `archives.json`.

## Решение
- **Переключились** на **Windows Security EID 4688** (`67027`).
- **Правило** `100710` **использует** `win.eventdata.newProcessName` **вместо** `image`.
- **Правило** `100720` **использует** `win.eventdata.processCommandLine` **вместо** `commandLine`.

## Результат
- ✅ **`100710` сработало** (уровень 12, «Behavioral: ProcDump execution detected»).
- ✅ **Слепая зона закрыта** через **альтернативный** **источник** телеметрии.
- ✅ **Дашборд** **показывает** **алерты** в **реальном** **времени**.

## Урок
- **Sysmon eventchannel** **может** **не** **создавать** **алерты** в Wazuh.
- **Windows Security 4688** — **надёжная** **альтернатива**.
- **Blind Spot** — **это** **не** **всегда** **отсутствие** **правила**; **иногда** — **отсутствие** **подходящего** **источника** телеметрии.




## Blind Spot 2: AMSI Bypass — Sysmon молчит

### Атака
- **Техника:** `[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)`.
- **Источник:** Win11 (PowerShell).
- **MITRE:** T1562.001 (Disable or Modify Tools).

### Слепая зона
- **Sysmon EID 1** **не логирует** AMSI Bypass (нет создания процесса).
- **`if_sid>64104`** **не сработал** для `100800`.
- **`win.system.channel`** = `Microsoft-Windows-PowerShell/Operational`.

### Фикс
1. **Включили** ScriptBlock Logging (EID 4104).
2. **Настроили** сбор `Microsoft-Windows-PowerShell/Operational` в `ossec.conf`.
3. **Правило `100800`** использует:
   - `<if_group>powershell</if_group>`.
   - `<field name="win.eventdata.scriptBlockText" type="pcre2">(?i)AmsiUtils</field>`.
   - `<description>CRITICAL: AMSI Bypass detected</description>`.

### Ключевые поля EID 4104
- `win.eventdata.scriptBlockText` — текст скрипта.
- `win.eventdata.scriptBlockId` — ID блока.
- `win.system.channel` — `Microsoft-Windows-PowerShell/Operational`.

### Результат
- ✅ `100800` сработало (level 12, CRITICAL).
- ✅ **Blind Spot 2 закрыт**.

---

## Выводы

### Sysmon vs Windows Event Log
- **Sysmon EID 1** — только создание процессов.
- **Sysmon EID 10** — доходит до `archives.json`, но **не** создаёт алерты.
- **Windows Security EID 4688** — **надёжная** альтернатива для ProcDump/rundll32.
- **PowerShell ScriptBlock Logging (EID 4104)** — **обязателен** для AMSI Bypass.

### Правила Wazuh
- **`if_sid>67027`** — для EID 4688.
- **`if_group>powershell`** — для EID 4104.
- **Поля** должны **совпадать** с **декодированными** именами (`newProcessName`, `scriptBlockText`).
- **`<match>`** ищет **только** в `full_log` — **используйте** `<field>` с **точным** именем.

### Purple Team Cycle
1. **Атака** → детект.
2. **Обход** → слепая зона.
3. **Патч** → правило.
4. **Повторная атака** → детект.

### Инструменты
- **Atomic Red Team** — для симуляции атак (T1003.001, T1562.001).
- **ProcDump** — дамп LSASS.
- **comsvcs.dll** — обход через rundll32.
- **AMSI Bypass** — обход через `AmsiUtils`.



## Blind Spot 3: Mshta LOLBin (T1218.005)

### Атака
- **Инструмент:** Atomic Red Team.
- **Тест:** `T1218.005-1` — *Mshta executes JavaScript Scheme Fetch Remote Payload With GetObject*.
- **Команда:** `Invoke-AtomicTest T1218.005 -TestNumbers 1`.
- **Источник:** Win11 (агент `Win11`, agent.id `002`).
- **MITRE:** T1218.005 (Signed Binary Proxy Execution: Mshta), T1059.007 (JavaScript/JScript).

### Слепая зона
- **Sysmon EID 1** доходит до `alerts.json` корректно.
- **Кастомное правило `100900`** (mshta + `javascript:`/`vbscript:`) **не срабатывало**.
- **Правило `100901`** (mshta + URL/UNC) **не срабатывало**.
- **Правило `100902`** (mshta + подозрительный родитель) **не срабатывало**.
- **Правило `100903`** (корреляция) **не срабатывало**.

### Диагностика

**Проблема 1: `if_sid 61603` не отображался в алертах.**
Базовое правило `61603` (Sysmon EID 1) имеет низкий уровень и не попадает в `alerts.json`, но **обязательно срабатывает** внутри движка Wazuh. Это не ошибка — кастомные правила наследуют контекст через `<if_sid>`.

**Проблема 2: `same_agent` — deprecated в Wazuh 4.14.x.**

#### Фикс
**Новый код не нужен.** Существующее правило `100901` (URL/UNC) уже покрывает этот вектор — его регулярка `(?i)(https?://|ftp://|\\\\)` матчит URL в командной строке.

Попытка создать отдельное правило `100904` для URL оказалась избыточной: Wazuh применяет **первое подходящее правило по порядку ID**, и `100901` перехватывает событие раньше.

#### Результат
- ✅ `100901` сработало (level 12) на тест №6, timestamp `15:42:24`.
- ✅ Вектор удаленного URL/UNC покрыт.
- ⚠️ `100902` не сработало из-за родителя `WmiPrvSE.exe`. Опционально расширено — добавлен `WmiPrvSE` в регулярку `parentImage`.
