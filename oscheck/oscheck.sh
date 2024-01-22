#!/bin/bash

# 检查系统版本
echo "# 检查系统版本" >> result.checklist
cat /etc/redhat-release >> result.checklist
echo "" >> result.checklist

# 检查系统YUM源仓库
echo "# 检查系统YUM源仓库" >> result.checklist
yum repolist >> result.checklist
echo "" >> result.checklist

# 检查防火墙配置
echo "# 检查防火墙配置" >> result.checklist
systemctl status firewalld >> result.checklist
echo "" >> result.checklist

# 检查SELinux配置
echo "# 检查SELinux配置" >> result.checklist
sestatus >> result.checklist
echo "" >> result.checklist

# 检查是否部署Dockcer
echo "# 检查是否部署Docker" >> result.checklist
docker -v >> result.checklist
echo "" >> result.checklist

# 检查是否安装了Docker-compose
echo "# 检查是否安装Docker-compose" >> result.checklist
docker-compose -v >> result.checklist
echo "" >> result.checklist

# 检查Docker的镜像仓库配置
echo "# 检查Docker的镜像仓库配置" >> result.checklist
cat /etc/docker/daemon.json >> result.checklist
echo "" >> result.checklist

# 检查部署了多少容器，并罗列相关容器
echo "# 检查部署的容器" >> result.checklist
docker ps -a >> result.checklist
echo "" >> result.checklist

# 检查系统监听的端口
echo "# 检查系统监听的端口" >> result.checklist
netstat -tunlp >> result.checklist
echo "" >> result.checklist