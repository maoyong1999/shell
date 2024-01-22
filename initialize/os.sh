#!/bin/bash

# 提示用户输入网卡名称，默认为eth1
read -p "请输入网卡名称[${NIC:-ens224}]: " nic
nic=${nic:-ens224}

# 提示用户输入IP地址
read -p "请输入IP地址: " ip_address

# 提示用户输入子网掩码，默认为255.255.255.0
read -p "请输入子网掩码[${NETMASK:-255.255.255.0}]: " netmask
netmask=${netmask:-255.255.255.0}

# 提示用户输入网关，默认为192.168.100.1
read -p "请输入网关[${GATEWAY:-192.168.100.1}]: " gateway
gateway=${gateway:-192.168.100.1}

# 提示用户输入DNS服务器，默认为223.5.5.5
read -p "请输入DNS服务器[${DNS1:-223.5.5.5}]: " dns1
dns1=${dns1:-223.5.5.5}

# 配置IP地址
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-$nic
TYPE=Ethernet
BOOTPROTO=static
IPADDR=$ip_address
NETMASK=$netmask
GATEWAY=$gateway
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
DEVICE=$nic
ONBOOT=yes
EOF

# 重启网络服务
# systemctl restart network
ifup $nic

# 停止防火墙服务
systemctl stop firewalld

# 禁用防火墙服务
systemctl disable firewalld

# 关闭 SELinux
setenforce 0

# 禁用 SELinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

# 配置DNS服务器
cat <<EOF > /etc/resolv.conf
nameserver 223.5.5.5
nameserver 223.6.6.6
nameserver 8.8.8.8
EOF

# 提示用户输入主机名
read -p "请输入主机名: " hostname

# 配置主机名
hostnamectl set-hostname $hostname

# 更新 /etc/hosts 文件
sed -i "s/^127.0.0.1.*/127.0.0.1\t$hostname localhost.localdomain localhost/g" /etc/hosts

# 备份原有 Yum 源文件
# mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak

# 下载阿里云 Yum 源文件
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo

# 备份原有 EPEL 源文件
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.bak

# 下载阿里云 EPEL 源文件
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# 清除 Yum 缓存
yum clean all

# 生成 Yum 缓存
yum makecache

# 安装 NTP 服务
yum install -y ntp

# 启动 NTP 服务
systemctl start ntpd

# 设置 NTP 服务开机自启
systemctl enable ntpd

# 配置时区为上海
timedatectl set-timezone Asia/Shanghai

# 配置时钟服务器为阿里云的时钟服务器
sed -i 's/^server.*/server ntp.aliyun.com iburst/g' /etc/ntp.conf

# 配置每天自动同步
echo "0 0 * * * /usr/sbin/ntpdate ntp.aliyun.com >/dev/null 2>&1" >> /etc/crontab

# 重启 crond 服务
systemctl restart crond