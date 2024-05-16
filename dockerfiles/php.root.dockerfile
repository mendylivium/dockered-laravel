FROM php:8.2.12-fpm-alpine3.18

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN sed -i "s/user = www-data/user = root/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = root/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN docker-php-ext-install pdo pdo_mysql bcmath

# RUN mkdir -p /usr/src/php/ext/bolt
# COPY ./php/bolt.so /usr/src/php/ext/bolt
# # RUN echo 'extension=bolt.so' > /usr/local/etc/php/conf.d/bolt.ini
# RUN echo 'bolt' >> /usr/src/php-available-exts \
#     && docker-php-ext-install bolt

COPY ./php/bolt.so /usr/local/etc/php/ext/bolt.so
RUN echo "extension='/usr/local/etc/php/ext/bolt.so'" >> /usr/local/etc/php/conf.d/docker-php-ext-bolt.ini

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis 

RUN apk add icu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl

USER root

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]