# Рабора с текстовыми логами

# Фильтрация лога
cat messages | grep err | grep -P '\d{2}:\d{2}:00'

# Последние 10 строк лога
tail -n 10 messages

# Первые 10 строк лога
head -n 10 messages

# Просмотр сообщений в реальном времени
tail -f messages

# Journald

# Проверка формата времени
timedatectl status
sudo timedatectl set-timezone zone

# Логи с момента загрузки
journalctl -b

# Сохрание логов между загрузками системы
sudo mkdir -p /var/log/journal
sudo nano /etc/systemd/journald.conf

[Journal]
Storage=persistent

# Фильтрация по времени
journalctl --since "2022-01-01 17:15:00"
journalctl --since "2022-01-01 17:15:00" --until "2022-01-02 17:15:00"
journalctl --since yesterday
journalctl --since 09:00 --until "1 hour ago"

# Фильтрация по юниту
journalctl -u nginx.service

# Фильтрация по приоритету
journalctl -p err -b

# Форматирование в JSON
journalctl -b -u nginx -o json-pretty


#############################################################
ELK setup
#############################################################

sudo apt update
sudo apt install default-jdk -y




# Качаем пакеты (или используем репозиторий)
# https://www.elastic.co/guide/en/elasticsearch/reference/8.9/deb.html
https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/kibana/kibana-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/logstash/logstash-8.9.1-amd64.deb
https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-8.9.1-amd64.deb

# Устанавливаем ES
sudo dpkg -i elasticsearch-8.9.1-amd64.deb

# Устанавливаем лимиты памяти для виртуальной машины Java
cat > /etc/elasticsearch/jvm.options.d/jvm.options

-Xms1g
-Xmx1g

# Конфигурация ES
nano /etc/elasticsearch/elasticsearch.yml
##############################################
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch

xpack.security.enabled: false
xpack.security.enrollment.enabled: true

xpack.security.http.ssl:
  enabled: false
  keystore.path: certs/http.p12

xpack.security.transport.ssl:
  enabled: false
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
cluster.initial_master_nodes: ["elk"]

http.host: 0.0.0.0

##############################################
# Старт сервиса
sudo systemctl daemon-reload
sudo systemctl enable --now elasticsearch.service

# Проверка
curl http://localhost:9200

# Установка kibana
dpkg -i kibana-8.9.1-amd64.deb

sudo systemctl daemon-reload
sudo systemctl enable --now kibana.service

sudo nano /etc/kibana/kibana.yml
server.port: 5601
server.host: "0.0.0.0"

systemctl restart kibana

#############################################
# Установка Logstash
dpkg -i logstash-8.9.1-amd64.deb

systemctl enable --now logstash.service

######
# logstash config
sudo nano /etc/logstash/logstash.yml

path.config: /etc/logstash/conf.d

cat > /etc/logstash/conf.d/logstash-nginx-es.conf
####################################################
input {
    beats {
        port => 5400
    }
}

filter {
 grok {
   match => [ "message" , "%{COMBINEDAPACHELOG}+%{GREEDYDATA:extra_fields}"]
   overwrite => [ "message" ]
 }
 mutate {
   convert => ["response", "integer"]
   convert => ["bytes", "integer"]
   convert => ["responsetime", "float"]
 }
 date {
   match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
   remove_field => [ "timestamp" ]
 }
 useragent {
   source => "agent"
 }
}

output {
 elasticsearch {
   hosts => ["http://localhost:9200"]
   #cacert => '/etc/logstash/certs/http_ca.crt'
   #ssl => true
   index => "weblogs-%{+YYYY.MM.dd}"
   document_type => "nginx_logs"
 }
 stdout { codec => rubydebug }
}
########################################################

systemctl restart logstash.service

# Установка filebeat
dpkg -i filebeat-8.9.1-amd64.deb 

sudo nano /etc/filebeat/filebeat.yml

# Закомментарить output.elasticsearch
##########################################
filebeat.inputs:
- type: filestream
  paths:
    - /var/log/nginx/*.log

  enabled: true
  exclude_files: ['.gz$']
  prospector.scanner.exclude_files: ['.gz$']

output.logstash:
  hosts: ["localhost:5400"]
###########################################
systemctl restart filebeat

sudo filebeat modules enable nginx

##############################
# Добавляем индексные шаблоны Stack management - Index management
http://192.168.122.229:5601/app/management/data/index_management/indices

# Analytics - Discover - Create data view - weblogs* (слева вверху)

# Analytics - Dashboard - Create

# Bar horizontal - request.keyword host.ip.keyword
# Donut - slice by response, size by #records

# Metricbeat настройка
dpkg -i metricbeat-8.9.1-amd64.deb

systemctl enable --now metricbeat

# https://www.elastic.co/guide/en/beats/metricbeat/current/load-kibana-dashboards.html

metricbeat setup --dashboards

#####################################
# Использование модулей и прямой редикект в ES
# https://www.elastic.co/guide/en/beats/filebeat/8.13/filebeat-installation-configuration.html
filebeat modules list
filebeat modules enable nginx

nano /etc/filebeat/filebeat.yml 
#####

filebeat.inputs:

# Each - is an input. Most options can be set at the input level, so
# you can use different inputs for various configurations.
# Below are the input specific configurations.

# filestream is an input for collecting log messages from files.
- type: filestream

  # Unique ID among all inputs, an ID is required.
  id: my-filestream-id

  # Change to true to enable this input configuration.
  enabled: true
  exclude_files: ['.gz$']
  prospector.scanner.exclude_files: ['.gz$']
  # Paths that should be crawled and fetched. Glob based paths.
  paths:
    - /var/log/*.log


# ---------------------------- Elasticsearch Output ----------------------------
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["localhost:9200"]

  # Protocol - either `http` (default) or `https`.
  #protocol: "https"

  # Authentication credentials - either API key or username/password.
  #api_key: "id:api_key"
  #username: "elastic"
  #password: "changeme"



#####

nano /etc/filebeat/modules.d/nginx.yml

#####

- module: nginx
  # Access logs
  access:
    enabled: true

    # Set custom paths for the log files. If left empty,
    # Filebeat will choose the paths depending on your OS.
    #var.paths:
    var.paths: ["/var/log/nginx/access.log*"]

  # Error logs
  error:
    enabled: true

    # Set custom paths for the log files. If left empty,
    # Filebeat will choose the paths depending on your OS.
    #var.paths:
    var.paths: ["/var/log/nginx/error.log*"]

#####

filebeat test config -e
# Настройка assets для elasticsearch и kibana
filebeat setup -e

