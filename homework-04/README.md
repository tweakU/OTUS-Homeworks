## Домашнее задание № 4 — «ZFS - Zettabyte File System»

Цель домашнего задания: научиться самостоятельно устанавливать ZFS, настраивать пулы, изучить основные возможности ZFS в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:

1) Определить алгоритм с наилучшим сжатием:

- Определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);

Смотрим список всех дисков, которые есть в виртуальной машине: 
```console
root@ubuntu2404:~# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda      8:0    0   16G  0 disk
├─sda1   8:1    0    1M  0 part
└─sda2   8:2    0   16G  0 part /
sdb      8:16   0  512M  0 disk
sdc      8:32   0  512M  0 disk
sdd      8:48   0  512M  0 disk
sde      8:64   0  512M  0 disk
sdf      8:80   0  512M  0 disk
sdg      8:96   0  512M  0 disk
sdh      8:112  0  512M  0 disk
sdi      8:128  0  512M  0 disk
sr0     11:0    1 1024M  0 rom
```

Установим пакет утилит для ZFS:
```console
root@ubuntu2404:~# apt install zfsutils-linux -y
```

Создадим четыре пула из двух дисков в режиме RAID 1:
```console
root@ubuntu2404:~# zpool create otus1 mirror /dev/sdb /dev/sdc
root@ubuntu2404:~# zpool create otus2 mirror /dev/sdd /dev/sde
root@ubuntu2404:~# zpool create otus3 mirror /dev/sdf /dev/sdg
root@ubuntu2404:~# zpool create otus4 mirror /dev/sdh /dev/sdi
```

Посмотрим  информацию о пулах zfs: 
Команда zpool list показывает информацию о размере пула, количеству занятого и свободного места, дедупликации и т.д.
```console
root@ubuntu2404:~# zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   116K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   114K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   110K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M   114K   480M        -         -     0%     0%  1.00x    ONLINE  -
```

Команда zpool status показывает информацию о каждом диске, состоянии сканирования и об ошибках чтения, записи и совпадения хэш-сумм.
```console
root@ubuntu2404:~# zpool status
  pool: otus1
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0

errors: No known data errors

  pool: otus2
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus2       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sde     ONLINE       0     0     0

errors: No known data errors

  pool: otus3
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus3       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdf     ONLINE       0     0     0
            sdg     ONLINE       0     0     0

errors: No known data errors

  pool: otus4
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        otus4       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdh     ONLINE       0     0     0
            sdi     ONLINE       0     0     0

errors: No known data errors
```

Добавим разные алгоритмы сжатия в каждую файловую систему:
Алгоритм lzjb:
```console
root@ubuntu2404:~# zfs set compression=lzjb otus1
```
Алгоритм lz4:
```console
root@ubuntu2404:~# zfs set compression=lz4 otus2
```

Алгоритм gzip:
```console
root@ubuntu2404:~# zfs set compression=gzip-9 otus3
```

Алгоритм zle:
```console
root@ubuntu2404:~# zfs set compression=zle otus4
```

Проверим, что все файловые системы имеют разные методы сжатия:
Команда zfs get all выведет полную информацию о пулах. Перенаправим stdout в grep для получения интересующей нас информации.
```console
root@ubuntu2404:~# zfs get all | grep compression
otus1  compression           lzjb                   local
otus2  compression           lz4                    local
otus3  compression           gzip-9                 local
otus4  compression           zle                    local
```

!! Сжатие файлов будет работать только с файлами, которые были добавлены после включение настройки сжатия.
Скачаем один и тот же текстовый файл во все пулы: 
Используем регулярные выражения и цикл for i in. 
```console
root@ubuntu2404:~# for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
```

Проверим, что файл был скачан во все пулы:
```console
root@ubuntu2404:~# ls -l /otus*
/otus1:
total 22097
-rw-r--r-- 1 root root 41130189 Mar  2 08:31 pg2600.converter.log

/otus2:
total 18007
-rw-r--r-- 1 root root 41130189 Mar  2 08:31 pg2600.converter.log

/otus3:
total 10966
-rw-r--r-- 1 root root 41130189 Mar  2 08:31 pg2600.converter.log

/otus4:
total 40195
-rw-r--r-- 1 root root 41130189 Mar  2 08:31 pg2600.converter.log
```

Уже на этом этапе видно, что самый оптимальный метод сжатия у нас используется в пуле otus3.
Проверим, сколько места занимает один и тот же файл в разных пулах и проверим степень сжатия файлов:
```console
root@ubuntu2404:~# zfs list
NAME    USED  AVAIL  REFER  MOUNTPOINT
otus1  21.7M   330M  21.6M  /otus1
otus2  17.7M   334M  17.6M  /otus2
otus3  10.9M   341M  10.7M  /otus3
otus4  39.4M   313M  39.3M  /otus4
```

Дважды "grep`ним" stdout команды zfs get all, ключ -v выдает все строки, за исключением содержащих образец.
```console
root@ubuntu2404:~# zfs get all | grep compressratio | grep -v ref
otus1  compressratio         1.81x                  -
otus2  compressratio         2.23x                  -
otus3  compressratio         3.65x                  -
otus4  compressratio         1.00x                  -
```
Таким образом, у нас получается, что алгоритм gzip-9 самый эффективный по сжатию. 








- создать 4 файловых системы на каждой применить свой алгоритм сжатия;

```console

```


- для сжатия использовать либо текстовый файл, либо группу файлов.

```console
```

2) Определить настройки пула.
С помощью команды zfs import собрать pool ZFS. Командами zfs определить настройки:
- размер хранилища;
- тип pool;
- значение recordsize;
- какое сжатие используется;
- какая контрольная сумма используется.

```console
```

3) Работа со снапшотами:
- скопировать файл из удаленной директории;
- восстановить файл локально. zfs receive;
- найти зашифрованное сообщение в файле secret_message.

```console
```



Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
