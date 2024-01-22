#!/bin/bash

# 创建 Docker Compose 配置文件
cat <<EOF > docker-compose.yml
version: '3'
services:
  dovecot:
    image: dovecot/dovecot
    volumes:
      - ./dovecot:/etc/dovecot
      - /etc/localtime:/etc/localtime:ro
      - dovecot-data:/var/mail
      - /etc/ssl/certs:/etc/ssl/certs:ro
      - /etc/ssl/private:/etc/ssl/private:ro
    ports:
      - "993:993"
    restart: always
  roundcube:
    image: roundcube/roundcubemail
    volumes:
      - ./roundcube:/usr/src/roundcubemail/config
      - /etc/localtime:/etc/localtime:ro
      - /etc/ssl/certs:/etc/ssl/certs:ro
    ports:
      - "80:80"
    restart: always
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: example
      MYSQL_DATABASE: roundcubemail
      MYSQL_USER: roundcube
      MYSQL_PASSWORD: password
    volumes:
      - ./db:/var/lib/mysql
    restart: always
  apache:
    image: httpd:2.4
    volumes:
      - ./apache:/usr/local/apache2/conf
      - ./roundcube:/usr/local/apache2/htdocs/roundcube
      - /etc/ssl/certs:/etc/ssl/certs:ro
      - /etc/ssl/private:/etc/ssl/private:ro
    ports:
      - "443:443"
    restart: always
volumes:
  dovecot-data:
EOF

# 创建 Dovecot 配置文件
mkdir dovecot
cat <<EOF > dovecot/dovecot.conf
# Dovecot configuration file

# Enable SSL/TLS
ssl = required
ssl_cert = </etc/ssl/certs/dovecot.pem
ssl_key = </etc/ssl/private/dovecot.pem

# Enable IMAP protocol
protocols = imap

# Enable authentication
auth_mechanisms = plain login
auth_username_format = %n

# Enable mail location
mail_location = maildir:~/Maildir

# Enable verbose logging
log_path = /var/log/dovecot.log
info_log_path = /var/log/dovecot-info.log
EOF

# 创建 Roundcube 配置文件
mkdir roundcube
cat <<EOF > roundcube/config.inc.php
<?php

// Roundcube configuration file

// Database configuration
\$config['db_dsnw'] = 'mysql://roundcube:password@db/roundcubemail';

// IMAP configuration
\$config['default_host'] = 'ssl://dovecot';
\$config['default_port'] = 993;
\$config['imap_auth_type'] = 'LOGIN';
\$config['imap_delimiter'] = '/';
\$config['imap_ns_personal'] = '';
\$config['imap_ns_other'] = '';
\$config['imap_ns_shared'] = '';
\$config['imap_force_caps'] = true;
\$config['imap_force_lsub'] = true;

// SMTP configuration
\$config['smtp_server'] = 'tls://postfix';
\$config['smtp_port'] = 587;
\$config['smtp_user'] = '%u';
\$config['smtp_pass'] = '%p';
\$config['smtp_auth_type'] = 'LOGIN';
\$config['smtp_helo_host'] = 'localhost';
\$config['smtp_timeout'] = 5;

// Enable verbose logging
\$config['log_driver'] = 'file';
\$config['log_date_format'] = 'Y-m-d H:i:s';
\$config['log_timezone'] = 'UTC';
\$config['log_dir'] = '/var/log/roundcube';
\$config['debug_level'] = 1;
EOF

# 创建 Apache 配置文件
mkdir apache
cat <<EOF > apache/httpd.conf
# Apache configuration file

# Enable SSL/TLS
LoadModule ssl_module modules/mod_ssl.so
Listen 443
<VirtualHost *:443>
  SSLEngine on
  SSLCertificateFile "/etc/ssl/certs/roundcube.pem"
  SSLCertificateKeyFile "/etc/ssl/private/roundcube.pem"
  DocumentRoot "/usr/local/apache2/htdocs/roundcube"
  <Directory "/usr/local/apache2/htdocs/roundcube">
    Options FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
EOF

# 生成 Dovecot 证书
openssl req -new -x509 -nodes -out /etc/ssl/certs/dovecot.pem -keyout /etc/ssl/private/dovecot.pem -days 3650 -subj "/C=US/ST=CA/L=San Francisco/O=My Company/CN=example.com"

# 生成 Roundcube 证书
openssl req -new -x509 -nodes -out /etc/ssl/certs/roundcube.pem -keyout /etc/ssl/private/roundcube.pem -days 3650 -subj "/C=US/ST=CA/L=San Francisco/O=My Company/CN=example.com"

# 启动 Docker Compose
docker-compose up -d