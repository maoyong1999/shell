#!/bin/bash

# 下载 Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.1/prometheus-2.45.1.linux-amd64.tar.gz

# 解压 Prometheus 安装包
tar -zxvf prometheus-2.45.1.linux-amd64.tar.gz

# 移动到 /usr/local 目录
mv prometheus-2.45.1.linux-amd64 /usr/local/prometheus

# 创建 Prometheus 服务
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml
WorkingDirectory=/usr/local/prometheus
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

# 启动 Prometheus 服务
sudo systemctl start prometheus

# 设置 Prometheus 服务开机自启
sudo systemctl enable prometheus

echo "Prometheus 安装完成。"