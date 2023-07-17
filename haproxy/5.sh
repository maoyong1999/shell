#!/bin/bash

# 安装编译工具和依赖库
yum install -y gcc pcre-devel openssl-devel

# 下载 HAProxy 源码
wget http://www.haproxy.org/download/2.4/src/haproxy-2.8.1.tar.gz
tar -xzf haproxy-2.8.1.tar.gz
cd haproxy-2.8.1

# 编译和安装 HAProxy
make TARGET=linux-glibc USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1
make install

# 创建 HAProxy 配置文件
cat <<EOF > /usr/local/etc/haproxy/haproxy.cfg
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /usr/local/etc/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend http-in
    bind *:80
    default_backend servers

backend servers
    server server1 127.0.0.1:8080
EOF

# 创建 HAProxy systemd unit 文件
cat <<EOF > /etc/systemd/system/haproxy.service
[Unit]
Description=HAProxy Load Balancer
After=network.target

[Service]
Environment="CONFIG=/usr/local/etc/haproxy/haproxy.cfg"
ExecStart=/usr/local/sbin/haproxy -Ws -f \$CONFIG -p /run/haproxy.pid
ExecReload=/bin/sh -c "/usr/sbin/haproxy -c -q \$CONFIG && /usr/sbin/service haproxy reload || /bin/kill -HUP \$MAINPID"
ExecStop=/bin/sh -c "/bin/kill -TERM \$MAINPID && /bin/kill -USR1 \$MAINPID && /bin/sleep 1 && /bin/kill -TERM \$MAINPID && /bin/sleep 1 && /bin/kill -KILL \$MAINPID"
KillMode=mixed
Restart=always
Type=notify

[Install]
WantedBy=multi-user.target
EOF

# 启动 HAProxy
systemctl start haproxy

# 设置 HAProxy 开机自启
systemctl enable haproxy