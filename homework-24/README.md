## Домашнее задание № 24 — «Пользователи и группы. Авторизация и аутентификация»

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






































**Домашнее задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
****
