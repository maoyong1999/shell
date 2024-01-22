#!/bin/bash

# 下载 Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz

# 解压 Node Exporter 安装包
tar -zxvf node_exporter-1.7.0.linux-amd64.tar.gz

# 移动到 /usr/local 目录
mv node_exporter-1.7.0.linux-amd64 /usr/local/node_exporter

# 创建 Node Exporter 服务
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/node_exporter/node_exporter --web.listen-address=:9100
WorkingDirectory=/usr/local/node_exporter
User=root
LimitNOFILE=4096
TimeoutStopSec=20
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

# 重载 systemd 配置
sudo systemctl daemon-reload

# 启动 Node Exporter 服务
sudo systemctl start node_exporter

# 设置 Node Exporter 服务开机自启
sudo systemctl enable node_exporter

echo "Node Exporter 安装完成。"