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
curl -O https://downloads.apache.org/tomcat/tomcat-9/v9.0.52/bin/apache-tomcat-9.0.52.tar.gz

# 解压 Tomcat
echo "正在解压 Tomcat..."
tar -xzf apache-tomcat-9.0.52.tar.gz
mv apache-tomcat-9.0.52 /usr/local/tomcat
rm -f apache-tomcat-9.0.52.tar.gz

# 配置 Tomcat 环境变量
echo "正在配置 Tomcat 环境变量..."
echo "export CATALINA_HOME=/usr/local/tomcat" >> /etc/profile
echo "export PATH=\$PATH:\$CATALINA_HOME/bin" >> /etc/profile
source /etc/profile

# 启动 Tomcat
echo "正在启动 Tomcat..."
/usr/local/tomcat/bin/startup.sh

echo "Java 和 Tomcat 安装和配置完成！"