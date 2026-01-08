# Laravel Docker Development Environment

> **Note**: This is an AI-generated development environment created for interview purposes. It provides a production-ready setup for Laravel development using Docker.

## Overview

This is a containerized Laravel application running on:
- **PHP 8.4-FPM** with extensions (MySQL, Redis, OPcache, BCMath, GD, Zip, Intl)
- **NGINX** (latest) as a reverse proxy with static file caching
- **MySQL 8.0** for database with performance tuning
- **Redis 7** for caching, sessions, and queues with persistence
- **Multi-stage Docker build** for optimized image size and security

## Quick Start

### Using Make (Recommended)

```bash
# View all available commands
make help

# Start the environment
make up

# Fresh installation
make fresh
```

### Manual Setup

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Start the environment:**
   ```bash
   docker compose up -d
   ```

3. **Install dependencies:**
   ```bash
   docker compose exec app composer install
   ```

4. **Generate application key:**
   ```bash
   docker compose exec app php artisan key:generate
   ```

5. **Run migrations:**
   ```bash
   docker compose exec app php artisan migrate
   ```

6. **Access the application:**
   - Web: http://localhost:8080

## Architecture

### Services

- **nginx**: Reverse proxy on port 8080 (only service exposed to host) with security headers and static file caching
- **app**: PHP 8.4-FPM application container with OPcache optimization
- **mysql**: MySQL 8.0 database (internal only) with performance tuning
- **redis**: Redis 7 cache/session store (internal only) with AOF persistence

### Security Features

- Only NGINX exposed to local network on port 8080
- MySQL and Redis accessible only within Docker network
- Security headers enabled (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection)
- Non-root user for PHP-FPM processes
- Read-only volume mounts where appropriate

### Performance Optimizations

- **OPcache**: Enabled with optimal settings for development
- **Static File Caching**: Images, CSS, JS cached for 1 year
- **PHP-FPM**: Dynamic process manager with 50 max children
- **MySQL**: 256MB buffer pool, optimized for development
- **Redis**: AOF persistence with everysec sync
- **Resource Limits**: CPU and memory limits on all services

### Configuration Files

- NGINX config: `.docker/nginx/nginx.conf`
- PHP config: `.docker/php/php.ini`
- PHP-FPM pool: `.docker/php/www.conf`
- MySQL config: `.docker/mysql/my.cnf`
- Docker build: `Dockerfile`
- Services: `docker-compose.yml`

## Make Commands

```bash
make help       # Show all available commands
make up         # Start all containers
make down       # Stop all containers
make build      # Build containers
make rebuild    # Rebuild and restart containers
make restart    # Restart all containers
make shell      # Access app container shell
make logs       # View logs (e.g., make logs app)
make test       # Run tests
make clean      # Stop and remove all containers and volumes
make fresh      # Fresh install (rebuild, migrate, seed)
make migrate    # Run database migrations
make seed       # Run database seeders
make artisan    # Run artisan command (e.g., make artisan cmd='cache:clear')
make composer   # Run composer (e.g., make composer cmd='require package')
```

## Development Commands

### Artisan Commands
```bash
docker compose exec app php artisan migrate
docker compose exec app php artisan db:seed
docker compose exec app php artisan cache:clear
docker compose exec app php artisan queue:work
```

### Composer
```bash
docker compose exec app composer install
docker compose exec app composer update
docker compose exec app composer require vendor/package
```

### Testing
```bash
# Run all tests
docker compose exec app php artisan test

# Run specific test
docker compose exec app php artisan test --filter TestName

# Run with coverage
docker compose exec app php artisan test --coverage
```

### Database Access
```bash
# MySQL CLI
docker compose exec mysql mysql -ularavel -psecret laravel

# Export database
docker compose exec mysql mysqldump -ularavel -psecret laravel > backup.sql

# Import database
docker compose exec -T mysql mysql -ularavel -psecret laravel < backup.sql
```

### Redis CLI
```bash
# Access Redis
docker compose exec redis redis-cli

# Monitor Redis
docker compose exec redis redis-cli MONITOR

# Clear cache
docker compose exec redis redis-cli FLUSHDB
```

### Container Shell Access
```bash
# App container
docker compose exec app bash

# As root (for system operations)
docker compose exec -u root app bash

# MySQL container
docker compose exec mysql bash
```

### Logs
```bash
# All logs
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f nginx
docker compose logs -f mysql

# Last 100 lines
docker compose logs --tail=100 app
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

## Troubleshooting

### Common Issues

**Port 8080 already in use:**
```bash
# Change port in docker-compose.yml
ports:
  - "8081:80"  # Use different port
```

**Permission denied errors:**
```bash
# Update .env.docker with your user ID
id -u  # Get your UID
id -g  # Get your GID
# Update .env.docker, then rebuild
docker compose build app
```

**Database connection refused:**
```bash
# Wait for MySQL to be ready (health check should handle this)
docker compose logs mysql
# Check if MySQL is healthy
docker compose ps
```

**Redis connection issues:**
```bash
# Check Redis is running
docker compose exec redis redis-cli ping
# Should return: PONG
```

**Composer memory limit:**
```bash
# Already set to 512M in php.ini
# If needed, increase temporarily:
docker compose exec app php -d memory_limit=1G /usr/bin/composer install
```

**Container won't start:**
```bash
# Check logs
docker compose logs app

# Rebuild from scratch
make clean
make rebuild
```

### Performance Issues

**Slow on Mac/Windows:**
- Use delegated volume mounts (already configured)
- Consider using mutagen or docker-sync for large projects
- Reduce file watchers if using hot reload

**High memory usage:**
- Resource limits are configured in docker-compose.yml
- Adjust based on your system:
  ```yaml
  deploy:
    resources:
      limits:
        memory: 2G  # Increase if needed
  ```

### Debug Mode

**Check service health:**
```bash
docker compose ps  # Shows health status
```

**Check resource usage:**
```bash
docker stats
```

**Inspect container:**
```bash
docker compose exec app php --info
docker compose exec mysql mysqladmin -uroot -proot status
```

## Production Considerations

> **Warning**: This environment is optimized for development. For production deployment:

### Required Changes:

1. **Remove development tools:**
   - Composer dev dependencies
   - Debug mode disabled

2. **Security:**
   - Use secrets management for credentials
   - Enable HTTPS with SSL certificates
   - Restrict NGINX to specific domains
   - Add rate limiting
   - Update security headers for your domain

3. **Performance:**
   - Use production PHP settings
   - Optimize OPcache for production
   - Add CDN for static assets
   - Implement proper caching strategy
   - Use read replicas for database

4. **Monitoring:**
   - Add health check endpoints
   - Implement logging aggregation
   - Set up monitoring (Prometheus, Grafana)
   - Configure alerts

5. **Scaling:**
   - Remove container_name for horizontal scaling
   - Use external database (RDS, Cloud SQL)
   - Use managed Redis (ElastiCache, MemoryStore)
   - Implement load balancing

## Multi-Stage Docker Build

The PHP container uses a multi-stage build for optimal image size and security:

**Builder Stage:**
- Installs all build tools (g++, git, etc.)
- Compiles PHP extensions
- Runs Composer with optimization flags
- Generates optimized autoloader

**Runtime Stage:**
- Contains only production dependencies
- No build tools (smaller attack surface)
- Copies compiled extensions from builder
- Copies optimized application code

**Benefits:**
- Smaller final image (excludes build tools)
- Faster deployment (optimized layers)
- Better security (minimal runtime dependencies)
- Optimized Composer autoloader

Image size: ~630MB (includes PHP 8.4, all extensions, Laravel, dependencies)

## Resource Limits

Current limits per service:

| Service | CPU | Memory |
|---------|-----|--------|
| nginx   | 0.5 | 256M   |
| app     | 2.0 | 1G     |
| mysql   | 1.0 | 512M   |
| redis   | 0.5 | 256M   |

Adjust in docker-compose.yml based on your requirements.

## Health Checks

All services have health checks configured:

- **App**: PHP-FPM process test
- **MySQL**: mysqladmin ping
- **Redis**: redis-cli ping

Services won't be marked as "ready" until health checks pass.

## Xdebug (Optional)

Xdebug has been removed for performance. To add it back for debugging:

1. Add to Dockerfile:
   ```dockerfile
   RUN pecl install xdebug-3.5.0 && docker-php-ext-enable xdebug
   ```

2. Add to php.ini:
   ```ini
   [xdebug]
   xdebug.mode = ${XDEBUG_MODE:-off}
   xdebug.start_with_request = yes
   xdebug.client_host = host.docker.internal
   xdebug.client_port = 9003
   ```

3. Enable via environment:
   ```bash
   XDEBUG_MODE=debug docker compose up -d
   ```

## Contributing

This is a demonstration project. For improvements or issues, please document them clearly with reproduction steps.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
