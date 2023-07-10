#!/bin/bash

# 安装HAPROXY
yum install -y haproxy

# 配置HAPROXY
cat <<EOF > /etc/haproxy/haproxy.cfg
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
    log     global
    mode    http

frontend http-in
    bind 192.168.100.100:80
    default_backend servers

backend servers
    balance roundrobin
    server web1 192.168.100.12:80 check
    server web2 192.168.100.13:80 check
EOF

# 启动HAPROXY
systemctl enable haproxy
systemctl start haproxy