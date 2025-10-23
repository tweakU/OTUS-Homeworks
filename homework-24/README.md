## Домашнее задание № 24 — «Пользователи и группы. Авторизация и аутентификация»  


    

**ЧТИВО:** [1stVDS - Управление пользователями](https://firstvds.ru/technology/linux-user-management)

**Цель домашнего задания: *Научиться создавать пользователей и добавлять им ограничения*.

**Выполнение домашнего задания**:

1) Подключаемся к созданной VM: vagrant ssh
2) Переходим в root-пользователя: sudo -i
3) Создаём пользователя otusadm и otus:
```console
root@pam:~# useradd otusadm && useradd otus

root@pam:~# cat /etc/passwd | grep otus
otusadm:x:1002:1002::/home/otusadm:/bin/sh
otus:x:1003:1003::/home/otus:/bin/sh
```

4) Создаём пользователям пароли:
```console
root@pam:~# echo "otus2022!" | passwd --stdin otusadm && echo "otus2022!" | passwd --stdin otus
```

5) Создаём группу admin:
```console
root@pam:~# groupadd -f admin
```

6) Добавляем пользователей vagrant,root и otusadm в группу admin:
```console
root@pam:~# usermod otusadm -a -G admin && usermod root -a -G admin && usermod vagrant -a -G admin
```
Обратите внимание, что мы просто добавили пользователя otusadm в группу admin. Это не делает пользователя otusadm администратором.

После создания пользователей, нужно проверить, что они могут подключаться по SSH к нашей VM.  
Для этого пытаемся подключиться с хостовой машины: ssh otus@192.168.57.10  
Далее вводим наш созданный пароль. 
```console
PS C:\Users\funt1k> ssh otus@192.168.57.10
The authenticity of host '192.168.57.10 (192.168.57.10)' can't be established.
ED25519 key fingerprint is SHA256:BTpm5itWkBIORV7YBZygJw4/Bz7DkJDlFSBQjvIGgEc.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.57.10' (ED25519) to the list of known hosts.
otus@192.168.57.10's password:
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-142-generic x86_64)
...
otus@pam:~$ exit
logout
Connection to 192.168.57.10 closed.

PS C:\Users\funt1k> ssh otusadm@192.168.57.10
otusadm@192.168.57.10's password:
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-142-generic x86_64)
...
otusadm@pam:~$ exit
logout
Connection to 192.168.57.10 closed.
```

Далее настроим правило, по которому все пользователи кроме тех, что указаны в группе admin не смогут подключаться в выходные дни:  

7) Проверим, что пользователи root, vagrant и otusadm есть в группе admin:
```console
root@pam:~# cat /etc/group | grep admin
admin:x:118:otusadm,root,vagrant
```

Информация о группах и пользователях в них хранится в файле /etc/group, пользователи указываются через запятую. 

Выберем метод PAM-аутентификации, так как у нас используется только ограничение по времени, то было бы логично использовать метод pam_time,  однако, данный метод не работает с локальными группами пользователей, и, получается, что использование данного метода добавит нам большое количество однообразных строк с разными пользователями. В текущей ситуации лучше написать небольшой скрипт контроля и использовать модуль pam_exec

8) Создадим файл-скрипт /usr/local/bin/login.sh
```console
root@pam:~# cat > /usr/local/bin/login.sh
#!/bin/bash
#Первое условие: если день недели суббота или воскресенье
if [ $(date +%a) = "Sat" ] || [ $(date +%a) = "Sun" ]; then
 #Второе условие: входит ли пользователь в группу admin
 if getent group admin | grep -qw "$PAM_USER"; then
        #Если пользователь входит в группу admin, то он может подключиться
        exit 0
      else
        #Иначе ошибка (не сможет подключиться)
        exit 1
    fi
  #Если день не выходной, то подключиться может любой пользователь
  else
    exit 0
fi
```
В скрипте подписаны все условия. Скрипт работает по принципу: 
Если сегодня суббота или воскресенье, то нужно проверить, входит ли пользователь в группу admin, если не входит — то подключение запрещено. При любых других вариантах подключение разрешено. 

9) Добавим права на исполнение файла: chmod +x /usr/local/bin/login.sh
```console
root@pam:~# chmod +x /usr/local/bin/login.sh

root@pam:~# ll /usr/local/bin/login.sh
-rwxr-xr-x 1 root root 719 Oct 23 21:35 /usr/local/bin/login.sh*
```

10) Укажем в файле /etc/pam.d/sshd модуль pam_exec и наш скрипт:
```console
root@pam:~# cat > /etc/pam.d/sshd
#%PAM-1.0
#auth       substack     password-auth
#auth       include      postlogin
auth required pam_exec.so debug /usr/local/bin/login.sh
#account    required     dad
#account    required     pam_nologin.so
#account    include      password-auth
#password   include      password-auth
#pam_selinux.so close should be the first session rule
#session    required     pam_selinux.so close
#session    required     pam_loginuid.so
#pam_selinux.so open should only be followed by sessions to be executed in the user context
#session    required     pam_selinux.so open env_params
#session    required     pam_namespace.so
#session    optional     pam_keyinit.so force revoke
#session    optional     pam_motd.so
#session    include      password-auth
#session    include      postlogin
```

На этом настройка завершена, нужно только проверить, что скрипт отрабатывает корректно. 

Если настройки выполнены правильно, то при логине пользователя otus у Вас должна появиться ошибка.  
Пользователь otusadm должен подключаться без проблем: 

```console
root@pam:~# date --set "25 Oct 2025 12:00:00"
Sat Oct 25 12:00:00 UTC 2025

PS C:\Users\funt1k> ssh otus@192.168.57.10
otus@192.168.57.10's password:
Permission denied, please try again.
otus@192.168.57.10's password:

PS C:\Users\funt1k> ssh otusadm@192.168.57.10
otusadm@192.168.57.10's password:
Last login: Sat Oct 25 12:00:26 2025 from 192.168.57.1
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

otusadm@pam:~$ exit
logout
Connection to 192.168.57.10 closed.

root@pam:~# tail -f /var/log/auth.log
...
Oct 25 12:00:13 pam sshd[3160]: pam_exec(sshd:auth): Calling /usr/local/bin/login.sh ...
Oct 25 12:00:13 pam sshd[3158]: Accepted password for otusadm from 192.168.57.1 port 61682 ssh2
Oct 25 12:00:13 pam sshd[3158]: pam_unix(sshd:session): session opened for user otusadm(uid=1002) by (uid=0)
Oct 25 12:00:13 pam systemd-logind[713]: New session c18 of user otusadm.
Oct 25 12:00:13 pam systemd: pam_unix(systemd-user:session): session opened for user otusadm(uid=1002) by (uid=0)
Oct 25 12:00:15 pam sshd[3172]: Received disconnect from 192.168.57.1 port 61682:11: disconnected by user
Oct 25 12:00:15 pam sshd[3172]: Disconnected from user otusadm 192.168.57.1 port 61682
Oct 25 12:00:15 pam sshd[3158]: pam_unix(sshd:session): session closed for user otusadm
Oct 25 12:00:15 pam systemd-logind[713]: Session c18 logged out. Waiting for processes to exit.
Oct 25 12:00:15 pam systemd-logind[713]: Removed session c18.
```


**Домашнее задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
****
