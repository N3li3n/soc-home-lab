# Telegram Integration

## Статус: ✅ Работает

## Настройка

### 1. Создание бота
- **BotFather** → `/newbot` → получили **токен**.
- **Chat ID** — через `https://api.telegram.org/bot<TOKEN>/getUpdates`.

### 2. Wazuh config (`/var/ossec/etc/ossec.conf`)
```xml
<integration>
  <name>custom-telegram</name>
  <hook_url>https://api.telegram.org/bot<TOKEN>/sendMessage</hook_url>
  <api_key><CHAT_ID></api_key>
  <level>12</level>
  <alert_format>json</alert_format>
</integration>

Python-скрипт (/var/ossec/integrations/custom-telegram.py)
