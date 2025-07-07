#!/bin/sh

PHP_FPM_USER="www-data"
PHP_FPM_GROUP="www-data"
PHP_FPM_LISTEN_MODE="0660"
PHP_MEMORY_LIMIT="512M"
PHP_MAX_UPLOAD="50M"
PHP_MAX_FILE_UPLOAD="200"
PHP_MAX_POST="100M"
PHP_DISPLAY_ERRORS="On"
PHP_DISPLAY_STARTUP_ERRORS="On"
PHP_ERROR_REPORTING="E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR"
PHP_CGI_FIX_PATHINFO=0

FPM_CONF="/usr/local/etc/php-fpm.d/www.conf"
PHP_INI="/usr/local/etc/php/php.ini"

# Configure php-fpm
sed -i "s|;listen.owner\s*=.*|listen.owner = ${PHP_FPM_USER}|g" $FPM_CONF
sed -i "s|;listen.group\s*=.*|listen.group = ${PHP_FPM_GROUP}|g" $FPM_CONF
sed -i "s|;listen.mode\s*=.*|listen.mode = ${PHP_FPM_LISTEN_MODE}|g" $FPM_CONF
sed -i "s|user\s*=.*|user = ${PHP_FPM_USER}|g" $FPM_CONF
sed -i "s|group\s*=.*|group = ${PHP_FPM_GROUP}|g" $FPM_CONF
sed -i "s|;log_level\s*=.*|log_level = notice|g" $FPM_CONF

# Configure php.ini
sed -i "s|display_errors\s*=.*|display_errors = ${PHP_DISPLAY_ERRORS}|i" $PHP_INI
sed -i "s|display_startup_errors\s*=.*|display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}|i" $PHP_INI
sed -i "s|error_reporting\s*=.*|error_reporting = ${PHP_ERROR_REPORTING}|i" $PHP_INI
sed -i "s|;*memory_limit\s*=.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" $PHP_INI
sed -i "s|;*upload_max_filesize\s*=.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|i" $PHP_INI
sed -i "s|;*max_file_uploads\s*=.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" $PHP_INI
sed -i "s|;*post_max_size\s*=.*|post_max_size = ${PHP_MAX_POST}|i" $PHP_INI
sed -i "s|;*cgi.fix_pathinfo\s*=.*|cgi.fix_pathinfo = ${PHP_CGI_FIX_PATHINFO}|i" $PHP_INI

# Enable useful extensions manually if not already loaded
echo "extension=fileinfo" >> $PHP_INI
echo "extension=gd" >> $PHP_INI
echo "extension=pdo_sqlite" >> $PHP_INI
echo "extension=sqlite3" >> $PHP_INI