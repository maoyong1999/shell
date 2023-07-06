#!/bin/bash

# 安装 NFS
yum install -y nfs-utils

# 创建共享目录
mkdir /shared

# 配置 NFS
echo "/shared *(rw,sync,no_root_squash)" >> /etc/exports

# 启动 NFS
systemctl enable nfs-server
systemctl start nfs-server

# 安装必要的依赖
yum install -y epel-release
yum install -y munge munge-libs munge-devel mariadb-server mariadb-devel mariadb-libs mariadb-devel slurm slurm-munge slurm-slurmdbd slurm-devel slurm-perlapi

# 配置 Munge
systemctl enable munge
systemctl start munge

# 配置 MariaDB
systemctl enable mariadb
systemctl start mariadb

# 创建 Slurm 数据库
mysql -u root <<EOF
CREATE DATABASE slurmdb;
CREATE USER 'slurm'@'localhost';
SET PASSWORD FOR 'slurm'@'localhost' = PASSWORD('password');
GRANT ALL PRIVILEGES ON slurmdb.* TO 'slurm'@'localhost';
FLUSH PRIVILEGES;
EOF

# 配置 Slurm
cp /etc/slurm/slurm.conf.example /etc/slurm/slurm.conf
sed -i 's/ControlMachine=slurm/ControlMachine=<your_control_node_hostname>/g' /etc/slurm/slurm.conf
sed -i 's/NodeName=linux NodeAddr=192.168.0.0/NodeName=<your_compute_node_hostname> NodeAddr=<your_compute_node_ip_address>/g' /etc/slurm/slurm.conf
sed -i 's/PartitionName=debug Nodes=linux Default=YES/PartitionName=debug Nodes=<your_compute_node_hostname> Default=YES/g' /etc/slurm/slurm.conf
sed -i 's/AccountingStorageType=accounting_storage/AccountingStorageType=accounting_storage/mysql/g' /etc/slurm/slurm.conf
sed -i 's/AccountingStorageHost=localhost/AccountingStorageHost=<your_control_node_hostname>/g' /etc/slurm/slurm.conf
sed -i 's/AccountingStoragePass=slurm/AccountingStoragePass=password/g' /etc/slurm/slurm.conf

# 启动 Slurm
systemctl enable slurmctld
systemctl start slurmctld

# 配置 Slurm 数据库
systemctl enable slurmdbd
systemctl start slurmdbd
sacctmgr -i add cluster <your_cluster_name>
sacctmgr -i add account <your_account_name>
sacctmgr -i add user <your_username> account=<your_account_name> adminlevel=operator