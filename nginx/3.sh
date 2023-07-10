#!/bin/bash

# 安装NGINX
yum install -y epel-release
yum install -y nginx

# 配置NGINX
cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name web1;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# 创建测试页面
echo "This is Web Server 1" > /usr/share/nginx/html/index.html

# 启动NGINX
systemctl enable nginx
systemctl start nginx