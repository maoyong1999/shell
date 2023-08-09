#!/bin/bash

# 安装 CoreDNS
tar -zxvf coredns_1.10.1_linux_amd64.tgz
mv coredns /usr/local/bin/

mkdir -p /etc/coredns/zones

# 创建 CoreDNS 配置文件
cat <<EOF > /etc/coredns/Corefile
.:53 {
    forward . 223.5.5.5 8.8.8.8
    health
    prometheus
    file /etc/coredns/zones/james.local james.local {
        reload 1s
    }
}
EOF

# 创建 james.local 的解析文件
cat <<EOF > /etc/coredns/zones/james.local
\$TTL 1h
@       IN      SOA     ns1.james.local. admin.james.local. (
                        2021102001      ; serial
                        1h              ; refresh
                        10m             ; retry
                        1w              ; expire
                        1h              ; minimum
                        )
        IN      NS      ns1.james.local.
        IN      NS      ns2.james.local.
ns1     IN      A       192.168.100.25
ns2     IN      A       192.168.100.26
k8smaster.james.local.      IN      A       192.168.100.1
k8snode01.james.local.      IN      A       192.168.100.2
k8snode02.james.local.      IN      A       192.168.100.3
prometheus01.james.local.    IN      A       192.168.100.4
haproxytest.james.local.     IN      A       192.168.100.5
zabbix.james.local.          IN      A       192.168.100.6
winclient.james.local.       IN      A       192.168.100.7
gitlab.james.local.          IN      A       192.168.100.8
blackbox.james.local.        IN      A       192.168.100.9
nginx01.james.local.         IN      A       192.168.100.10
nginx02.james.local.         IN      A       192.168.100.11
web01.james.local.           IN      A       192.168.100.12
web02.james.local.           IN      A       192.168.100.13
EOF

# 创建 CoreDNS systemd 配置文件
cat <<EOF > /etc/systemd/system/coredns.service
[Unit]
Description=CoreDNS DNS server
Documentation=https://coredns.io/manual/toc/
After=network.target

[Service]
ExecStart=/usr/local/bin/coredns -conf /etc/coredns/Corefile
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 重载 systemd 配置文件
systemctl daemon-reload

# 启动 CoreDNS 服务
systemctl start coredns

# 设置 CoreDNS 开机自启
systemctl enable coredns