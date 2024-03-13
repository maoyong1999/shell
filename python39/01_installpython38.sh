# 安装必要的依赖
sudo yum install -y gcc openssl-devel bzip2-devel libffi-devel

# 下载 Python 3.8 的源码
cd /opt
sudo wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz

# 解压源码包
sudo tar xzf Python-3.8.0.tgz

# 编译和安装 Python 3.8
cd Python-3.8.0
sudo ./configure --enable-optimizations
sudo make altinstall

# 创建一个符号链接，使得我们可以使用 `python3` 命令来启动 Python 3.8
sudo ln -s /usr/local/bin/python3.8 /usr/bin/python3

# 检查 Python 版本
python3 --version