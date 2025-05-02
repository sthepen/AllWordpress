sudo dnf install certbot python3-certbot-nginx -y
sudo certbot --nginx -d antvnews.online -d www.antvnews.online --email your_email@gmail.com --agree-tos --redirect --non-interactive
sudo nginx -t
sudo systemctl reload nginx
sudo certbot renew --dry-run
