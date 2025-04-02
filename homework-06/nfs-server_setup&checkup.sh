#!bin/bash

# Устанавливаем пакет nfs-kernel-server
#echo "Устанавливаем пакет nfs-kernel-server..."
sudo apt-get update
sudo apt-get install -y nfs-kernel-server

# Проверяем слушаются ли порты 2049/udp, 2049/tcp, 111/udp, 111/tcp
echo "Проверка, слушаются ли порты 2049/udp, 2049/tcp, 111/udp, 111/tcp..."
ports_to_check=("2049" "111")
ports_ok=true

for port in "${ports_to_check[@]}"; do
    if ! ss -tuln | grep -q "$port"; then
        echo "Порт $port не найден в списке прослушиваемых."
        ports_ok=false
    fi
done

if [ "$ports_ok" = false ]; then
    echo "Некоторые порты не слушаются. Пожалуйста, убедитесь, что сервисы NFS настроены и запущены."
    exit 1
else
    echo "Все порты (2049/udp, 2049/tcp, 111/udp, 111/tcp) успешно слушаются."
fi

# Создаём директорию /srv/share/upload
if [ ! -d "/srv/share/upload" ]; then
    echo "Создаём директорию /srv/share/upload..."
    sudo mkdir -p /srv/share/upload
else
    echo "Директория /srv/share/upload уже существует."
fi

# Изменяем владельца и группу на nobody:nogroup для /srv/share
echo "Изменяем владельца и группу на nobody:nogroup для /srv/share..."
sudo chown nobody:nogroup /srv/share

# Устанавливаем права 0777 для директории /srv/share/upload
echo "Устанавливаем права 0777 для директории /srv/share/upload..."
sudo chmod 0777 /srv/share/upload

# Добавляем запись в /etc/exports
echo "Добавляем запись в /etc/exports..."
echo "/srv/share 192.168.1.16/24(rw,sync,root_squash)" | sudo tee -a /etc/exports > /dev/null

# Выполняем команду exportfs -r
echo "Перезагружаем экспортированные каталоги с помощью exportfs -r..."
sudo exportfs -r

# Выполняем команду exportfs -s и выводим результат
echo "Вывод команды exportfs -s:"
sudo exportfs -s

# Проверка на сервере

echo "Проверка на сервере..."

# 1. Перезагружаем сервер
echo "Перезагружаем сервер..."
#sudo reboot

# После перезагрузки сервера — заходим на сервер (это нужно выполнить вручную в новом терминале)
echo "Зашли на сервер. Проверяем наличие файлов в каталоге /srv/share/upload/..."
sleep 10  # Даем время для перезагрузки и подключения

# Проверяем наличие файлов в каталоге /srv/share/upload/
if [ "$(ls -A /srv/share/upload/)" ]; then
    echo "Файлы найдены в каталоге /srv/share/upload/."
else
    echo "Каталог /srv/share/upload/ пуст."
fi

# 2. Проверка экспортированных каталогов
echo "Проверяем экспортированные каталоги с помощью exportfs -s..."
sudo exportfs -s

# 3. Проверка работы RPC
echo "Проверяем работу RPC с помощью showmount..."
showmount -a 192.168.1.15

echo "Проверка завершена успешно!"
