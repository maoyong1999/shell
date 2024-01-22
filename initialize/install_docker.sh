#!/bin/bash

# 麻烦编写一段脚本,要求如下:
# 1.卸载旧版本Docker
# 2.设置 yum repository,配置yum-config-manager为阿里云的镜像仓库
# 安装docker和docker-compose
# 2.配置docker镜像仓库为阿里云的镜像仓库


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