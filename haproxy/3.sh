#!/bin/bash

# 安装 redis
yum install -y redis

# 配置 redis
sed -i 's/# requirepass foobared/requirepass P@ssw0rd/g' /etc/redis.conf
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis.conf

# 启动 redis
systemctl enable redis
systemctl start redis