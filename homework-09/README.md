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
root@test:~/tmp# apt install nginx -y
```

Для запуска нескольких экземпляров сервиса модифицируем исходный service для использования различной конфигурации,  
а также PID-файлов. Для этого создадим новый unit для работы с шаблонами (/etc/systemd/system/nginx@.service):
```console
cat > /etc/systemd/system/nginx@.service

# Stop dance for nginx
# =======================
#
# ExecStop sends SIGSTOP (graceful stop) to the nginx process.
# If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
# and sends SIGTERM (fast shutdown) to the main process.
# After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
# SIGKILL to all the remaining processes in the process group (KillMode=mixed).
#
# nginx signals reference doc:
# http://nginx.org/en/docs/control.html
#
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx-%I.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target

Ctrl + D
```

Далее необходимо создать два файла конфигурации (/etc/nginx/nginx-first.conf, /etc/nginx/nginx-second.conf).  
Их можно сформировать из стандартного конфига /etc/nginx/nginx.conf, с модификацией путей до PID-файлов и разделением по портам:
```console
pid /run/nginx-first.pid;

http {
…
	server {
		listen 9001;
	}
#include /etc/nginx/sites-enabled/*;
….
}
```

Этого достаточно для успешного запуска сервисов.
Проверим работу:
```console
root@test:~# systemctl start nginx@first

root@test:~# systemctl status nginx@first
● nginx@first.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; vendor preset: enabled)
     Active: active (running) since Tue 2025-09-30 03:17:15 MSK; 3min 1s ago
       Docs: man:nginx(8)
    Process: 3068 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-first.conf -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 3069 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 3116 ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on; -s reload (code=exited, status=0/SUCCESS)
   Main PID: 3070 (nginx)
      Tasks: 3 (limit: 2198)
     Memory: 3.4M
        CPU: 29ms
     CGroup: /system.slice/system-nginx.slice/nginx@first.service
             ├─3070 "nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on;"
             ├─3117 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ">
             └─3118 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ">

Sep 30 03:17:15 test systemd[1]: Starting A high performance web server and a reverse proxy server...
Sep 30 03:17:15 test systemd[1]: Started A high performance web server and a reverse proxy server.
Sep 30 03:19:06 test systemd[1]: Reloading A high performance web server and a reverse proxy server...
Sep 30 03:19:06 test systemd[1]: Reloaded A high performance web server and a reverse proxy server.

root@test:~# systemctl start nginx@second

root@test:~# systemctl status nginx@second
● nginx@second.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; vendor preset: enabled)
     Active: active (running) since Tue 2025-09-30 03:19:28 MSK; 1min 5s ago
       Docs: man:nginx(8)
    Process: 3129 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-second.conf -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 3130 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 3131 (nginx)
      Tasks: 3 (limit: 2198)
     Memory: 3.2M
        CPU: 15ms
     CGroup: /system.slice/system-nginx.slice/nginx@second.service
             ├─3131 "nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on;"
             ├─3132 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ">
             └─3133 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ">

Sep 30 03:19:28 test systemd[1]: Starting A high performance web server and a reverse proxy server...
Sep 30 03:19:28 test systemd[1]: Started A high performance web server and a reverse proxy server.
```

Проверить можно несколькими способами, например, посмотреть, какие порты слушаются:
```console
root@test:~# ss -tnlp | grep nginx
LISTEN 0      511          0.0.0.0:9002      0.0.0.0:*    users:(("nginx",pid=3133,fd=6),("nginx",pid=3132,fd=6),("nginx",pid=3131,fd=6))
LISTEN 0      511          0.0.0.0:9001      0.0.0.0:*    users:(("nginx",pid=3118,fd=6),("nginx",pid=3117,fd=6),("nginx",pid=3070,fd=6))
```

Или просмотреть список процессов:
```console
root@test:~# ps afx | grep nginx
   3175 pts/1    S+     0:00                          \_ grep --color=auto nginx
   3070 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on;
   3117 ?        S      0:00  \_ nginx: worker process
   3118 ?        S      0:00  \_ nginx: worker process
   3131 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on;
   3132 ?        S      0:00  \_ nginx: worker process
   3133 ?        S      0:00  \_ nginx: worker process
```
Если мы видим две группы процессов nginx, то всё в порядке.


Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
