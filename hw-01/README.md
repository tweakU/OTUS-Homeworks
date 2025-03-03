## Домашнее задание № 1 — «С чего начинается Linux»

Обновление ядра
Подключаемся по ssh к созданной виртуальной машины.
Перед работами проверим текущую версию ядра:
[db@server ~]$ uname -r
6.8.0-49-generic

Далее зайдём браузеров в репозиторий, где найдём свежую версию ядра для нашей архитектуры https://kernel.ubuntu.com/mainline .
На момент составления документа нам подходит версия 6.13.2: https://kernel.ubuntu.com/mainline/v6.13.2/ 
Архитектура системы для процессоров типа x86_64 (uname -p) требуется amd64.
Находим актуальную ссылку и качаем пакеты на виртуальную машину:
[db@server ~]$ mkdir kernel && cd kernel
[db@server ~]$ wget https://kernel.ubuntu.com/mainline/v6.13.2/amd64/linux-headers-6.13.2-061302-generic_6.13.2-061302.202502081010_amd64.deb
[db@server ~]$ wget https://kernel.ubuntu.com/mainline/v6.13.2/amd64/linux-headers-6.13.2-061302_6.13.2-061302.202502081010_all.deb
[db@server ~]$ wget https://kernel.ubuntu.com/mainline/v6.13.2/amd64/linux-image-unsigned-6.13.2-061302-generic_6.13.2-061302.202502081010_amd64.deb
[db@server ~]$ wget https://kernel.ubuntu.com/mainline/v6.13.2/amd64/linux-modules-6.13.2-061302-generic_6.13.2-061302.202502081010_amd64.deb

Устанавливаем все пакеты сразу:
[db@server ~]$ sudo dpkg -i *.deb 

Проверяем, что ядро появилось в /boot.
[db@server ~]$ ls -al /boot
…
lrwxrwxrwx  1 root root       29 Feb 20 09:54 vmlinuz -> vmlinuz-6.13.2-061302-generic
-rw-------  1 root root 15647232 Feb  8 10:10 vmlinuz-6.13.2-061302-generic
-rw-------  1 root root 14948744 Aug  2  2024 vmlinuz-6.8.0-41-generic
-rw-------  1 root root 14956936 Nov  1 11:41 vmlinuz-6.8.0-49-generic
lrwxrwxrwx  1 root root       24 Feb 20 09:54 vmlinuz.old -> vmlinuz-6.8.0-49-generic
… 

Уже на этом этапе можно перезагрузить нашу виртуальную машину и выбрать новое ядро при загрузке ОС. 
Если требуется, можно назначить новое ядро по умолчанию вручную:
1) Обновить конфигурацию загрузчика:
[db@server ~]$ sudo update-grub
2) Выбрать загрузку нового ядра по-умолчанию:
   	[db@server ~]$ sudo grub-set-default 0

Далее перезагружаем нашу виртуальную машину с помощью команды sudo reboot

После перезагрузки снова проверяем версию ядра (версия должна стать новее):
[db@server ~]$ uname -r 
6.13.2-061302-generic
На этом обновление ядра закончено.


Команда uname - выдает имя текущей системы, с ключем -r выдает информацию о релизе ядра операционной системы.

```console
tanin@ubuntu24:~$ uname -r
6.8.0-54-generic
```

С помощью команд mkdir создадим каталог kernel, с помощью команды cp переместимся в каталог ~/kernel (при вводе команды используется оператор AND (&&), который выполнит вторую команду (cp) при условии успешного выполнения первой команды (mrdir))

```console
tanin@ubuntu24:~$ mkdir ./kernel && cd ./kernel
tanin@ubuntu24:~/kernel$
```

С помощью утилиты wget скачаем необходимые пакеты свежей версии ядра ОС. 

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

С помощью команды ls установим перечень скачанных пакетов.

```console











br/>

[Вернуться к списку всех ДЗ](../README.md)
