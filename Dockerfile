FROM debian:buster
MAINTAINER Noel van Veldhuisen <novan-ve@student.codam.nl>
COPY srcs/nginx-conf ./tmp/
COPY srcs/config.inc.php ./tmp/
COPY srcs/phpmyadmin.sql ./tmp/
COPY srcs/mkcert ./root/
COPY srcs/wp-cli.phar ./tmp/
COPY srcs/wordpress.tar.gz ./tmp/
COPY srcs/index.sh ./
RUN apt-get -y update && \
	apt-get -y install wget php php-fpm php-mbstring php-mysql php-gd nginx lsb-release gnupg && \
	cp /tmp/nginx-conf /etc/nginx/sites-available/default && \
	chmod +x /root/mkcert && \
	./root/mkcert -install && \
	./root/mkcert localhost && \
	mv /localhost.pem /etc/ssl/certs/ && \
	mv /localhost-key.pem /etc/ssl/private/ && \
	nginx -t && \
	wget https://dev.mysql.com/get/mysql-apt-config_0.8.9-1_all.deb && \
	DEBIAN_FRONTEND=noninteractive dpkg -i /mysql-apt-config* && \
	apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5 && \
	echo "mysql-community-server mysql-community-server/root-pass password wachtwoord" | debconf-set-selections && \
	echo "mysql-community-server mysql-community-server/re-root-pass password wachtwoord" | debconf-set-selections && \
	apt-get update && \
	apt-get install -y mysql-server && \
	service mysql start && \
	mysql -u root --password=wachtwoord -e "create database wordpress;" && \
	mysql -u root --password=wachtwoord -e "create database phpmyadmin;" && \
	mysql -u root --password=wachtwoord -e "grant all privileges on *.* to root@localhost;" && \
	mysql -u root --password=wachtwoord -e "flush privileges;" && \
	mysql phpmyadmin -u root --password=wachtwoord < /tmp/phpmyadmin.sql && \
	service mysql stop && \
	wget -nv https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-all-languages.tar.gz && \
	mkdir /var/www/html/phpmyadmin/ && \
	tar xzf phpMyAdmin-5.0.1-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin && \
	cp /tmp/config.inc.php /var/www/html/phpmyadmin/ && \
	mkdir /var/www/html/phpmyadmin/tmp && \
	tar xzf /tmp/wordpress.tar.gz -C /var/www/html && \
	chmod +x /tmp/wp-cli.phar && \
	mv /tmp/wp-cli.phar /usr/local/bin/wp && \
	service mysql restart && \
	wp core install --allow-root --url=localhost --path=/var/www/html/ --title=ft_server --admin_user=root --admin_password=wachtwoord \ 
	--admin_email=novan-ve@student.codam.nl --skip-email && \
	rm -rf /tmp/* /root/mkcert /phpMyAdmin-5.0.1-all-languages.tar.gz /var/www/html/index.nginx-debian.html && \
	chown -R www-data:www-data /var/www/* && \
	chmod +x /index.sh
CMD	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && service mysql restart && service php7.3-fpm start && service nginx start && tail -f /dev/null
