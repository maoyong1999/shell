#!/bin/bash

# 更新系统
sudo yum -y update

# 安装编译工具和依赖库
sudo yum -y groupinstall "Development Tools"
sudo yum -y install gcc-gfortran
sudo yum -y install readline-devel
sudo yum -y install xorg-x11-devel
sudo yum -y install libpng-devel
sudo yum -y install libjpeg-turbo-devel
sudo yum -y install libtiff-devel
sudo yum -y install cairo-devel
sudo yum -y install libXt-devel
sudo yum -y install lapack-devel
sudo yum -y install libcurl-devel
sudo yum -y install xz-devel
sudo yum -y install bzip2-devel

# 创建目录并安装 JAGS
mkdir /root/JAGS
cd /root/JAGS
wget https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Source/JAGS-4.3.0.tar.gz
tar -xvf JAGS-4.3.0.tar.gz
cd JAGS-4.3.0
./configure --prefix=/root/JAGS
make
make install
cd ..

# 将 JAGS 的安装路径添加到 PATH 环境变量
echo 'export PATH=/root/JAGS/bin:$PATH' >> /root/.bashrc
source /root/.bashrc

# 下载并安装 Anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
bash Anaconda3-2021.05-Linux-x86_64.sh -b -p $HOME/anaconda

# 将 Anaconda 的安装路径添加到 PATH 环境变量
echo 'export PATH=$HOME/anaconda/bin:$PATH' >> /root/.bashrc
source /root/.bashrc

# 创建名为 infercnv 的 Conda 环境
conda create -n infercnv

# 激活 infercnv 环境
conda activate infercnv

# 添加清华大学的Anaconda镜像
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/

# 添加中科大的Anaconda镜像
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/

# 设置搜索时显示通道地址
conda config --set show_channel_urls yes

# 查看可以安装的 R 语言版本
conda search -c r r

# 提供版本选择对话框
echo "Available versions:"
versions=$(conda search -c r r | awk 'NR>2 {print NR-2 " " $2}')
echo "$versions"
echo "Please enter the number of the version of R you want to install:"
read number
version=$(echo "$versions" | awk -v number="$number" '$1 == number {print $2}')

# 安装选择的 R 语言版本
conda install -c r r=$version

# 检查 R 是否已经成功安装
which R
R --version

# 安装 BiocManager
R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager')"

# 安装 rjags
R -e "install.packages('rjags')"

# 安装 infercnv
R -e "BiocManager::install('infercnv')"
R -e "options(repos = c(CRAN = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/')); install.packages('rjags')"