#!/bin/bash

# 安装 Docker 和 Docker Compose
# yum install -y docker
# systemctl start docker
# systemctl enable docker
# curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose

# 创建 rsyslog 的配置文件和日志目录
mkdir -p /etc/rsyslog.d
touch /etc/rsyslog.d/50-coredns.conf
mkdir -p /var/log/coredns

# 编辑 rsyslog 的配置文件
cat << EOF > /etc/rsyslog.d/50-coredns.conf
# CoreDNS 日志配置
\$ModLoad imfile
\$InputFileName /var/log/coredns/coredns.log
\$InputFileTag coredns:
\$InputFileStateFile coredns-state
\$InputFileSeverity info
\$InputFileFacility local7
\$InputRunFileMonitor

local7.* @@<rsyslog_host>:514
EOF

# 启动 rsyslog 服务
cat << EOF > docker-compose.yml
version: '3'
services:
  rsyslog:
    image: rsyslog/rsyslog_v8
    container_name: rsyslog
    restart: always
    volumes:
      - /etc/rsyslog.d:/etc/rsyslog.d
      - /var/log/coredns:/var/log/coredns
    ports:
      - "514:514/udp"
      - "514:514/tcp"
EOF

# 替换 <rsyslog_host> 为 rsyslog 服务器的 IP 地址
sed -i "s/<rsyslog_host>/$(hostname -I | awk '{print $1}')/g" docker-compose.yml

# 启动 rsyslog 服务
docker-compose up -d