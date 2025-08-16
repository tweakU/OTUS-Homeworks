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


















Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
