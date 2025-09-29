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
root@test:~# cat > /etc/default/watchlog
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
root@test:~# cat > /opt/watchlog.sh
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
root@test:~# cat > /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/default/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
```

Создадим юнит для таймера:
```console
root@test:~# cat > /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 seconds

[Timer]
#Run every 30 seconds
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
```

Затем достаточно запустить timer и убедиться в результате:
```console
root@test:~# systemctl start watchlog.timer

root@test:~# tail -n 1000 /var/log/syslog | grep word
Sep 29 23:03:23 test root: Mon Sep 29 11:03:23 PM MSK 2025: I found word, Master!
Sep 29 23:04:04 test root: Mon Sep 29 11:04:04 PM MSK 2025: I found word, Master!
Sep 29 23:04:36 test root: Mon Sep 29 11:04:36 PM MSK 2025: I found word, Master!
```

2) Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта.
Устанавливаем spawn-fcgi и необходимые для него пакеты:
```console
root@test:~# apt install spawn-fcgi php php-cgi php-cli apache2 libapache2-mod-fcgid -y
```

Сам init скрипт, который будем переписывать, можно найти здесь: https://gist.github.com/cea2k/1318020 

Но перед этим необходимо создать файл с настройками для будущего сервиса в файле /etc/spawn-fcgi/fcgi.conf.
Он должен получится следующего вида:
```console
cat > /etc/spawn-fcgi/fcgi.conf

# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u www-data -g www-data -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"

Ctrl + D
```

А сам юнит-файл будет примерно следующего вида:
```console
cat > /etc/systemd/system/spawn-fcgi.service

[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/spawn-fcgi/fcgi.conf
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target

Ctrl + D
```

Убеждаемся, что все успешно работает:
```console
root@test:~# systemctl start spawn-fcgi

root@test:~# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-09-29 23:14:17 MSK; 3s ago
   Main PID: 10616 (php-cgi)
      Tasks: 33 (limit: 991)
     Memory: 20.7M
        CPU: 23ms
     CGroup: /system.slice/spawn-fcgi.service
             ├─10616 /usr/bin/php-cgi
             ├─10617 /usr/bin/php-cgi
             ├─10618 /usr/bin/php-cgi
             ├─10619 /usr/bin/php-cgi
             ├─10620 /usr/bin/php-cgi
             ├─10621 /usr/bin/php-cgi
             ├─10622 /usr/bin/php-cgi
             ├─10623 /usr/bin/php-cgi
             ├─10624 /usr/bin/php-cgi
             ├─10625 /usr/bin/php-cgi
             ├─10626 /usr/bin/php-cgi
             ├─10627 /usr/bin/php-cgi
             ├─10628 /usr/bin/php-cgi
             ├─10629 /usr/bin/php-cgi
             ├─10630 /usr/bin/php-cgi
             ├─10631 /usr/bin/php-cgi
             ├─10632 /usr/bin/php-cgi
             ├─10633 /usr/bin/php-cgi
             ├─10634 /usr/bin/php-cgi
             ├─10635 /usr/bin/php-cgi
             ├─10636 /usr/bin/php-cgi
             ├─10637 /usr/bin/php-cgi
             ├─10638 /usr/bin/php-cgi
             ├─10639 /usr/bin/php-cgi
             ├─10640 /usr/bin/php-cgi
             ├─10641 /usr/bin/php-cgi
             ├─10642 /usr/bin/php-cgi
             ├─10643 /usr/bin/php-cgi
             ├─10644 /usr/bin/php-cgi
             ├─10645 /usr/bin/php-cgi
             ├─10646 /usr/bin/php-cgi
             ├─10647 /usr/bin/php-cgi
             └─10648 /usr/bin/php-cgi

Sep 29 23:14:17 test systemd[1]: Started Spawn-fcgi startup service by Otus.
```


3) Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.
Установим Nginx из стандартного репозитория:
```console

```




Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
