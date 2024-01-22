#!/bin/bash

# 检查nouveau驱动是否已经被禁用
lsmod | grep nouveau
if [ $? -eq 0 ]; then
    echo "nouveau driver is still active"
else
    echo "nouveau driver is disabled"
fi