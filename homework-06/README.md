## Домашнее задание № 6 — «NFS, FUSE»

Цель домашнего задания: научиться монтировать файловые системы с помощью FUSE (filesystem in userspace — файловая система в пользовательском пространстве); настраивать и использовать NFS (Network File System — протокол сетевого доступа к файловым системам) в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:

1) Настраиваем сервер NFS:

Установим пакет с NFS-сервером:
```console
root@nfs-server:~# apt install nfs-kernel-server
```

Проверяем наличие слушающих портов 2049/udp, 2049/tcp, 111/udp, 111/tcp:
```console
root@nfs-server:~# ss -tulnp | grep -e 2049 -e 111
udp   UNCONN 0      0                  0.0.0.0:111        0.0.0.0:*    users:(("rpcbind",pid=2440,fd=5),("systemd",pid=1,fd=124))
udp   UNCONN 0      0                     [::]:111           [::]:*    users:(("rpcbind",pid=2440,fd=7),("systemd",pid=1,fd=126))
tcp   LISTEN 0      64                 0.0.0.0:2049       0.0.0.0:*
tcp   LISTEN 0      4096               0.0.0.0:111        0.0.0.0:*    users:(("rpcbind",pid=2440,fd=4),("systemd",pid=1,fd=122))
tcp   LISTEN 0      64                    [::]:2049          [::]:*
tcp   LISTEN 0      4096                  [::]:111           [::]:*    users:(("rpcbind",pid=2440,fd=6),("systemd",pid=1,fd=125))
```

Создаём и настраиваем директорию, которая будет экспортирована в будущем:
```console
root@nfs-server:~# mkdir -p /srv/share/upload
```

Меняем владельца:
```console
root@nfs-server:~# chown -R nobody:nogroup /srv/share
```

Задаем права:
```console
root@nfs-server:~# chmod 0777 /srv/share/upload
```

Допишем в /etc/exports host клиента (весьма экзотический способ), EOF это состояние, о котором сообщает ядро, и которое может быть обнаружено приложением в том случае, когда операция чтения данных доходит до конца файла):
```console
root@nfs-server:~# cat << EOF >> /etc/exports
> /srv/share 192.168.1.16/24(rw,sync,root_squash)
> EOF

root@nfs-server:~# cat /etc/exports
# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
/srv/share 192.168.1.16/24(rw,sync,root_squash)
```

Экспортируем ранее созданную директорию (exportfs осуществляет ведение таблицы экспортированных файловых систем NFS, ключ -r проводит реэкспорт всех директорий):
```console
root@nfs-server:~# exportfs -r

exportfs: /etc/exports [1]: Neither 'subtree_check' or 'no_subtree_check' specified for export "192.168.1.16/24:/srv/share".
  Assuming default behaviour ('no_subtree_check').
  NOTE: this default has changed since nfs-utils version 1.0.x
```

Отобразим текущий список экспорта, подходящий для /etc/exports:
```console
root@nfs-server:~# exportfs -s

/srv/share  192.168.1.16/24(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```

2. Настраиваем клиент NFS: 

Установим пакет с NFS-клиентом:
```console
root@nfs-client:~# apt install nfs-common -y

root@nfs-client:~# apt list | grep -i nfs-common
WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
nfs-common/noble-updates,now 1:2.6.4-3ubuntu5.1 amd64 [installed]
```

Добавляем в /etc/fstab (еще один "экзотический" способ не использовать текстовый редактор):
```console
root@nfs-client:~# echo "192.168.1.15:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab

root@nfs-client:~# cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/ubuntu-vg/ubuntu-lv during curtin installation
/dev/disk/by-id/dm-uuid-LVM-Izm7m3jaT8JG2ZIT6nbKFEPAa3GkELIYAGyHtIYDy9hWhDIEneG7mQHqdU9JbzsL / ext4 defaults 0 1
# /boot was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/b24e12bc-ebb1-4829-9954-d92a5e72d5d0 /boot ext4 defaults 0 1
/swap.img       none    swap    sw      0       0
192.168.1.15:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0
```

Выполняем команды (systemctl осуществляет управление systemd и менеджером служб; daemon-reload перезагрузит конфигурацию systemd менеджера; restart перезапустит юнит remote-fs.target):
```console
root@nfs-client:~# systemctl daemon-reload

root@nfs-client:~# systemctl restart remote-fs.target
```


```console
root@nfs-client:~# mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=65,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=40464)
192.168.1.15:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.1.15,mountvers=3,mountport=60502,mountproto=udp,local_lock=none,addr=192.168.1.15)
```

После ребута сервера проверим работоспособность:
```console
root@nfs-server:~# exportfs -s
/srv/share  192.168.1.16/24(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)

root@nfs-server:~# showmount -a 192.168.1.15
All mount points on 192.168.1.15:
192.168.1.16:/srv/share
```


```console

```


```console

```


```console

```


```console

```




```console

```

Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
