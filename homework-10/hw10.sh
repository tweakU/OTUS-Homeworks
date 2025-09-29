#!/bin/bash

# Захват блокировки
exec 200>./hw10.lock
flock -n 200 || {
  echo "$(date)"
  echo "Script already running. Exiting..."
  exit 1
}

# Путь к log файлу
LOG=./access-4560-644067.log

# Файл для хранения позиции последнего прочитанного байта
STATE_FILE="./last_position.txt"

# Если состояние не существует, создаём его с начальной позицией 0
if [ ! -f "$STATE_FILE" ]; then
  echo 0 > "$STATE_FILE"
fi

# Чтение последней позиции
LAST_POS=$(cat "$STATE_FILE")

# Чтение новых данных из лога (с позиции LAST_POS)
NEW_LOG=$(tail -c +$((LAST_POS + 1)) "$LOG")

# Если в логе появились новые строки, парсим их
if [ -n "$NEW_LOG" ]; then
  echo "$NEW_LOG" | awk '{print $1}' | sort | uniq -c | sort -n
else
  echo "There are no changes in access.log file"
fi

# Обновляем позицию последнего прочитанного байта
NEW_POS=$(stat -c %s "$LOG")
echo "$NEW_POS" > "$STATE_FILE"
