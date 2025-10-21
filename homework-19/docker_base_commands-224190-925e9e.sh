# Установка Docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
apt install docker.io

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Список доступных команд
docker

# Информацию о Docker
sudo docker info

# Запустим тестовый контейнер
sudo docker run hello-world

# Поищем nginx
sudo docker search nginx

# Скачаем образ
sudo docker pull nginx

# Запустим контейнер
sudo docker run -d --name nginx -p 80:80 -v /var/www/html:/usr/share/nginx/html nginx

# Добавить в автозапуск
docker update --restart always nginx

# Список активных контейнеров
sudo docker ps

# Чтобы увидеть и активные, и неактивные контейнеры
sudo docker ps -a

# Зайдём в оболочку контейнера
sudo docker exec -ti nginx bash

# Остановка и запуск контейнеров
sudo docker stop sharp_volhard
sudo docker start d9b100f2f636

# Перезагрузка
sudo docker restart nginx

# Отправка сигнала
sudo docker kill -s HUP nginx

# Логи контейнера
sudo docker logs nginx

# Информация о контейнере
sudo docker inspect nginx

# Публичные порты
sudo docker port nginx

# Выполняющиеся процессы
sudo docker top nginx

# Использование ресурсов
sudo docker stats nginx

# Список образов
sudo docker images

# Просмотр истории образа
sudo docker history nginx

# Удаление контейнера
sudo docker rm nginx

# Удаление образа
sudo docker rmi nginx

# Удаление остановленных контейнеров без volume
docker rm $(docker ps -aq)

# Удаление всех контейнеров c анонимными volume для них
docker rm -fv $(docker ps -aq)

# Удаление всех volume
docker volume rm  $(docker volume ls -q)

# Удалить все образы, которые в данный момент не используются в контейнерах
docker rmi $(docker images -q -f "dangling=true")
docker rmi $(docker images -q)

# Получить локальный IP контейнера
docker inspect --format="{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}"
# Полная очистка неиспользуемых контейнеров, сетей, образов и томов
docker system prune -a -f --volumes

# Дополнительные команды по обслуживанию
# Использование диска
docker system df
# Подробности
docker system df --verbose

docker system prune
docker system info


# Сети
docker network create mynet
docker run -d --name nginx2 --network=mynet -p 80:80 nginx
docker run -d --name nginx2 --network=host -p 80:80 nginx

# Установка нескольких контейнеров, соединённых сетью
docker network create some-network

docker run --rm --network some-network --name some-mariadb -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mariadb:10.5
docker run -it --network some-network --rm mariadb:10.5 mysql -hsome-mariadb -uroot -p

docker run --name myadmin -d --network some-network --link some-mariadb:db -p 8080:80 phpmyadmin

# Установка контейнеров для работы WordPress с помощью docker-compose

https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose-ru

# Dockerfile
FROM nginx:latest
COPY ./index.html /usr/share/nginx/html/index.html

docker build -t webserver .


# Dockerfile 2
FROM alpine:3.12
ARG tf_ver=0.12.28
ARG tflint_ver=0.16.2
RUN apk update && apk upgrade
RUN wget https://releases.hashicorp.com/terraform/${tf_ver}/terraform_${tf_ver}_linux_amd64.zip \
    && unzip terraform_${tf_ver}_linux_amd64.zip && rm terraform_${tf_ver}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ 
RUN wget https://github.com/terraform-linters/tflint/releases/download/v${tflint_ver}/tflint_linux_amd64.zip \
    && unzip tflint_linux_amd64.zip && rm tflint_linux_amd64.zip \
    && mv tflint /usr/local/bin/
RUN echo ${hello} ${tf_ver} ${tflint_ver}
CMD ["/bin/sh"]

docker build -t tfcont .

######################################################
version: '3.1'

services:

  redmine:
    image: redmine
    restart: always
    ports:
      - 8080:3000
    environment:
      REDMINE_DB_MYSQL: db
      REDMINE_DB_PASSWORD: example
      REDMINE_SECRET_KEY_BASE: supersecretkey

  db:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: redmine
#########################################################
