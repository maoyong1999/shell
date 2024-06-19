#!/bin/bash

# 更新系统
sudo yum update -y

# 安装Perl
sudo yum install -y perl

# 安装cpan
sudo yum install -y perl-CPAN

# 配置CPAN镜像
echo "o conf urllist unshift https://mirrors.tuna.tsinghua.edu.cn/CPAN/" | perl -MCPAN -e shell
echo "o conf urllist unshift https://mirrors.aliyun.com/CPAN/" | perl -MCPAN -e shell
echo "o conf urllist unshift https://mirrors.ustc.edu.cn/CPAN/" | perl -MCPAN -e shell
echo "o conf commit" | perl -MCPAN -e shell

# 安装Archive::Tar模块
sudo perl -MCPAN -e 'install Archive::Tar'

# 安装JSON::PP模块
sudo perl -MCPAN -e 'install JSON::PP'


#!/bin/bash

# 定义变量
PERL_VERSION="5.36.0"
PERL_URL="https://mirrors.tuna.tsinghua.edu.cn/CPAN/src/5.0/perl-${PERL_VERSION}.tar.gz"
INSTALL_DIR="/usr/local/perl"
CPAN_MIRRORS=(
    "https://mirrors.tuna.tsinghua.edu.cn/CPAN/"
    "https://mirrors.aliyun.com/CPAN/"
    "https://mirrors.ustc.edu.cn/CPAN/"
)

# 更新系统并安装必要的依赖包
echo "Updating system and installing dependencies..."
yum groupinstall -y "Development Tools"
yum install -y wget tar

# 下载和解压 Perl 源码
echo "Downloading and extracting Perl ${PERL_VERSION}..."
wget $PERL_URL -O /tmp/perl-${PERL_VERSION}.tar.gz
tar -zxvf /tmp/perl-${PERL_VERSION}.tar.gz -C /tmp

# 配置、编译和安装 Perl
echo "Configuring, compiling and installing Perl..."
cd /tmp/perl-${PERL_VERSION}
./Configure -des -Dprefix=$INSTALL_DIR
make
make install

# 添加 Perl 安装路径到系统 PATH
echo "Updating system PATH..."
echo "export PATH=${INSTALL_DIR}/bin:\$PATH" >> ~/.bashrc
source ~/.bashrc

# 验证 Perl 安装
echo "Verifying Perl installation..."
perl -v

# 配置 CPAN 镜像源
echo "Configuring CPAN mirrors..."
cpan <<EOF
o conf urllist push ${CPAN_MIRRORS[0]}
o conf urllist push ${CPAN_MIRRORS[1]}
o conf urllist push ${CPAN_MIRRORS[2]}
o conf commit
exit
EOF

# 清理临时文件
echo "Cleaning up temporary files..."
rm -rf /tmp/perl-${PERL_VERSION}
rm /tmp/perl-${PERL_VERSION}.tar.gz

echo "Perl installation and CPAN configuration completed!"
