#!/bin/bash

# 网卡名称
INTERFACE="ens192"

# 配置文件路径
FILE="/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"

# 检查文件是否存在
if [ ! -f "$FILE" ]; then
    echo "配置文件 $FILE 不存在。"
    exit 1
fi

# 检查 ONBOOT 行是否存在
if grep -q "^ONBOOT=" $FILE; then
    # 如果存在，则修改它
    sed -i "/^ONBOOT=/c\ONBOOT=yes" $FILE
else
    # 如果不存在，则添加它
    echo "ONBOOT=yes" >> $FILE
fi

echo "配置完成。"
# 提示用户输入网卡名称，默认为 ens224
read -p "请输入网卡名称 (默认: ens224): " INTERFACE
INTERFACE=${INTERFACE:-ens224}

# 提示用户输入 IP 地址
read -p "请输入 IP 地址: " IPADDR

# 提示用户输入子网掩码，默认为 255.255.255.0
read -p "请输入子网掩码 (默认: 255.255.255.0): " NETMASK
NETMASK=${NETMASK:-255.255.255.0}

# 提示用户输入网关，默认为 192.168.100.1
read -p "请输入网关 (默认: 192.168.100.1): " GATEWAY
GATEWAY=${GATEWAY:-192.168.100.1}

# 提示用户输入 DNS 服务器，默认为 223.5.5.5
read -p "请输入 DNS 服务器 (默认: 223.5.5.5): " DNS1
DNS1=${DNS1:-223.5.5.5}

# 配置 IP 地址
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
BOOTPROTO=static
DEVICE=$INTERFACE
ONBOOT=yes
IPADDR=$IPADDR
NETMASK=$NETMASK
GATEWAY=$GATEWAY
DNS1=$DNS1
EOF

# 重启网络服务
systemctl restart network

# 停止防火墙服务
systemctl stop firewalld

# 禁用防火墙服务
systemctl disable firewalld

# 关闭 SELinux
setenforce 0

# 禁用 SELinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# 配置 DNS 服务器
echo "nameserver 223.5.5.5" > /etc/resolv.conf
echo "nameserver 223.6.6.6" >> /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# 提示用户输入主机名
read -p "请输入主机名: " HOSTNAME

# 配置主机名
hostnamectl set-hostname $HOSTNAME

# 更新 /etc/hosts 文件
echo "$IPADDR $HOSTNAME" >> /etc/hosts

# 安装 wget 和 yum-utils
yum install -y wget yum-utils

# 备份原有的 YUM 源
# mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

# 配置阿里云的 YUM 源
# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# wget -O /etc/yum.repos.d/CentOS-aliyun.repo http://mirrors.aliyun.com/repo/Centos-7.repo

# 配置清华大学的 YUM 源
# wget -O /etc/yum.repos.d/CentOS-Tsinghua.repo https://mirrors.tuna.tsinghua.edu.cn/help/centos/

# 配置上海交大的 YUM 源
# wget -O /etc/yum.repos.d/CentOS-SJTUG.repo https://mirrors.sjtug.sjtu.edu.cn/centos/7/os/x86_64/
# sed -e 's/mirrorlist/#mirrorlist/g' -e 's|#baseurl=http://mirror.centos.org/|baseurl=http://mirror.sjtu.edu.cn/|g' -i.bak /etc/yum.repos.d/CentOS-Base.repo

# 配置网易的 YUM 源
# wget -O /etc/yum.repos.d/CentOS-163.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo

# 安装 EPEL 源
yum install -y epel-release

# 配置 EPEL 源
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# 清除缓存
yum clean all

# 生成缓存
yum makecache

# 自动选择最快的 YUM 源
yum install -y yum-plugin-fastestmirror

yum -y update

# 安装 NTP
yum install -y ntp lrzsz net-tools

# 配置时区为上海
timedatectl set-timezone Asia/Shanghai

# 配置时钟服务器为阿里云的时钟服务器，并配置每天同步
echo "server ntp.aliyun.com iburst" > /etc/ntp.conf
echo "restrict default kod nomodify notrap nopeer noquery" >> /etc/ntp.conf
echo "restrict 127.0.0.1" >> /etc/ntp.conf
echo "restrict ::1" >> /etc/ntp.conf
systemctl enable ntpd
systemctl start ntpd