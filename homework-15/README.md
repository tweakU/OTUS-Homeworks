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


1) Запуск Nginx на нестандартном порту 3-мя разными способами:
Для начала проверим, что в ОС отключен файервол:

```console
[root@selinux ~]# systemctl status firewalld
○ firewalld.service - firewalld - dynamic firewall daemon
     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; preset: enabled)
     Active: inactive (dead)
       Docs: man:firewalld(1)
```

Также можно проверить, что конфигурация Nginx настроена без ошибок:  
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


**Разрешим в SELinux работу Nginx на порту TCP 4881 c помощью переключателей setsebool**  
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


Включим параметр nis_enabled и перезапустим Nginx:  
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

Вернём запрет работы Nginx на порту 4881 обратно. Для этого отключим nis_enabled:  
```console
[root@selinux ~]# setsebool -P nis_enabled off
```

После отключения nis_enabled служба nginx снова не запустится:  
```console
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.
```


**Теперь разрешим в SELinux работу Nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип:**  
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

Теперь перезапускаем службу Nginx и проверим её работу:  
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
[root@selinux ~]# systemctl status nginx
× nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: failed (Result: exit-code) since Wed 2025-10-22 13:58:31 UTC; 41s ago
   Duration: 2min 31.381s
    Process: 9199 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 9200 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
        CPU: 61ms

Oct 22 13:58:30 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 22 13:58:31 selinux nginx[9200]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 22 13:58:31 selinux nginx[9200]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)
Oct 22 13:58:31 selinux nginx[9200]: nginx: configuration file /etc/nginx/nginx.conf test failed
Oct 22 13:58:31 selinux systemd[1]: nginx.service: Control process exited, code=exited, status=1/FAILURE
Oct 22 13:58:31 selinux systemd[1]: nginx.service: Failed with result 'exit-code'.
Oct 22 13:58:31 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
```

**Разрешим в SELinux работу Nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux**:  
Попробуем снова запустить Nginx:
```console
[root@selinux ~]# systemctl start nginx
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.
```

Nginx не запустится, так как SELinux продолжает его блокировать. Посмотрим логи SELinux, которые относятся к Nginx:  
```console
[root@selinux ~]# grep nginx /var/log/audit/audit.log | tail -n 10
type=SYSCALL msg=audit(1761141088.929:763): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=5638a9f226b0 a2=10 a3=7ffd8f44b140 items=0 ppid=1 pid=9144 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)ARCH=x86_64 SYSCALL=bind AUID="unset" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
type=SERVICE_START msg=audit(1761141088.946:764): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'UID="root" AUID="unset"
type=SERVICE_START msg=audit(1761141359.554:773): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'UID="root" AUID="unset"
type=SERVICE_STOP msg=audit(1761141510.966:776): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'UID="root" AUID="unset"
type=AVC msg=audit(1761141511.069:777): avc:  denied  { name_bind } for  pid=9200 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1761141511.069:777): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=55e2fef0e6b0 a2=10 a3=7ffe4e82f6a0 items=0 ppid=1 pid=9200 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)ARCH=x86_64 SYSCALL=bind AUID="unset" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
type=SERVICE_START msg=audit(1761141511.086:778): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'UID="root" AUID="unset"
type=AVC msg=audit(1761141632.137:783): avc:  denied  { name_bind } for  pid=9223 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1761141632.137:783): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=557adbb506b0 a2=10 a3=7ffe9fe931b0 items=0 ppid=1 pid=9223 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)ARCH=x86_64 SYSCALL=bind AUID="unset" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
type=SERVICE_START msg=audit(1761141632.141:784): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'UID="root" AUID="unset"
```

Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу Nginx на нестандартном порту:  
```console
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp
```

Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль:  
```console
[root@selinux ~]# semodule -i nginx.pp
```

Попробуем снова запустить Nginx:  
```console
[root@selinux ~]# systemctl start nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Wed 2025-10-22 14:03:58 UTC; 6s ago
    Process: 9272 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 9273 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 9274 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 9275 (nginx)
      Tasks: 3 (limit: 11984)
     Memory: 2.9M
        CPU: 113ms
     CGroup: /system.slice/nginx.service
             ├─9275 "nginx: master process /usr/sbin/nginx"
             ├─9276 "nginx: worker process"
             └─9277 "nginx: worker process"

Oct 22 14:03:58 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Oct 22 14:03:58 selinux nginx[9273]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Oct 22 14:03:58 selinux nginx[9273]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Oct 22 14:03:58 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

После добавления модуля Nginx запустился без ошибок. При использовании модуля изменения сохранятся после перезагрузки. 
Просмотр всех установленных модулей: semodule -l

Для удаления модуля воспользуемся командой:  
```console
[root@selinux ~]# semodule -r nginx
libsemanage.semanage_direct_remove_key: Removing last nginx module (no other nginx module exists at another priority).
```


**2. Обеспечение работоспособности приложения при включенном SELinux**

Выполним клонирование репозитория:  
```console
root@test:~# mkdir -p ./otus/hw15
root@test:~# cd !$
cd ./otus/hw15
root@test:~/otus/hw15# git clone https://github.com/Nickmob/vagrant_selinux_dns_problems.git
Cloning into 'vagrant_selinux_dns_problems'...
remote: Enumerating objects: 32, done.
remote: Counting objects: 100% (32/32), done.
remote: Compressing objects: 100% (21/21), done.
remote: Total 32 (delta 9), reused 29 (delta 9), pack-reused 0 (from 0)
Receiving objects: 100% (32/32), 7.23 KiB | 7.23 MiB/s, done.
Resolving deltas: 100% (9/9), done.
```

Перейдём в каталог со стендом: cd vagrant_selinux_dns_problems
Развернём 2 ВМ с помощью vagrant: vagrant up
После того, как стенд развернется, проверим ВМ с помощью команды: vagrant status  
```console
root@test:~/otus/hw15/vagrant_selinux_dns_problems# vagrant status
Current machine states:

ns01                      running (virtualbox)
client                    running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Подключимся к клиенту: vagrant ssh client
```console
root@test:~/otus/hw15/vagrant_selinux_dns_problems# vagrant ssh client
###############################
### Welcome to the DNS lab! ###
###############################

- Use this client to test the enviroment
- with dig or nslookup. Ex:
    dig @192.168.50.10 ns01.dns.lab

- nsupdate is available in the ddns.lab zone. Ex:
    nsupdate -k /etc/named.zonetransfer.key
    server 192.168.50.10
    zone ddns.lab
    update add www.ddns.lab. 60 A 192.168.50.15
    send

- rndc is also available to manage the servers
    rndc -c ~/rndc.conf reload

###############################
### Enjoy! ####################
###############################
```

Попробуем внести изменения в зону: nsupdate -k /etc/named.zonetransfer.key
```console
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
> quit
```

Изменения внести не получилось. Давайте посмотрим логи SELinux, чтобы понять в чём может быть проблема.
Для этого воспользуемся утилитой audit2why:
```console
[vagrant@client ~]$ sudo -i
[root@client ~]# cat /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1761173008.341:858): avc:  denied  { dac_read_search } for  pid=4150 comm="20-chrony-dhcp" capability=2  scontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tcontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tclass=capability permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1761173008.341:858): avc:  denied  { dac_override } for  pid=4150 comm="20-chrony-dhcp" capability=1  scontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tcontext=system_u:system_r:NetworkManager_dispatcher_chronyc_t:s0 tclass=capability permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.
```

Тут мы видим, что на клиенте отсутствуют ошибки. 
Не закрывая сессию на клиенте, подключимся к серверу ns01 и проверим логи SELinux:
```console
[root@client ~]# exit
logout

[vagrant@client ~]$ ssh ns01
The authenticity of host 'ns01 (192.168.50.10)' can't be established.
ED25519 key fingerprint is SHA256:zCME3sU33PbIByvDrtNXXmhSOIdZP2zzJePtrjZydRQ.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'ns01' (ED25519) to the list of known hosts.
vagrant@ns01's password:
Last login: Wed Oct 22 22:08:20 2025 from 10.0.2.2

[vagrant@ns01 ~]$ sudo -i

[root@ns01 ~]# cat /var/log/audit/audit.log | audit2why | grep named_conf_t
type=AVC msg=audit(1761173336.598:706): avc:  denied  { write } for  pid=661 comm="isc-net-0000" name="dynamic" dev="sda4" ino=34029560 scontext=system_u:system_r:named_t:s0 tcontext=unconfined_u:object_r:named_conf_t:s0 tclass=dir permissive=0
```

В логах мы видим, что ошибка в контексте безопасности. Целевой контекст named_conf_t.
Для сравнения посмотрим существующую зону (localhost) и её контекст:
```console
[root@ns01 ~]# ls -alZ /var/named/named.localhost
-rw-r-----. 1 root named system_u:object_r:named_zone_t:s0 152 Jul 29 21:44 /var/named/named.localhost
```

У наших конфигов в /etc/named вместо типа named_zone_t используется тип named_conf_t.
Проверим данную проблему в каталоге /etc/named:
```console
[root@ns01 ~]# ls -laZ /etc/named
total 28
drw-rwx---.  3 root named system_u:object_r:named_conf_t:s0      121 Oct 22 22:08 .
drwxr-xr-x. 85 root root  system_u:object_r:etc_t:s0            8192 Oct 22 22:41 ..
drw-rwx---.  2 root named unconfined_u:object_r:named_conf_t:s0   56 Oct 22 22:07 dynamic
-rw-rw----.  1 root named system_u:object_r:named_conf_t:s0      784 Oct 22 22:08 named.50.168.192.rev
-rw-rw----.  1 root named system_u:object_r:named_conf_t:s0      610 Oct 22 22:07 named.dns.lab
-rw-rw----.  1 root named system_u:object_r:named_conf_t:s0      609 Oct 22 22:07 named.dns.lab.view1
-rw-rw----.  1 root named system_u:object_r:named_conf_t:s0      657 Oct 22 22:08 named.newdns.lab
```

Тут мы также видим, что контекст безопасности неправильный. Проблема заключается в том, что конфигурационные файлы лежат в другом каталоге. 
Посмотреть в каком каталоги должны лежать, файлы, чтобы на них распространялись правильные политики SELinux можно с помощью команды: semanage fcontext -l | grep named
```console
[root@ns01 ~]# semanage fcontext -l | grep named
/dev/gpmdata                                       named pipe         system_u:object_r:gpmctl_t:s0
/dev/initctl                                       named pipe         system_u:object_r:initctl_t:s0
/dev/xconsole                                      named pipe         system_u:object_r:xconsole_device_t:s0
/dev/xen/tapctrl.*                                 named pipe         system_u:object_r:xenctl_t:s0
/etc/named(/.*)?                                   all files          system_u:object_r:named_conf_t:s0
/etc/named\.caching-nameserver\.conf               regular file       system_u:object_r:named_conf_t:s0
/etc/named\.conf                                   regular file       system_u:object_r:named_conf_t:s0
/etc/named\.rfc1912.zones                          regular file       system_u:object_r:named_conf_t:s0
/etc/named\.root\.hints                            regular file       system_u:object_r:named_conf_t:s0
/etc/rc\.d/init\.d/named                           regular file       system_u:object_r:named_initrc_exec_t:s0
/etc/rc\.d/init\.d/named-sdb                       regular file       system_u:object_r:named_initrc_exec_t:s0
/etc/rc\.d/init\.d/unbound                         regular file       system_u:object_r:named_initrc_exec_t:s0
/etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0
/etc/unbound(/.*)?                                 all files          system_u:object_r:named_conf_t:s0
/usr/lib/systemd/system/named-sdb.*                regular file       system_u:object_r:named_unit_file_t:s0
/usr/lib/systemd/system/named.*                    regular file       system_u:object_r:named_unit_file_t:s0
/usr/lib/systemd/system/unbound.*                  regular file       system_u:object_r:named_unit_file_t:s0
/usr/lib/systemd/systemd-hostnamed                 regular file       system_u:object_r:systemd_hostnamed_exec_t:s0
/usr/sbin/lwresd                                   regular file       system_u:object_r:named_exec_t:s0
/usr/sbin/named                                    regular file       system_u:object_r:named_exec_t:s0
/usr/sbin/named-checkconf                          regular file       system_u:object_r:named_checkconf_exec_t:s0
/usr/sbin/named-pkcs11                             regular file       system_u:object_r:named_exec_t:s0
/usr/sbin/named-sdb                                regular file       system_u:object_r:named_exec_t:s0
/usr/sbin/unbound                                  regular file       system_u:object_r:named_exec_t:s0
/usr/sbin/unbound-anchor                           regular file       system_u:object_r:named_exec_t:s0
/usr/sbin/unbound-checkconf                        regular file       system_u:object_r:named_exec_t:s0
/usr/sbin/unbound-control                          regular file       system_u:object_r:named_exec_t:s0
/usr/share/munin/plugins/named                     regular file       system_u:object_r:services_munin_plugin_exec_t:s0
/var/lib/softhsm(/.*)?                             all files          system_u:object_r:named_cache_t:s0
/var/lib/unbound(/.*)?                             all files          system_u:object_r:named_cache_t:s0
/var/log/named.*                                   regular file       system_u:object_r:named_log_t:s0
/var/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0
/var/named/chroot(/.*)?                            all files          system_u:object_r:named_conf_t:s0
/var/named/chroot/dev                              directory          system_u:object_r:device_t:s0
/var/named/chroot/dev/log                          socket             system_u:object_r:devlog_t:s0
/var/named/chroot/dev/null                         character device   system_u:object_r:null_device_t:s0
/var/named/chroot/dev/random                       character device   system_u:object_r:random_device_t:s0
/var/named/chroot/dev/urandom                      character device   system_u:object_r:urandom_device_t:s0
/var/named/chroot/dev/zero                         character device   system_u:object_r:zero_device_t:s0
/var/named/chroot/etc(/.*)?                        all files          system_u:object_r:etc_t:s0
/var/named/chroot/etc/localtime                    regular file       system_u:object_r:locale_t:s0
/var/named/chroot/etc/named\.caching-nameserver\.conf regular file       system_u:object_r:named_conf_t:s0
/var/named/chroot/etc/named\.conf                  regular file       system_u:object_r:named_conf_t:s0
/var/named/chroot/etc/named\.rfc1912.zones         regular file       system_u:object_r:named_conf_t:s0
/var/named/chroot/etc/named\.root\.hints           regular file       system_u:object_r:named_conf_t:s0
/var/named/chroot/etc/pki(/.*)?                    all files          system_u:object_r:cert_t:s0
/var/named/chroot/etc/rndc\.key                    regular file       system_u:object_r:dnssec_t:s0
/var/named/chroot/lib(/.*)?                        all files          system_u:object_r:lib_t:s0
/var/named/chroot/proc(/.*)?                       all files          <<None>>
/var/named/chroot/run/named.*                      all files          system_u:object_r:named_var_run_t:s0
/var/named/chroot/usr/lib(/.*)?                    all files          system_u:object_r:lib_t:s0
/var/named/chroot/var/log                          directory          system_u:object_r:var_log_t:s0
/var/named/chroot/var/log/named.*                  regular file       system_u:object_r:named_log_t:s0
/var/named/chroot/var/named(/.*)?                  all files          system_u:object_r:named_zone_t:s0
/var/named/chroot/var/named/data(/.*)?             all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/named/dynamic(/.*)?          all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/named/named\.ca              regular file       system_u:object_r:named_conf_t:s0
/var/named/chroot/var/named/slaves(/.*)?           all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/run/dbus(/.*)?               all files          system_u:object_r:system_dbusd_var_run_t:s0
/var/named/chroot/var/run/named.*                  all files          system_u:object_r:named_var_run_t:s0
/var/named/chroot/var/tmp(/.*)?                    all files          system_u:object_r:named_cache_t:s0
/var/named/chroot_sdb/dev                          directory          system_u:object_r:device_t:s0
/var/named/chroot_sdb/dev/null                     character device   system_u:object_r:null_device_t:s0
/var/named/chroot_sdb/dev/random                   character device   system_u:object_r:random_device_t:s0
/var/named/chroot_sdb/dev/urandom                  character device   system_u:object_r:urandom_device_t:s0
/var/named/chroot_sdb/dev/zero                     character device   system_u:object_r:zero_device_t:s0
/var/named/data(/.*)?                              all files          system_u:object_r:named_cache_t:s0
/var/named/dynamic(/.*)?                           all files          system_u:object_r:named_cache_t:s0
/var/named/named\.ca                               regular file       system_u:object_r:named_conf_t:s0
/var/named/slaves(/.*)?                            all files          system_u:object_r:named_cache_t:s0
/var/run/bind(/.*)?                                all files          system_u:object_r:named_var_run_t:s0
/var/run/ecblp0                                    named pipe         system_u:object_r:cupsd_var_run_t:s0
/var/run/initctl                                   named pipe         system_u:object_r:initctl_t:s0
/var/run/named(/.*)?                               all files          system_u:object_r:named_var_run_t:s0
/var/run/ndc                                       socket             system_u:object_r:named_var_run_t:s0
/var/run/systemd/initctl/fifo                      named pipe         system_u:object_r:initctl_t:s0
/var/run/unbound(/.*)?                             all files          system_u:object_r:named_var_run_t:s0
/var/named/chroot/usr/lib64 = /usr/lib
/var/named/chroot/lib64 = /usr/lib
/var/named/chroot/var = /var
```

Изменим тип контекста безопасности для каталога /etc/named: chcon -R -t named_zone_t /etc/named
```console
[root@ns01 ~]# chcon -R -t named_zone_t /etc/named

[root@ns01 ~]# ls -laZ /etc/named
total 28
drw-rwx---.  3 root named system_u:object_r:named_zone_t:s0      121 Oct 22 22:08 .
drwxr-xr-x. 85 root root  system_u:object_r:etc_t:s0            8192 Oct 22 22:41 ..
drw-rwx---.  2 root named unconfined_u:object_r:named_zone_t:s0   56 Oct 22 22:07 dynamic
-rw-rw----.  1 root named system_u:object_r:named_zone_t:s0      784 Oct 22 22:08 named.50.168.192.rev
-rw-rw----.  1 root named system_u:object_r:named_zone_t:s0      610 Oct 22 22:07 named.dns.lab
-rw-rw----.  1 root named system_u:object_r:named_zone_t:s0      609 Oct 22 22:07 named.dns.lab.view1
-rw-rw----.  1 root named system_u:object_r:named_zone_t:s0      657 Oct 22 22:08 named.newdns.lab
```

Попробуем снова внести изменения с клиента: 
```console
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
> quit

[vagrant@client ~]$ dig www.ddns.lab

; <<>> DiG 9.16.23-RH <<>> www.ddns.lab
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8809
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 2e388470678575c20100000068f961cf27ffdaf4e319de21 (good)
;; QUESTION SECTION:
;www.ddns.lab.                  IN      A

;; ANSWER SECTION:
www.ddns.lab.           60      IN      A       192.168.50.15

;; Query time: 1 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Wed Oct 22 22:59:27 UTC 2025
;; MSG SIZE  rcvd: 85
```

Видим, что изменения применились. Попробуем перезагрузить хосты и ещё раз сделать запрос с помощью dig: 
```console
[vagrant@client ~]$ dig @192.168.50.10 www.ddns.lab

; <<>> DiG 9.16.23-RH <<>> @192.168.50.10 www.ddns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12570
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: ee80021678edbc7b0100000068f961f44d63b5897e42c05e (good)
;; QUESTION SECTION:
;www.ddns.lab.                  IN      A

;; ANSWER SECTION:
www.ddns.lab.           60      IN      A       192.168.50.15

;; Query time: 1 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Wed Oct 22 23:00:04 UTC 2025
;; MSG SIZE  rcvd: 85
```

Всё правильно. После перезагрузки настройки сохранились. 
Важно, что мы не добавили новые правила в политику для назначения этого контекста в каталоге. Значит, что при перемаркировке файлов контекст вернётся на тот, который прописан в файле политики.
Для того, чтобы вернуть правила обратно, можно ввести команду: restorecon -v -R /etc/named
```console
[root@ns01 ~]# restorecon -v -R /etc/named
Relabeled /etc/named from system_u:object_r:named_zone_t:s0 to system_u:object_r:named_conf_t:s0
Relabeled /etc/named/named.dns.lab.view1 from system_u:object_r:named_zone_t:s0 to system_u:object_r:named_conf_t:s0
Relabeled /etc/named/named.dns.lab from system_u:object_r:named_zone_t:s0 to system_u:object_r:named_conf_t:s0
Relabeled /etc/named/dynamic from unconfined_u:object_r:named_zone_t:s0 to unconfined_u:object_r:named_conf_t:s0
Relabeled /etc/named/dynamic/named.ddns.lab from system_u:object_r:named_zone_t:s0 to system_u:object_r:named_conf_t:s0
Relabeled /etc/named/dynamic/named.ddns.lab.view1 from system_u:object_r:named_zone_t:s0 to system_u:object_r:named_conf_t:s0
Relabeled /etc/named/dynamic/named.ddns.lab.view1.jnl from system_u:object_r:named_zone_t:s0 to system_u:object_r:named_conf_t:s0
Relabeled /etc/named/named.newdns.lab from system_u:object_r:named_zone_t:s0 to system_u:object_r:named_conf_t:s0
Relabeled /etc/named/named.50.168.192.rev from system_u:object_r:named_zone_t:s0 to system_u:object_r:named_conf_t:s0
```
Работает!  

Q: **выяснить причину неработоспособности механизма обновления зоны**  
A: При попытке обновить DNS-запись через nsupdate, SELinux заблокировал операцию из-за несоответствия контекстов безопасности.  
Лог сообщает, что процесс, который запускает isc-net-0001 (это процесс сервера BIND/DNS), не имеет нужных прав на запись в файл с типом контекста named_conf_t.  
Согласно логам SELinux, процесс с типом named_t пытается записать данные в файл с контекстом named_conf_t, что и вызывает ошибку доступа.

Решение: 
1) проверить контексты файлов с помощью команды ls -laZ
2) использовать команду chcon -R -t named_zone_t /etc/named для исправления типов контекста на нужные
3) при повторной попытке внести изменения с помощью nsupdate, все прошло успешно, так как теперь контексты безопасности файлов и процессов совпали.

Пояснение:
SELinux требует, чтобы файлы и процессы имели согласованные контексты безопасности.  
Например, процесс named_t (служба DNS) может взаимодействовать только с файлами, имеющими тип контекста named_zone_t или другой соответствующий тип.
Если контекст объекта (например, файл зоны DNS) не совпадает с тем, что ожидает процесс, SELinux блокирует доступ, даже если это выглядит как ошибка конфигурации (не ошибка приложения).


**Домашнее задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
