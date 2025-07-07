FROM php:8.2-fpm-alpine

ENV GROCY_VERSION=4.5.0

# Install build dependencies and libs
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

# Link expected paths (needed for gd extension build)
RUN ln -s /usr/include/freetype2 /usr/include/freetype \
 && ln -s /usr/include/libpng16 /usr/include/libpng

# Configure and install PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
 && docker-php-ext-install -j$(nproc) \
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

# Optional configure script
COPY scripts/configure_php.sh /usr/local/bin/configure_php.sh
RUN chmod +x /usr/local/bin/configure_php.sh && /usr/local/bin/configure_php.sh

# Download Grocy
WORKDIR /var/www/html

RUN curl -L -o grocy.zip https://github.com/grocy/grocy/releases/download/v${GROCY_VERSION}/grocy_${GROCY_VERSION}.zip \
 && unzip grocy.zip -d . \
 && rm grocy.zip

RUN cp config-dist.php data/config.php \
 && chown -R www-data:www-data data/config.php

RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000
CMD ["php-fpm"]
