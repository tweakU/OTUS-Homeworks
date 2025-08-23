## Домашнее задание № 25 — «Основы сбора и хранения логов»


**Цель домашнего задания**:  
Научится проектировать централизованный сбор логов. Рассмотреть особенности разных платформ для сбора логов.

**Выполнение домашнего задания**:

**1) Создаём виртуальные машины.**
```console
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  boxes = [
    { name: "web", ip: "192.168.56.10" },
    { name: "log", ip: "192.168.56.15" }
  ]

  boxes.each do |opts|
    config.vm.define opts[:name] do |node_config|
      node_config.vm.hostname = opts[:name]
      node_config.vm.network "private_network", ip: opts[:ip]

      node_config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
      end
    end
  end
end
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
Тоже самое выполним на ВМ log.

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

Версия nginx должна быть 1.7 или выше. В нашем примере используется версия nginx 1.18.  
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

Для Access-логов указываем удаленный сервер и уровень логов, которые нужно отправлять. Для error_log добавляем удаленный сервер. Если требуется чтобы логи хранились локально и отправлялись на удаленный сервер, требуется указать 2 строки. 	
Tag нужен для того, чтобы логи записывались в разные файлы.
По умолчанию, error-логи отправляют логи, которые имеют severity: error, crit, alert и emerg. Если требуется хранить или пересылать логи с другим severity, то это также можно указать в настройках nginx. 


```console
root@web:~# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

























Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
