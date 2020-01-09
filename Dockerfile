FROM debian:buster
MAINTAINER Noel van Veldhuisen <novan-ve@student.codam.nl>
COPY srcs/nginx-conf ./tmp/
COPY srcs/config.inc.php ./tmp/
COPY srcs/phpmyadmin.sql ./tmp/
COPY srcs/wordpress.tar.gz ./tmp/
COPY srcs/index.sh ./
COPY srcs/start.sh ./
CMD bash start.sh && tail -f /dev/null
