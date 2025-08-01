## Домашнее задание № 18 — «Vagrant»

Цель домашнего задания: Научиться обновлять ядро в ОС Linux. Получение навыков работы с Vagrant в операционной системе (ОС) GNU/Linux.

Описание домашнего задания:
1) Запустить ВМ с помощью Vagrant.
2) Обновить ядро ОС из репозитория ELRepo.

**Выполнение домашнего задания:**

Создадим Vagrantfile (оригинал с правильными отступами [тут](https://github.com/Nickmob/vagrant_kernel_update/blob/main/Vagrantfile)), в котором будут указаны параметры нашей ВМ (Текст конфигов здесь представлен для ознакомления):

```console
# Описываем Виртуальные машины
MACHINES = {
# Указываем имя ВМ "kernel update"
:"kernel-update" => {
#Какой vm box будем использовать
:box_name => "generic/centos8s",
#Указываем box_version
:box_version => "4.3.4",
#Указываем количество ядер ВМ
:cpus => 2,
#Указываем количество ОЗУ в мегабайтах
:memory => 1024,
}
}
Vagrant.configure("2") do |config|
MACHINES.each do |boxname, boxconfig|
# Отключаем проброс общей папки в ВМ
config.vm.synced_folder ".", "/vagrant", disabled: true
# Применяем конфигурацию ВМ
config.vm.define boxname do |box|
box.vm.box = boxconfig[:box_name]
box.vm.box_version = boxconfig[:box_version]
box.vm.host_name = boxname.to_s
box.vm.provider "virtualbox" do |v|
v.memory = boxconfig[:memory]
v.cpus = boxconfig[:cpus]
end
end
end
end
```

Правильный синтаксис Vagrantfile выглядит так:
```console
MACHINES = {
  :"kernel-update" => {
              :box_name => "generic/centos8s",
              :box_version => "4.3.4",
              :cpus => 2,
              :memory => 1024,
            }
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.box_version = boxconfig[:box_version]
      box.vm.host_name = boxname.to_s
      box.vm.provider "virtualbox" do |v|
        v.memory = boxconfig[:memory]
        v.cpus = boxconfig[:cpus]
      end
    end
  end
end
```

После создания Vagrantfile, запустим виртуальную машину командой vagrant
up. Будет создана виртуальная машина с ОС CentOS 8 Stream, с 2-мя ядрами
CPU и 1ГБ ОЗУ: 

```console
PS D:\linux\otus\linux_prof\hw-18> vagrant up
...
==> kernel-update: Machine booted and ready!
==> kernel-update: Checking for guest additions in VM...
...
```

**Обновление ядра**
Подключаемся по ssh к созданной виртуальной машины. Для этого в каталоге
с нашим Vagrantfile вводим команду vagrant ssh.
Перед работами проверим текущую версию ядра

```console
PS D:\linux\otus\linux_prof\hw-18> vagrant ssh

[vagrant@kernel-update ~]$ uname -r
4.18.0-516.el8.x86_64
```

Далее подключим репозиторий, откуда возьмём необходимую версию ядра:

```console
[vagrant@kernel-update ~]$ sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
Last metadata expiration check: 0:01:13 ago on Fri 01 Aug 2025 04:27:10 PM UTC.
elrepo-release-8.el8.elrepo.noarch.rpm                                                                                                                                              19 kB/s |  19 kB     00:00
Dependencies resolved.
===================================================================================================================================================================================================================
 Package                                              Architecture                                 Version                                                Repository                                          Size
===================================================================================================================================================================================================================
Installing:
 elrepo-release                                       noarch                                       8.4-2.el8.elrepo                                       @commandline                                        19 k

Transaction Summary
===================================================================================================================================================================================================================
Install  1 Package

Total size: 19 k
Installed size: 8.3 k
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                           1/1
  Installing       : elrepo-release-8.4-2.el8.elrepo.noarch                                                                                                                                                    1/1
  Verifying        : elrepo-release-8.4-2.el8.elrepo.noarch                                                                                                                                                    1/1

Installed:
  elrepo-release-8.4-2.el8.elrepo.noarch

Complete!
```

В репозитории есть две версии ядер:
kernel-ml — свежие и стабильные ядра
kernel-lt — стабильные ядра с длительной версией поддержки, более старые, чем версия ml.

Установим последнее ядро из репозитория elrepo-kernel:
(Параметр --enablerepo elrepo-kernel указывает что пакет ядра будет запрошен из репозитория elrepo-kernel.)

```console
[vagrant@kernel-update ~]$ sudo yum --enablerepo elrepo-kernel install kernel-ml -y
CentOS Stream 8 - AppStream                                                                                                                                                         18 kB/s | 4.4 kB     00:00
CentOS Stream 8 - BaseOS                                                                                                                                                            26 kB/s | 3.9 kB     00:00
CentOS Stream 8 - Extras                                                                                                                                                            22 kB/s | 2.9 kB     00:00
CentOS Stream 8 - Extras common packages                                                                                                                                            22 kB/s | 3.0 kB     00:00
ELRepo.org Community Enterprise Linux Repository - el8                                                                                                                             267 kB/s | 238 kB     00:00
ELRepo.org Community Enterprise Linux Kernel Repository - el8                                                                                                                      2.5 MB/s | 2.2 MB     00:00
Extra Packages for Enterprise Linux 8 - x86_64                                                                                                                                     104 kB/s |  39 kB     00:00
Extra Packages for Enterprise Linux 8 - Next - x86_64                                                                                                                              4.4 kB/s | 1.9 kB     00:00
Dependencies resolved.
===================================================================================================================================================================================================================
 Package                                               Architecture                               Version                                                  Repository                                         Size
===================================================================================================================================================================================================================
Installing:
 kernel-ml                                             x86_64                                     6.15.8-1.el8.elrepo                                      elrepo-kernel                                     155 k
Installing dependencies:
 kernel-ml-core                                        x86_64                                     6.15.8-1.el8.elrepo                                      elrepo-kernel                                      67 M
 kernel-ml-modules                                     x86_64                                     6.15.8-1.el8.elrepo                                      elrepo-kernel                                      62 M

Transaction Summary
===================================================================================================================================================================================================================
Install  3 Packages

Total download size: 129 M
Installed size: 175 M
Downloading Packages:
(1/3): kernel-ml-6.15.8-1.el8.elrepo.x86_64.rpm                                                                                                                                    560 kB/s | 155 kB     00:00
(2/3): kernel-ml-core-6.15.8-1.el8.elrepo.x86_64.rpm                                                                                                                                10 MB/s |  67 MB     00:06
(3/3): kernel-ml-modules-6.15.8-1.el8.elrepo.x86_64.rpm                                                                                                                            4.8 MB/s |  62 MB     00:13
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                              9.7 MB/s | 129 MB     00:13
ELRepo.org Community Enterprise Linux Kernel Repository - el8                                                                                                                      1.6 MB/s | 1.7 kB     00:00
Importing GPG key 0xBAADAE52:
 Userid     : "elrepo.org (RPM Signing Key for elrepo.org) <secure@elrepo.org>"
 Fingerprint: 96C0 104F 6315 4731 1E0B B1AE 309B C305 BAAD AE52
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
Key imported successfully
ELRepo.org Community Enterprise Linux Kernel Repository - el8                                                                                                                      3.0 MB/s | 3.1 kB     00:00
Importing GPG key 0xEAA31D4A:
 Userid     : "elrepo.org (RPM Signing Key v2 for elrepo.org) <secure@elrepo.org>"
 Fingerprint: B8A7 5587 4DA2 40C9 DAC4 E715 5160 0989 EAA3 1D4A
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-v2-elrepo.org
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                           1/1
  Installing       : kernel-ml-core-6.15.8-1.el8.elrepo.x86_64                                                                                                                                                 1/3
  Running scriptlet: kernel-ml-core-6.15.8-1.el8.elrepo.x86_64                                                                                                                                                 1/3
  Installing       : kernel-ml-modules-6.15.8-1.el8.elrepo.x86_64                                                                                                                                              2/3
  Running scriptlet: kernel-ml-modules-6.15.8-1.el8.elrepo.x86_64                                                                                                                                              2/3
  Installing       : kernel-ml-6.15.8-1.el8.elrepo.x86_64                                                                                                                                                      3/3
  Running scriptlet: kernel-ml-core-6.15.8-1.el8.elrepo.x86_64                                                                                                                                                 3/3
dracut: Disabling early microcode, because kernel does not support it. CONFIG_MICROCODE_[AMD|INTEL]!=y
dracut: Disabling early microcode, because kernel does not support it. CONFIG_MICROCODE_[AMD|INTEL]!=y

  Running scriptlet: kernel-ml-6.15.8-1.el8.elrepo.x86_64                                                                                                                                                      3/3
  Verifying        : kernel-ml-6.15.8-1.el8.elrepo.x86_64                                                                                                                                                      1/3
  Verifying        : kernel-ml-core-6.15.8-1.el8.elrepo.x86_64                                                                                                                                                 2/3
  Verifying        : kernel-ml-modules-6.15.8-1.el8.elrepo.x86_64                                                                                                                                              3/3

Installed:
  kernel-ml-6.15.8-1.el8.elrepo.x86_64                             kernel-ml-core-6.15.8-1.el8.elrepo.x86_64                             kernel-ml-modules-6.15.8-1.el8.elrepo.x86_64

Complete!
```

Уже на этом этапе можно перезагрузить нашу виртуальную машину и выбрать новое ядро при загрузке ОС. 
Если требуется, можно назначить новое ядро по-умолчанию вручную:
1) Обновить конфигурацию загрузчика:
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg
3) Выбрать загрузку нового ядра по-умолчанию:
   sudo grub2-set-default 0

Далее перезагружаем нашу виртуальную машину с помощью команды sudo reboot
```console
[vagrant@kernel-update ~]$ sudo reboot
Connection to 127.0.0.1 closed by remote host.
```

После перезагрузки снова проверяем версию ядра (версия должна стать новее):
```console
[vagrant@kernel-update ~]$ uname -r
6.15.8-1.el8.elrepo.x86_64
```
На этом обновление ядра закончено.


Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
