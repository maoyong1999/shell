#!/bin/bash

# 安装NGINX
yum install -y epel-release
yum install -y nginx

# 配置NGINX
cat <<EOF > /etc/nginx/conf.d/default.conf
upstream backend {
    server 192.168.100.12;
    server 192.168.100.13;
}

server {
    listen 80;
    server_name web;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

# 启动NGINX
systemctl enable nginx
systemctl start nginx