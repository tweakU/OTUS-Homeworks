## Домашнее задание № 8 — «Загрузка системы»

Цель домашнего задания: 
1) научиться попадать в систему без пароля;
2) устанавливать систему с LVM и переименовывать VolumeGroup в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:
```console
По умолчанию меню загрузчика Grub скрыто и нет задержки при загрузке.
Для отображения меню нужно отредактировать конфигурационный файл.
Комментируем строку, скрывающую меню и ставим задержку для выбора пункта меню в 10 секунд.
- #GRUB_TIMEOUT_STYLE=hidden
- GRUB_TIMEOUT=10

root@test:~# nano /etc/default/grub
```

```console
Обновляем конфигурацию загрузчика и перезагружаемся для проверки.

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

ВОПРОС: в методическом пособии к домашнему заданию далее сказано следующее:
```console
В целом на этом все, Вы попали в систему. Но есть один нюанс. Рутовая файловая
система при этом монтируется в режиме Read-Only. Если вы хотите перемонтировать
ее в режим Read-Write, можно воспользоваться командой:
root@ubuntu22:~# mount -o remount,rw /

После чего можно убедиться, записав данные в любой файл или прочитав вывод
команды:

root@ubuntu22:~# mount | grep root
```

Но, если при редактировании меню загрузчика Grub заменить ro на rw, то root fs монтируется в режиме Read-Write. Вводим команду passwd -d %target_username и после reboot попадаем в систему без пароля. Тем самым мы отпускаем ряд дополнительных манипуляций в рамках решения поставленной задачи. Прошу, по возможности, прокомментировать если я в чём-то не прав, спасибо.


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




```console
root@test:~# vgs
  VG   #PV #LV #SN Attr   VSize  VFree
  vg00   1   1   0 wz--n- 15.98g 5.98g

root@test:~# vgrename vg00 ubuntu-otus
  Volume group "vg00" successfully renamed to "ubuntu-otus"
```













Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
