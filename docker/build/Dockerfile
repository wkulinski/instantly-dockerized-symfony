FROM php:7.2-fpm-alpine3.7
ARG TIMEZONE

RUN apk add --update \
    openssl \
    git \
    unzip \
    curl \
    make \
    nano \
    autoconf \
    g++ \
    gcc \
    php7-pdo \
    php7-fpm \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-gd \
    php7-iconv \
    php7-json \
    php7-intl \
    php7-mcrypt \
    php7-mbstring \
    php7-opcache \
    php7-pgsql \
    php7-xml \
    php7-phar \
    php7-tokenizer \
    php7-session \
    php7-redis \
    php7-soap \
    php7-dom \
    php7-xmlreader \
    php7-openssl \
    php7-bcmath \
    php7-ctype \
    php7-imagick \
    php7-zlib

# https://github.com/docker-library/php/issues/221
RUN set -ex \
  && apk --no-cache add \
    postgresql-dev

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini
RUN "date"

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pdo pgsql pdo_pgsql
RUN docker-php-ext-install mbstring

ADD symfony.pool.conf /etc/php7/php-fpm.d/

# install xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_startup_errors = Off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_errors = Off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN COMPOSER_ALLOW_SUPERUSER=1 composer --version

CMD ["php-fpm7", "-F"]

WORKDIR /var/www/symfony

COPY --chown=www-data:www-data . .

RUN rm -Rf var/cache/*
RUN rm -Rf var/log/*

EXPOSE 9000

