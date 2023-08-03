#!/bin/bash

# 安装 CoreDNS
# wget https://github.com/coredns/coredns/releases/download/v1.10.1/coredns_1.10.1_linux_amd64.tgz
tar -zxvf coredns_1.10.1_linux_amd64.tgz
mv coredns /usr/local/bin/

# 创建 CoreDNS 配置文件
cat <<EOF > /etc/coredns/Corefile
.:53 {
    forward . 223.5.5.5 8.8.8.8
    health
    prometheus
    file /etc/coredns/zones/db.internal example.com {
        reload 1s
    }
}
EOF

# 创建内网主机名和IP的解析文件
cat <<EOF > /etc/coredns/zones/db.internal
example.com. {
    192.168.100.1    k8s-master
    192.168.100.2    k8s-node01
    192.168.100.3    k8s-node02    
    192.168.100.4    prometheus01
    192.168.100.5    haproxytest
    192.168.100.6    zabbix
    192.168.100.7    winclient
    192.168.100.8    gitlab
    192.168.100.9    blackbox
    192.168.100.10    nginx01
    192.168.100.11    nginx02
    192.168.100.12    web01
    192.168.100.13    web02
}
EOF

# 创建 CoreDNS systemd 配置文件
cat <<EOF > /etc/systemd/system/coredns.service
[Unit]
Description=CoreDNS DNS server
Documentation=https://coredns.io/manual/toc/
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/coredns -conf /etc/coredns/Corefile
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 启动 CoreDNS
systemctl daemon-reload
systemctl start coredns
systemctl enable coredns

# 安装 CoreDNS 健康检查插件
wget https://github.com/miekg/coredns-health/releases/download/v1.0.1/health_linux_amd64.tgz
tar -zxvf health_linux_amd64.tgz
mv health /usr/local/bin/

# 修改 CoreDNS 配置文件，增加健康检查插件
sed -i '/health/a\    health' /etc/coredns/Corefile

# 重启 CoreDNS
systemctl restart coredns