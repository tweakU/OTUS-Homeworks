## Домашнее задание № 3 — «Файловые системы и LVM»

Цель домашнего задания: научиться создавать и управлять логическими томами в Logical Volume Manager (LVM) в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:

1) Настроить LVM в Ubuntu 24.04 Server:

```console
root@ubuntu24-lvm:~# lsb_release -a | grep -i 'ubuntu 24'
Description:	Ubuntu 24.04.1 LTS

root@ubuntu24-lvm:~# lsblk 
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   64G  0 disk 
├─sda1                      8:1    0    1G  0 part /boot/efi
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0 60,9G  0 part 
  └─ubuntu--vg-ubuntu--lv 252:0    0 30,5G  0 lvm  /
sdb                         8:16   0   10G  0 disk 
sdc                         8:32   0    2G  0 disk 
sdd                         8:48   0    1G  0 disk 
sde                         8:64   0    1G  0 disk 
sr0                        11:0    1 1024M  0 rom
```

2) Создать Physical Volume, Volume Group и Logical Volume:

LVM имеет три уровня абстракции: 
- физический том
- группа томов 
- логический том 

Командой vgcreate создадим группу логических томов "otus", при этом физический том будет создан автоматически на блочном устройстве /dev/sdb (таким образом применение команды pvcreate опускается)

```console
root@ubuntu24-lvm:~# vgcreate otus /dev/sdb
  Physical volume "/dev/sdb" successfully created.
  Volume group "otus" successfully created


```

3) Отформатировать и смонтировать файловую систему:

```console

```

4) Расширить файловую систему за счёт нового диска:

```console

```

5) Выполнить resize: 

```console

```

6) Проверить корректность работы:

```console

```











RAID-массив 10 уровня создан, разделы нарезаны, файловая система создана, рандомное копирование проведено. 
Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
