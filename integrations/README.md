# Integrations

Интеграции Wazuh с внешними сервисами.

## Статус

| Сервис | Статус | Примечание |
|--------|--------|------------|
| Telegram | ✅ Работает | Уведомления о критичных алертах (level 12+) |
| VirusTotal | ✅ Работает | Обогащение хешей файлов из FIM |

---

## Telegram

### Настройка
1. **BotFather** → создан бот `SOC_Home_Lab_Bot`.
2. **Chat ID** — `885839603`.
3. **Wazuh config** (`ossec.conf`):
```xml
<integration>
  <name>custom-telegram</name>
  <hook_url>https://api.telegram.org/bot<TOKEN>/sendMessage</hook_url>
  <api_key><CHAT_ID></api_key>
  <level>12</level>
  <alert_format>json</alert_format>
</integration>

Тестирование
Атака: mshta.exe javascript:alert('test') на Win11.

Результат: уведомления пришли в Telegram (rules 100900, 100902, 92900).


## VirusTotal

### Wazuh config (ossec.conf):

xml
<integration>
  <name>virustotal</name>
  <api_key><VT_API_KEY></api_key>
  <rule_id>554</rule_id>
  <alert_format>json</alert_format>
</integration>

Тестирование
Файл: EICAR test file (MD5 44d88612fea8a8f36de82e1278abb02f).

Результат: интеграция сработала, API вернул ответ, алерт 87104 создан.

###Ограничение (не баг интеграции!)
FIM на Windows фиксирует событие added до полной записи файла (size_after: 0).

MD5 в событии — хеш пустого файла (d41d8cd98f00b204e9800998ecf8427e), а не EICAR.

VirusTotal возвращает positives: 0 (потому что проверяет пустой файл).

Интеграция работает корректно — это ограничение Windows FIM
