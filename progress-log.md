## День 1 (Неделя 3) — Successful Brute Force
- Создано правило `100700` (10+ failed logins).
- Создано правило `100701` (successful brute force).
- Тест «шум» — OK.
- Тест «паттерн» — OK (с реальным пользователем `hacker`).
- Скриншот: `docs/screenshots/correlation-bruteforce.png`
- Lessons learned: `same_field` вместо `same_user` для eventchannel.

## Correlation Rules: Successful Brute Force (T1110)

### Правило 100700 (10+ failed logins)
- **Цель**: детектировать **много неудачных** попыток входа.
- **Условие**: `<if_matched_sid>60122</if_matched_sid>` + `frequency="5" timeframe="300"`.
- **Группировка**: `<same_field>win.eventdata.targetUserName</same_field>`.

### Правило 100701 (successful brute force)
- **Цель**: детектировать **успешный вход** после серии неудачных.
- **Условие**: `<if_sid>60106</if_sid>` + `<if_matched_sid>100700</if_matched_sid>`.
- **Группировка**: `<same_field>win.eventdata.targetUserName</same_field>`.

### Ключевые уроки
1. `same_user` **не работает** для eventchannel-событий — используйте `same_field`.
2. `frequency` + `timeframe` **требуют** `<if_matched_sid>`, а не `<if_sid>`.
3. Для теста successful brute force **нужен реальный пользователь** (не `NonexistentUser`), иначе `same_field` не сработает.


## Recon Chain (T1087)

### Правило 100702
- **Цель**: детектировать **3+ разведочные команды** за 2 минуты.
- **Условие**: `<if_matched_sid>92031</if_matched_sid>` + `frequency="3" timeframe="120"`.
- **Группировка**: `<same_field>win.eventdata.user</same_field>`.

### Ключевые уроки
1. `61603` (Sysmon EID 1) — **уровень 0**, не создаёт алерт, `if_matched_sid` **не работает**.
2. `92032` — срабатывает **только на `cmd.exe`**, не на `net`/`whoami`.
3. `92031` — **правильное** правило для recon: срабатывает на **разведочные** команды (`net user`, `whoami` и т.д.).
4. Для `if_matched_sid` используйте **только** правила, которые **создают алерты** (уровень > 0).


## День 2 (Неделя 3) — Recon Chain
- Создано правило `100702` (3+ discovery commands in 2 minutes).
- Тест «шум» — OK (один `cmd.exe`).
- Тест «паттерн» — OK (`net user`, `whoami`, `net localgroup`).
- Скриншот: `docs/screenshots/correlation-recon-chain.png`
- Lessons learned: `92031` (Discovery activity) — правильное родительское правило для recon.


## День 3 (Неделя 4) — Behavioral Detection

### Правило 100710 (LSASS Anomaly) — РАБОТАЕТ
- **Цель**: детектировать аномальный доступ к `lsass.exe`.
- **Метод**: прямое правило (без `if_sid`) с явным списком подозрительных процессов.
- **Тесты**:
  - `wazuh-logtest` — ✅ Phase 3 сработала.
  - `alerts.json` — ✅ (нужно проверить `grep`).
  - Дашборд — ⏳ (требует времени на индексацию).

### Ключевые уроки
1. `if_sid>61609` **не работает** — Sysmon EID 10 уровня 0.
2. **Прямое правило** (без `if_sid`) — работает.
3. `wazuh-logtest` **не всегда** отражает реальную работу — проверяйте `alerts.json`.

### Вывод
Behavioral Detection **работает**. Правило `100710` детектирует ProcDump и другие дамперы.
