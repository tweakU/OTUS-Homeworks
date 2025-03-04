## Домашнее задание № 1 — «С чего начинается Linux»

Цель домашнего задания: научиться обновлять ядро операционной систнмы (ОС) GNU/Linux.

Выполнение домашнего задания:

1) команда uname - выдает имя текущей системы, с ключем -r выдает информацию о релизе ядра ОС: 

```console
tanin@ubuntu24:~$ uname -r
6.8.0-54-generic
```

2) с помощью команд mkdir создадим каталог kernel, с помощью команды cp переместимся в каталог ~/kernel (при вводе команды используется оператор AND (&&), который выполнит вторую команду (cp) при условии успешного выполнения первой команды (mrdir)): 

```console
tanin@ubuntu24:~$ mkdir ./kernel && cd ./kernel
tanin@ubuntu24:~/kernel$
```

3) с помощью утилиты wget скачаем необходимые пакеты свежей версии ядра ОС: 

```console
tanin@ubuntu24:~/kernel$ wget https://kernel.ubuntu.com/mainline/v6.13/amd64/linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb https://kernel.ubuntu.com/mainline/v6.13/amd64/linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb https://kernel.ubuntu.com/mainline/v6.13/amd64/linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb https://kernel.ubuntu.com/mainline/v6.13/amd64/linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
--2025-03-03 20:52:19--  https://kernel.ubuntu.com/mainline/v6.13/amd64/linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.75, 185.125.189.76, 185.125.189.74
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.75|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3812282 (3.6M) [application/x-debian-package]
Saving to: ‘linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb’

linux-headers-6.13.0-061300-generic_6.13.0-061300.20 100%[===================================================================================================================>]   3.63M  8.43MB/s    in 0.4s

2025-03-03 20:52:20 (8.43 MB/s) - ‘linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb’ saved [3812282/3812282]

--2025-03-03 20:52:20--  https://kernel.ubuntu.com/mainline/v6.13/amd64/linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb
Reusing existing connection to kernel.ubuntu.com:443.
HTTP request sent, awaiting response... 200 OK
Length: 13868606 (13M) [application/x-debian-package]
Saving to: ‘linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb’

linux-headers-6.13.0-061300_6.13.0-061300.2025013021 100%[===================================================================================================================>]  13.23M  42.6MB/s    in 0.3s

2025-03-03 20:52:20 (42.6 MB/s) - ‘linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb’ saved [13868606/13868606]

--2025-03-03 20:52:20--  https://kernel.ubuntu.com/mainline/v6.13/amd64/linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
Reusing existing connection to kernel.ubuntu.com:443.
HTTP request sent, awaiting response... 200 OK
Length: 15861952 (15M) [application/x-debian-package]
Saving to: ‘linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb’

linux-image-unsigned-6.13.0-061300-generic_6.13.0-06 100%[===================================================================================================================>]  15.13M  37.5MB/s    in 0.4s

2025-03-03 20:52:21 (37.5 MB/s) - ‘linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb’ saved [15861952/15861952]

--2025-03-03 20:52:21--  https://kernel.ubuntu.com/mainline/v6.13/amd64/linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
Reusing existing connection to kernel.ubuntu.com:443.
HTTP request sent, awaiting response... 200 OK
Length: 191856832 (183M) [application/x-debian-package]
Saving to: ‘linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb’

linux-modules-6.13.0-061300-generic_6.13.0-061300.20 100%[===================================================================================================================>] 182.97M  29.8MB/s    in 6.3s

2025-03-03 20:52:27 (29.2 MB/s) - ‘linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb’ saved [191856832/191856832]

FINISHED --2025-03-03 20:52:27--
Total wall clock time: 8.0s
Downloaded: 4 files, 215M in 7.4s (29.0 MB/s)
```

4) от имени администратора запустим менеджер пакетов dpkg с ключем -i (--install) для их установки (используется маска поиска *.deb, т.е.все файлы с расширением deb): 

```console
tanin@ubuntu24:~/kernel$ sudo dpkg -i *.deb
(Reading database ... 146111 files and directories currently installed.)
Preparing to unpack linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb ...
Unpacking linux-headers-6.13.0-061300 (6.13.0-061300.202501302155) over (6.13.0-061300.202501302155) ...
Preparing to unpack linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb ...
Unpacking linux-headers-6.13.0-061300-generic (6.13.0-061300.202501302155) over (6.13.0-061300.202501302155) ...
Preparing to unpack linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb ...
Unpacking linux-image-unsigned-6.13.0-061300-generic (6.13.0-061300.202501302155) over (6.13.0-061300.202501302155) ...
Preparing to unpack linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb ...
Unpacking linux-modules-6.13.0-061300-generic (6.13.0-061300.202501302155) over (6.13.0-061300.202501302155) ...
Setting up linux-headers-6.13.0-061300 (6.13.0-061300.202501302155) ...
Setting up linux-headers-6.13.0-061300-generic (6.13.0-061300.202501302155) ...
Setting up linux-modules-6.13.0-061300-generic (6.13.0-061300.202501302155) ...
Setting up linux-image-unsigned-6.13.0-061300-generic (6.13.0-061300.202501302155) ...
Processing triggers for linux-image-unsigned-6.13.0-061300-generic (6.13.0-061300.202501302155) ...
/etc/kernel/postinst.d/initramfs-tools:
update-initramfs: Generating /boot/initrd.img-6.13.0-061300-generic
/etc/kernel/postinst.d/zz-update-grub:
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.13.0-061300-generic
Found initrd image: /boot/initrd.img-6.13.0-061300-generic
Found linux image: /boot/vmlinuz-6.8.0-54-generic
Found initrd image: /boot/initrd.img-6.8.0-54-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
```

5) проверяем, что новая версия (v6.13) ядра имеется в каталоге /boot/: 

```console
tanin@ubuntu24:~/kernel$ ls -ls /boot/ | grep 6.13
  308 -rw-r--r-- 1 root root   311399 Jan 30 21:55 config-6.13.0-061300-generic
    0 lrwxrwxrwx 1 root root       32 Mar  3 17:23 initrd.img -> initrd.img-6.13.0-061300-generic
76876 -rw-r--r-- 1 root root 78719615 Mar  3 21:33 initrd.img-6.13.0-061300-generic
 9828 -rw------- 1 root root 10059981 Jan 30 21:55 System.map-6.13.0-061300-generic
    0 lrwxrwxrwx 1 root root       29 Mar  3 17:23 vmlinuz -> vmlinuz-6.13.0-061300-generic
15464 -rw------- 1 root root 15831552 Jan 30 21:55 vmlinuz-6.13.0-061300-generic
```

6) от имени администратора обновим конфигурацию загрузчика grub: 

```console
tanin@ubuntu24:~/kernel$ sudo update-grub
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.13.0-061300-generic
Found initrd image: /boot/initrd.img-6.13.0-061300-generic
Found linux image: /boot/vmlinuz-6.8.0-54-generic
Found initrd image: /boot/initrd.img-6.8.0-54-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
```

7) от имени администратора выберем загрузку нового ядра ОС по-умолчанию: 

```console
tanin@ubuntu24:~/kernel$ sudo grub-set-default 0
```

8) от имени администатора перезагружаем ОС: 
```console
tanin@ubuntu24:~$ sudo reboot
```

9) повторно проверяем версию релиза ядра ОС (до обновления 6.8.0-54-generic): 
```console
tanin@ubuntu24:~$ uname -r
6.13.0-061300-generic
```

Ядро ОС GNU/Linux обновлено. Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
