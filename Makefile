.PHONY: help up down build rebuild restart shell logs test clean fresh migrate seed artisan composer npm

# Default target
help:
	@echo "Laravel Docker Development Environment"
	@echo ""
	@echo "Available commands:"
	@echo "  make up         - Start all containers"
	@echo "  make down       - Stop all containers"
	@echo "  make build      - Build containers"
	@echo "  make rebuild    - Rebuild and restart containers"
	@echo "  make restart    - Restart all containers"
	@echo "  make shell      - Access app container shell"
	@echo "  make logs       - View logs (use: make logs app)"
	@echo "  make test       - Run tests"
	@echo "  make clean      - Stop and remove all containers and volumes"
	@echo "  make fresh      - Fresh install (rebuild, migrate, seed)"
	@echo "  make migrate    - Run database migrations"
	@echo "  make seed       - Run database seeders"
	@echo "  make artisan    - Run artisan command (use: make artisan cmd='migrate')"
	@echo "  make composer   - Run composer command (use: make composer cmd='install')"
	@echo "  make npm        - Run npm command (use: make npm cmd='install')"

# Start containers
up:
	docker compose up -d

# Stop containers
down:
	docker compose down

# Build containers
build:
	docker compose build

# Rebuild and restart
rebuild:
	docker compose down
	docker compose build --no-cache
	docker compose up -d

# Restart containers
restart:
	docker compose restart

# Access app container shell
shell:
	docker compose exec app bash

# View logs
logs:
	docker compose logs -f $(filter-out $@,$(MAKECMDGOALS))

# Run tests
test:
	docker compose exec app php artisan test

# Stop and remove everything
clean:
	docker compose down -v
	rm -rf vendor node_modules

# Fresh installation
fresh: rebuild
	docker compose exec app composer install
	docker compose exec app php artisan migrate:fresh --seed
	docker compose exec app php artisan key:generate

# Run migrations
migrate:
	docker compose exec app php artisan migrate

# Run seeders
seed:
	docker compose exec app php artisan db:seed

# Run artisan command
artisan:
	docker compose exec app php artisan $(cmd)

# Run composer command
composer:
	docker compose exec app composer $(cmd)

# Run npm command
npm:
	docker compose exec app npm $(cmd)

# Allow additional arguments
%:
	@:
