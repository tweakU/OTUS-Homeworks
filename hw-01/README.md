## Домашнее задание № 1 — «С чего начинается Linux»

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
tanin@ubuntu24:~/kernel$ ls -l
total 220124
-rw-rw-r-- 1 tanin tanin  13868606 Feb  8 09:32 linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb
-rw-rw-r-- 1 tanin tanin   3812282 Feb  8 09:32 linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
-rw-rw-r-- 1 tanin tanin  15861952 Feb  8 09:32 linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
-rw-rw-r-- 1 tanin tanin 191856832 Feb  8 09:32 linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
```

ОПЦИОНАЛЬНО скачаем файл содержащий контрольные суммы и проверим их. 

```console
tanin@ubuntu24:~/kernel$ wget https://kernel.ubuntu.com/mainline/v6.13/amd64/CHECKSUMS
--2025-03-03 21:10:39--  https://kernel.ubuntu.com/mainline/v6.13/amd64/CHECKSUMS
Resolving kernel.ubuntu.com (kernel.ubuntu.com)... 185.125.189.74, 185.125.189.76, 185.125.189.75
Connecting to kernel.ubuntu.com (kernel.ubuntu.com)|185.125.189.74|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1121 (1.1K)
Saving to: ‘CHECKSUMS’

CHECKSUMS                                            100%[===================================================================================================================>]   1.09K  --.-KB/s    in 0s

2025-03-03 21:10:40 (587 MB/s) - ‘CHECKSUMS’ saved [1121/1121]
```

```console
tanin@ubuntu24:~/kernel$ shasum -c CHECKSUMS
linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb: OK
linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb: OK
linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb: OK
linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb: OK
linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb: OK
linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb: OK
linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb: OK
linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb: OK
```

```console
tanin@ubuntu24:~/kernel$ cat CHECKSUMS
# Checksums, check with the command below:
#     shasum -c CHECKSUMS
#
# Checksums-Sha1:
ac4ce3e74c61227c71e3654959aa35d9393a5e08  linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
1b9281268ec2741f0f0648c5eed8a2670fbbc2c1  linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb
53ab2cbc69fdc165ecbb7f2329ed30152596c848  linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
c85aae557cc4802def43c3621b1a028594bab05d  linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
#
# Checksums-Sha256:
298da8f03ed5e05fb6d9fef63ab40f0796e005bdd3ce5df123cdd7c01fa7bbf1  linux-headers-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
11019230e7b7ab93db36f292d69d372704b77e592a7cc347c725501a4fdfa4a0  linux-headers-6.13.0-061300_6.13.0-061300.202501302155_all.deb
cc174bc57b858f996855cf8c4d6e71c353ded3ed32cd55c26780b62435778806  linux-image-unsigned-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
d04414b6b38e4a26c806180bcd7ee7799caafccdd538deb5ce3cc5bcf97bdd42  linux-modules-6.13.0-061300-generic_6.13.0-061300.202501302155_amd64.deb
```















<br/>

[Вернуться к списку всех ДЗ](../README.md)
