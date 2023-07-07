#!/bin/bash

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
systemctl enable slurmdbd
systemctl start slurmdbd

# Start Slurm
systemctl enable slurmd
systemctl start slurmd
systemctl enable slurmctld
systemctl start slurmctld