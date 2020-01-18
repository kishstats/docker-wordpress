FROM phpdockerio/php72-fpm:latest
WORKDIR "/application"

RUN apt-get update -y && \
    apt-get -y install vim && \
    apt-get -y install php7.2 php7.2-fpm php7.2-mysql php-common php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-mbstring php7.2-xml php7.2-gd php7.2-curl php7.2-imagick libapache2-mod-php7.2 -y && \
    apt-get clean
