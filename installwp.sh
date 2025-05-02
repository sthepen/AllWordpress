#!/bin/bash

# --- Cấu hình ---
DOMAIN="yourdomain.com"
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="wppassword"
PHP_VERSION="8.1"

# chạy quyền root 
sudo -i


# --- Cập nhật và cài repo ---
dnf update -y
dnf install epel-release -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
dnf module reset php -y
dnf module enable php:remi-${PHP_VERSION} -y

# --- Cài đặt gói cần thiết ---
dnf install nginx mariadb-server php php-fpm php-mysqlnd php-opcache php-gd php-xml php-mbstring php-curl php-intl php-zip unzip wget firewalld -y

# --- Khởi động dịch vụ ---
systemctl enable --now nginx mariadb php-fpm firewalld

# --- Cấu hình firewall ---
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# --- Tạo database ---
mysql -e "CREATE DATABASE ${DB_NAME};"
mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# --- Tải WordPress ---
cd /tmp
wget https://wordpress.org/latest.zip
unzip latest.zip
cp -r wordpress/* /usr/share/nginx/html/
chown -R nginx:nginx /usr/share/nginx/html
chmod -R 755 /usr/share/nginx/html

# --- Cấu hình wp-config.php ---
cp /usr/share/nginx/html/wp-config-sample.php /usr/share/nginx/html/wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" /usr/share/nginx/html/wp-config.php
sed -i "s/username_here/${DB_USER}/" /usr/share/nginx/html/wp-config.php
sed -i "s/password_here/${DB_PASS}/" /usr/share/nginx/html/wp-config.php

# --- Cấu hình Nginx đơn giản ---
cat > /etc/nginx/conf.d/wordpress.conf <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    root /usr/share/nginx/html;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php-fpm/www.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# --- Khởi động lại Nginx ---
nginx -t && systemctl reload nginx

echo "✅ Cài đặt WordPress hoàn tất. Truy cập server IP để cài đặt qua trình duyệt."
