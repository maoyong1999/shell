#!/usr/bin/env sh

# 此脚本用于本地部署GitLab, OS为CentOS 7.9, GitLab版本为13.12.3, 请提前安装好docker和docker-compose

# 1. 创建目录
mkdir -p /data/gitlab/config
mkdir -p /data/gitlab/logs
mkdir -p /data/gitlab/data

# 2. 下载docker-compose.yml文件
curl -o /data/gitlab/docker-compose.yml https://raw.githubusercontent.com/linjiayu6/ShellScript/main/docker-compose.yml

# 3. 修改docker-compose.yml文件

# 4. 启动GitLab
cd /data/gitlab
docker-compose up -d

# 5. 查看GitLab状态
docker-compose ps

# 6. 查看GitLab日志
docker-compose logs -f

# 7. 访问GitLab
# http://<IP>:8929
# 初始用户名: root
# 初始密码: 5iveL!fe

# 8. 停止GitLab
# docker-compose down
