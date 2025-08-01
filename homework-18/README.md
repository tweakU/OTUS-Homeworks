## Домашнее задание № 18 — «Vagrant»

Цель домашнего задания: Научиться обновлять ядро в ОС Linux. Получение навыков работы с Vagrant в операционной системе (ОС) GNU/Linux.

Описание домашнего задания:
1) Запустить ВМ с помощью Vagrant.
2) Обновить ядро ОС из репозитория ELRepo.

**Выполнение домашнего задания:**

Создадим Vagrantfile (оригинал тут https://github.com/Nickmob/vagrant_kernel_update/blob/main/Vagrantfile), в котором будут указаны параметры нашей ВМ:

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


PS D:\linux\otus\linux_prof\hw-18> vagrant ssh



[vagrant@kernel-update ~]$ uname -r
4.18.0-516.el8.x86_64




```

2) Обновим ядро ОС из репозитория ELRepo.

```console
```

3) 

```console
```

4) 

```console
```

5) 

```console
```

6) 

```console
```

7) 

```console
```

8) 

```console

```

9) 

```console
```

10) 

```console
```

11) 

```console

```

Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
