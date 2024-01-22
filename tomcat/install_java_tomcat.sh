#!/bin/bash

# 安装 Java
echo "正在安装 Java..."
yum install -y java-1.8.0-openjdk-devel

# 配置 Java 环境变量
echo "正在配置 Java 环境变量..."
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> /etc/profile
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
source /etc/profile

# 下载 Tomcat
echo "正在下载 Tomcat..."
curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.78/bin/apache-tomcat-9.0.78.tar.gz

# 解压 Tomcat
echo "正在解压 Tomcat..."
tar -xzf apache-tomcat-9.0.78.tar.gz
mv apache-tomcat-9.0.78 /usr/local/tomcat
rm -f apache-tomcat-9.0.78.tar.gz

# 配置 Tomcat 环境变量
echo "正在配置 Tomcat 环境变量..."
echo "export CATALINA_HOME=/usr/local/tomcat" >> /etc/profile
echo "export PATH=\$PATH:\$CATALINA_HOME/bin" >> /etc/profile
source /etc/profile

# 创建 Tomcat 的 systemd 服务文件
echo "正在创建 Tomcat 的 systemd 服务文件..."
cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
Environment=CATALINA_PID=/usr/local/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'

ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/usr/local/tomcat/bin/shutdown.sh

User=root
Group=root
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd 配置文件
echo "正在重新加载 systemd 配置文件..."
systemctl daemon-reload

# 启动 Tomcat 服务
echo "正在启动 Tomcat 服务..."
systemctl start tomcat

# 设置 Tomcat 服务开机自启
echo "正在设置 Tomcat 服务开机自启..."
systemctl enable tomcat

echo "Java 和 Tomcat 安装和配置完成！"