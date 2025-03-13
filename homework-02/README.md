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
Вывод команд указывается на успешное выполнение задачи.

4) от 

```console
```

5) проверяем

```console
```

6) от 
```console
```

7) от 

```console
```

8) от 

```console
```

9) повторно 

```console
```

Ядро ОС GNU/Linux обновлено. Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
