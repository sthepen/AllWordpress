sudo dnf update -y
sudo dnf install wget -y
wget https://github.com/sthepen/AllWordpress/blob/main/installwp.sh 
chmod +x installwp.sh
./installwp.sh
  =================================================================
  wget https://github.com/sthepen/AllWordpress/blob/main/ssl.sh
chmod +x ssl.sh
./ssl.sh

========================================================================
fix lỗi không chạy plugin được 
sudo chown -R apache:apache /usr/share/nginx/html
sudo chmod -R 755 /usr/share/nginx/html
sudo mkdir -p /usr/share/nginx/html/wp-content/upgrade
sudo chown -R apache:apache /usr/share/nginx/html/wp-content/upgrade
sudo chmod -R 755 /usr/share/nginx/html/wp-content/upgrade
sudo setenforce 0
sudo chcon -R -t httpd_sys_rw_content_t /usr/share/nginx/html
sudo systemctl restart php-fpm
sudo systemctl restart nginx
