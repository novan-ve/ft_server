apt-get -y update
apt-get -y install wget mariadb-server php php-fpm php-mbstring php-mysql nginx
cp /tmp/nginx-conf /etc/nginx/sites-available/default
wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 -P /root/mkcert
chmod +x /root/mkcert/mkcert-v1.4.1-linux-amd64
./root/mkcert/mkcert-v1.4.1-linux-amd64 -install
./root/mkcert/mkcert-v1.4.1-linux-amd64 localhost
mv /localhost.pem /etc/ssl/certs/
mv /localhost-key.pem /etc/ssl/private/
nginx -t
service mysql start
echo "SET PASSWORD FOR root@localhost = PASSWORD('wachtwoord');" | mysql -u root
echo "create database wordpress;" | mysql -u root --password=wachtwoord
echo "grant all privileges on wordpress.* to root@localhost;" | mysql -u root --password=wachtwoord
echo "flush privileges;" | mysql -u root --password=wachtwoord
echo "create database phpmyadmin;" | mysql -u root --password=wachtwoord
echo "grant all privileges on phpmyadmin.* to root@localhost;" | mysql -u root --password=wachtwoord
echo "flush privileges;" | mysql -u root --password=wachtwoord
mysql phpmyadmin -u root --password=wachtwoord < /tmp/phpmyadmin.sql
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-all-languages.tar.gz
mkdir /var/www/html/phpmyadmin
tar xzf phpMyAdmin-5.0.1-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin
cp /tmp/config.inc.php /var/www/html/phpmyadmin/
mkdir /var/www/html/phpmyadmin/tmp
chmod 777 /var/www/html/phpmyadmin/tmp
rm /var/www/html/index.nginx-debian.html
tar xzf /tmp/wordpress.tar.gz -C /var/www/html
rm -rf /tmp/* /root/mkcert
service mysql restart
service php7.3-fpm start
service nginx restart
