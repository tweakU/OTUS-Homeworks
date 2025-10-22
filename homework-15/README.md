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


































**Домашнее задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
