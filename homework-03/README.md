## Домашнее задание № 3 — «Файловые системы и LVM»

Цель домашнего задания: научиться создавать и управлять логическими томами в Logical Volume Manager (LVM) в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:

1) Установить Ubuntu 24.04 Server с LVM по умолчанию:

```console
root@ubuntu24-lvm:~# cat /etc/os-release 
PRETTY_NAME="Ubuntu 24.04.1 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.1 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```

Добавим четыре вирутальных блочных устройства. Диски sdb, sdc будем использовать для базовых вещей и снапшотов; на sdd, sde создадим LVM mirror.

```console
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

Командой vgcreate создадим группу логических томов 'otus', при этом физический том будет создан автоматически на блочном устройстве /dev/sdb (таким образом использование команды pvcreate опускается):

```console
root@ubuntu24-lvm:~# vgcreate otus /dev/sdb
  Physical volume "/dev/sdb" successfully created.
  Volume group "otus" successfully created
```

Командой lvcreate создадим логический том с именем 'test' внутри группы 'otus', ключ -l|--extents позволяет указать размер тома в % от объёма свободного пространства, ключ -n|--name позволяет задать имя логического тома:

Команды pvs, vgs, lvs выводят информацию о физических томах, группе томов и логических томах соотвественно:

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

Команды pvdisplay, vgdisplay, lvdisplay выводят расширенную информацию о физических томах, группе томов и логических томах соотвественно:

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

Ключ -v|--verbose команды vgdisplay увеличивает детализацию вывода информации о группе томов, перенаправляя stdout vgdisplay на stdin grep видим какие блочные устройства входят в группу томов с именем "otus":

```console
root@ubuntu24-lvm:~# vgdisplay -v otus | grep 'PV Name'
  PV Name               /dev/sdb
```

Чтобы получить детальную информацию о логическом томе "test" введем комнаду lvdisplay с аргументом абсолютного пути:

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

Посмотрим краткую информацию о группе томов и логических томах:

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

Создадим логичекий том с именем "small" внутри гурппы томов "otus" с указанием абсолютного размера в 100 Мегабайт: 

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

Командой mkfs.ext4 создадим файловую систему ext4 на логическом томе "test" и смонтируем его:

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
```

Создадим каталог и смонитируем логический том "test" в /data:

```console
root@ubuntu24-lvm:~# mkdir /data

root@ubuntu24-lvm:~# mount /dev/otus/test /data

root@ubuntu24-lvm:~# mount | grep /data
/dev/mapper/otus-test on /data type ext4 (rw,relatime)
```

4) Расширить файловую систему за счёт нового диска:

Командой pvs выведем краткую информацию о физических томах; командой pvcreate создадим физический том на /dev/sdc:

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

Командой vgextend добавим (расширим существующую группу томов) физический том в существующую группу томов:
Выводом команд vgdisplay и vgs убедимся в том, что группа томов "otus" содержит два физических тома и её объём увеличился: 

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

Командой dd сымитируем занятое место:

```console
root@ubuntu24-lvm:~# dd if=/dev/zero of=/data/test.log bs=1M  count=8000 status=progress
6351224832 bytes (6,4 GB, 5,9 GiB) copied, 2 s, 3,2 GB/s
dd: error writing '/data/test.log': No space left on device
7944+0 records in
7943+0 records out
8329297920 bytes (8,3 GB, 7,8 GiB) copied, 2,52268 s, 3,3 GB/s

root@ubuntu24-lvm:~# df -Th /data/
Filesystem            Type  Size  Used Avail Use% Mounted on
/dev/mapper/otus-test ext4  7,8G  7,8G     0 100% /data
```

Командой lvextend увеличим размер логического тома "test" 

```console
root@ubuntu24-lvm:~# lvextend -l+80%FREE /dev/otus/test
  Size of logical volume otus/test changed from <8,00 GiB (2047 extents) to <11,12 GiB (2846 extents).
  Logical volume otus/test successfully resized.

root@ubuntu24-lvm:~# lvs /dev/otus/test 
  LV   VG   Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  test otus -wi-ao---- <11,12g                                                    

root@ubuntu24-lvm:~# df -Th /data/
Filesystem            Type  Size  Used Avail Use% Mounted on
/dev/mapper/otus-test ext4  7,8G  7,8G     0 100% /data
```

5) Выполнить resize: 

```console
root@ubuntu24-lvm:~# resize2fs /dev/otus/test 
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/otus/test is mounted on /data; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/otus/test is now 2914304 (4k) blocks long.

root@ubuntu24-lvm:~# df -Th /data/
Filesystem            Type  Size  Used Avail Use% Mounted on
/dev/mapper/otus-test ext4   11G  7,8G  2,6G  76% /data

root@ubuntu24-lvm:~# umount /data 

root@ubuntu24-lvm:~# e2fsck -fy /dev/otus/test 
e2fsck 1.47.0 (5-Feb-2023)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/otus/test: 12/729088 files (0.0% non-contiguous), 2105907/2914304 blocks

root@ubuntu24-lvm:~# resize2fs /dev/otus/test 10G
resize2fs 1.47.0 (5-Feb-2023)
Resizing the filesystem on /dev/otus/test to 2621440 (4k) blocks.
The filesystem on /dev/otus/test is now 2621440 (4k) blocks long.

root@ubuntu24-lvm:~# lvreduce /dev/otus/test -L 10G
  WARNING: Reducing active logical volume to 10,00 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce otus/test? [y/n]: y
  Size of logical volume otus/test changed from <11,12 GiB (2846 extents) to 10,00 GiB (2560 extents).
  Logical volume otus/test successfully resized.

root@ubuntu24-lvm:~# mount /dev/otus/test /data/
```

6) Проверить корректность работы:

```console
root@ubuntu24-lvm:~# df -Th /data/
Filesystem            Type  Size  Used Avail Use% Mounted on
/dev/mapper/otus-test ext4  9,8G  7,8G  1,6G  84% /data

root@ubuntu24-lvm:~# lvs /dev/otus/test
  LV   VG   Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  test otus -wi-ao---- 10,00g
```





7) Уменьшить том под / до 8G.

```console
root@ubuntu24-lvm:~# vgcreate vg_root /dev/sdb
  Physical volume "/dev/sdb" successfully created.
  Volume group "vg_root" successfully created

root@ubuntu24-lvm:~# lvcreate -n lv_root -l +100%FREE /dev/vg_root
WARNING: ext4 signature detected on /dev/vg_root/lv_root at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/vg_root/lv_root.
  Logical volume "lv_root" created.

root@ubuntu24-lvm:~# mkfs.ext4 /dev/vg_root/lv_root
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 2620416 4k blocks and 655360 inodes
Filesystem UUID: 41293be5-9266-42e6-870b-3822bb01ad18
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

root@ubuntu24-lvm:~# mount /dev/vg_root/lv_root /mnt

root@ubuntu24-lvm:~# ls -l /mnt/
total 16
drwx------ 2 root root 16384 мар 17 20:48 lost+found

root@ubuntu24-lvm:~# rsync -aqvxHAX --progress / /mnt/

root@ubuntu24-lvm:~# ls -l /mnt/
total 2097256
lrwxrwxrwx   1 root root          7 апр 22  2024 bin -> usr/bin
drwxr-xr-x   2 root root       4096 фев 26  2024 bin.usr-is-merged
drwxr-xr-x   2 root root       4096 мар 16 20:26 boot
dr-xr-xr-x   2 root root       4096 авг 27  2024 cdrom
drwxr-xr-x   2 root root       4096 мар 17 19:52 data
drwxr-xr-x   2 root root       4096 мар 17 20:48 dev
drwxr-xr-x 106 root root       4096 мар 16 20:27 etc
drwxr-xr-x   3 root root       4096 мар 16 20:27 home
lrwxrwxrwx   1 root root          7 апр 22  2024 lib -> usr/lib
drwxr-xr-x   2 root root       4096 фев 26  2024 lib.usr-is-merged
drwx------   2 root root      16384 мар 16 20:18 lost+found
drwxr-xr-x   2 root root       4096 авг 27  2024 media
drwxr-xr-x   2 root root       4096 мар 17 20:48 mnt
drwxr-xr-x   2 root root       4096 авг 27  2024 opt
dr-xr-xr-x   2 root root       4096 мар 17 16:57 proc
drwx------   3 root root       4096 мар 17 20:24 root
drwxr-xr-x   2 root root       4096 мар 17 19:32 run
lrwxrwxrwx   1 root root          8 апр 22  2024 sbin -> usr/sbin
drwxr-xr-x   2 root root       4096 мар 31  2024 sbin.usr-is-merged
drwxr-xr-x   2 root root       4096 мар 16 20:27 snap
drwxr-xr-x   2 root root       4096 авг 27  2024 srv
-rw-------   1 root root 2147483648 мар 16 20:26 swap.img
dr-xr-xr-x   2 root root       4096 мар 17 16:57 sys
drwxrwxrwt  12 root root       4096 мар 17 20:48 tmp
drwxr-xr-x  11 root root       4096 авг 27  2024 usr
drwxr-xr-x  13 root root       4096 мар 16 20:27 var

root@ubuntu24-lvm:~# for i in /proc/ /sys/ /dev/ /run/ /boot/; \
 do mount --bind $i /mnt/$i; done

root@ubuntu24-lvm:~# chroot /mnt/

root@ubuntu24-lvm:/# grub-mkconfig -o /boot/grub/grub.cfg
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.8.0-55-generic
Found initrd image: /boot/initrd.img-6.8.0-55-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done

root@ubuntu24-lvm:/# update-initramfs -u
update-initramfs: Generating /boot/initrd.img-6.8.0-55-generic

root@ubuntu24-lvm:/# exit
exit

root@ubuntu24-lvm:~# reboot

root@ubuntu24-lvm:~# lsblk 
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   64G  0 disk 
├─sda1                      8:1    0    1G  0 part /boot/efi
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0 60,9G  0 part 
  └─ubuntu--vg-ubuntu--lv 252:1    0 30,5G  0 lvm  
sdb                         8:16   0   10G  0 disk 
└─vg_root-lv_root         252:0    0   10G  0 lvm  /
sdc                         8:32   0    2G  0 disk 
sdd                         8:48   0    1G  0 disk 
sde                         8:64   0    1G  0 disk 
sr0                        11:0    1 1024M  0 rom

root@ubuntu24-lvm:~# lvremove /dev/ubuntu-vg/ubuntu-lv
Do you really want to remove and DISCARD active logical volume ubuntu-vg/ubuntu-lv? [y/n]: y
  Logical volume "ubuntu-lv" successfully removed.

root@ubuntu24-lvm:~# lvcreate -n ubuntu-vg/ubuntu-lv -L 8G /dev/ubuntu-vg
WARNING: ext4 signature detected on /dev/ubuntu-vg/ubuntu-lv at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/ubuntu-vg/ubuntu-lv.
  Logical volume "ubuntu-lv" created.

root@ubuntu24-lvm:~# mkfs.ext4 /dev/ubuntu-vg/ubuntu-lv
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 2097152 4k blocks and 524288 inodes
Filesystem UUID: d5377723-5e4f-4997-a76e-45a481508b3a
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

root@ubuntu24-lvm:~# mount /dev/ubuntu-vg/ubuntu-lv /mnt/

root@ubuntu24-lvm:~# ls -l /mnt/
total 16
drwx------ 2 root root 16384 мар 17 20:54 lost+found

root@ubuntu24-lvm:~# rsync -aqvxHAX --progress / /mnt/

root@ubuntu24-lvm:~# ls -l /mnt/
total 2097256
lrwxrwxrwx   1 root root          7 апр 22  2024 bin -> usr/bin
drwxr-xr-x   2 root root       4096 фев 26  2024 bin.usr-is-merged
drwxr-xr-x   2 root root       4096 мар 17 20:51 boot
dr-xr-xr-x   2 root root       4096 авг 27  2024 cdrom
drwxr-xr-x   2 root root       4096 мар 17 19:52 data
drwxr-xr-x   2 root root       4096 мар 17 20:54 dev
drwxr-xr-x 106 root root       4096 мар 16 20:27 etc
drwxr-xr-x   3 root root       4096 мар 16 20:27 home
lrwxrwxrwx   1 root root          7 апр 22  2024 lib -> usr/lib
drwxr-xr-x   2 root root       4096 фев 26  2024 lib.usr-is-merged
drwx------   2 root root      16384 мар 16 20:18 lost+found
drwxr-xr-x   2 root root       4096 авг 27  2024 media
drwxr-xr-x   2 root root       4096 мар 17 20:54 mnt
drwxr-xr-x   2 root root       4096 авг 27  2024 opt
dr-xr-xr-x   2 root root       4096 мар 17 20:52 proc
drwx------   3 root root       4096 мар 17 20:24 root
drwxr-xr-x   2 root root       4096 мар 17 20:52 run
lrwxrwxrwx   1 root root          8 апр 22  2024 sbin -> usr/sbin
drwxr-xr-x   2 root root       4096 мар 31  2024 sbin.usr-is-merged
drwxr-xr-x   2 root root       4096 мар 16 20:27 snap
drwxr-xr-x   2 root root       4096 авг 27  2024 srv
-rw-------   1 root root 2147483648 мар 16 20:26 swap.img
dr-xr-xr-x   2 root root       4096 мар 17 20:52 sys
drwxrwxrwt  12 root root       4096 мар 17 20:53 tmp
drwxr-xr-x  11 root root       4096 авг 27  2024 usr
drwxr-xr-x  13 root root       4096 мар 16 20:27 var

root@ubuntu24-lvm:~# for i in /proc/ /sys/ /dev/ /run/ /boot/; \
 do mount --bind $i /mnt/$i; done

root@ubuntu24-lvm:~# chroot /mnt/

root@ubuntu24-lvm:/# grub-mkconfig -o /boot/grub/grub.cfg
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.8.0-55-generic
Found initrd image: /boot/initrd.img-6.8.0-55-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done

root@ubuntu24-lvm:/# update-initramfs -u
update-initramfs: Generating /boot/initrd.img-6.8.0-55-generic
W: Couldn't identify type of root file system for fsck hook
```

8) Выделить том под /home.

```console

```

9) Выделить том под /var - сделать в mirror.

```console
root@ubuntu24-lvm:/# vgcreate vg_var /dev/sdc /dev/sdd
  Physical volume "/dev/sdc" successfully created.
  Physical volume "/dev/sdd" successfully created.
  Volume group "vg_var" successfully created

root@ubuntu24-lvm:/# lvcreate -L 950M -m1 -n lv_var vg_var
  Rounding up size to full physical extent 952,00 MiB
  Logical volume "lv_var" created.

root@ubuntu24-lvm:/# mkfs.ext4 /dev/vg_var/lv_var
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 243712 4k blocks and 60928 inodes
Filesystem UUID: ad604876-7596-45ec-90ce-fdbaa4f52430
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

root@ubuntu24-lvm:/# mount /dev/vg_var/lv_var /mnt/

root@ubuntu24-lvm:/# cp -aR /var/* /mnt/

root@ubuntu24-lvm:/# mkdir /tmp/oldvar && mv /var/* /tmp/oldvar

root@ubuntu24-lvm:/# umount /mnt/

root@ubuntu24-lvm:/# mount /dev/vg_var/lv_var /var

root@ubuntu24-lvm:/# echo "`blkid | grep var: | awk '{print $2}'` \
 /var ext4 defaults 0 0" >> /etc/fstab

root@ubuntu24-lvm:/# exit 
exit

root@ubuntu24-lvm:~# reboot

root@ubuntu24-lvm:~# lvremove /dev/vg_root/lv_root
Do you really want to remove and DISCARD active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed.

root@ubuntu24-lvm:~# vgremove /dev/vg_root
  Volume group "vg_root" successfully removed

root@ubuntu24-lvm:~# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
```

10) /home - сделать том для снапшотов.

```console
root@ubuntu24-lvm:~# lvcreate -n LogVol_Home -L 2G /dev/ubuntu-vg
  Logical volume "LogVol_Home" created.

root@ubuntu24-lvm:~# mkfs.ext4 /dev/ubuntu-vg/LogVol_Home
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 524288 4k blocks and 131072 inodes
Filesystem UUID: eb73cb94-f14a-4977-8e00-03094375fa10
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

root@ubuntu24-lvm:~# mount /dev/ubuntu-vg/LogVol_Home /mnt/

root@ubuntu24-lvm:~# cp -aR /home/* /mnt/

root@ubuntu24-lvm:~# rm -rf /home/*

root@ubuntu24-lvm:~# umount /mnt 

root@ubuntu24-lvm:~# mount /dev/ubuntu-vg/LogVol_Home /home/

root@ubuntu24-lvm:~# echo "`blkid | grep Home | awk '{print $2}'` \
 /home xfs defaults 0 0" >> /etc/fstab
```

11) Прописать монтирование в fstab. Попробовать с разными опциями и разными файловыми системами (на выбор).

```console

```

12) Работа со снапшотами:
	сгенерить файлы в /home/;
	снять снапшот;
	удалить часть файлов;
	восстановится со снапшота.






Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
