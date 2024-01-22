
mv /etc/yum.repos.d /etc/yum.repos.d.backup
mkdir /etc/yum.repos.d
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
yum clean all && yum makecache
yum update -y
yum install -y yum-utils device-mapper-persistent-data lvm2
# yum install -y docker-ce docker-ce-cli containerd.io docker-compose
yum install -y docker-ce docker-ce-cli containerd.io 
# yum install -y docker-ce
# sudo yum install -y docker-ce
# dnf -y  install docker-ce  docker-ce-cli --nobest
# dnf -y  install docker-ce  docker-ce-cli --nobest --alowerasing
# yum install -y yum-utils
# yum install docker-ce docker-ce-cli containerd.io
# sudo yum install -y --allowerasing docker-ce docker-ce-cli containerd.io docker-compose
# sudo yum install -y --allowerasing docker-ce docker-ce-cli containerd.io
systemctl status docker
systemctl start docker
systemctl status docker
cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://jx9181e6.mirror.aliyuncs.com"]
}
EOF

   systemctl restart docker
   systemctl status docker


   sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo



sudo docker pull trinityctat/infercnv:latest

docker run --rm -it -v `pwd`:`pwd` trinityctat/infercnv:latest bash

cd inferCNV/example   

Rscript ./run.R
 