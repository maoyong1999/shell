#!/bin/bash

# MySQL配置
HOST=127.0.0.1
PORT=3306
DATABASE=testdb
USER=root
PASSWORD=P@ssw0rd  # 请将此处替换为你的MySQL root密码

# sysbench配置
TABLES=10
SIZE=10000
THREADS=10
TIME=60

# 安装sysbench
yum -y install sysbench

# 准备数据
sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=$HOST --mysql-port=$PORT --mysql-user=$USER --mysql-password=$PASSWORD --mysql-db=$DATABASE --tables=$TABLES --table-size=$SIZE prepare

# 运行压力测试
sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=$HOST --mysql-port=$PORT --mysql-user=$USER --mysql-password=$PASSWORD --mysql-db=$DATABASE --tables=$TABLES --table-size=$SIZE --threads=$THREADS --time=$TIME run

# 清理数据
sysbench /usr/share/sysbench/oltp_read_write.lua --mysql-host=$HOST --mysql-port=$PORT --mysql-user=$USER --mysql-password=$PASSWORD --mysql-db=$DATABASE --tables=$TABLES --table-size=$SIZE cleanup