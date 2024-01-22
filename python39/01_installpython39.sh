#!/bin/bash

# 更新系统
sudo yum -y update

# 安装依赖
sudo yum -y install gcc openssl-devel bzip2-devel libffi-devel

# 下载Python 3.9
cd /opt
sudo wget https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz

# 解压下载的文件
sudo tar xzf Python-3.9.0.tgz

# 编译Python源码
cd Python-3.9.0
sudo ./configure --enable-optimizations
sudo make altinstall

# 创建python3链接
sudo ln -s /usr/local/bin/python3.9 /usr/bin/python3

# 检查Python版本
python3 --version