## Домашнее задание № 8 — «Загрузка системы»

Цель домашнего задания: 
1) научиться попадать в систему без пароля;
2) устанавливать систему с LVM и переименовывать VolumeGroup в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:
```console
По умолчанию меню загрузчика Grub скрыто и нет задержки при загрузке. Для отображения меню нужно отредактировать конфигурационный файл.
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

<img width="640" height="480" alt="VirtualBox_ubuntu-20 04 6-raid1-lvm_29_07_2025_00_42_18" src="https://github.com/user-attachments/assets/d3cbcb44-7810-4a3e-842d-78919c817641" />

![VirtualBox_ubuntu-22 04 5-server_08_06_2025_21_12_31](https://github.com/user-attachments/assets/d95a08b5-8988-40b0-b342-77da67e611d5)








































Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
