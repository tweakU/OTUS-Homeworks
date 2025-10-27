## Домашнее задание № 19 — «Docker: основы работы с контейнеризацией»


**ЧТИВО:** [DigitalOcean - Tutorials - Docker - How To Remove Docker Images, Containers, and Volumes](https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes)


**Цель домашнего задания**:  
1 изучить основные понятия контейнеризации;  
2 написать Dockerfile;  
3 запустить контейнер;  
4 запустить docker-compose.  


**Выполнение домашнего задания**:

```console
root@test:~/otus/hw19# docker --version
Docker version 28.5.1, build e180ab8
```


**Рассмотрим два варианта создания custom Nginx page.**

Простой вариант:
1) Создадим официальный образ (image) Nginx на базе Alpine Linux:

```console
root@test:~/otus/hw19/nginx-alpine# cat Dockerfile
# Используем официальный образ Nginx на базе Alpine Linux
FROM nginx:alpine

# Копируем кастомную HTML-страницу в контейнер
COPY ./index.html /usr/share/nginx/html

# Экспонируем порт 80
EXPOSE 80

root@test:~/otus/hw19/nginx-alpine# docker build -t otus-hw19-nginx_alpine .
[+] Building 4.3s (7/7) FINISHED                                                                                                                                                                    docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                          0.0s
 => => transferring dockerfile: 318B                                                                                                                                                                          0.0s
 => [internal] load metadata for docker.io/library/nginx:alpine                                                                                                                                               1.8s
 => [internal] load .dockerignore                                                                                                                                                                             0.0s
 => => transferring context: 2B                                                                                                                                                                               0.0s
 => [internal] load build context                                                                                                                                                                             0.0s
 => => transferring context: 485B                                                                                                                                                                             0.0s
 => [1/2] FROM docker.io/library/nginx:alpine@sha256:61e01287e546aac28a3f56839c136b31f590273f3b41187a36f46f6a03bbfe22                                                                                         2.3s
 => => resolve docker.io/library/nginx:alpine@sha256:61e01287e546aac28a3f56839c136b31f590273f3b41187a36f46f6a03bbfe22                                                                                         0.0s
 => => sha256:5e7abcdd20216bbeedf1369529564ffd60f830ed3540c477938ca580b645dff5 10.78kB / 10.78kB                                                                                                              0.0s
 => => sha256:621a51978ed7f4a65a4324aaf124c21292fd986ed107e731f860572233073798 627B / 627B                                                                                                                    0.6s
 => => sha256:61e01287e546aac28a3f56839c136b31f590273f3b41187a36f46f6a03bbfe22 10.33kB / 10.33kB                                                                                                              0.0s
 => => sha256:b03ccb7431a2e3172f5cbae96d82bd792935f33ecb88fbf2940559e475745c4e 2.50kB / 2.50kB                                                                                                                0.0s
 => => sha256:2d35ebdb57d9971fea0cac1582aa78935adf8058b2cc32db163c98822e5dfa1b 3.80MB / 3.80MB                                                                                                                0.7s
 => => sha256:f80aba050eadb732c9571d549167ce0f71adce202ac619ae8786fe6c9eec3374 1.81MB / 1.81MB                                                                                                                0.6s
 => => sha256:03e63548f2091b6073fb9744492242182874f6b2d2554c9f3a94455203a033f0 954B / 954B                                                                                                                    0.8s
 => => sha256:83ce83cd996042dd16a6124be94e6046da71a9c6b59a6cc48704f6cffca76d7d 403B / 403B                                                                                                                    1.0s
 => => extracting sha256:2d35ebdb57d9971fea0cac1582aa78935adf8058b2cc32db163c98822e5dfa1b                                                                                                                     0.1s
 => => sha256:e2d0ea5d3690e523d1c4fc7f288e0b98b6c405d5880fa11d1637483fd5afc74c 1.21kB / 1.21kB                                                                                                                0.9s
 => => sha256:7fb80c2f28bc872ae84429312ddfbc823aca17b7ce107a0f24074294cd3beac5 1.40kB / 1.40kB                                                                                                                1.0s
 => => extracting sha256:f80aba050eadb732c9571d549167ce0f71adce202ac619ae8786fe6c9eec3374                                                                                                                     0.0s
 => => extracting sha256:621a51978ed7f4a65a4324aaf124c21292fd986ed107e731f860572233073798                                                                                                                     0.0s
 => => extracting sha256:03e63548f2091b6073fb9744492242182874f6b2d2554c9f3a94455203a033f0                                                                                                                     0.0s
 => => extracting sha256:83ce83cd996042dd16a6124be94e6046da71a9c6b59a6cc48704f6cffca76d7d                                                                                                                     0.0s
 => => extracting sha256:e2d0ea5d3690e523d1c4fc7f288e0b98b6c405d5880fa11d1637483fd5afc74c                                                                                                                     0.0s
 => => sha256:76c9bcaa4163e6fb844375a66c86911591b942e01511e28eec442e187f667f4e 16.96MB / 16.96MB                                                                                                              1.9s
 => => extracting sha256:7fb80c2f28bc872ae84429312ddfbc823aca17b7ce107a0f24074294cd3beac5                                                                                                                     0.0s
 => => extracting sha256:76c9bcaa4163e6fb844375a66c86911591b942e01511e28eec442e187f667f4e                                                                                                                     0.3s
 => [2/2] COPY ./index.html /usr/share/nginx/html                                                                                                                                                             0.1s
 => exporting to image                                                                                                                                                                                        0.0s
 => => exporting layers                                                                                                                                                                                       0.0s
 => => writing image sha256:24d6c3e0f9167fb3f1cea7f8c5b10e9cac0dc759841e30315e75cced8e1a6ef3                                                                                                                  0.0s
 => => naming to docker.io/library/otus-hw19-nginx_alpine                                                                                                                                                     0.0s

root@test:~/otus/hw19/nginx-alpine# docker images
REPOSITORY               TAG       IMAGE ID       CREATED         SIZE
otus-hw19-nginx_alpine   latest    24d6c3e0f916   6 seconds ago   52.8MB
```


2) Создадим и запустим контейнер, из только что собранного образа:

```console
root@test:~/otus/hw19/nginx-alpine# docker run -d -p 8080:80 otus-hw19-nginx_alpine:latest
d4c44d85c16004635dda8e839e4f15237f1064256f86b100ca3eadc922c4afb9

root@test:~/otus/hw19/nginx-alpine# docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED         STATUS         PORTS                                     NAMES
d4c44d85c160   otus-hw19-nginx_alpine:latest   "/docker-entrypoint.…"   4 seconds ago   Up 4 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   elegant_mendeleev
``` 


3) С помощью утилиты ss и curl проверим работоспособность сервера Nginx:

```console
root@test:~/otus/hw19/nginx-alpine# ss -ntlp | grep docker
LISTEN 0      4096         0.0.0.0:8080      0.0.0.0:*    users:(("docker-proxy",pid=3137,fd=7))
LISTEN 0      4096            [::]:8080         [::]:*    users:(("docker-proxy",pid=3142,fd=7))

root@test:~/otus/hw19/nginx-alpine# curl localhost:8080
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Custom Alpine-based Nginx page</title>
</head>
<body>
    <h1>Привет, Otus! Это кастомная страница Nginx на базе дистрибутива Alpine Linux!</h1>
    <p>Запуск кастомного Docker-образа прошёл успешно.</p>
</body>
</html>
```


**Вариант сборки Nginx в соотвествии с шаблоном из Домашнего задания:**

1) Создадим официальный образ (image) Alpine Linux и установим Nginx:

```console
root@test:~/otus/hw19/alpine-lastest# cat Dockerfile
FROM alpine:latest

RUN apk update && \
    apk add --no-cache nginx

COPY ./default.conf /etc/nginx/http.d/
COPY ./index.html /var/www/default/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

root@test:~/otus/hw19/alpine-lastest# docker build -t otus-hw19-alpine_nginx .
[+] Building 4.4s (9/9) FINISHED                                                                                                                                                                    docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                          0.0s
 => => transferring dockerfile: 236B                                                                                                                                                                          0.0s
 => [internal] load metadata for docker.io/library/alpine:latest                                                                                                                                              1.9s
 => [internal] load .dockerignore                                                                                                                                                                             0.0s
 => => transferring context: 2B                                                                                                                                                                               0.0s
 => [1/4] FROM docker.io/library/alpine:latest@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412                                                                                        0.0s
 => => resolve docker.io/library/alpine:latest@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412                                                                                        0.0s
 => => sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412 9.22kB / 9.22kB                                                                                                                0.0s
 => => sha256:85f2b723e106c34644cd5851d7e81ee87da98ac54672b29947c052a45d31dc2f 1.02kB / 1.02kB                                                                                                                0.0s
 => => sha256:706db57fb2063f39f69632c5b5c9c439633fda35110e65587c5d85553fd1cc38 581B / 581B                                                                                                                    0.0s
 => [internal] load build context                                                                                                                                                                             0.0s
 => => transferring context: 750B                                                                                                                                                                             0.0s
 => [2/4] RUN apk update &&     apk add --no-cache nginx                                                                                                                                                      2.4s
 => [3/4] COPY ./default.conf /etc/nginx/http.d/                                                                                                                                                              0.0s
 => [4/4] COPY ./index.html /var/www/default/html/                                                                                                                                                            0.0s
 => exporting to image                                                                                                                                                                                        0.0s
 => => exporting layers                                                                                                                                                                                       0.0s
 => => writing image sha256:bc5b4a72e87443b5efbb1584402b642a51e7cb16b0df06dd0366bdbb0a839194                                                                                                                  0.0s
 => => naming to docker.io/library/otus-hw19-alpine_nginx

root@test:~/otus/hw19/alpine-lastest# docker images
REPOSITORY               TAG       IMAGE ID       CREATED              SIZE
otus-hw19-alpine_nginx   latest    bc5b4a72e874   About a minute ago   12.9MB
otus-hw19-nginx_alpine   latest    24d6c3e0f916   13 minutes ago       52.8MB
```
(!) Тут стоит обратить внимание на разницу в "весе" контейнеров.


2) Создадим и запустим контейнер, из только что собранного образа:

```console
root@test:~/otus/hw19/alpine-lastest# docker run -d -p 8081:80 otus-hw19-alpine_nginx:latest
57f5626887e599befe243b6bd78271a5a6beec7e6b556e953238f32fd7f84eb3

root@test:~/otus/hw19/alpine-lastest# docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS          PORTS                                     NAMES
57f5626887e5   otus-hw19-alpine_nginx:latest   "nginx -g 'daemon of…"   13 seconds ago   Up 13 seconds   0.0.0.0:8081->80/tcp, [::]:8081->80/tcp   musing_rubin
d4c44d85c160   otus-hw19-nginx_alpine:latest   "/docker-entrypoint.…"   12 minutes ago   Up 12 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   elegant_mendeleev
```


3) С помощью утилиты ss и curl проверим работоспособность сервера Nginx:

```console
root@test:~/otus/hw19/alpine-lastest# ss -ntlp | grep docker
LISTEN 0      4096         0.0.0.0:8080      0.0.0.0:*    users:(("docker-proxy",pid=3137,fd=7))
LISTEN 0      4096         0.0.0.0:8081      0.0.0.0:*    users:(("docker-proxy",pid=3464,fd=7))
LISTEN 0      4096            [::]:8080         [::]:*    users:(("docker-proxy",pid=3142,fd=7))
LISTEN 0      4096            [::]:8081         [::]:*    users:(("docker-proxy",pid=3469,fd=7))

root@test:~/otus/hw19/alpine-lastest# curl localhost:8081
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alpine Linux container with installed custon Nginx</title>
</head>
<body>
    <h1>Привет, Otus! Это кастомная страница Nginx, установленного в контейнере Alpine Linux!</h1>
    <p>Запуск кастомного Docker-образа прошёл успешно.</p>
</body>
</html>
```


Q: **Определите разницу между контейнером и образом**  
A: Образ - это шаблон, а контейнер - это экземпляр шаблона, в котором работает приложение.

Определение контейнера, данного Николаем Лавлинским:  
Контейнер - это процесс, запущеннный в изолированном окружении и работающий в рамках хостовой ОС с определенными параметрами изоляции (по сети, ФС, пространству пользователей и т.д.)  

Q: **Ответьте на вопрос: Можно ли в контейнере собрать ядро?**  
A: Собрать ядро в контейнере возможно, использовать нет, т.к. контейнер не имеет собственного ядра, а использует ядро хостовой ОС. 


**Задание со звездочкой**: 

1. Написать Docker-compose для приложения Redmine, с использованием опции build.
2. Добавить в базовый образ redmine любую кастомную тему оформления.
3. Убедиться что после сборки новая тема доступна в настройках.
4. Настроить вольюмы, для сохранения всей необходимой информации

```console
root@test:~/otus/hw19/redmine# cat docker-compose.yml
services:
   postgres:
     image: postgres:10
     volumes:
       - ./storage/postgresql-data:/var/lib/postgresql/data
     environment:
       POSTGRES_PASSWORD: "PASSWORD"
       POSTGRES_DB: "redmine"
       PGDATA: "/var/lib/postgresql/data"
     restart: always

   redmine:
     build:
       context: .
     image: redmine:custom
     ports:
       - 8080:3000
     volumes:
       - ./storage/docker_redmine-plugins:/usr/src/redmine/plugins
       - ./storage/docker_redmine-themes:/usr/src/redmine/themes
       - ./storage/docker_redmine-data:/usr/src/redmine/files
     environment:
       REDMINE_DB_POSTGRES: "postgres"
       REDMINE_DB_USERNAME: "postgres"
       REDMINE_DB_PASSWORD: "PASSWORD"
       REDMINE_DB_DATABASE: "redmine"
       REDMINE_SECRET_KEY_BASE: "…"
     restart: always

root@test:~/otus/hw19/redmine# tree -d
.
└── storage
    ├── docker_redmine-data
    ├── docker_redmine-plugins
    ├── docker_redmine-themes
    │   └── farend_bleuclair
    │       ├── javascripts
    │       ├── src
    │       │   ├── images
    │       │   ├── scripts
    │       │   └── styles
    │       │       ├── components
    │       │       └── foundation
    │       ├── storybook
    │       └── stylesheets
    └── postgresql-data

16 directories

root@test:~/otus/hw19# cd ./storage/docker_redmine-themes/
root@test:~/otus/hw19/storage/docker_redmine-themes# git clone https://github.com/farend/redmine_theme_farend_bleuclair.git
Cloning into 'redmine_theme_farend_bleuclair'...
remote: Enumerating objects: 2289, done.
remote: Counting objects: 100% (902/902), done.
remote: Compressing objects: 100% (262/262), done.
remote: Total 2289 (delta 764), reused 648 (delta 640), pack-reused 1387 (from 2)
Receiving objects: 100% (2289/2289), 7.84 MiB | 16.06 MiB/s, done.
Resolving deltas: 100% (1421/1421), done.
root@test:~/otus/hw19/storage/docker_redmine-themes# ll
total 12
drwxr-xr-x 3 root root 4096 Oct 28 00:53 ./
drwxr-xr-x 6 root root 4096 Oct 28 00:20 ../
drwxr-xr-x 9 root root 4096 Oct 28 00:53 redmine_theme_farend_bleuclair/

root@test:~/otus/hw19# docker compose up -d
[+] Running 29/29
 ✔ postgres Pulled                                                                                                                                                                                            8.7s
   ✔ bff3e048017e Pull complete                                                                                                                                                                               2.7s
   ✔ e3e180bf7c2b Pull complete                                                                                                                                                                               2.8s
   ✔ 62eff3cc0cff Pull complete                                                                                                                                                                               2.8s
   ✔ 3d90a128d4ff Pull complete                                                                                                                                                                               3.1s
   ✔ ba4ce0c5ab29 Pull complete                                                                                                                                                                               3.3s
   ✔ a8f4b87076a9 Pull complete                                                                                                                                                                               3.3s
   ✔ 4b437d281a7e Pull complete                                                                                                                                                                               4.5s
   ✔ f1841d9dcb17 Pull complete                                                                                                                                                                               4.5s
   ✔ b05674a6c170 Pull complete                                                                                                                                                                               6.4s
   ✔ d59b5be914c6 Pull complete                                                                                                                                                                               6.4s
   ✔ 901d5d9b0beb Pull complete                                                                                                                                                                               6.5s
   ✔ 4a7aa9546b2c Pull complete                                                                                                                                                                               6.5s
   ✔ 0a0d389be22f Pull complete                                                                                                                                                                               6.5s
   ✔ fb7bd7cfbcd2 Pull complete                                                                                                                                                                               6.5s
 ✔ redmine Pulled                                                                                                                                                                                            22.7s
   ✔ 38513bd72563 Pull complete                                                                                                                                                                               8.6s
   ✔ 0d20d0d16a44 Pull complete                                                                                                                                                                               8.7s
   ✔ 1e3adf046075 Pull complete                                                                                                                                                                               8.7s
   ✔ 2b081c9f8f24 Pull complete                                                                                                                                                                              10.5s
   ✔ 2d825b8e4939 Pull complete                                                                                                                                                                              10.5s
   ✔ 6307e1b53a2c Pull complete                                                                                                                                                                              10.5s
   ✔ 8b4a339d6a12 Pull complete                                                                                                                                                                              18.2s
   ✔ ef41a70d31fc Pull complete                                                                                                                                                                              18.2s
   ✔ 171cfa4d9038 Pull complete                                                                                                                                                                              18.2s
   ✔ a06c24d89389 Pull complete                                                                                                                                                                              18.2s
   ✔ fb5a406b5e6a Pull complete                                                                                                                                                                              18.7s
   ✔ d46c50292da3 Pull complete                                                                                                                                                                              20.5s
   ✔ 0c2ea1e6376e Pull complete                                                                                                                                                                              20.6s
[+] Running 2/2
 ✔ Container hw19-redmine-1   Started                                                                                                                                                                         0.3s
 ✔ Container hw19-postgres-1  Started                                                                                                                                                                         0.3s

root@test:~/otus/hw19# docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS                                         NAMES
9a3a76afc77d   redmine:latest   "/docker-entrypoint.…"   4 seconds ago   Up 4 seconds   0.0.0.0:8080->3000/tcp, [::]:8080->3000/tcp   hw19-redmine-1
4980645b41f4   postgres:10      "docker-entrypoint.s…"   4 seconds ago   Up 4 seconds   5432/tcp                                      hw19-postgres-1

root@test:~/otus/hw19# ss -ntlp | grep 8080
LISTEN 0      4096         0.0.0.0:8080       0.0.0.0:*    users:(("docker-proxy",pid=10503,fd=7))
LISTEN 0      4096            [::]:8080          [::]:*    users:(("docker-proxy",pid=10510,fd=7))
```

<img width="1920" height="1040" alt="изображение" src="https://github.com/user-attachments/assets/49935a8a-df34-4f98-bd9a-878572037bfd" />


**Домашнее задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
