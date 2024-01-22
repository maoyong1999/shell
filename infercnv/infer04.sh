#!/bin/bash

# 1. Update system
sudo yum -y update

# 2. Install development tools and libraries
sudo yum -y groupinstall "Development Tools"
sudo yum -y install gcc-gfortran readline-devel xorg-x11-devel libpng-devel libjpeg-turbo-devel libtiff-devel cairo-devel libXt-devel lapack-devel libcurl-devel xz-devel bzip2-devel wget

# 3. Create directory and install JAGS
mkdir /root/jags
cd /root/jags
wget https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Source/JAGS-4.3.1.tar.gz
tar -xvf JAGS-4.3.1.tar.gz
cd JAGS-4.3.1
./configure --prefix=/root/jags
make
make install
cd ..

# 4. Add JAGS to PATH and set environment variables
export PATH=/root/jags/bin:$PATH
export JAGS_PREFIX=/root/jags
export JAGS_LIBDIR=$JAGS_PREFIX/lib
export JAGS_INCLUDEDIR=$JAGS_PREFIX/include
export LD_LIBRARY_PATH=$JAGS_LIBDIR:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/root/jags/lib/pkgconfig:$PKG_CONFIG_PATH

echo 'export PATH=/root/jags/bin:$PATH' >> ~/.bashrc
echo 'export JAGS_PREFIX=/root/jags' >> ~/.bashrc
echo 'export JAGS_LIBDIR=$JAGS_PREFIX/lib' >> ~/.bashrc
echo 'export JAGS_INCLUDEDIR=$JAGS_PREFIX/include' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$JAGS_LIBDIR:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export PKG_CONFIG_PATH=/root/jags/lib/pkgconfig:$PKG_CONFIG_PATH' >> ~/.bashrc
source ~/.bashrc

# 5. Check JAGS installation
jags -v
read -p "Press enter to continue if JAGS installation was successful, otherwise abort the script."

# 6. Download and install Anaconda
mkdir /root/anaconda
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
bash Anaconda3-2021.05-Linux-x86_64.sh -b -p /root/anaconda
export PATH=$PATH:/root/anaconda/bin
echo 'export PATH=/root/anaconda/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 7. Check Anaconda installation
conda --version
read -p "Press enter to continue if Anaconda installation was successful, otherwise abort the script."

# 8. Create conda environment and run conda init
conda create -n infercnv
conda init

# 9. Activate infercnv environment
conda activate infercnv

# 10. Add Tsinghua and USTC Anaconda mirrors
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/

conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/bioconda/
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --add channels r
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
show_channel_urls: tr

# 11. Install R 4.3.1
conda install -c r r=4.3.1

# 12. Install BiocManager
R -e "install.packages('BiocManager', repos='http://cran.rstudio.com/')"

# 13. Install rjags
R -e "install.packages('rjags', repos='http://cran.rstudio.com/')"

# 14. Load rjags in R environment
R -e "library(rjags)"

# 15. Install infercnv
R -e "BiocManager::install('infercnv')"

# install infercnv
# conda activate infercnv
# conda install -c r r=4.3.1
# R
# conda install -c conda-forge jags
# conda install -c conda-forge r-rjags
# R -e "install.packages('BiocManager', repos='http://cran.rstudio.com/')
# R -e "library(rjags)"
# R -e "BiocManager::install('infercnv')"
# R -e "packageVersion('infercnv')"
