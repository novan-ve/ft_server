FROM debian:buster
MAINTAINER Noel van Veldhuisen <novan-ve@student.codam.nl>
COPY srcs/nginx-conf ./tmp/
COPY srcs/config.inc.php ./tmp/
COPY srcs/phpmyadmin.sql ./tmp/
COPY srcs/mkcert ./root/
COPY srcs/wp-cli.phar ./tmp/
COPY srcs/wordpress.tar.gz ./tmp/
COPY srcs/index.sh ./
RUN apt-get -y update
RUN apt-get -y install wget mariadb-server php php-fpm php-mbstring php-mysql php-gd nginx
RUN cp /tmp/nginx-conf /etc/nginx/sites-available/default && \
	chmod +x /root/mkcert && \
	./root/mkcert -install && \
	./root/mkcert localhost && \
	mv /localhost.pem /etc/ssl/certs/ && \
	mv /localhost-key.pem /etc/ssl/private/ && \
	nginx -t
RUN	service mysql start && \
	echo "create user 'novanve'@'localhost' identified by 'wachtwoord'" | mysql -u root && \
	echo "create database wordpress;" | mysql -u root && \
	echo "create database phpmyadmin;" | mysql -u root  && \
	echo "grant all privileges on *.* to novanve@localhost;" | mysql -u root && \
	echo "flush privileges;" | mysql -u root && \
	mysql phpmyadmin -u root < /tmp/phpmyadmin.sql
RUN wget -nv https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-all-languages.tar.gz && \
	mkdir /var/www/html/phpmyadmin/ && \
	tar xzf phpMyAdmin-5.0.1-all-languages.tar.gz --strip-components=1 -C /var/www/html/phpmyadmin && \
	cp /tmp/config.inc.php /var/www/html/phpmyadmin/ && \
	mkdir /var/www/html/phpmyadmin/tmp
RUN tar xzf /tmp/wordpress.tar.gz -C /var/www/html && \
	chmod +x /tmp/wp-cli.phar && \
	mv /tmp/wp-cli.phar /usr/local/bin/wp && \
	service mysql restart && \
	wp core install --allow-root --url=localhost --path=/var/www/html/ --title=ft_server --admin_user=novanve \ 
	--admin_password=wachtwoord --admin_email=novan-ve@student.codam.nl && \
	rm -rf /tmp/* /root/mkcert /phpMyAdmin-5.0.1-all-languages.tar.gz /var/www/html/index.nginx-debian.html && \
	chown -R www-data:www-data /var/www/*
RUN chmod +x /index.sh
CMD service mysql restart && service php7.3-fpm start && nginx -g 'daemon off;'
