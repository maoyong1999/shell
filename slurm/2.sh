#!/bin/bash

# Install Munge
yum install -y munge munge-libs munge-devel
systemctl enable munge
systemctl start munge

# Install Slurm
yum install -y epel-release
yum install -y slurm slurm-munge slurm-devel slurm-perlapi

# Configure Slurm
cp /etc/slurm/slurm.conf.example /etc/slurm/slurm.conf
sed -i 's/ControlMachine=slurm/ControlMachine=<your_control_node_hostname>/g' /etc/slurm/slurm.conf
sed -i 's/NodeName=linux NodeAddr=192.168.0.0/NodeName=<your_compute_node_hostname> NodeAddr=<your_compute_node_ip_address>/g' /etc/slurm/slurm.conf
sed -i 's/PartitionName=debug Nodes=linux Default=YES/PartitionName=debug Nodes=<your_compute_node_hostname> Default=YES/g' /etc/slurm/slurm.conf

# Start Slurm
systemctl enable slurmd
systemctl start slurmd