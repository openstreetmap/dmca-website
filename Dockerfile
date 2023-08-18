FROM docker.io/library/php:7-apache

# Use port 8080
RUN sed -i "s/80/8080/g" /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

# Install composer requirements
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    && docker-php-ext-install zip \
    && rm -rf /var/lib/apt/lists/*

# Install composer
COPY --from=docker.io/library/composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html/
ADD . /var/www/html/

# Add user
RUN groupadd -r user && useradd -m -r -g user user
RUN mkdir -p /var/www/html/vendor && chown user:user /var/www/html/vendor
USER user

# Install composer dependencies
RUN composer install --no-dev --no-cache --no-interaction --no-progress --optimize-autoloader

# Basic Linting
RUN php -l index.php

CMD ["docker-php-entrypoint", "apache2-foreground"]
