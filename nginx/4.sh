#!/bin/bash

# 安装nginx
sudo apt-get update
sudo apt-get install nginx -y

# 配置nginx
sudo rm /etc/nginx/sites-enabled/default
sudo touch /etc/nginx/sites-available/web
sudo ln -s /etc/nginx/sites-available/web /etc/nginx/sites-enabled/web

# 编辑nginx配置文件
sudo bash -c "cat > /etc/nginx/sites-available/web <<EOF
server {
    listen 80;
    server_name web;
    location / {
        root /var/www/html;
        index index.html;
    }
}
EOF"

# 创建测试页面
sudo bash -c "cat > /var/www/html/index.html <<EOF
<html>
    <head>
        <title>Web Server 2</title>
    </head>
    <body>
        <h1>Web Server 2</h1>
    </body>
</html>
EOF"

# 重启nginx
sudo systemctl restart nginx