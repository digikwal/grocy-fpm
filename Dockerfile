FROM php:8.2-fpm-alpine

ENV GROCY_VERSION=4.5.0

# Install runtime dependencies + build tools (as virtual build-deps)
# hadolint ignore=DL3018
RUN apk add --no-cache --virtual .build-deps \
    g++ \
    make \
    autoconf \
    pkgconf \
    icu-dev \
    libzip-dev \
    zlib-dev \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    sqlite-dev \
    libxml2-dev \
 && apk add --no-cache \
    unzip \
    wget

# Fix include paths for GD (required for PHP build)
RUN ln -s /usr/include/freetype2 /usr/include/freetype \
 && ln -s /usr/include/libpng16 /usr/include/libpng

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" \  # SC2046: quote $(nproc)
    gd \
    pdo \
    pdo_mysql \
    simplexml \
    opcache \
    zip \
    exif \
    intl \
 && apk del .build-deps

# Add Composer from official Composer image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Optional config script
COPY scripts/configure_php.sh /usr/local/bin/configure_php.sh
RUN chmod +x /usr/local/bin/configure_php.sh && /usr/local/bin/configure_php.sh

# Set working directory
WORKDIR /var/www/html

# Download and extract Grocy
RUN wget --progress=dot:giga https://github.com/grocy/grocy/releases/download/v${GROCY_VERSION}/grocy_${GROCY_VERSION}.zip \
 && unzip grocy_${GROCY_VERSION}.zip -d . \
 && rm grocy_${GROCY_VERSION}.zip

# Configure Grocy
RUN cp config-dist.php data/config.php \
 && chown -R www-data:www-data data/config.php

# Fix ownership of all files
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php-fpm"]
