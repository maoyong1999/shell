#!/bin/bash

# 下载 Grafana
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-10.2.0.linux-amd64.tar.gz

# 解压 Grafana 安装包
tar -zxvf grafana-enterprise-10.2.0.linux-amd64.tar.gz

# 移动到 /usr/local 目录
mv grafana-8.1.5 /usr/local/grafana

# 创建 Grafana 服务
cat <<EOF | sudo tee /etc/systemd/system/grafana.service
[Unit]
Description=Grafana
After=network.target

[Service]
Environment="GF_PATHS_HOME=/usr/local/grafana"
ExecStart=/usr/local/grafana/bin/grafana-server web
WorkingDirectory=/usr/local/grafana
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

# 启动 Grafana 服务
sudo systemctl start grafana

# 设置 Grafana 服务开机自启
sudo systemctl enable grafana

echo "Grafana 安装完成。"