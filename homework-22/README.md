## Домашнее задание № 22 — Мониторинг производительности. Prometheus»

**Цель домашнего задания**: научиться настраивать дашборд.  

Настроить дашборд с 4-мя графиками:  
- память;  
- процессор;  
- диск;  
- сеть.


**Выполнение домашнего задания**:

Обновим списки доступных пакетов:
```console
root@test:~# apt update
...
All packages are up to date.
```

Установим 
```console
root@test:~# apt install prometheus -y

root@test:~# ss -ntlp | grep prometheus
LISTEN 0      4096               *:9090            *:*    users:(("prometheus",pid=2982,fd=4))
LISTEN 0      4096               *:9100            *:*    users:(("prometheus-node",pid=2253,fd=3))

root@test:~# systemctl status prometheus
● prometheus.service - Monitoring system and time series database
     Loaded: loaded (/lib/systemd/system/prometheus.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2025-08-16 23:32:06 MSK; 2min 18s ago
       Docs: https://prometheus.io/docs/introduction/overview/
             man:prometheus(1)
   Main PID: 2982 (prometheus)
      Tasks: 8 (limit: 2198)
     Memory: 22.8M
        CPU: 202ms
     CGroup: /system.slice/prometheus.service
             └─2982 /usr/bin/prometheus

Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.141Z caller=head.go:515 level=info component=tsdb msg="On-disk memory mappable chunks replay completed" duration=1.07µs
Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.141Z caller=head.go:521 level=info component=tsdb msg="Replaying WAL, this may take a while"
Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.141Z caller=tls_config.go:195 level=info component=web msg="TLS is disabled." http2=false
Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.141Z caller=head.go:592 level=info component=tsdb msg="WAL segment loaded" segment=0 maxSegment=0
Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.141Z caller=head.go:598 level=info component=tsdb msg="WAL replay completed" checkpoint_replay_duration=24.58µs wal_replay_duration=339.458µs total_>
Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.142Z caller=main.go:850 level=info fs_type=EXT4_SUPER_MAGIC
Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.142Z caller=main.go:853 level=info msg="TSDB started"
Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.142Z caller=main.go:980 level=info msg="Loading configuration file" filename=/etc/prometheus/prometheus.yml
Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.143Z caller=main.go:1017 level=info msg="Completed loading of configuration file" filename=/etc/prometheus/prometheus.yml totalDuration=448.238µs db>
Aug 16 23:32:06 test prometheus[2982]: ts=2025-08-16T20:32:06.143Z caller=main.go:795 level=info msg="Server is ready to receive web requests."
```


















Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
