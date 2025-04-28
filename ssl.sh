#!/bin/bash

# Cập nhật hệ thống
echo "Cập nhật hệ thống..."
sudo dnf update -y

# Cài đặt EPEL repository (nếu chưa cài)
echo "Cài đặt EPEL repository..."
sudo dnf install epel-release -y

# Cài đặt certbot và plugin Apache
echo "Cài đặt Certbot và plugin Apache..."
sudo dnf install certbot python3-certbot-apache -y

# Kiểm tra cài đặt Apache
echo "Kiểm tra Apache..."
sudo systemctl status httpd || sudo systemctl start httpd

# Tạo chứng chỉ SSL cho tên miền 'antvnews.online'
echo "Cài đặt SSL cho Apache cho tên miền antvnews.online..."
sudo certbot --apache --agree-tos --no-eff-email --email your-email@example.com -d antvnews.online

# Kiểm tra chứng chỉ SSL
echo "Kiểm tra chứng chỉ SSL..."
sudo certbot certificates

# Cập nhật cấu hình Apache với chứng chỉ SSL của Let's Encrypt
echo "Cập nhật cấu hình Apache với chứng chỉ Let's Encrypt..."
sudo sed -i 's|SSLCertificateFile /etc/pki/tls/certs/localhost.crt|SSLCertificateFile /etc/letsencrypt/live/antvnews.online/fullchain.pem|' /etc/httpd/conf.d/ssl.conf
sudo sed -i 's|SSLCertificateKeyFile /etc/pki/tls/private/localhost.key|SSLCertificateKeyFile /etc/letsencrypt/live/antvnews.online/privkey.pem|' /etc/httpd/conf.d/ssl.conf
sudo sed -i 's|#SSLCertificateChainFile /etc/pki/tls/certs/chain.pem|SSLCertificateChainFile /etc/letsencrypt/live/antvnews.online/chain.pem|' /etc/httpd/conf.d/ssl.conf

# Kiểm tra lại cấu hình Apache
echo "Kiểm tra cấu hình Apache..."
sudo apachectl configtest

# Khởi động lại Apache
echo "Khởi động lại Apache..."
sudo systemctl restart httpd

# Cấu hình cron job để tự động gia hạn chứng chỉ SSL
echo "Cấu hình tự động gia hạn SSL..."
(crontab -l 2>/dev/null; echo "0 0 * * * certbot renew --quiet && systemctl reload httpd") | sudo crontab -

# Thông báo cài đặt hoàn tất
echo "Cài đặt SSL hoàn tất. SSL đã được cấu hình và tự động gia hạn."

# Kiểm tra trạng thái cron job
echo "Kiểm tra cron job tự động gia hạn SSL..."
sudo systemctl list-timers | grep certbot
