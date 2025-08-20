## Домашнее задание № 22 — Мониторинг производительности. Prometheus»

**Цель домашнего задания**: научиться настраивать дашборд.  

Настроить дашборд с 4-мя графиками:  
- память;  
- процессор;  
- диск;  
- сеть.


**Выполнение домашнего задания**:

#**1) Prometheus**

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

Prometheus работает:
<img width="1920" height="1040" alt="изображение" src="https://github.com/user-attachments/assets/217c220f-404b-4a64-9158-eb0b11f368cd" />


#**2) Grafana**

Установим Grafana с помощью [deb пакета](https://grafana.com/grafana/download):

Установим необходимые пакеты. Скачаем и установим Grafana:
```console
sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/grafana-enterprise/release/12.1.1/grafana-enterprise_12.1.1_16903967602_linux_amd64.deb
sudo dpkg -i grafana-enterprise_12.1.1_16903967602_linux_amd64.deb
```


<img width="1920" height="1040" alt="изображение" src="https://github.com/user-attachments/assets/3dfcd665-e905-4bd7-9fd7-2ad33f1b8b44" />


#**2) Zabbix**

```console
root@test:~# cat /etc/os-release
PRETTY_NAME="Ubuntu 22.04.5 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.5 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
```

Установим Zabbix согласно [инструкции]([url](https://www.zabbix.com/download)):  
Zabbix version: 7.0 LTS  
OS Distribution: Ubunttu  
OS Version: 22.04 Jammy  
ZABBIX COMPONENT: Server, Frontend, Agent 2  
Database: MySQL  
Web Server: Apache

a. Install Zabbix repository
```console
# wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu22.04_all.deb
# dpkg -i zabbix-release_latest_7.4+ubuntu22.04_all.deb
# apt update
```

b. Install Zabbix server, frontend, agent2
```console
# apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent2
```

c. Install Zabbix agent 2 plugins
```console
# apt install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql
```

d. Create initial database  
Make sure you have database server up and running.  
Run the following on your database host.  
```console
# mysql -uroot -p
password
mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
mysql> create user zabbix@localhost identified by 'password';
mysql> grant all privileges on zabbix.* to zabbix@localhost;
mysql> set global log_bin_trust_function_creators = 1;
mysql> quit;
```
On Zabbix server host import initial schema and data. You will be prompted to enter your newly created password.
```console
# zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
```
Disable log_bin_trust_function_creators option after importing database schema.
```console
# mysql -uroot -p
password
mysql> set global log_bin_trust_function_creators = 0;
mysql> quit;
```

e. Configure the database for Zabbix server  
Edit file /etc/zabbix/zabbix_server.conf
```console
DBPassword=password
```

f. Start Zabbix server and agent processes  
Start Zabbix server and agent processes and make it start at system boot.
```console
# systemctl restart zabbix-server zabbix-agent2 apache2
# systemctl enable zabbix-server zabbix-agent2 apache2
```

g. Open Zabbix UI web page  
The default URL for Zabbix UI when using Apache web server is http://host/zabbix


<img width="1920" height="1040" alt="изображение" src="https://github.com/user-attachments/assets/c5388f66-ed1e-4bce-9977-717d824cb2b0" />


Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
