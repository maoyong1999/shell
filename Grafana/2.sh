#!/bin/bash

# 麻烦编写一段脚本,要求如下:
# 1.卸载旧版本Docker
# 2.设置 yum repository,配置yum-config-manager为阿里云的镜像仓库
# 安装docker和docker-compose
# 2.配置docker镜像仓库为阿里云的镜像仓库
# 3.安装和配置Prometheus、Alert Manager和Grafana
# 4.创建需要挂载的目录并配置目录的读写权限


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
mkdir -p /opt/prometheus/data
chmod -R 777 /opt/prometheus/data
mkdir -p /opt/alertmanager/data
chmod -R 777 /opt/alertmanager/data
mkdir -p /opt/grafana/data
chmod -R 777 /opt/grafana/data

# 下载 Prometheus 配置文件
# curl -o /opt/prometheus/prometheus.yml https://raw.githubusercontent.com/prometheus/prometheus/main/documentation/examples/prometheus.yml
cp /root/shell/Grafana/prometheus.yml /opt/prometheus/

# 下载 Alert Manager 配置文件
# curl -o /opt/alertmanager/alertmanager.yml https://raw.githubusercontent.com/prometheus/alertmanager/main/doc/examples/simple.yml
cp /root/shell/Grafana/alertmanager.yml /opt/alertmanager/

# 创建 Docker-Compose 配置文件
cat <<EOF > /opt/docker-compose.yml
version: '3'
services:
  prometheus:
    image: prom/prometheus
    container_name: prometheus
    ports:
      - 9090:9090
    volumes:
      - /opt/prometheus/:/etc/prometheus/
      - /opt/prometheus/data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
  alertmanager:
    image: prom/alertmanager
    container_name: alertmanager
    ports:
      - 9093:9093
    volumes:
      - /opt/alertmanager/:/etc/alertmanager/
      - /opt/alertmanager/data:/data
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/data'
  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - 3000:3000
    volumes:
      - /opt/grafana/data:/var/lib/grafana
EOF

# 启动 Prometheus、Alert Manager 和 Grafana

docker-compose -f /opt/docker-compose.yml up -d

