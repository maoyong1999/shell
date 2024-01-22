#!/bin/bash

# Set variables
CONTROL_NODE="m1"
COMPUTE_NODES=("c1" "c2")
CONTROL_NODE_IP="192.168.100.15"
C1_IP="192.168.100.16"
C2_IP="192.168.100.17"

# Configure hosts file on control node
echo "$CONTROL_NODE_IP $CONTROL_NODE" >> /etc/hosts
echo "$C1_IP c1" >> /etc/hosts
echo "$C2_IP c2" >> /etc/hosts

# Configure hosts file on compute nodes
for node in "${COMPUTE_NODES[@]}"; do
    ssh $node "echo '$CONTROL_NODE_IP $CONTROL_NODE' >> /etc/hosts"
    ssh $node "echo '$C1_IP c1' >> /etc/hosts"
    ssh $node "echo '$C2_IP c2' >> /etc/hosts"
done

# Set limits for all users
echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* hard nofile 65535" >> /etc/security/limits.conf
echo "* soft nproc 65535" >> /etc/security/limits.conf
echo "* hard nproc 65535" >> /etc/security/limits.conf

# Set limits for specific user
echo "james soft nofile 65535" >> /etc/security/limits.conf
echo "james hard nofile 65535" >> /etc/security/limits.conf
echo "james soft nproc 65535" >> /etc/security/limits.conf
echo "james hard nproc 65535" >> /etc/security/limits.conf

# Set hostname
hostnamectl set-hostname m1

# Install and configure NFS
yum install -y nfs-utils
systemctl enable nfs-server
systemctl start nfs-server

# Create NFS directory
mkdir /nfs
chmod 777 /nfs

# Add NFS share to /etc/exports
echo "/nfs *(rw,sync,no_root_squash)" >> /etc/exports

# Restart NFS service
systemctl restart nfs-server

# Configure SSH passwordless login
ssh-keygen -t rsa
ssh-copy-id c1
ssh-copy-id c2


# Install Munge
yum install -y munge munge-libs munge-devel

# Set UID and GID for Munge user
MUNGE_UID=991
MUNGE_GID=991

# Create Munge user
groupadd -g $MUNGE_GID munge
useradd -u $MUNGE_UID -g $MUNGE_GID -s /sbin/nologin munge

# Install rng-tools
yum install -y rng-tools

# Configure rngd service
echo 'HRNGDEVICE=/dev/urandom' >> /etc/sysconfig/rngd
echo 'RNGDOPTIONS="-W 2048 -r /dev/random -o /dev/random"' >> /etc/sysconfig/rngd

# Start rngd service
systemctl enable rngd
systemctl start rngd

# Generate Munge key
dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key

# Copy Munge key to Compute Nodes
for node in c1 c2; do
    ssh $node mkdir /etc/munge/
    scp /etc/munge/munge.key $node:/etc/munge/munge.key
    ssh $node chown munge:munge /etc/munge/munge.key
    ssh $node chmod 400 /etc/munge/munge.key
done

# Start Munge service
systemctl enable munge
systemctl start munge

# Set UID and GID for Slurm user
SLURM_UID=995
SLURM_GID=995

# Create Slurm user
groupadd -g $SLURM_GID slurm
useradd -u $SLURM_UID -g $SLURM_GID -s /bin/false slurm

# Copy Slurm user to Compute Nodes
for node in c1 c2; do
    ssh $node groupadd -g $SLURM_GID slurm
    ssh $node useradd -u $SLURM_UID -g $SLURM_GID -s /bin/false slurm
done

# Install Slurm
yum install -y epel-release
yum install -y slurm slurm-munge slurm-devel slurm-perlapi

# Configure Slurm
cp /etc/slurm/slurm.conf.example /etc/slurm/slurm.conf
sed -i 's/ControlMachine=slurm/ControlMachine=m1/g' /etc/slurm/slurm.conf
sed -i 's/NodeName=linux NodeAddr=192.168.0.0/NodeName=c1 NodeAddr=192.168.100.10/g' /etc/slurm/slurm.conf
sed -i 's/PartitionName=debug Nodes=linux Default=YES/PartitionName=debug Nodes=c1,c2 Default=YES/g' /etc/slurm/slurm.conf
scp /etc/slurm/slurm.conf c1:/etc/slurm/slurm.conf
scp /etc/slurm/slurm.conf c2:/etc/slurm/slurm.conf
chown slurm:slurm /etc/slurm/slurm.conf
chmod 644 /etc/slurm/slurm.conf

# Configure Slurm Accounting
cp /etc/slurm/slurmdbd.conf.example /etc/slurm/slurmdbd.conf
sed -i 's/DbdAddr=localhost/DbdAddr=m1/g' /etc/slurm/slurmdbd.conf
sed -i 's/StorageHost=localhost/StorageHost=m1/g' /etc/slurm/slurmdbd.conf
sed -i 's/StoragePass=slurm/StoragePass=mysql1234/g' /etc/slurm/slurmdbd.conf
sed -i 's/StorageUser=slurm/StorageUser=root/g' /etc/slurm/slurmdbd.conf
sed -i 's/StoragePort=6819/StoragePort=3306/g' /etc/slurm/slurmdbd.conf

# Copy Slurm configuration file to compute nodes
for node in "${COMPUTE_NODES[@]}"; do
    ssh $node mkdir /etc/slurm/
    scp /etc/slurm/slurm.conf $node:/etc/slurm/
done

# Copy Slurm Accounting to Compute Nodes
scp /etc/slurm/slurmdbd.conf c1:/etc/slurm/slurmdbd.conf
scp /etc/slurm/slurmdbd.conf c2:/etc/slurm/slurmdbd.conf
chown slurm:slurm /etc/slurm/slurmdbd.conf
chmod 644 /etc/slurm/slurmdbd.conf

# Set permissions for Slurm configuration file
chown slurm:slurm /etc/slurm/slurm.conf
chmod 644 /etc/slurm/slurm.conf

# Set permissions for Slurm Accounting configuration file
chown slurm:slurm /etc/slurm/slurmdbd.conf
chmod 644 /etc/slurm/slurmdbd.conf

# Set permissions for Slurm state save directory
chown slurm:slurm /var/spool/slurm
chmod 755 /var/spool/slurm

# Set permissions for Slurm state save directory on compute nodes
for node in "${COMPUTE_NODES[@]}"; do
    ssh $node chown slurm:slurm /var/spool/slurm
    ssh $node chmod 755 /var/spool/slurm
done

# Set permissions for Slurm log directory
chown slurm:slurm /var/log/slurm
chmod 755 /var/log/slurm

# Set permissions for Slurm log directory on compute nodes
for node in "${COMPUTE_NODES[@]}"; do
    ssh $node chown slurm:slurm /var/log/slurm
    ssh $node chmod 755 /var/log/slurm
done

# Set password for Slurm user
echo "mysql1234" | passwd --stdin slurm

# Create Slurm database

# Install MariaDB
yum install -y mariadb-server mariadb

# Start MariaDB
systemctl enable mariadb
systemctl start mariadb

# Configure MariaDB
mysql -u root -e "CREATE DATABASE slurm_acct_db;"
mysql -u root -e "CREATE USER 'slurm'@'localhost';"

# Grant privileges to Slurm user
mysql -u root -e "GRANT ALL ON slurm_acct_db.* TO 'slurm'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Create Slurm database
mysql -u root slurm_acct_db < /usr/share/doc/slurmdbd/mysql.sql

# Start Slurm Accounting
systemctl enable slurmdbd
systemctl start slurmdbd


# Start Slurm
systemctl enable slurmd
systemctl start slurmd
systemctl enable slurmctld
systemctl start slurmctld