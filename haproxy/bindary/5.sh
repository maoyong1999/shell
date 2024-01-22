#!/bin/bash

# 部署 haproxy 的 IP 地址
haproxy_ip="192.168.100.5"

# haproxy 的版本号
haproxy_version="2.8.1"

# haproxy 的安装路径
haproxy_path="/usr/local/haproxy"

# haproxy 的日志文件路径
haproxy_log="/var/log/haproxy.log"

# haproxy 的用户和用户组
haproxy_user="haproxy"
haproxy_group="haproxy"

# 安装编译工具和依赖库
yum install -y gcc make pcre-devel openssl-devel systemd-devel

# 解压 haproxy 源码包
tar -zxvf haproxy-${haproxy_version}.tar.gz

# 进入 haproxy 源码目录
cd haproxy-${haproxy_version}

# 编译并安装 haproxy
make TARGET=linux-glibc USE_SYSTEMD=1 USE_PCRE=1 USE_OPENSSL=1 USE_PROMEX=1
make install PREFIX=${haproxy_path}

# 创建 haproxy 用户和用户组
groupadd ${haproxy_group}
useradd -g ${haproxy_group} ${haproxy_user}

# 创建运行需要的目录，并设置好权限
mkdir -p ${haproxy_path}/var/run/haproxy
mkdir -p ${haproxy_path}/var/lib/haproxy
mkdir -p ${haproxy_path}/var/log
chown -R ${haproxy_user}:${haproxy_group} ${haproxy_path}

# 配置 haproxy
cat <<EOF > ${haproxy_path}/haproxy.cfg
global
    log ${haproxy_log} local0
    log ${haproxy_log} local1 notice
    chroot ${haproxy_path}/var/lib/haproxy
    pidfile ${haproxy_path}/var/run/haproxy.pid
    maxconn 4000
    user ${haproxy_user}
    group ${haproxy_group}
    daemon

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend http-in
    bind *:80
    default_backend servers
    stats enable
    stats uri /haproxy_stats
    stats realm Haproxy\ Statistics
    stats auth admin:password
    use_backend prometheus if { path /metrics }

backend servers
    server server1 $haproxy_ip:8080

backend prometheus
    mode http
    stats enable
    stats uri /metrics
    stats realm Haproxy\ Prometheus
    stats auth admin:password
    server prometheus $haproxy_ip:9101
EOF

# 创建 HAProxy systemd unit 文件
cat <<EOF > /etc/systemd/system/haproxy.service
[Unit]
Description=HAProxy Load Balancer
After=network.target

[Service]
Environment="CONFIG=${haproxy_path}/haproxy.cfg"
ExecStart=${haproxy_path}/sbin/haproxy -Ws -f \$CONFIG -p ${haproxy_path}/var/run/haproxy.pid
ExecReload=/bin/sh -c "${haproxy_path}/sbin/haproxy -c -q \$CONFIG && /usr/sbin/service haproxy reload || /bin/kill -HUP \$MAINPID"
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