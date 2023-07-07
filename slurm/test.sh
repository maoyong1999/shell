#!/bin/bash

# Set variables
CONTROL_NODE="m1"
COMPUTE_NODES=("c1" "c2")
CONTROL_NODE_IP="192.168.100.16"
C1_IP="192.168.100.15"
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

# Configure SSH passwordless login
ssh-keygen -t rsa
for node in "${COMPUTE_NODES[@]}"; do
    ssh-copy-id $node
done

# Install and configure Munge
yum install -y epel-release
yum install -y munge munge-libs munge-devel
useradd -r -s /sbin/nologin munge
dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key
for node in "${COMPUTE_NODES[@]}"; do
    scp /etc/munge/munge.key $node:/etc/munge/
done
systemctl enable munge
systemctl start munge

# Install and configure rng-tools
yum install -y rng-tools
systemctl enable rngd
systemctl start rngd

# Test Munge service
munge -n | unmunge | grep STATUS

# Create Slurm user
groupadd -r slurm
useradd -r -g slurm -s /bin/false slurm

# Install Slurm dependencies
yum install -y epel-release
yum install -y gcc gcc-c++ make munge munge-libs munge-devel mariadb-devel mariadb-server openssl-devel pam-devel perl-ExtUtils-MakeMaker perl-Switch readline-devel rpm-build

# Download and install Slurm
wget https://download.schedmd.com/slurm/slurm-20.11.7.tar.bz2
tar -xjf slurm-20.11.7.tar.bz2
cd slurm-20.11.7
./configure --prefix=/usr/local/slurm
make
make install

# Configure Slurm on control node
cp /usr/local/slurm/etc/slurm.conf.example /usr/local/slurm/etc/slurm.conf
vi /usr/local/slurm/etc/slurm.conf
cp /usr/local/slurm/etc/slurmdbd.conf.example /usr/local/slurm/etc/slurmdbd.conf
vi /usr/local/slurm/etc/slurmdbd.conf
chown -R slurm:slurm /usr/local/slurm
chmod 755 /usr/local/slurm
chmod 644 /usr/local/slurm/etc/slurm.conf

# Copy Slurm configuration to compute nodes
for node in "${COMPUTE_NODES[@]}"; do
    scp /usr/local/slurm/etc/slurm.conf $node:/usr/local/slurm/etc/
done

# Configure Slurm accounting on control node
/usr/local/slurm/sbin/slurmdbd
/usr/local/slurm/sbin/slurmctld

# Start Slurm services on control node
systemctl enable slurmdbd
systemctl start slurmdbd
systemctl enable slurmctld
systemctl start slurmctld