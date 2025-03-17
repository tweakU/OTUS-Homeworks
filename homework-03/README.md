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
- PV, Physical volume, физический том — это физический диск, либо раздел на диске, если по каким-то причинам нельзя использовать его целиком.
- VG, Volume group, группа томов — группа томов объединяет в себя физические тома и является следующим уровнем абстракции, представляя собой единое пространство хранения, которое может быть размечено на логические разделы — эквивалентно обычному диску в классической системе.
- LV, Logical volume, логический том — логический раздел в группе томов, аналогичен обычном разделу, представляет из себя блочное устройство и может содержать файловую систему.

Командой vgcreate создадим группу логических томов 'otus', при этом физический том будет создан автоматически на блочном устройстве /dev/sdb (таким образом использование команды pvcreate опускается)

```console
root@ubuntu24-lvm:~# vgcreate otus /dev/sdb
  Physical volume "/dev/sdb" successfully created.
  Volume group "otus" successfully created
```

Командой lvcreate создадим логический том с именем 'test' внутри группы 'otus', ключ -l, --extents позволяет указать размер тома в % от объёма свободного пространства, ключ -n, --name позволяет задать имя логического тома:

```console
root@ubuntu24-lvm:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree  
  otus        1   0   0 wz--n- <10,00g <10,00g
  ubuntu-vg   1   1   0 wz--n- <60,95g  30,47g

root@ubuntu24-lvm:~# lvcreate -l+80%FREE -n test otus
  Logical volume "test" created.

root@ubuntu24-lvm:~# lvs
  LV        VG        Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  test      otus      -wi-a----- <8,00g                                                    
  ubuntu-lv ubuntu-vg -wi-ao---- 30,47g
```

```console
root@ubuntu24-lvm:~# vgdisplay otus
  --- Volume group ---
  VG Name               otus
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <10,00 GiB
  PE Size               4,00 MiB
  Total PE              2559
  Alloc PE / Size       2047 / <8,00 GiB
  Free  PE / Size       512 / 2,00 GiB
  VG UUID               UY5zz7-pzZt-3lKD-45rn-SSyw-ZkI3-fX0NXP
```

```console
root@ubuntu24-lvm:~# vgdisplay -v otus | grep 'PV Name'
  PV Name               /dev/sdb
```

```console
root@ubuntu24-lvm:~# lvdisplay /dev/otus/test
  --- Logical volume ---
  LV Path                /dev/otus/test
  LV Name                test
  VG Name                otus
  LV UUID                jrfnM3-RBBy-VBmU-VMEa-HfHV-uZ6I-zwlPNK
  LV Write Access        read/write
  LV Creation host, time ubuntu24-lvm, 2025-03-17 17:07:11 +0000
  LV Status              available
  # open                 0
  LV Size                <8,00 GiB
  Current LE             2047
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           252:0
```

```console
root@ubuntu24-lvm:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree 
  otus        1   1   0 wz--n- <10,00g  2,00g
  ubuntu-vg   1   1   0 wz--n- <60,95g 30,47g

root@ubuntu24-lvm:~# lvs
  LV        VG        Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  test      otus      -wi-a----- <8,00g                                                    
  ubuntu-lv ubuntu-vg -wi-ao---- 30,47g
```

```console
root@ubuntu24-lvm:~# lvcreate -L100M -n small otus
  Logical volume "small" created.

root@ubuntu24-lvm:~# lvs
  LV        VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  small     otus      -wi-a----- 100,00m                                                    
  test      otus      -wi-a-----  <8,00g                                                    
  ubuntu-lv ubuntu-vg -wi-ao----  30,47g
```

3) Отформатировать и смонтировать файловую систему:

```console
root@ubuntu24-lvm:~# mkfs.ext4 /dev/otus/test
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 2096128 4k blocks and 524288 inodes
Filesystem UUID: f1ed528c-1fb2-44d0-8208-aac5a2cf46b5
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

#Создадим каталог:

root@ubuntu24-lvm:~# mkdir /data

root@ubuntu24-lvm:~# mount /dev/otus/test /data

root@ubuntu24-lvm:~# mount | grep /data
/dev/mapper/otus-test on /data type ext4 (rw,relatime)
```

4) Расширить файловую систему за счёт нового диска:

```console
root@ubuntu24-lvm:~# pvs
  PV         VG        Fmt  Attr PSize   PFree 
  /dev/sda3  ubuntu-vg lvm2 a--  <60,95g 30,47g
  /dev/sdb   otus      lvm2 a--  <10,00g  1,90g

root@ubuntu24-lvm:~# pvcreate /dev/sdc
  Physical volume "/dev/sdc" successfully created.

root@ubuntu24-lvm:~# pvs
  PV         VG        Fmt  Attr PSize   PFree 
  /dev/sda3  ubuntu-vg lvm2 a--  <60,95g 30,47g
  /dev/sdb   otus      lvm2 a--  <10,00g  1,90g
  /dev/sdc             lvm2 ---    2,00g  2,00g
```

```console
root@ubuntu24-lvm:~# vgextend otus /dev/sdc
  Volume group "otus" successfully extended

root@ubuntu24-lvm:~# vgdisplay -v otus | grep 'PV Name'
  PV Name               /dev/sdb     
  PV Name               /dev/sdc     

root@ubuntu24-lvm:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree 
  otus        2   2   0 wz--n-  11,99g <3,90g
  ubuntu-vg   1   1   0 wz--n- <60,95g 30,47g
```

```console
root@ubuntu24-lvm:~# mkdir /data

root@ubuntu24-lvm:~# mount /dev/otus/test /data

root@ubuntu24-lvm:~# mount | grep /data
/dev/mapper/otus-test on /data type ext4 (rw,relatime)
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
