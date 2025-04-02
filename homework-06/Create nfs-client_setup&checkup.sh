#!/bin/bash

# Устанавливаем пакет nfs-common
echo "Устанавливаем пакет nfs-common..."
sudo apt-get update
sudo apt-get install -y nfs-common

# Добавляем запись в /etc/fstab
echo "Добавляем запись в /etc/fstab для монтирования NFS..."
echo "192.168.1.15:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" | sudo tee -a /etc/fstab > /dev/null

# Выполняем перезагрузку демонов и перезапускаем remote-fs.target
echo "Выполняем systemctl daemon-reload и systemctl restart remote-fs.target..."
sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target

# Проверяем успешность монтирования
echo "Проверяем успешность монтирования в директории /mnt..."
if mount | grep -q "/mnt"; then
    echo "Монтирование успешно! NFS доступен в /mnt."
else
    echo "Ошибка монтирования! Проверьте настройки."
    exit 1
fi

# Проверка на клиенте

echo "Проверка на клиенте..."

# 1. Перезагружаем клиент
echo "Перезагружаем клиент..."
#sudo reboot

# После перезагрузки клиента — заходим на клиент (это нужно выполнить вручную в новом терминале)
echo "Зашли на клиент. Проверяем работу RPC с помощью showmount..."
sleep 10  # Даем время для перезагрузки и подключения

# Проверка работы RPC на клиенте
showmount -a 192.168.1.15

# 2. Заходим в каталог /mnt/upload
echo "Переходим в каталог /mnt/upload..."
cd /mnt/upload

# 3. Проверка статуса монтирования
echo "Проверяем статус монтирования с помощью mount | grep mnt..."
mount | grep mnt

# 4. Проверка наличия ранее созданных файлов
echo "Проверяем наличие ранее созданных файлов..."
if [ "$(ls -A /mnt/upload/)" ]; then
    echo "Файлы найдены в каталоге /mnt/upload/."
else
    echo "Каталог /mnt/upload/ пуст."
fi

# 5. Создаем тестовый файл
echo "Создаём тестовый файл final_check..."
touch /mnt/upload/final_check

# 6. Проверяем, что файл успешно создан
if [ -f /mnt/upload/final_check ]; then
    echo "Файл final_check успешно создан."
else
    echo "Не удалось создать файл final_check."
    exit 1
fi

echo "Проверка завершена успешно!"
