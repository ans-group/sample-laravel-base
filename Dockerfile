FROM php:8.4-fpm AS base

# Install system dependencies
RUN apt-get update && apt-get install -y \
  zlib1g-dev \
  libicu-dev \
  libzip-dev \
  libpng-dev \
  libjpeg-dev \
  libfreetype6-dev \
  g++ \
  unzip \
  git \
  && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) \
  pdo_mysql \
  mysqli \
  opcache \
  pcntl \
  intl \
  zip \
  gd \
  bcmath

# Install Redis extension
RUN pecl install redis \
  && docker-php-ext-enable redis

# Install Xdebug
RUN pecl install xdebug \
  && docker-php-ext-enable xdebug

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

#RUN composer install


# Configure PHP-FPM
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /usr/local/etc/php-fpm.d/www.conf

EXPOSE 9000

CMD ["php-fpm"]
