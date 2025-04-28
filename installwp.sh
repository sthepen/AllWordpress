#!/bin/bash

# Cập nhật hệ thống
sudo dnf update -y

# Cài đặt Apache, MariaDB, PHP và các extensions cần thiết
sudo dnf install httpd mariadb-server mariadb php php-mysqlnd php-fpm php-xml php-mbstring php-zip php-curl php-gd wget unzip -y

# Khởi động MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Cấu hình cơ sở dữ liệu
sudo mysql -u root -e "CREATE DATABASE wordpress_db;"
sudo mysql -u root -e "CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY '@Nokia123123';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# Tải và cài đặt WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
cp -r wordpress/* /var/www/html/

# Cấu hình wp-config.php
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/wordpress_db/" /var/www/html/wp-config.php
sed -i "s/username_here/wordpress_user/" /var/www/html/wp-config.php
sed -i "s/password_here/your_password/" /var/www/html/wp-config.php

# Đảm bảo quyền truy cập thư mục
sudo chown -R apache:apache /var/www/html/*

# Cấu hình Apache
sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# Mở port HTTP và HTTPS
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=https --permanent
sudo firewall-cmd --reload

# Khởi động Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Hoàn thành cài đặt
echo "Cài đặt WordPress hoàn tất. Vui lòng truy cập http://your-server-ip để tiếp tục."
