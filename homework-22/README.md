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

Установим Prometheus, посмотрим на состояние сервиса, а также информацию о сетевых сокетах:
```console
root@test:~# apt install prometheus -y

root@test:~# systemctl status prometheus
● prometheus.service - Monitoring system and time series database
     Loaded: loaded (/lib/systemd/system/prometheus.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2025-08-17 09:02:14 MSK; 34s ago
       Docs: https://prometheus.io/docs/introduction/overview/
             man:prometheus(1)
   Main PID: 678 (prometheus)
      Tasks: 9 (limit: 2198)
     Memory: 76.7M
        CPU: 273ms
     CGroup: /system.slice/prometheus.service
             └─678 /usr/bin/prometheus

Aug 17 09:02:15 test prometheus[678]: ts=2025-08-17T06:02:15.749Z caller=head.go:592 level=info component=tsdb msg="WAL segment loaded" segment=0 maxSegment=1
Aug 17 09:02:15 test prometheus[678]: ts=2025-08-17T06:02:15.757Z caller=head.go:592 level=info component=tsdb msg="WAL segment loaded" segment=1 maxSegment=1
Aug 17 09:02:15 test prometheus[678]: ts=2025-08-17T06:02:15.758Z caller=head.go:598 level=info component=tsdb msg="WAL replay completed" checkpoint_replay_duration=37.45µs wal_replay_duration=165.187901ms tota>
Aug 17 09:02:15 test prometheus[678]: ts=2025-08-17T06:02:15.768Z caller=main.go:850 level=info fs_type=EXT4_SUPER_MAGIC
Aug 17 09:02:15 test prometheus[678]: ts=2025-08-17T06:02:15.770Z caller=main.go:853 level=info msg="TSDB started"
Aug 17 09:02:15 test prometheus[678]: ts=2025-08-17T06:02:15.771Z caller=main.go:980 level=info msg="Loading configuration file" filename=/etc/prometheus/prometheus.yml
Aug 17 09:02:15 test prometheus[678]: ts=2025-08-17T06:02:15.779Z caller=main.go:1017 level=info msg="Completed loading of configuration file" filename=/etc/prometheus/prometheus.yml totalDuration=8.743513ms db>
Aug 17 09:02:15 test prometheus[678]: ts=2025-08-17T06:02:15.791Z caller=main.go:795 level=info msg="Server is ready to receive web requests."
Aug 17 09:02:22 test prometheus[678]: ts=2025-08-17T06:02:22.583Z caller=compact.go:518 level=info component=tsdb msg="write block" mint=1755376331795 maxt=1755381600000 ulid=01K2V9YBYF8M3Z2VHF55VVF7AF duration>
Aug 17 09:02:22 test prometheus[678]: ts=2025-08-17T06:02:22.585Z caller=head.go:805 level=info component=tsdb msg="Head GC completed" duration=1.783667ms

root@test:~# systemctl status prometheus-node-exporter
● prometheus-node-exporter.service - Prometheus exporter for machine metrics
     Loaded: loaded (/lib/systemd/system/prometheus-node-exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2025-08-17 09:02:14 MSK; 42s ago
       Docs: https://github.com/prometheus/node_exporter
   Main PID: 677 (prometheus-node)
      Tasks: 6 (limit: 2198)
     Memory: 18.8M
        CPU: 138ms
     CGroup: /system.slice/prometheus-node-exporter.service
             └─677 /usr/bin/prometheus-node-exporter

Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=node_exporter.go:115 level=info collector=thermal_zone
Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=node_exporter.go:115 level=info collector=time
Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=node_exporter.go:115 level=info collector=timex
Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=node_exporter.go:115 level=info collector=udp_queues
Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=node_exporter.go:115 level=info collector=uname
Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=node_exporter.go:115 level=info collector=vmstat
Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=node_exporter.go:115 level=info collector=xfs
Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=node_exporter.go:115 level=info collector=zfs
Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=node_exporter.go:199 level=info msg="Listening on" address=:9100
Aug 17 09:02:14 test prometheus-node-exporter[677]: ts=2025-08-17T06:02:14.752Z caller=tls_config.go:195 level=info msg="TLS is disabled." http2=false

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
