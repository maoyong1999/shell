#!/bin/bash

# 安装 CoreDNS
wget https://github.com/coredns/coredns/releases/download/v1.10.1/coredns_1.10.1_linux_amd64.tgz
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
    10.0.0.1    host1.example.com
    10.0.0.2    host2.example.com
    10.0.0.3    host3.example.com
    10.0.0.4    host4.example.com
    10.0.0.5    host5.example.com
    10.0.0.6    host6.example.com
    10.0.0.7    host7.example.com
    10.0.0.8    host8.example.com
    10.0.0.9    host9.example.com
    10.0.0.10   host10.example.com
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