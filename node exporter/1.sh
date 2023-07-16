#!/bin/bash

# 卸载旧版本 Docker
yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

# 安装 Docker 依赖
yum install -y yum-utils device-mapper-persistent-data lvm2

# 设置 yum repository 为阿里云的镜像仓库
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装 Docker 和 Docker-Compose
yum install -y docker-ce docker-ce-cli containerd.io docker-compose

# 启动 Docker
systemctl start docker

# 设置 Docker 开机自启
systemctl enable docker

# 配置 Docker 镜像仓库为阿里云的镜像仓库
cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://jx9181e6.mirror.aliyuncs.com"]
}
EOF

# 重启 Docker
systemctl daemon-reload
systemctl restart docker

# 创建需要挂载的目录并配置目录的读写权限
mkdir -p /opt/node_exporter/data
chmod -R 777 /opt/node_exporter/data

# 创建 Docker-Compose 配置文件
cat <<EOF > /opt/docker-compose.yml
version: '3'
services:
  node_exporter:
    image: prom/node-exporter
    container_name: node_exporter
    ports:
      - 9100:9100
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
      - /opt/node_exporter/data:/prometheus
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
      - '--web.listen-address=:9100'
      - '--web.telemetry-path=/metrics'
EOF

# 启动 Node Exporter
docker-compose -f /opt/docker-compose.yml up -d