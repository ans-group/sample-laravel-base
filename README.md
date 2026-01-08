# Laravel Docker Development Environment

> **Note**: This is an AI-generated development environment created for interview purposes. It provides a quick setup for Laravel development using Docker.

## Overview

This is a containerized Laravel application running on:
- **PHP 8.4-FPM** with extensions (MySQL, Redis, Xdebug, BCMath, GD, Zip, Intl)
- **NGINX** (latest) as a reverse proxy
- **MySQL 8.0** for database
- **Redis 7** for caching, sessions, and queues

## Quick Start

1. **Start the environment:**
   ```bash
   docker compose up -d
   ```

2. **Install dependencies (if needed):**
   ```bash
   docker compose exec app composer install
   ```

3. **Set up environment:**
   ```bash
   cp .env.example .env
   docker compose exec app php artisan key:generate
   ```

4. **Run migrations:**
   ```bash
   docker compose exec app php artisan migrate
   ```

5. **Access the application:**
   - Web: http://localhost:8080

## Architecture

### Services

- **nginx**: Reverse proxy on port 8080 (only service exposed to host)
- **app**: PHP 8.4-FPM application container
- **mysql**: MySQL 8.0 database (internal only)
- **redis**: Redis 7 cache/session store (internal only)

### Security

Only NGINX is exposed to the local network on port 8080. MySQL and Redis are accessible only from within the Docker network for security.

### Configuration

- NGINX config: `.docker/nginx/nginx.conf`
- PHP config: `.docker/php/php.ini`
- Docker build: `Dockerfile`
- Services: `docker-compose.yml`

## Development Commands

```bash
# Run artisan commands
docker compose exec app php artisan [command]

# Run composer
docker compose exec app composer [command]

# Run tests
docker compose exec app ./vendor/bin/phpunit

# Access MySQL
docker compose exec mysql mysql -ularavel -psecret laravel

# Access Redis CLI
docker compose exec redis redis-cli

# View logs
docker compose logs -f [service]

# Stop containers
docker compose down
```

## User Permissions

The PHP-FPM container runs as a user matching your host system's user ID to avoid file permission issues. By default, it uses UID/GID 1000.

### Platform-Specific Notes

- **Linux**: Works as designed. Files created in container match host user ownership.
- **Mac**: Docker Desktop automatically handles file permissions. The UID/GID mapping is unnecessary but harmless.
- **Windows**: File permissions work differently depending on your setup:
  - WSL2 with Linux filesystem: Works like Linux
  - WSL2 with Windows filesystem: Permissions may be ignored (files appear as 777)

### Configuration

To configure for your specific user:

1. Check your user ID:
   ```bash
   id -u  # Your user ID
   id -g  # Your group ID
   ```

2. Update `.env.docker` with your values:
   ```env
   USER_ID=1000
   GROUP_ID=1000
   ```

3. Rebuild the app container:
   ```bash
   docker compose build app
   docker compose up -d
   ```

On Linux, files created inside the container will be owned by your host user. On Mac/Windows, default Docker Desktop behavior typically handles permissions automatically.

## Environment Variables

Key Docker-specific settings in `.env`:

```env
APP_URL=http://localhost:8080

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

REDIS_HOST=redis
REDIS_PORT=6379

SESSION_DRIVER=redis
CACHE_STORE=redis
QUEUE_CONNECTION=redis
```

Additional Docker configuration in `.env.docker`:

```env
USER_ID=1000   # Set to your host user ID (run: id -u)
GROUP_ID=1000  # Set to your host group ID (run: id -g)
```

## Xdebug

Xdebug is installed and configured to connect to `host.docker.internal:9003`. Configure your IDE to listen on port 9003 for debugging.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
