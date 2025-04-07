#!/bin/bash

 

# Переменные

LOCK_FILE="/tmp/script_lockfile"

LOG_FILE="/var/log/apache2/access.log"  # Лог Apache на Ubuntu

OUTPUT_EMAIL="taninaa@rambler.ru"  # Ваш адрес электронной почты

FROM_EMAIL="taninaa@rambler.ru"  # Отправитель (ваш адрес)

TEMP_FILE="/tmp/report.txt"

LAST_RUN_FILE="/tmp/last_run_time"

 

# Проверка наличия блокировки (чтобы не запускать несколько копий)

if [ -f "$LOCK_FILE" ]; then

  echo "Скрипт уже запущен. Выход."

  exit 1

else

  touch "$LOCK_FILE"

fi

 

# Определение времени последнего запуска (если файл существует)

if [ -f "$LAST_RUN_FILE" ]; then

  LAST_RUN=$(cat "$LAST_RUN_FILE")

else

  LAST_RUN="1970-01-01 00:00:00"

fi

 

# Обновление времени последнего запуска

echo "$(date '+%Y-%m-%d %H:%M:%S')" > "$LAST_RUN_FILE"

 

# Временной диапазон

START_TIME="$LAST_RUN"

END_TIME=$(date '+%Y-%m-%d %H:%M:%S')

 

# Формирование отчета

{

  echo "Отчет за период с $START_TIME по $END_TIME"

  echo "----------------------------------------------------"

  echo "1. Список IP адресов с наибольшим количеством запросов:"

  

  sudo awk -v start="$START_TIME" -v end="$END_TIME" \

    '$4 >= "["start && $4 <= "["end {

      ip[$1]++

    } END {

      for (i in ip) {

        print i, ip[i]

      }

    }' "$LOG_FILE" | sort -k2,2nr | head -n 10

 

  echo "----------------------------------------------------"

  echo "2. Список запрашиваемых URL с наибольшим количеством запросов:"

  

  sudo awk -v start="$START_TIME" -v end="$END_TIME" \

    '$4 >= "["start && $4 <= "["end {

      url[$7]++

    } END {

      for (i in url) {

        print i, url[i]

      }

    }' "$LOG_FILE" | sort -k2,2nr | head -n 10

 

  echo "----------------------------------------------------"

  echo "3. Ошибки веб-сервера/приложения:"

  

  sudo awk -v start="$START_TIME" -v end="$END_TIME" \

    '$4 >= "["start && $4 <= "["end && $9 ~ /^5/ {

      print $0

    }' "$LOG_FILE"

  

  echo "----------------------------------------------------"

  echo "4. Список всех HTTP кодов с количеством запросов:"

  

  sudo awk -v start="$START_TIME" -v end="$END_TIME" \

    '$4 >= "["start && $4 <= "["end {

      codes[$9]++

    } END {

      for (i in codes) {

        print i, codes[i]

      }

    }' "$LOG_FILE" | sort -k2,2nr

  

} > "$TEMP_FILE"

 

# Отправка отчета на почту через msmtp

msmtp --from="$FROM_EMAIL" "$OUTPUT_EMAIL" < "$TEMP_FILE"

 

# Удаление временного файла и блокировки

rm -f "$TEMP_FILE"

rm -f "$LOCK_FILE"

```
