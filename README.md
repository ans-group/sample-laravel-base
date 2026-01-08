# sample-laravel-base
A sample of a base install of Laravel

## Environment Stack
- **NGINX**: Latest (Web Server)
- **PHP**: 8.4-FPM
- **MySQL**: 8.0
- **Redis**: 7 Alpine

## Quick Start

1. **Build and start the containers:**
   ```bash
   docker-compose up -d --build
   ```

2. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

3. **Install Laravel dependencies (if needed):**
   ```bash
   docker-compose exec app composer install
   ```

4. **Generate application key:**
   ```bash
   docker-compose exec app php artisan key:generate
   ```

5. **Run migrations:**
   ```bash
   docker-compose exec app php artisan migrate
   ```

## Services Access

- **Application**: http://localhost
- **MySQL**: localhost:3306
  - Database: `laravel`
  - Username: `laravel`
  - Password: `secret`
  - Root Password: `root`
- **Redis**: localhost:6379

## Useful Commands

```bash
# Stop containers
docker-compose down

# View logs
docker-compose logs -f

# Access PHP container
docker-compose exec app bash

# Access MySQL
docker-compose exec mysql mysql -u laravel -psecret laravel

# Access Redis CLI
docker-compose exec redis redis-cli

# Run artisan commands
docker-compose exec app php artisan [command]

# Run tests
docker-compose exec app php artisan test
```

## Directory Structure

```
.docker/
├── nginx/
│   └── nginx.conf       # NGINX configuration
└── php/
    └── php.ini          # PHP configuration
```

## Features

- PHP 8.4 with FPM
- Pre-installed PHP extensions: PDO MySQL, Redis, OPcache, Intl, Zip, GD, BCMath
- Xdebug configured for debugging
- Persistent MySQL and Redis data volumes
- Optimized NGINX configuration for Laravel
