## Домашнее задание № 8 — «Загрузка системы»

Цель домашнего задания: 
1) научиться попадать в систему без пароля;
2) устанавливать систему с LVM и переименовывать VolumeGroup в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:

По умолчанию меню загрузчика Grub скрыто и нет задержки при загрузке. Для отображения меню нужно отредактировать конфигурационный файл.
Комментируем строку, скрывающую меню и ставим задержку для выбора пункта меню в 10 секунд.

#GRUB_TIMEOUT_STYLE=hidden 
GRUB_TIMEOUT=10

```console
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


![VirtualBox_ubuntu-22 04 5-server_08_06_2025_21_12_31](https://github.com/user-attachments/assets/d95a08b5-8988-40b0-b342-77da67e611d5)








































Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
