## Домашнее задание № 15 — «SELinux - когда все запрещено»

**Цель домашнего задания: Диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется**.

**Выполнение домашнего задания**:

0) Развернем образ VM Almalinux/9 (версия 9.4.20240805) посредством Vagrant:

```console
PS C:\Users\Funt1k\otus\hw15> vagrant up
...
selinux: Complete!
    selinux: Job for nginx.service failed because the control process exited with error code.
    selinux: See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.
    selinux: × nginx.service - The nginx HTTP and reverse proxy server
    selinux:      Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
    selinux:      Active: failed (Result: exit-code) since Wed 2025-10-22 13:13:20 UTC; 65ms ago
    selinux:     Process: 8223 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    selinux:     Process: 8242 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
    selinux:         CPU: 62ms
    selinux:
    selinux: Oct 22 13:13:20 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
    selinux: Oct 22 13:13:20 selinux nginx[8242]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    selinux: Oct 22 13:13:20 selinux nginx[8242]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)
    selinux: Oct 22 13:13:20 selinux nginx[8242]: nginx: configuration file /etc/nginx/nginx.conf test failed
    selinux: Oct 22 13:13:20 selinux systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE
    selinux: Oct 22 13:13:20 selinux systemd[1]: nginx.service: Failed with result 'exit-code'.
    selinux: Oct 22 13:13:20 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
```
Данная ошибка появляется из-за того, что SELinux блокирует работу Nginx на нестандартном порту.


1) Запуск nginx на нестандартном порту 3-мя разными способами:
Для начала проверим, что в ОС отключен файервол:

```console
[root@selinux ~]# systemctl status firewalld
○ firewalld.service - firewalld - dynamic firewall daemon
     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; preset: enabled)
     Active: inactive (dead)
       Docs: man:firewalld(1)
```

Также можно проверить, что конфигурация nginx настроена без ошибок:  
```console
[root@selinux ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Далее проверим режим работы SELinux:  
```console
[root@selinux ~]# getenforce
Enforcing
```
Режим Enforcing. Данный режим означает, что SELinux будет блокировать запрещенную активность.


**Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool**  
Находим в логах (/var/log/audit/audit.log) информацию о блокировании порта  
Копируем время, в которое был записан этот лог, и, с помощью утилиты audit2why смотрим:  
```console
[root@selinux ~]# grep 1761138800.643:701 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1761138800.643:701): avc:  denied  { name_bind } for  pid=8242 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly.
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1
```
Утилита audit2why покажет почему трафик блокируется. Исходя из вывода утилиты, мы видим, что нам нужно поменять параметр nis_enabled.


Включим параметр nis_enabled и перезапустим nginx:  
```console
[root@selinux ~]# setsebool -P nis_enabled on

[root@selinux ~]# systemctl restart nginx

[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Wed 2025-10-22 13:45:52 UTC; 7s ago
    Process: 9107 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 9108 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 9109 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 9110 (nginx)
      Tasks: 3 (limit: 11984)
     Memory: 2.9M
        CPU: 114ms
     CGroup: /system.slice/nginx.service
             ├─9110 "nginx: master process /usr/sbin/nginx"
             ├─9111 "nginx: worker process"
             └─9112 "nginx: worker process"

Oct 22 13:45:52 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 22 13:45:52 selinux nginx[9108]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 22 13:45:52 selinux nginx[9108]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Oct 22 13:45:52 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.

[root@selinux ~]# ss -ntlp | grep nginx
LISTEN 0      511          0.0.0.0:4881      0.0.0.0:*    users:(("nginx",pid=9112,fd=6),("nginx",pid=9111,fd=6),("nginx",pid=9110,fd=6))
LISTEN 0      511             [::]:4881         [::]:*    users:(("nginx",pid=9112,fd=7),("nginx",pid=9111,fd=7),("nginx",pid=9110,fd=7))
```

Также можно проверить работу Nginx curl`ом:  
```console
[root@selinux ~]# curl 127.0.0.1:4881
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
        <head>
                <title>Test Page for the HTTP Server on AlmaLinux</title>
...
```

Проверить статус параметра можно с помощью команды:  
```console
[root@selinux ~]# getsebool -a | grep nis_enabled
nis_enabled --> on
```

Вернём запрет работы nginx на порту 4881 обратно. Для этого отключим nis_enabled:  
```console
[root@selinux ~]# setsebool -P nis_enabled off
```

После отключения nis_enabled служба nginx снова не запустится:  
```console
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.
```


**Теперь разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип:**  
Поиск имеющегося типа, для http трафика:
```cosnole
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
```

Добавим порт в тип http_port_t:  
```console
[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep  http_port_t
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
```

Теперь перезапускаем службу nginx и проверим её работу:  
```console
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Wed 2025-10-22 13:55:59 UTC; 5s ago
    Process: 9174 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 9175 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 9176 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 9177 (nginx)
      Tasks: 3 (limit: 11984)
     Memory: 2.9M
        CPU: 113ms
     CGroup: /system.slice/nginx.service
             ├─9177 "nginx: master process /usr/sbin/nginx"
             ├─9178 "nginx: worker process"
             └─9179 "nginx: worker process"

Oct 22 13:55:59 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 22 13:55:59 selinux nginx[9175]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 22 13:55:59 selinux nginx[9175]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Oct 22 13:55:59 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

Также можно проверить работу Nginx curl`ом:  
```console
[root@selinux ~]# curl 127.0.0.1:4881
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
        <head>
                <title>Test Page for the HTTP Server on AlmaLinux</title>
...
```

Удалить нестандартный порт из имеющегося типа можно с помощью команды:  
```console
[root@selinux ~]# semanage port -d -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep  http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.
```

1












**Домашнее задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
