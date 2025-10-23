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

7) 







































**Домашнее задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
****
