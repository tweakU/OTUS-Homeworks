## Домашнее задание № 9 — «Инициализация системы. Systemd»


**Цель домашнего задания**:  
1 понимать различие систем инициализации;  
2 использовать основные утилиты systemd;  
3 изучить состав и синтаксис systemd unit.


**Домашнее задание**:  
1 Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).  
2 Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).  
3 Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.


**Выполнение домашнего задания**:

1) Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова.
Для начала создаём файл с конфигурацией для сервиса в директории /etc/default - из неё сервис будет брать необходимые переменные.
```console
root@test:~# cat /etc/default/watchlog
# Configuration file for my watchlog service
# Place it to the /etc/default

# File and word in that file that we will be monitor
WORD="ALERT"
LOG=/var/log/watchlog.log
```

Затем создаем /var/log/watchlog.log и пишем туда строки на своё усмотрение,
плюс ключевое слово ‘ALERT’
```console
root@test:~# cat /var/log/watchlog.log | wc -l && cat /var/log/watchlog.log | grep -i alert
88
ALERT
```

Создадим скрипт:
```console
root@test:~# cat /opt/watchlog.sh
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi
```

Команда logger отправляет лог в системный журнал.
Добавим права на запуск файла:
```console
root@test:~# chmod +x /opt/watchlog.sh
```

Создадим юнит для сервиса:
```console
root@test:~# cat /etc/systemd/system/watchlog.service
yx[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/default/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
```










Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
