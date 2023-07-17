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
mkdir -p /opt/blackbox_exporter/config
chmod -R 777 /opt/blackbox_exporter/config

# Blackbox 需要检测的协议和端口
protocols="icmp http tcp udp dns ssl"

# 创建 Docker-Compose 配置文件
cat <<EOF > /opt/docker-compose.yml
version: '3'
services:
  blackbox_exporter:
    image: prom/blackbox-exporter
    container_name: blackbox_exporter
    ports:
      - 9115:9115
    volumes:
      - /opt/blackbox_exporter/config:/config
    command:
      - '--config.file=/config/blackbox.yml'
    restart: always
EOF

# 创建 Blackbox 配置文件
cat <<EOF > /opt/blackbox_exporter/config/blackbox.yml
modules:
EOF

# 添加需要检测的协议和端口
for protocol in $protocols; do
    echo "  $protocol:" >> /opt/blackbox_exporter/config/blackbox.yml
    echo "    prober: $protocol" >> /opt/blackbox_exporter/config/blackbox.yml
    echo "    timeout: 5s" >> /opt/blackbox_exporter/config/blackbox.yml
    if [[ $protocol == "http" || $protocol == "tcp_tls" ]]; then
        echo "    $protocol:" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "      preferred_ip_protocol: \"ip4\"" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "      method: GET" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "      headers:" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "        Host: \"example.com\"" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "      no_follow_redirects: false" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "      fail_if_ssl: false" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "      fail_if_not_ssl: false" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "      tls_config:" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "        insecure_skip_verify: true" >> /opt/blackbox_exporter/config/blackbox.yml
    elif [[ $protocol == "dns" ]]; then
        echo "    $protocol:" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "      transport_protocol: udp" >> /opt/blackbox_exporter/config/blackbox.yml
        echo "      preferred_ip_protocol: \"ip4\"" >> /opt/blackbox_exporter/config/blackbox.yml
    fi
done

# 启动 Blackbox Exporter
docker-compose -f /opt/docker-compose.yml up -d