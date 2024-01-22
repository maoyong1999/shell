#!/bin/bash

# 创建一个黑名单文件
echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf

# 重新生成内核初始化映像
sudo dracut --force

# 重启系统
sudo reboot

