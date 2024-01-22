#!/bin/bash

# 安装Docker和Docker Compose
yum install -y docker docker-compose

# 创建HAPROXY容器
cat << EOF > docker-compose.yml
version: '3'
services:
  haproxy:
    image: haproxy:latest
    restart: always
    ports:
      - "80:80"
      - "6379:6379"
    volumes:
      - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
EOF

# 创建HAPROXY配置文件
cat << EOF > haproxy.cfg
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode tcp
    option tcplog
    option dontlognull
    timeout connect 5000
    timeout client 50000
    timeout server 50000

listen redis
    bind *:6379
    mode tcp
    balance roundrobin
    server redis01 192.168.100.20:6379 check inter 1000 rise 2 fall 3
    server redis02 192.168.100.21:6379 check inter 1000 rise 2 fall 3
    tcp-check send PING\r\n
    tcp-check expect string +PONG
    tcp-check send AUTH P@ssw0rd\r\n
    tcp-check expect string +OK

frontend http-in
    bind *:80
    mode http
    default_backend nginx-backend

backend nginx-backend
    mode http
    balance roundrobin
    server nginx01 192.168.100.12:80 check
    server nginx02 192.168.100.13:80 check    
EOF

# 启动HAPROXY容器
docker-compose up -d