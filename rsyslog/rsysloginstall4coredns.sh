#!/bin/bash

# 安装 rsyslog
yum install -y rsyslog

# 创建 rsyslog 的配置文件和日志目录
mkdir -p /etc/rsyslog.d
touch /etc/rsyslog.d/50-coredns.conf
mkdir -p /var/log/coredns

# 编辑 rsyslog 的配置文件
cat << EOF > /etc/rsyslog.d/50-coredns.conf
# CoreDNS 日志配置
\$ModLoad imfile
\$InputFileName /var/log/coredns/coredns.log
\$InputFileTag coredns:
\$InputFileStateFile coredns-state
\$InputFileSeverity info
\$InputFileFacility local7
\$InputRunFileMonitor

local7.* @@<rsyslog_host>:514
EOF

# 替换 <rsyslog_host> 为 rsyslog 服务器的 IP 地址
sed -i "s/<rsyslog_host>/$(hostname -I | awk '{print $1}')/g" /etc/rsyslog.d/50-coredns.conf

# 重启 rsyslog 服务
systemctl restart rsyslog