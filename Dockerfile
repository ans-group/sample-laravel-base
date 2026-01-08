FROM php:8.4-fpm AS builder

ARG USER_ID=1000
ARG GROUP_ID=1000

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

RUN pecl install redis-6.3.0 \
  && docker-php-ext-enable redis

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN groupadd -f -g ${GROUP_ID} laravel && \
  useradd -o -u ${USER_ID} -g laravel -m -s /bin/bash laravel 2>/dev/null || \
  usermod -u ${USER_ID} -g ${GROUP_ID} laravel

WORKDIR /var/www/html

COPY --chown=laravel:laravel composer.json composer.lock ./

USER laravel

RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

COPY --chown=laravel:laravel . .

RUN composer dump-autoload --optimize --classmap-authoritative

FROM php:8.4-fpm AS runtime

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apt-get update && apt-get install -y \
  libicu-dev \
  libzip-dev \
  libpng-dev \
  libjpeg-dev \
  libfreetype6-dev \
  unzip \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-20240924/ /usr/local/lib/php/extensions/no-debug-non-zts-20240924/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

COPY --from=builder /usr/bin/composer /usr/bin/composer

RUN groupadd -f -g ${GROUP_ID} laravel && \
  useradd -o -u ${USER_ID} -g laravel -m -s /bin/bash laravel 2>/dev/null || \
  usermod -u ${USER_ID} -g ${GROUP_ID} laravel

RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /usr/local/etc/php-fpm.d/www.conf && \
  sed -i 's/user = www-data/user = laravel/g' /usr/local/etc/php-fpm.d/www.conf && \
  sed -i 's/group = www-data/group = laravel/g' /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

COPY --from=builder --chown=laravel:laravel /var/www/html /var/www/html

USER laravel

EXPOSE 9000

CMD ["php-fpm"]
