# Edit the nginx configuration file
sudo nano /etc/nginx/conf.d/web.conf

# Add the following lines to the server block
server {
    listen 80;
    server_name web;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

# Save and exit the file

# Restart nginx to apply the changes
sudo systemctl restart nginx