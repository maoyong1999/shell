#!/bin/bash

# 安装nginx
sudo apt-get update
sudo apt-get install nginx -y

# 配置nginx
sudo rm /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-available/proxy
sudo ln -s /etc/nginx/sites-available/proxy /etc/nginx/sites-enabled/proxy

# 编辑nginx配置文件
sudo bash -c "cat > /etc/nginx/sites-available/proxy <<EOF
upstream backend {
    server 192.168.100.12;
    server 192.168.100.13;
}

server {
    listen 80;
    server_name proxy;
    location / {
        proxy_pass http://backend;
    }
}
EOF"

# 安装keepalived
sudo apt-get install keepalived -y

# 配置keepalived
sudo bash -c "cat > /etc/keepalived/keepalived.conf <<EOF
vrrp_script chk_nginx {
    script "/usr/bin/pgrep nginx"
    interval 2
}

vrrp_instance VI_1 {
    interface eth0
    state MASTER
    virtual_router_id 51
    priority 101
    virtual_ipaddress {
        192.168.100.10
    }
    track_script {
        chk_nginx
    }
}
EOF"

# 启动keepalived
sudo systemctl start keepalived