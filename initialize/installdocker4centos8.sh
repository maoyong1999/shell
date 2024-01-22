#!/bin/bash

mv /etc/yum.repos.d /etc/yum.repos.d.backup

mkdir /etc/yum.repos.d
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
#curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo

yum clean all && yum makecache

# 更新系统软件包
sudo yum update -y

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


# 配置阿里云Docker镜像加速器
# sudo mkdir -p /etc/docker
# sudo tee /etc/docker/daemon.json <<-'EOF'
#{
#    "registry-mirrors": ["https://<your-aliyun-docker-mirror>.mirror.aliyuncs.com"]
#}
#EOF

# 重启Docker服务
sudo systemctl daemon-reload
sudo systemctl restart docker

