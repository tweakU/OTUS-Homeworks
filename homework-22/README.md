## Домашнее задание № 22 — Мониторинг производительности. Prometheus»

**Цель домашнего задания**: научиться настраивать дашборд.  

Настроить дашборд с 4-мя графиками:  
- память;  
- процессор;  
- диск;  
- сеть.


**Выполнение домашнего задания**:

1) Prometheus

Обновим списки доступных пакетов:
```console
root@test:~# apt update
...
All packages are up to date.
```

Установим Prometheus и посмотрим информацию о сетевых сокетах:
```console
root@test:~# apt install prometheus -y

root@test:~# ss -ntlp | grep prometheus
LISTEN 0      4096               *:9090            *:*    users:(("prometheus",pid=2982,fd=4))
LISTEN 0      4096               *:9100            *:*    users:(("prometheus-node",pid=2253,fd=3))
```














2) Grafana

Установим Grafana из "родного" репозитория согласно [инструкции](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/):

```console
root@test:~# apt-get install -y apt-transport-https software-properties-common wget
```

Импортируем GPG (GNU Privacy Guard) ключ:
```console
root@test:~# mkdir -p /etc/apt/keyrings/
root@test:~# wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
```

```
root@test:~# echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
```

```console
root@test:~# apt-get update

root@test:~# apt-get install grafana
```

Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
