#!/bin/bash

# 安装NGINX
yum install -y epel-release
yum install -y nginx

# 配置NGINX
cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name web2;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# 创建测试页面
# echo "This is Web Server 1" > /usr/share/nginx/html/index.html

cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Page</title>
    <style>
        body {
            text-align: center;
        }
        h1 {
            font-size: 24px;
        }
        .highlight {
            font-size: 48px;
            color: red;
            animation: blink 1s infinite;
        }
        @keyframes blink {
            50% {
                opacity: 0;
            }
        }
    </style>
</head>
<body>
    <h1>This is Web Server <span class="highlight">01</span></h1>
</body>
</html>
EOF

# 启动NGINX
systemctl enable nginx
systemctl start nginx