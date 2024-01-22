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

# 下载并安装 JAGS
wget https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Source/JAGS-4.3.0.tar.gz
tar -xvf JAGS-4.3.0.tar.gz
cd JAGS-4.3.0
./configure
make
sudo make install
cd ..

# 下载并安装 R 3.6.0
wget https://cran.r-project.org/src/base/R-3/R-3.6.0.tar.gz
tar -xvf R-3.6.0.tar.gz
cd R-3.6.0
./configure --with-readline=yes --enable-R-shlib
make
sudo make install
cd ..

# 安装 Python 3
sudo yum -y install python3

# 安装 CRAN 包
sudo R -e "install.packages(c('graphics', 'grDevices', 'RColorBrewer', 'gplots', 'futile.logger', 'stats', 'utils', 'methods', 'ape', 'Matrix', 'fastcluster', 'dplyr', 'HiddenMarkov', 'ggplot2', 'coin', 'caTools', 'digest', 'reshape', 'rjags', 'fitdistrplus', 'future', 'foreach', 'doParallel', 'tidyr', 'parallel', 'coda', 'gridExtra', 'argparse'), repos='http://cran.rstudio.com/')"

# 安装 Bioconductor 包
sudo R -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager'); BiocManager::install(c('edgeR', 'BiocGenerics', 'SummarizedExperiment', 'SingleCellExperiment'))"

# 安装 inferCNV
sudo R -e "BiocManager::install('infercnv')"