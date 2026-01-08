# ============================================================================
# Build Stage: Install dependencies and build tools
# ============================================================================
FROM php:8.4-fpm AS builder

# Accept build arguments for user/group IDs
ARG USER_ID=1000
ARG GROUP_ID=1000

# Install system dependencies (build tools included)
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
RUN pecl install redis-6.3.0 \
  && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Create laravel user for build
RUN groupadd -f -g ${GROUP_ID} laravel && \
  useradd -o -u ${USER_ID} -g laravel -m -s /bin/bash laravel 2>/dev/null || \
  usermod -u ${USER_ID} -g ${GROUP_ID} laravel

# Set working directory
WORKDIR /var/www/html

# Copy composer files first (better layer caching)
COPY --chown=laravel:laravel composer.json composer.lock ./

# Switch to laravel user for composer install
USER laravel

# Install PHP dependencies (no dev dependencies for production)
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copy application code
COPY --chown=laravel:laravel . .

# Generate optimized autoloader
RUN composer dump-autoload --optimize --classmap-authoritative

# ============================================================================
# Runtime Stage: Minimal production image
# ============================================================================
FROM php:8.4-fpm AS runtime

# Accept build arguments for user/group IDs
ARG USER_ID=1000
ARG GROUP_ID=1000

# Install only runtime system dependencies (matching builder versions)
RUN apt-get update && apt-get install -y \
  libicu-dev \
  libzip-dev \
  libpng-dev \
  libjpeg-dev \
  libfreetype6-dev \
  unzip \
  && rm -rf /var/lib/apt/lists/*

# Copy PHP extensions from builder
COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-20240924/ /usr/local/lib/php/extensions/no-debug-non-zts-20240924/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Copy Composer from builder
COPY --from=builder /usr/bin/composer /usr/bin/composer

# Create user with same UID/GID as host user
RUN groupadd -f -g ${GROUP_ID} laravel && \
  useradd -o -u ${USER_ID} -g laravel -m -s /bin/bash laravel 2>/dev/null || \
  usermod -u ${USER_ID} -g ${GROUP_ID} laravel

# Configure PHP-FPM to listen on port 9000 and run as laravel user
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /usr/local/etc/php-fpm.d/www.conf && \
  sed -i 's/user = www-data/user = laravel/g' /usr/local/etc/php-fpm.d/www.conf && \
  sed -i 's/group = www-data/group = laravel/g' /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www/html

# Copy application from builder (with optimized vendor)
COPY --from=builder --chown=laravel:laravel /var/www/html /var/www/html

# Switch to non-root user
USER laravel

EXPOSE 9000

CMD ["php-fpm"]
