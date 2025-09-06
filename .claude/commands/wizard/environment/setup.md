---
allowed-tools: all
argument-hint: [--tool <tool>] [--ci] [--local]
description: Configure development environment with Herd, Docker, Git, and CI/CD workflows
---

# Development Environment Wizard

Set up complete development environment with Laravel Herd, Docker, Git configuration, and GitHub Actions workflows.

## Usage

```bash
# Interactive environment setup
/wizard:environment:setup

# Specific tool setup
/wizard:environment:setup --tool herd
/wizard:environment:setup --tool docker
/wizard:environment:setup --tool git

# CI/CD setup
/wizard:environment:setup --ci github

# Full local development setup
/wizard:environment:setup --local
```

## Examples

```bash
# Example 1: Laravel Herd setup
/wizard:environment:setup --tool herd

# Example 2: Docker development environment
/wizard:environment:setup --tool docker --ci

# Example 3: Complete Git + GitHub Actions
/wizard:environment:setup --tool git --ci github

# Example 4: Full environment setup
/wizard:environment:setup --local --ci
```

## Command Execution

```bash
bash .claude/commands/wizard/environment/scripts/setup.sh "$@"
```

## Laravel Herd Setup

### Installation
```bash
# macOS - Download from https://herd.laravel.com
# Automated via Homebrew
brew install --cask herd

# Start Herd
herd start
```

### Herd Configuration
```bash
# Link project
herd link my-app

# Secure with HTTPS
herd secure my-app

# Set PHP version
herd use php@8.3

# Enable services
herd service enable mysql@8.0
herd service enable redis
herd service enable minio
```

### Herd Sites
```bash
# Park directory for auto-discovery
herd park ~/Development

# Link specific project
cd /path/to/project
herd link

# Open in browser
herd open
```

### Herd Database Management
```bash
# Create database
herd db:create my_app_db

# Import database
herd db:import my_app_db < backup.sql

# Export database
herd db:export my_app_db > backup.sql
```

## Docker Setup

### Docker Compose Configuration
```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: laravel-app
    container_name: laravel-app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./:/var/www
      - ./docker/php/local.ini:/usr/local/etc/php/conf.d/local.ini
    networks:
      - laravel
    depends_on:
      - db
      - redis

  nginx:
    image: nginx:alpine
    container_name: laravel-nginx
    restart: unless-stopped
    ports:
      - "8000:80"
      - "443:443"
    volumes:
      - ./:/var/www
      - ./docker/nginx:/etc/nginx/conf.d
    networks:
      - laravel
    depends_on:
      - app

  db:
    image: mysql:8.0
    container_name: laravel-db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_USER: ${DB_USERNAME}
    ports:
      - "3306:3306"
    volumes:
      - dbdata:/var/lib/mysql
      - ./docker/mysql:/docker-entrypoint-initdb.d
    networks:
      - laravel

  redis:
    image: redis:alpine
    container_name: laravel-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    networks:
      - laravel

  mailhog:
    image: mailhog/mailhog
    container_name: laravel-mailhog
    ports:
      - "1025:1025"
      - "8025:8025"
    networks:
      - laravel

  minio:
    image: minio/minio
    container_name: laravel-minio
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: ${AWS_ACCESS_KEY_ID}
      MINIO_ROOT_PASSWORD: ${AWS_SECRET_ACCESS_KEY}
    command: server /data --console-address ":9001"
    volumes:
      - miniodata:/data
    networks:
      - laravel

networks:
  laravel:
    driver: bridge

volumes:
  dbdata:
    driver: local
  miniodata:
    driver: local
```

### Dockerfile
```dockerfile
# Dockerfile
FROM php:8.3-fpm

# Arguments
ARG user=laravel
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs \
    npm

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user
```

### Docker Commands
```bash
# Build and start containers
docker-compose up -d --build

# Stop containers
docker-compose down

# View logs
docker-compose logs -f app

# Execute commands in container
docker-compose exec app php artisan migrate
docker-compose exec app composer install
docker-compose exec app npm install

# Shell access
docker-compose exec app bash
```

## Git Configuration

### Initial Setup
```bash
# Set user information
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Set up aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
```

### .gitignore
```gitignore
# Laravel
/vendor/
/node_modules/
/public/hot
/public/storage
/storage/*.key
/.idea
/.vscode
/.vagrant
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log
.env
.env.backup
.phpunit.result.cache
.php_cs.cache
.php-cs-fixer.cache

# Docker
/docker/mysql/data
/docker/redis/data

# Testing
/coverage
/tests/Browser/screenshots
/tests/Browser/console

# OS
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo
*~
.project
.settings/
.buildpath
```

### Git Hooks
```bash
# pre-commit hook
#!/bin/sh
# .git/hooks/pre-commit

# Run tests
php artisan test --stop-on-failure

# Run linters
./vendor/bin/pint --test
./vendor/bin/phpstan analyse

# Check for debug statements
if grep -r "dd(\|dump(\|var_dump(" app/ resources/; then
    echo "Debug statements found. Please remove them."
    exit 1
fi
```

### Git Flow
```bash
# Initialize git flow
git flow init

# Start a feature
git flow feature start my-feature

# Finish a feature
git flow feature finish my-feature

# Start a release
git flow release start 1.0.0

# Finish a release
git flow release finish 1.0.0
```

## GitHub Actions Workflows

### CI/CD Pipeline
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PHP_VERSION: '8.3'
  NODE_VERSION: '20'

jobs:
  test:
    name: Tests
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: testing
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3
      
      redis:
        image: redis:alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd="redis-cli ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ env.PHP_VERSION }}
          extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite, bcmath, soap, intl, gd, exif, iconv, redis
          coverage: pcov
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Cache Composer packages
        uses: actions/cache@v3
        with:
          path: vendor
          key: ${{ runner.os }}-php-${{ hashFiles('**/composer.lock') }}
          restore-keys: |
            ${{ runner.os }}-php-
      
      - name: Install Dependencies
        run: |
          composer install --no-interaction --prefer-dist
          npm ci
      
      - name: Generate key
        run: php artisan key:generate
      
      - name: Directory Permissions
        run: chmod -R 777 storage bootstrap/cache
      
      - name: Build Assets
        run: npm run build
      
      - name: Run Tests
        env:
          DB_CONNECTION: mysql
          DB_HOST: 127.0.0.1
          DB_PORT: 3306
          DB_DATABASE: testing
          DB_USERNAME: root
          DB_PASSWORD: password
        run: |
          php artisan migrate --force
          php artisan test --parallel --coverage --min=80
      
      - name: Run Frontend Tests
        run: npm run test
      
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/clover.xml
          flags: backend
      
      - name: Upload Artifacts
        uses: actions/upload-artifact@v3
        if: failure()
        with:
          name: logs
          path: storage/logs

  lint:
    name: Code Quality
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ env.PHP_VERSION }}
      
      - name: Install Dependencies
        run: composer install --no-interaction --prefer-dist
      
      - name: Run Laravel Pint
        run: ./vendor/bin/pint --test
      
      - name: Run PHPStan
        run: ./vendor/bin/phpstan analyse
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Install NPM Dependencies
        run: npm ci
      
      - name: Run ESLint
        run: npm run lint
      
      - name: Run Type Check
        run: npm run type-check

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Security Check
        run: |
          composer audit
          npm audit

  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    needs: [test, lint, security]
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Production
        run: |
          # Add deployment script here
          echo "Deploying to production..."
```

### Dependabot Configuration
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "composer"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

### Release Workflow
```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    name: Create Release
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Changelog
        id: changelog
        uses: mikepenz/release-changelog-builder-action@v3
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body: ${{ steps.changelog.outputs.changelog }}
          draft: false
          prerelease: false
```

## Laravel Sail (Alternative to Docker)

```bash
# Install Sail
composer require laravel/sail --dev

# Publish Sail's docker-compose.yml
php artisan sail:install

# Start Sail
./vendor/bin/sail up -d

# Stop Sail
./vendor/bin/sail down

# Run commands
./vendor/bin/sail artisan migrate
./vendor/bin/sail composer install
./vendor/bin/sail npm install
```

## Environment Variables

### Development .env
```env
# Application
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=

# Cache & Session
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Mail (Development)
MAIL_MAILER=smtp
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null

# AWS (Minio for local)
AWS_ACCESS_KEY_ID=minio
AWS_SECRET_ACCESS_KEY=minio123
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=local
AWS_ENDPOINT=http://localhost:9000
AWS_USE_PATH_STYLE_ENDPOINT=true
```

## VS Code Configuration

### .vscode/settings.json
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.validate": [
    "javascript",
    "typescript",
    "vue"
  ],
  "php.validate.executablePath": "/usr/local/bin/php",
  "[php]": {
    "editor.defaultFormatter": "bmewburn.vscode-intelephense-client"
  },
  "[vue]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

### .vscode/extensions.json
```json
{
  "recommendations": [
    "bmewburn.vscode-intelephense-client",
    "onecentlin.laravel-blade",
    "amiralizadeh9480.laravel-extra-intellisense",
    "codingyu.laravel-goto-view",
    "vue.volar",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-azuretools.vscode-docker",
    "github.copilot"
  ]
}
```

## Requirements

- macOS/Linux/Windows with WSL2
- Docker Desktop or Laravel Herd
- Git 2.0+
- GitHub account for workflows
- PHP 8.2+ (for local development)
- Node.js 18+ (for frontend tooling)