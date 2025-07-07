FROM php:8.2-fpm-alpine

ENV GROCY_VERSION=4.5.0

# Install required Alpine packages
RUN apk add --no-cache \
    unzip \
    icu-dev \
    libzip-dev \
    oniguruma-dev \
    zlib-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    curl \
    bash \
    git \
    g++ \
    make \
    autoconf

# Configure and install PHP extensions (GD has special flags)
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
 && docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_sqlite \
    mbstring \
    simplexml \
    ctype \
    tokenizer \
    dom \
    fileinfo \
    opcache \
    xml \
    zip \
    exif \
    intl \
    gd \
    session

# Add Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Run PHP configuration script
COPY scripts/configure_php.sh /usr/local/bin/configure_php.sh
RUN chmod +x /usr/local/bin/configure_php.sh && /usr/local/bin/configure_php.sh

# Set working directory
WORKDIR /var/www/html

# Download specific Grocy version
RUN curl -L -o grocy.zip https://github.com/grocy/grocy/releases/download/v${GROCY_VERSION}/grocy_${GROCY_VERSION}.zip && \
    unzip grocy.zip -d . && \
    rm grocy.zip

# Initial config
RUN cp config-dist.php data/config.php && \
    chown -R www-data:www-data data/config.php

# Fix permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php-fpm"]
