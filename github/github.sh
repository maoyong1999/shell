#!/bin/bash

# 解析github的IP
GITHUB_IP=$(dig +short github.com)

# 把github和IP写入hosts文件
echo "$GITHUB_IP github.com" | sudo tee -a /etc/hosts