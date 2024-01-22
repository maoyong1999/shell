#!/bin/bash

# 删除Python 3.9的安装文件
sudo rm -rf /usr/local/lib/python3.9
sudo rm -rf /usr/local/bin/python3.9
sudo rm -rf /usr/local/bin/pip3.9

# 删除python3链接
sudo rm -f /usr/bin/python3

# 检查Python版本
python3 --version || echo "Python 3.9 is successfully removed"