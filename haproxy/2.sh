#!/bin/bash

# 提示输入虚拟IP
read -p "请输入haproxy的虚拟IP（默认为192.168.100.101）：" virtual_ip
virtual_ip=${virtual_ip:-192.168.100.101}

# 安装 haproxy 和 keepalived
yum install -y haproxy keepalived

# 配置 haproxy
cat << EOF > /etc/haproxy/haproxy.cfg
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

# 配置 keepalived
cat << EOF > /etc/keepalived/keepalived.conf
global_defs {
    router_id haproxy02
}

vrrp_script chk_haproxy {
    script "killall -0 haproxy"
    interval 2
    weight 2
}

vrrp_instance VI_1 {
    interface ens224
    state BACKUP
    virtual_router_id 51
    priority 100
    virtual_ipaddress {
        $virtual_ip
    }
    track_script {
        chk_haproxy
    }
}
EOF

# 启动 haproxy 和 keepalived
systemctl enable haproxy
systemctl enable keepalived
systemctl start haproxy
systemctl start keepalived

# 配置 haproxy 统计页面
cat << EOF >> /etc/haproxy/haproxy.cfg
listen stats
    bind *:8080
    mode http
    stats enable
    stats uri /
    stats realm Haproxy\ Statistics
    stats auth admin:P@ssw0rd
EOF

# 重启 haproxy
systemctl restart haproxy