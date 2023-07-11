#!/bin/bash

# 安装keepalived
yum install -y keepalived

# 配置keepalived
cat <<EOF > /etc/keepalived/keepalived.conf
vrrp_script chk_nginx {
    script "/usr/bin/pgrep nginx"
    interval 2
}

vrrp_instance VI_1 {
    state MASTER
    interface ens224
    virtual_router_id 51
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.100.100
    }
    track_script {
        chk_nginx
    }
}
EOF

# 启动keepalived
systemctl enable keepalived
systemctl start keepalived