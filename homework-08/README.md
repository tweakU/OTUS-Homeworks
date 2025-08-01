## Домашнее задание № 8 — «Загрузка системы»

Цель домашнего задания: 
1) научиться попадать в систему без пароля;
2) устанавливать систему с LVM и переименовывать VolumeGroup в операционной системе (ОС) GNU/Linux.

**Задание**:
1. Включить отображение меню Grub.
2. Попасть в систему без пароля несколькими способами.
3. Установить систему с LVM, после чего переименовать VG.

**Выполнение домашнего задания**

Включить отображение меню Grub:
По умолчанию меню загрузчика Grub скрыто и нет задержки при загрузке.
Для отображения меню нужно отредактировать конфигурационный файл.

root@test:~# nano /etc/default/grub

Комментируем строку, скрывающую меню и ставим задержку для выбора пункта меню в 10 секунд.
```console
- #GRUB_TIMEOUT_STYLE=hidden
- GRUB_TIMEOUT=10
```

Обновляем конфигурацию загрузчика и перезагружаемся для проверки.
```console
root@test:~# update-grub
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/init-select.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.4.0-216-generic
Found initrd image: /boot/initrd.img-5.4.0-216-generic
done

root@test:~# reboot
```

При загрузке в окне виртуальной машины мы должны увидеть меню загрузчика.
<img width="640" height="480" alt="VirtualBox_ubuntu-20 04 6-raid1-lvm_29_07_2025_00_42_18" src="https://github.com/user-attachments/assets/d3cbcb44-7810-4a3e-842d-78919c817641" />


**Попасть в систему без пароля несколькими способами**

Для получения доступа необходимо открыть GUI VirtualBox (или другой системы
виртуализации), запустить виртуальную машину и при выборе ядра для загрузки
нажать e - в данном контексте edit. Попадаем в окно, где мы можем изменить
параметры загрузки


**Способ 1. init=/bin/bash**

В конце строки, начинающейся с linux, добавляем init=/bin/bash и нажимаем сtrl-x для
загрузки в систему

<img width="1024" height="768" alt="VirtualBox_ubuntu-22 04 5-server_08_06_2025_21_12_31" src="https://github.com/user-attachments/assets/fcd22d69-a9bf-48ce-97ea-910c00dda528" />

В целом на этом все, Вы попали в систему. Но есть один нюанс. Рутовая файловая
система при этом монтируется в режиме Read-Only. Если вы хотите перемонтировать
ее в режим Read-Write, можно воспользоваться командой:
```console
root@ubuntu22:~# mount -o remount,rw /
```

После чего можно убедиться, записав данные в любой файл или прочитав вывод
команды: 
```console 
root@ubuntu22:~# mount | grep root
```

**Способ 2. Recovery mode**

В меню загрузчика на первом уровне выбрать второй пункт (Advanced options…),
далее загрузить пункт меню с указанием recovery mode в названии.
Получим меню режима восстановления

<img width="1024" height="768" alt="VirtualBox_ubuntu-22 04 5-server_08_06_2025_21_38_39" src="https://github.com/user-attachments/assets/eaaba266-c293-4e77-bcfa-66b5c4d6da40" />

В этом меню сначала включаем поддержку сети (network) для того, чтобы файловая
система перемонтировалась в режим read/write (либо это можно сделать вручную).
Далее выбираем пункт root и попадаем в консоль с пользователем root. Если вы
ранее устанавливали пароль для пользователя root (по умолчанию его нет), то
необходимо его ввести.
В этой консоли можно производить любые манипуляции с системой

<img width="1024" height="768" alt="VirtualBox_ubuntu-22 04 5-server_08_06_2025_21_30_51" src="https://github.com/user-attachments/assets/c61f0133-ae9a-4d16-967b-d94ce7bfa201" />

<img width="1024" height="768" alt="VirtualBox_ubuntu-22 04 5-server_08_06_2025_21_40_16" src="https://github.com/user-attachments/assets/b45a1aa1-810c-4941-af53-50efedddf553" />


**Установить систему с LVM, после чего переименовать VG** 

- Отобразим информации о группах томов
- Проведем переименование группы томов

```console
root@test:~# vgs
  VG   #PV #LV #SN Attr   VSize  VFree
  vg00   1   1   0 wz--n- 15.98g 5.98g

root@test:~# vgrename vg00 ubuntu-otus
  Volume group "vg00" successfully renamed to "ubuntu-otus"
```

Далее правим /boot/grub/grub.cfg. Везде заменяем старое название VG на новое (в
файле дефис меняется на два дефиса ubuntu--otus)

Далее случился fail - я указал один дефис, вместо двух и ессно ОС не загрузилась, провалившись в консоль initramfs. 

<img width="800" height="600" alt="VirtualBox_ubuntu-20 04 6-raid1-lvm_29_07_2025_01_33_15" src="https://github.com/user-attachments/assets/5286a960-6f22-459f-abc2-217b30d23135" />

Исправим это: (опять же, выдумывать ничего не нужно) обратимся к методическому материалу выше 
"и при выборе ядра для загрузки нажать e - в данном контексте edit. 
Попадаем в окно, где мы можем изменить параметры загрузки.", ищем запись root=/dev/mapper/ubuntu-otus-root и добавляем второй дефис в названии VG, загружаеся и проверяем новое название: 

```console
root@test:~# vgs
  VG          #PV #LV #SN Attr   VSize  VFree
  ubuntu-otus   1   1   0 wz--n- 15.98g 5.98g
```


Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
