FROM php:8.2-fpm-alpine

ENV GROCY_VERSION=4.5.0

# Install system dependencies and build tools
RUN apk add --no-cache \
    bash \
    git \
    unzip \
    icu-dev \
    libzip-dev \
    zlib-dev \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    sqlite-dev \
    libxml2-dev \
    g++ \
    make \
    autoconf \
    pkgconf

# Fix expected include paths for GD build
RUN ln -s /usr/include/freetype2 /usr/include/freetype \
 && ln -s /usr/include/libpng16 /usr/include/libpng

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) \
    gd \
    pdo \
    pdo_mysql \
    simplexml \
    opcache \
    zip \
    exif \
    intl

# Add Composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Optional config script
COPY scripts/configure_php.sh /usr/local/bin/configure_php.sh
RUN chmod +x /usr/local/bin/configure_php.sh && /usr/local/bin/configure_php.sh

# Set working directory
WORKDIR /var/www/html

# Download specific Grocy version
RUN wget https://github.com/grocy/grocy/releases/download/v${GROCY_VERSION}/grocy_${GROCY_VERSION}.zip \
 && unzip grocy_${GROCY_VERSION}.zip -d . \
 && rm grocy_${GROCY_VERSION}.zip

# Configure Grocy
RUN cp config-dist.php data/config.php \
 && chown -R www-data:www-data data/config.php

# Fix permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php-fpm"]