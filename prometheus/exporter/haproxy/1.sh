#!/bin/bash

# 提示输入 haproxy 的 IP 地址
read -p "请输入 haproxy 的 IP 地址: " haproxy_ip

# 创建 Docker-Compose 配置文件
cat <<EOF > docker-compose.yml
version: '3'
services:
  haproxy_exporter:
    image: prom/haproxy-exporter:v0.11.0
    container_name: haproxy_exporter
    ports:
      - "9101:9101"
    command:
      - "--haproxy.scrape-uri=http://${haproxy_ip}:8080/haproxy?stats;csv"
    restart: always
EOF

# 启动 haproxy_exporter 服务
docker-compose up -d