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

# 重启nginx
sudo systemctl restart nginx