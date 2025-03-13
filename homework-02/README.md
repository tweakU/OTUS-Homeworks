## Домашнее задание № 2 — «Дисковая подсистема»

Цель домашнего задания: научиться использовать утилиту mdadm для управления программными RAID-массивами в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:

1) проверим текущее состояние RAID-массивов, управляемых с помощью инструмента mdadm:

```console
tanin@ubuntu24:~$ cat /proc/mdstat 
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
unused devices: <none>
```

2) выполним скрипт, который позволит создать RAID-массив 10 уровня (mdadm_create_raid_volume.sh): 

```console
tanin@ubuntu24:~$ sudo ./OTUS-Homeworks/homework-02/mdadm_create_raid_volume.sh 
[sudo] password for tanin: 
ЗАДАЧА: создать  RAID-массив 10 уровня из четырех дисков. Установим перечень блочных устройств (далее во время паузы вы можете 
нажать любую клавишу, чтобы продолжить; либо ctrl+C, чтобы прервать выполнение скрипта):
/0/3/0/0.0.0    /dev/sda    disk        26GB HARDDISK
/0/3/0/0.1.0    /dev/cdrom  disk        CD-ROM
/0/3/0/0.2.0    /dev/sdb    disk        1073MB HARDDISK
/0/3/0/0.3.0    /dev/sdc    disk        1073MB HARDDISK
/0/3/0/0.4.0    /dev/sdd    disk        1073MB HARDDISK
/0/3/0/0.5.0    /dev/sde    disk        1073MB HARDDISK
/0/3/0/0.6.0    /dev/sdf    disk        1073MB HARDDISK
/0/3/0/0.7.0    /dev/sdg    disk        1073MB HARDDISK

Далее удалим суперблоки на дисках /dev/sdX (если при создании RAID-массива не удалить суперблоки с устройств, которые ранее 
использовались в других RAID-массивах или бьли частью других файловых систем, могут возникнуть следующие проблемы: 1) неправильное 
распознование устройства как части другого массива 2) конфликты и ошибки при создании массива 3) проблемы при добавлении дисков в 
новый массив). Для этого воспользуемся коммандой mdadm с параметром --zero-superblock, если использовать параметр --force, то даже 
если суперблок выглядит как поврежденный или инвалидный, он всё равно будет перезаписан нулями):
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde

Создадим RAID-маасив 10 уровня. Параметр --create (-C) создает новый RAID-массив, --level (-l) указывает уровень RAID-массива, 
--raid-devices (-n) указывает количество устройтсв в массиве, --verbose (-v) включает подборный вывод:
mdadm: layout defaults to n2
mdadm: layout defaults to n2
mdadm: chunk size defaults to 512K
mdadm: size set to 1046528K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

Проверим как создался RAID-массив. Для этого с помощью команды cat посмотрим на содержимое файла /proc/mdstat, который содержит 
информацию о текущем состоянии RAID-масствов, управляемых с помощью инструмента mdadm. Другой способ проверить созданный 
RAID-массив можно с помощью парамента --detail (-D) команды mdadm :
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid10 sde[3] sdd[2] sdc[1] sdb[0]
      2093056 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      [=======>.............]  resync = 39.7% (832640/2093056) finish=0.1min speed=208160K/sec
      
unused devices: <none>
/dev/md0:
           Version : 1.2
     Creation Time : Fri Mar 14 00:20:49 2025
        Raid Level : raid10
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Fri Mar 14 00:20:53 2025
             State : clean, resyncing 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

     Resync Status : 39% complete

              Name : ubuntu24:0  (local to host ubuntu24)
              UUID : b668fb7e:c6ce05dd:d98815bc:655841e9
            Events : 6

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde
```

3) упс, проверим ещё раз) ... руками:

```console
tanin@ubuntu24:~$ cat /proc/mdstat 
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid10 sde[3] sdd[2] sdc[1] sdb[0]
      2093056 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      
unused devices: <none>

tanin@ubuntu24:~$ sudo mdadm -D /dev/md0 
/dev/md0:
           Version : 1.2
     Creation Time : Fri Mar 14 00:38:20 2025
        Raid Level : raid10
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Fri Mar 14 00:38:31 2025
             State : clean 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : ubuntu24:0  (local to host ubuntu24)
              UUID : d3f77766:7d5edc7b:f8b9267d:50cb7c28
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde
```

Вывод команд указывает на успешное выполнение задачи.

4) далее: "сломаем" RAID-массив:

```console
tanin@ubuntu24:~$ sudo mdadm /dev/md0 --fail /dev/sdb
mdadm: set /dev/sdb faulty in /dev/md0
```

5) посмотрим что изменилось:

```console
tanin@ubuntu24:~$ cat /proc/mdstat 
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid10 sde[3] sdd[2] sdc[1] sdb[0](F)
      2093056 blocks super 1.2 512K chunks 2 near-copies [4/3] [_UUU]
      
unused devices: <none>
```

Диск /dev/sdb получил префикс F.

На выводе комнады ниже также видим неисправность данного диска, а также раздел "Состояние (State) говорит нам, что RAID-массив 
деградировал.

```console
tanin@ubuntu24:~$ sudo mdadm -D /dev/md0 
/dev/md0:
           Version : 1.2
     Creation Time : Fri Mar 14 00:38:20 2025
        Raid Level : raid10
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Fri Mar 14 01:00:24 2025
             State : clean, degraded 
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 1
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : ubuntu24:0  (local to host ubuntu24)
              UUID : d3f77766:7d5edc7b:f8b9267d:50cb7c28
            Events : 19

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde

       0       8       16        -      faulty   /dev/sdb
```

6) удалим "сломанный" диск из RAID-массива: 

```console
tanin@ubuntu24:~$ sudo mdadm /dev/md0 --remove /dev/sdb
mdadm: hot removed /dev/sdb from /dev/md0
```

7) представим, что дежурный сисадмин провёл замену неисправного диска) добавим "новый" диск:

```console
tanin@ubuntu24:~$ sudo mdadm /dev/md0 --add /dev/sdb
mdadm: added /dev/sdb
```

8) проверим состояние RAID-массива после замены "неисправного" диска, выводе команд можем видеть процесс его перестроения:

```console
tanin@ubuntu24:~$ sudo mdadm -D /dev/md0 
/dev/md0:
           Version : 1.2
     Creation Time : Fri Mar 14 00:38:20 2025
        Raid Level : raid10
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Fri Mar 14 01:13:20 2025
             State : clean, degraded, recovering 
    Active Devices : 3
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 1

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

    Rebuild Status : 41% complete

              Name : ubuntu24:0  (local to host ubuntu24)
              UUID : d3f77766:7d5edc7b:f8b9267d:50cb7c28
            Events : 50

    Number   Major   Minor   RaidDevice State
       4       8       16        0      spare rebuilding   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde

tanin@ubuntu24:~$ cat /proc/mdstat 
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid10 sdb[4] sde[3] sdd[2] sdc[1]
      2093056 blocks super 1.2 512K chunks 2 near-copies [4/3] [_UUU]
      [===================>.]  recovery = 98.5% (1032320/1046528) finish=0.0min speed=258080K/sec
      
unused devices: <none>
```

9) далее: создадим Globally Unique Identifier Partition Table (GPT) или таблицу разделов GUID, четыре раздела и смонтируем их:

Создадим раздел GPT внутри RAID-массива:

```console
tanin@ubuntu24:~$ sudo parted -s /dev/md0 mklabel gpt
```

Создадим разделы:

```console
tanin@ubuntu24:~$ sudo parted /dev/md0 mkpart primary ext4 0% 25%
Information: You may need to update /etc/fstab.

tanin@ubuntu24:~$ sudo parted /dev/md0 mkpart primary ext4 25% 50%        
Information: You may need to update /etc/fstab.

tanin@ubuntu24:~$ sudo parted /dev/md0 mkpart primary ext4 50% 75%       
Information: You may need to update /etc/fstab.

tanin@ubuntu24:~$ sudo parted /dev/md0 mkpart primary ext4 75% 100%     
Information: You may need to update /etc/fstab.
```

Создадим файловую систему ext4 только что созданных разделов, используя цикл for i in:

```console
tanin@ubuntu24:~$ for i in $(seq 1 4); do sudo mkfs.ext4 /dev/md0p$i; done
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 130560 4k blocks and 130560 inodes
Filesystem UUID: 0091f311-d114-4583-b4fe-e5b29b0a72f0
Superblock backups stored on blocks: 
	32768, 98304

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 130816 4k blocks and 130816 inodes
Filesystem UUID: d23581ac-6859-4a21-8ec1-6b422755b52c
Superblock backups stored on blocks: 
	32768, 98304

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 130816 4k blocks and 130816 inodes
Filesystem UUID: a16c9a9f-3a32-4f50-ab1b-93dfb3078ba5
Superblock backups stored on blocks: 
	32768, 98304

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 130560 4k blocks and 130560 inodes
Filesystem UUID: 6a830df9-80ee-4ac7-ad1a-039b2bf555ec
Superblock backups stored on blocks: 
	32768, 98304

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done
```

Смонитируем их (разделы) по директориям, используя регулярные выражения и цикл for i in:

```console
tanin@ubuntu24:~$ sudo mkdir -p /raid/part{1,2,3,4}
tanin@ubuntu24:~$ ls -l /raid/
total 16
drwxr-xr-x 2 root root 4096 Mar 14 01:45 part1
drwxr-xr-x 2 root root 4096 Mar 14 01:45 part2
drwxr-xr-x 2 root root 4096 Mar 14 01:45 part3
drwxr-xr-x 2 root root 4096 Mar 14 01:45 part4

tanin@ubuntu24:~$ for i in $(seq 1 4); do sudo mount /dev/md0p$i /raid/part$i; done
```

Проверим содеянное):

```console
tanin@ubuntu24:~$ cat /proc/mdstat 
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid10 sdb[4] sde[3] sdd[2] sdc[1]
      2093056 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      
unused devices: <none>

tanin@ubuntu24:~$ sudo mdadm -D /dev/md0 | grep /dev/sd
       4       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde

tanin@ubuntu24:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           196M  1.2M  195M   1% /run
efivarfs        256K   47K  210K  19% /sys/firmware/efi/efivars
/dev/sda2        24G  4.0G   19G  18% /
tmpfs           978M     0  978M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sda1       1.1G  6.4M  1.1G   1% /boot/efi
tmpfs           196M   12K  196M   1% /run/user/1000
/dev/md0p1      462M   24K  426M   1% /raid/part1
/dev/md0p2      463M   24K  427M   1% /raid/part2
/dev/md0p3      463M   24K  427M   1% /raid/part3
/dev/md0p4      462M   24K  426M   1% /raid/part4

tanin@ubuntu24:~$ sudo cp -r /var/log/* /raid/part3/

tanin@ubuntu24:~$ ls /raid/part3/
alternatives.log    auth.log.2.gz  boot.log.5             dist-upgrade  dmesg.4.gz  kern.log       private      unattended-upgrades
alternatives.log.1  boot.log       bootstrap.log          dmesg         dpkg.log    kern.log.1     README       vboxpostinstall.log
apport.log          boot.log.1     btmp                   dmesg.0       dpkg.log.1  kern.log.2.gz  syslog       wtmp
apt                 boot.log.2     btmp.1                 dmesg.1.gz    faillog     landscape      syslog.1
auth.log            boot.log.3     cloud-init.log         dmesg.2.gz    installer   lastlog        syslog.2.gz
auth.log.1          boot.log.4     cloud-init-output.log  dmesg.3.gz    journal     lost+found     sysstat

tanin@ubuntu24:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           196M  1.2M  195M   1% /run
efivarfs        256K   47K  210K  19% /sys/firmware/efi/efivars
/dev/sda2        24G  4.0G   19G  18% /
tmpfs           978M     0  978M   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sda1       1.1G  6.4M  1.1G   1% /boot/efi
tmpfs           196M   12K  196M   1% /run/user/1000
/dev/md0p1      462M  8.0K  426M   1% /raid/part1
/dev/md0p2      463M  8.0K  427M   1% /raid/part2
/dev/md0p3      463M  404M   23M  95% /raid/part3
/dev/md0p4      462M  8.0K  426M   1% /raid/part4
```

RAID-массив 10 уровня создан, разделы нарезаны, файловая система создана, рандомное копирование проведено. 
Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
