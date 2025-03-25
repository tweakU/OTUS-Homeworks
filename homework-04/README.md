## Домашнее задание № 4 — «ZFS - Zettabyte File System»

Цель домашнего задания: научиться самостоятельно устанавливать ZFS, настраивать пулы, изучить основные возможности ZFS в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:

1) Определить алгоритм с наилучшим сжатием:

- определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
- создать 4 файловых системы на каждой применить свой алгоритм сжатия;
- для сжатия использовать либо текстовый файл, либо группу файлов.


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

Команда zfs get all выведет полную информацию о пулах. 

Перенаправим stdout в grep для получения интересующей нас информации.

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



2) Определить настройки пула.
С помощью команды zfs import собрать pool ZFS.
Командами zfs определить настройки:

- размер хранилища;
- тип pool;
- значение recordsize;
- какое сжатие используется;
- какая контрольная сумма используется.

Скачиваем архив в домашний каталог: 
```console
root@ubuntu2404:~# pwd
/root

root@ubuntu2404:~# wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'

root@ubuntu2404:~# ls -l
total 7108
-rw-r--r-- 1 root root 7275140 Dec  6  2023 archive.tar.gz
```

Разархивируем его:

```console
root@ubuntu2404:~# tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
```

Проверим, возможно ли импортировать данный каталог в пул:

```console
root@ubuntu2404:~# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
        (Note that they may be intentionally disabled if the
        'compatibility' property is set.)
 action: The pool can be imported using its name or numeric identifier, though
        some features will not be available without an explicit 'zpool upgrade'.
 config:

        otus                         ONLINE
          mirror-0                   ONLINE
            /root/zpoolexport/filea  ONLINE
            /root/zpoolexport/fileb  ONLINE
```

Данный вывод показывает нам имя пула, тип raid и его состав. 

Сделаем импорт данного пула:

```console
root@ubuntu2404:~# zpool import -d zpoolexport/ otus

root@ubuntu2404:~# zpool status
  pool: otus
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
        The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(7) for details.
config:

        NAME                         STATE     READ WRITE CKSUM
        otus                         ONLINE       0     0     0
          mirror-0                   ONLINE       0     0     0
            /root/zpoolexport/filea  ONLINE       0     0     0
            /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

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

Команда zpool status выдаст нам информацию о составе импортированного пула.

Далее нам нужно определить настройки. Запрос сразу всех параметром файловой системы:

```console
root@ubuntu2404:~# zfs get all otus
NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  4:00 2020  -
otus  used                  2.05M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclmode               discard                default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.02M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1M                     -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              on                     default
otus  redundant_metadata    all                    default
otus  overlay               on                     default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default
```

C помощью команды zfs get #аргумент (!! в методичке ошибка, если в качестве команды написано grep) можно уточнить конкретный параметр, например:

```console
root@ubuntu2404:~# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -

root@ubuntu2404:~# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default

root@ubuntu2404:~# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local

root@ubuntu2404:~# zfs get compression otus
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local

root@ubuntu2404:~# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```


3) Работа со снапшотами:
- скопировать файл из удаленной директории;
- восстановить файл локально, zfs receive;
- найти зашифрованное сообщение в файле secret_message.

Скачаем файл, указанный в задании:

```console
root@ubuntu2404:~# wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download
[1] 2851
root@ubuntu2404:~#
Redirecting output to ‘wget-log’.
[1]+  Done
```

(!!)Так и не понял почему wget проваливается в фон (background), man wget говорит, что для этого должен быть указан ключ -b, --background ... сразу после старта wget вторым окном запустил tail -f

```console
root@ubuntu2404:~# tail -f wget-log
--2025-03-24 23:39:45--  https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI
Resolving drive.usercontent.google.com (drive.usercontent.google.com)... 142.250.203.97, 2a00:1450:400a:808::2001
Connecting to drive.usercontent.google.com (drive.usercontent.google.com)|142.250.203.97|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5432736 (5.2M) [application/octet-stream]
Saving to: ‘otus_task2.file’

otus_task2.file                                      100%[===================================================================================================================>]   5.18M  10.2MB/s    in 0.5s

2025-03-24 23:39:48 (10.2 MB/s) - ‘otus_task2.file’ saved [5432736/5432736]
```
Хмм, ничего интересного; файл скачан за 3 секунды. Что ж, поехали дальше.


Восстановим файловую систему из снапшота: 

Снэпшот - это версия файловой системы или тома, доступная только для чтения, в определенный момент времени. Указывается как filesystem@name или volume@name. 

```console
root@ubuntu2404:~# zfs receive otus/test@today < otus_task2.file
```

Далее, ищем в каталоге /otus/test файл с именем “secret_message”:

```console
root@ubuntu2404:~# find /otus/test/ -name "secret_message"
/otus/test/task1/file_mess/secret_message
```


Посмотрим содержимое найденного файла:

```console
root@ubuntu2404:~# cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/
```


Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
