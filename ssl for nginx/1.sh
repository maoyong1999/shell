# Install OpenSSL
sudo yum install openssl -y

# Generate a self-signed SSL certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

# Configure nginx to use SSL
sudo bash -c "cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF"

# Restart nginx
sudo systemctl restart nginx