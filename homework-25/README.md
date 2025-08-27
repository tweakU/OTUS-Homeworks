## Домашнее задание № 25 — «Основы сбора и хранения логов»


**Цель домашнего задания**:  
Научится проектировать централизованный сбор логов. Рассмотреть особенности разных платформ для сбора логов.

**Выполнение домашнего задания**:

**1) Создаём виртуальные машины.**
```console
PS C:\Users\tanin\otus\hw-25> vagrant up
Bringing machine 'web' up with 'virtualbox' provider...
Bringing machine 'log' up with 'virtualbox' provider...
...
==> web: Machine booted and ready!
...
==> log: Machine booted and ready!
```

Для правильной работы c логами, нужно, чтобы на всех хостах было настроено одинаковое время. 
```console
root@web:~# timedatectl
               Local time: Thu 2025-08-21 00:27:44 UTC
           Universal time: Thu 2025-08-21 00:27:44 UTC
                 RTC time: Thu 2025-08-21 00:27:44
                Time zone: Etc/UTC (UTC, +0000)
System clock synchronized: no
              NTP service: inactive
          RTC in local TZ: no
root@web:~# date
Thu Aug 21 12:28:00 AM UTC 2025

root@web:~# timedatectl set-timezone Europe/Moscow
root@web:~# date
Thu Aug 21 03:29:52 AM MSK 2025

root@web:~# timedatectl set-ntp true
```
Выполним аналогичные действия на виртуальной машине "log".

**2) Установка nginx на виртуальной машине web:**

Установим nginx:
```console
root@web:~# apt update && apt install -y nginx
```

Проверим, что nginx работает корректно:
```console
root@web:~# systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2025-08-21 03:48:42 MSK; 20s ago
       Docs: man:nginx(8)
    Process: 3425 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 3426 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 3517 (nginx)
      Tasks: 3 (limit: 2219)
     Memory: 4.7M
        CPU: 19ms
     CGroup: /system.slice/nginx.service
             ├─3517 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─3520 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
             └─3521 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""

Aug 21 03:48:42 web systemd[1]: Starting A high performance web server and a reverse proxy server...
Aug 21 03:48:42 web systemd[1]: Started A high performance web server and a reverse proxy server.

root@web:~# ss -ntlp | grep 80
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=3521,fd=6),("nginx",pid=3520,fd=6),("nginx",pid=3517,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=3521,fd=7),("nginx",pid=3520,fd=7),("nginx",pid=3517,fd=7))

root@web:~# curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
Видим что nginx запускается корректно.

**3) Настройка центрального сервера сбора логов.**

rsyslog должен быть установлен по умолчанию в нашей ОС, проверим это:
```console
root@log:~# apt list rsyslog
Listing... Done
rsyslog/jammy-updates,jammy-security,now 8.2112.0-2ubuntu2.2 amd64 [installed,automatic]
N: There is 1 additional version. Please use the '-a' switch to see it
```
или таким образом
```console
root@log:~# dpkg -l | grep rsyslog
ii  rsyslog                                8.2112.0-2ubuntu2.2                     amd64        reliable system and kernel logging daemon
```

Все настройки Rsyslog хранятся в файле /etc/rsyslog.conf.  
Для того, чтобы наш сервер мог принимать логи, нам необходимо внести следующие изменения в файл: открыть порт 514 (TCP и UDP) в разделе MODULES.  

Находим закомментированные строки:
```console
# provides UDP syslog reception
#module(load="imudp")
#input(type="imudp" port="514")

# provides TCP syslog reception
#module(load="imtcp")
#input(type="imtcp" port="514")
```

И приводим их к виду:
```console
# provides UDP syslog reception
module(load="imudp")
input(type="imudp" port="514")

# provides TCP syslog reception
module(load="imtcp")
input(type="imtcp" port="514")
```

В конец файла /etc/rsyslog.conf добавляем правила приёма сообщений от хостов:
```console
# Adds remote logs
$template RemoteLogs,"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~
```
Данные параметры будут отправлять в папку /var/log/rsyslog логи, которые будут приходить от других серверов.  
Например, access-логи nginx от сервера web, будут идти в файл /var/log/rsyslog/web/nginx_access.log.  
Далее сохраняем файл и перезапускаем службу rsyslog: systemctl restart rsyslog.

Если ошибок не допущено, то у нас будут видны открытые порты TCP, UDP 514:  
```console
root@log:~# ss -ntulp | grep rsyslog
udp   UNCONN 0      0             0.0.0.0:514       0.0.0.0:*    users:(("rsyslogd",pid=2027,fd=5))
udp   UNCONN 0      0                [::]:514          [::]:*    users:(("rsyslogd",pid=2027,fd=6))
tcp   LISTEN 0      25            0.0.0.0:514       0.0.0.0:*    users:(("rsyslogd",pid=2027,fd=7))
tcp   LISTEN 0      25               [::]:514          [::]:*    users:(("rsyslogd",pid=2027,fd=8))
```


Далее настроим отправку логов с web-сервера.  
Заходим на web сервер: vagrant ssh web.  
Переходим в root пользователя: sudo -i.  
Проверим версию nginx: nginx -v:  
```console
root@web:~# nginx -v
nginx version: nginx/1.18.0 (Ubuntu)
```

Версия nginx должна быть 1.17 или выше. В нашем примере используется версия nginx 1.18.  
Находим в файле /etc/nginx/nginx.conf раздел с логами и приводим их к следующему виду:  
```console
        ##
        # Logging Settings
        ##

        access_log /var/log/nginx/access.log;
        access_log syslog:server=192.168.56.15:514,tag=nginx_access,severity=info combined;
        error_log /var/log/nginx/error.log;
        error_log syslog:server=192.168.56.15:514,tag=nginx_error;
```

Для access-логов указываем удаленный сервер и уровень логов, которые нужно отправлять.  
Для error_log добавляем удаленный сервер.  
Если требуется чтобы логи хранились локально и отправлялись на удаленный сервер, требуется указать 2 строки.  
Tag нужен для того, чтобы логи записывались в разные файлы.  
По умолчанию, error-логи отправляют логи, которые имеют severity: error, crit, alert и emerg.  
Если требуется хранить или пересылать логи с другим severity, то это также можно указать в настройках nginx.  
Далее проверяем, что конфигурация nginx указана правильно:  
```console
root@web:~# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Попробуем несколько раз зайти по адресу http://192.168.56.10  
Далее заходим на log-сервер и смотрим информацию об nginx:  
```console
root@log:~# cat /var/log/rsyslog/web/nginx_access.log
Aug 24 18:01:57 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:01:57 +0300] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
Aug 24 18:02:00 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:02:00 +0300] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
Aug 24 18:02:08 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:02:08 +0300] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
Aug 24 18:02:56 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:02:56 +0300] "GET /metrics HTTP/1.1" 404 162 "-" "curl/7.81.0"
Aug 24 18:03:00 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:03:00 +0300] "GET /metrics HTTP/1.1" 404 162 "-" "curl/7.81.0"

root@log:~# cat /var/log/rsyslog/web/nginx_error.log
cat: /var/log/rsyslog/web/nginx_error.log: No such file or directory
```

Поскольку наше приложение работает без ошибок, файл nginx_error.log не будет создан.  
Чтобы сгенерировать ошибку, можно переместить файл веб-страницы, который открывает nginx:  
mv /var/www/html/index.nginx-debian.html /var/www/ 
После этого мы получим 403 ошибку.
```console
root@log:~# cat /var/log/rsyslog/web/nginx_error.log
Aug 24 18:13:29 web nginx_error: 2025/08/24 18:13:29 [error] 3275#3275: *1 directory index of "/var/www/html/" is forbidden, client: 192.168.56.10, server: _, request: "GET / HTTP/1.1", host: "192.168.56.10"

root@log:~# cat /var/log/rsyslog/web/nginx_access.log
Aug 24 18:01:57 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:01:57 +0300] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
Aug 24 18:02:00 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:02:00 +0300] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
Aug 24 18:02:08 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:02:08 +0300] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
Aug 24 18:02:56 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:02:56 +0300] "GET /metrics HTTP/1.1" 404 162 "-" "curl/7.81.0"
Aug 24 18:03:00 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:03:00 +0300] "GET /metrics HTTP/1.1" 404 162 "-" "curl/7.81.0"
Aug 24 18:03:00 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:03:00 +0300] "GET /metrics HTTP/1.1" 404 162 "-" "curl/7.81.0"
Aug 24 18:13:29 web nginx_access: 192.168.56.10 - - [24/Aug/2025:18:13:29 +0300] "GET / HTTP/1.1" 403 162 "-" "curl/7.81.0"
```
Видим, что логи отправляются корректно. 

**8) ELK**

Для установки ELK стека с помощью пакетного менеджера APT добавим зеркало Яндекc:
```console
root@elk:~# echo "deb [trusted=yes] https://mirror.yandex.ru/mirrors/elastic/8/ stable main" | tee /etc/apt/sources.list.d/elastic-8.x.list
```

Установим Elasticsearch и сохраним блок Security autoconfiguration information в файл:
```console
root@elk:~# apt install elasticsearch -y

root@elk:~# cat ~/elk/elk_help
--------------------------- Security autoconfiguration information ------------------------------

Authentication and authorization are enabled.
TLS for the transport and HTTP layers is enabled and configured.

The generated password for the elastic built-in superuser is : *VTLBiOW6UmfqeNxt0qo

If this node should join an existing cluster, you can reconfigure this with
'/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <token-here>'
after creating an enrollment token on your existing cluster.

You can complete the following actions at any time:

Reset the password of the elastic built-in superuser with
'/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic'.

Generate an enrollment token for Kibana instances with
 '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana'.

Generate an enrollment token for Elasticsearch nodes with
'/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node'.

-------------------------------------------------------------------------------------------------
### NOT starting on installation, please execute the following statements to configure elasticsearch service to start automatically using systemd
 sudo systemctl daemon-reload
 sudo systemctl enable elasticsearch.service
### You can start elasticsearch service by executing
 sudo systemctl start elasticsearch.service
```

Перед запуском Elasticsearch проведём базовую настройку:
1. cluster.name
2. node.name
3. network.host: 0.0.0.0 (в таком случае es будет работать на любом IP)
4. cluster.initial_master_nodes: best practice - указать IP вместо hostname
5. transport.host: 0.0.0.0

```console
root@elk:~# systemctl start elasticsearch

root@elk:~# systemctl status elasticsearch
● elasticsearch.service - Elasticsearch
     Loaded: loaded (/lib/systemd/system/elasticsearch.service; disabled; vendor preset: enabled)
     Active: active (running) since Sun 2025-08-24 17:02:53 UTC; 52s ago
       Docs: https://www.elastic.co
   Main PID: 3473 (java)
      Tasks: 79 (limit: 2275)
     Memory: 1.4G
        CPU: 39.581s
     CGroup: /system.slice/elasticsearch.service
             ├─3473 /usr/share/elasticsearch/jdk/bin/java -Xms4m -Xmx64m -XX:+UseSerialGC -Dcli.name=server -Dcli.script=/usr/share/elasticsearch/bin/elasticsearch -Dcli.libs=lib/tools/server-cli -Des.path.home>
             ├─3535 /usr/share/elasticsearch/jdk/bin/java -Des.networkaddress.cache.ttl=60 -Des.networkaddress.cache.negative.ttl=10 -XX:+AlwaysPreTouch -Xss1m -Djava.awt.headless=true -Dfile.encoding=UTF-8 -Dj>
             └─3555 /usr/share/elasticsearch/modules/x-pack-ml/platform/linux-x86_64/bin/controller

Aug 24 17:02:06 elk systemd[1]: Starting Elasticsearch...
Aug 24 17:02:53 elk systemd[1]: Started Elasticsearch.
```

Проверим работу кластера, сменой пароля в интерактивном режиме (ключ i).  
Нужная команда содержится в сохраненном выше help`е:
```console
root@elk:~# cat ~/elk/elk_help | grep -i reset
Reset the password of the elastic built-in superuser with
'/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic'.

root@elk:~# /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -i
This tool will reset the password of the [elastic] user.
You will be prompted to enter the password.
Please confirm that you would like to continue [y/N]y
Enter password for [elastic]:
Re-enter password for [elastic]:
Password for the [elastic] user successfully reset.

root@elk:~# curl -k -u elastic:897653 https://localhost:9200/_cat/health?v
epoch      timestamp cluster    status node.total node.data shards pri relo init unassign unassign.pri pending_tasks max_task_wait_time active_shards_percent
1756079294 23:48:14  otus-tanin green           1         1      3   3    0    0        0            0             0                  -                100.0%
```

**Kibana**
(best practice: ставить Kibana на хост с nginx и делать proxy_pass на 127.0.0.1:5601)

Установим Kibana, используем зеркало Яндекc:
```console
root@elk:~# apt install kibana

root@elk:~# systemctl status kibana
○ kibana.service - Kibana
     Loaded: loaded (/lib/systemd/system/kibana.service; disabled; vendor preset: enabled)
     Active: inactive (dead)
       Docs: https://www.elastic.co
```

Внесем изменения в конфигурационный файл в соотвествии с техзаданием - заменим значение по умолчанию "localhost", "любой IP-адрес":
```
server.host: "0.0.0.0"
```

Запустим Kibana:
```cosnole
root@elk:~# systemctl status kibana.service
● kibana.service - Kibana
     Loaded: loaded (/lib/systemd/system/kibana.service; disabled; vendor preset: enabled)
     Active: active (running) since Wed 2025-08-27 17:41:52 MSK; 47s ago
       Docs: https://www.elastic.co
   Main PID: 1949 (node)
      Tasks: 11 (limit: 2219)
     Memory: 653.1M
        CPU: 27.882s
     CGroup: /system.slice/kibana.service
             └─1949 /usr/share/kibana/bin/../node/glibc-217/bin/node /usr/share/kibana/bin/../src/cli/dist

root@elk:~# ss -tnlp | grep :5601
LISTEN 0      511          0.0.0.0:5601      0.0.0.0:*    users:(("node",pid=1949,fd=22))

root@elk:~# ip a | grep 192.
    inet 192.168.1.125/24 brd 192.168.1.255 scope global eth1
```

```console
root@elk:~# curl http://192.168.1.125:5601/login?next=%2F | head
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html><html lang="en"><head><meta charSet="utf-8"/><meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/><meta name="viewport" content="width=device-width"/><title>Elastic</title><style>

        @font-face {
          font-family: 'Inter';
          font-style: normal;
          font-weight: 100;
          src: url('/8634f44eaffa/ui/fonts/inter/Inter-Thin.woff2') format('woff2'), url('/8634f44eaffa/ui/fonts/inter/Inter-Thin.woff') format('woff');
        }

        @font-face {
 59  106k   59 64665    0     0  4835k      0 --:--:-- --:--:-- --:--:-- 5262k
curl: (23) Failure writing output to destination
```

Установим Logstash








Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
