#!/bin/bash

# 打印提示信息
echo "开始安装Blast+ 2.15.0"

# 更新系统并安装依赖
echo "更新系统并安装依赖..."
sudo yum update -y
sudo yum groupinstall "Development Tools" -y
sudo yum install -y wget

# 安装SCL（Software Collections）并启用devtoolset-9（GCC 9）
echo "安装并启用GCC 9..."
sudo yum install -y centos-release-scl
sudo yum install -y devtoolset-9
source /opt/rh/devtoolset-9/enable

# 验证GCC版本
echo "验证GCC版本..."
gcc --version

# 安装额外依赖
echo "安装额外依赖..."
sudo yum install -y ncurses-devel zlib-devel bzip2-devel xz-devel sqlite-devel

# 下载Blast+源码
echo "下载Blast+ 2.15.0 源码..."
BLAST_VERSION="2.15.0"
wget "ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${BLAST_VERSION}/ncbi-blast-${BLAST_VERSION}+-src.tar.gz" -O ncbi-blast-src.tar.gz

# 解压源码
echo "解压源码..."
tar -xzvf ncbi-blast-src.tar.gz
cd ncbi-blast-${BLAST_VERSION}+-src/c++/

# 配置并编译Blast+
echo "配置并编译Blast+..."
./configure --with-mt --with-sqlite3 # 确保多线程和SQLite支持
make -j$(nproc)

# 安装Blast+
echo "安装Blast+..."
sudo make install

# 配置环境变量
echo "配置环境变量..."
echo 'export PATH=$PATH:/usr/local/ncbi/blast/bin' >> ~/.bashrc
source ~/.bashrc

# 验证安装
echo "验证安装..."
blastn -version

echo "Blast+ 2.15.0 安装完成"
