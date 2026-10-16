## Correlation Rules: как дебажить

### Проблема 1: `same_user` не находит поле
- **Симптом**: правило не срабатывает.
- **Причина**: `<same_user />` ищет `TargetUserName` (с заглавной), а в eventchannel-событиях поле называется `win.eventdata.targetUserName` (с маленькой).
- **Решение**: `<same_field>win.eventdata.targetUserName</same_field>`.

### Проблема 2: `if_sid` + `frequency` — несовместимы
- **Симптом**: `ERROR: Invalid use of frequency/context options`.
- **Причина**: Wazuh требует `<if_matched_sid>` для правил с `frequency` и `timeframe`.
- **Решение**: использовать `<if_matched_sid>` вместо `<if_sid>`.

### Вывод
Wazuh **не унифицирует** имена полей для разных источников. Перед написанием правила **всегда** проверяйте поля через `wazuh-logtest`.


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
