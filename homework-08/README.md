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




































Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
