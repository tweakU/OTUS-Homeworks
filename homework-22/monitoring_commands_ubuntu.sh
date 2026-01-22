# Установка утилит мониторинга
apt install -y {jnet,h,io,if,a}top iptraf-ng nmon

# Актуальные адреса скачивания берём здесь: https://prometheus.io/download/

# Скачиваем, можно через wget
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz

# Распаковка архивов 
tar xzvf node_exporter-*.t*gz
tar xzvf prometheus-*.t*gz

# Добавляем пользователей
useradd --no-create-home --shell /usr/sbin/nologin prometheus
useradd --no-create-home --shell /bin/false node_exporter

# Установка node_exporter

# Копируем файлы в /usr/local
cp node_exporter-*.linux-amd64/node_exporter /usr/local/bin
chown node_exporter: /usr/local/bin/node_exporter

# Создаём службу node exporter

cat > /etc/systemd/system/node_exporter.service

##############################
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
###############################

systemctl daemon-reload
systemctl start node_exporter
systemctl status node_exporter
systemctl enable node_exporter

# Проверяем 
curl localhost:9100
curl localhost:9100/metrics


# Установка prometheus

# Создаём папки и копируем файлы
mkdir {/etc/,/var/lib/}prometheus
cp -vi prometheus-*.linux-amd64/prom{etheus,tool} /usr/local/bin
cp -rvi prometheus-*.linux-amd64/{console{_libraries,s},prometheus.yml} /etc/prometheus/
chown -Rv prometheus: /usr/local/bin/prom{etheus,tool} /etc/prometheus/ /var/lib/prometheus/

# Проверка запуска вручную
sudo -u prometheus /usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

# Проверяем
wget localhost:9090

# Настраиваем сервис
cat > /etc/systemd/system/prometheus.service

################################
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=multi-user.target
#################################

# Конфиг prometheus
cat > /etc/prometheus/prometheus.yml
#####################################
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']
  
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
###############################################################

# Запускаем сервис Prometheus
systemctl daemon-reload
systemctl start prometheus
systemctl status prometheus
systemctl enable prometheus

# Проверка по адресу
http://ip:9090

# Установка Grafana
# https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/

# VPN требуется для работы репозитория
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
# Установка из репозитория (VPN)
apt update
apt install grafana

# Установка из пакета
sudo apt install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_10.0.3_amd64.deb
sudo dpkg -i grafana_10.0.3_amd64.deb

# Запуск
systemctl daemon-reload
systemctl start grafana-server
systemctl status grafana-server

# Проверка admin:admin
curl http://localhost:3000/login

# Настройка Grafana

# Confuguration - Data sources
# Add data source - Prometheus
# URL http://localhost:9090
# Save & test

# + - Create dashboard

# + - Import
# https://grafana.com/grafana/dashboards
# paste ID - Load

# Import
# Prometheus - выбрать data source
# Import




#Ссылки:
https://grafana.com/grafana/dashboards
https://grafana.com/grafana/dashboards/1860
https://grafana.com/grafana/dashboards/11074
https://grafana.com/grafana/download?pg=get&plcmt=selfmanaged-box1-cta1
https://github.com/prometheus/node_exporter/releases/
https://github.com/prometheus/prometheus/releases/
