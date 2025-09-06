#!/bin/bash

# Development Environment Setup Wizard
# Configure development environment with Herd, Docker, Git, and CI/CD workflows

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
TOOL="${1:-}"
CI_PROVIDER=""
LOCAL_SETUP=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tool)
            TOOL="$2"
            shift 2
            ;;
        --ci)
            CI_PROVIDER="$2"
            shift 2
            ;;
        --local)
            LOCAL_SETUP=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Function to print colored output
print_message() {
    echo -e "${1}${2}${NC}"
}

# Function to print section header
print_section() {
    echo
    print_message "$BLUE" "🛠️ $1"
    echo
}

# Interactive tool selection if not specified
if [[ -z "$TOOL" && "$LOCAL_SETUP" != true ]]; then
    print_message "$BLUE" "🛠️ Development Environment Setup Wizard"
    echo
    echo "Choose a development tool to set up:"
    echo "  1) Laravel Herd (macOS)"
    echo "  2) Docker Development Environment"
    echo "  3) Git Configuration"
    echo "  4) Complete Local Environment"
    echo "  5) CI/CD Setup Only"
    read -p "Choose [1-5]: " tool_choice
    
    case $tool_choice in
        1) TOOL="herd" ;;
        2) TOOL="docker" ;;
        3) TOOL="git" ;;
        4) LOCAL_SETUP=true ;;
        5) TOOL="ci" ;;
        *) TOOL="herd" ;;
    esac
fi

# Interactive CI provider selection if not specified
if [[ -z "$CI_PROVIDER" && ("$TOOL" == "ci" || "$LOCAL_SETUP" == true) ]]; then
    echo
    echo "Choose CI/CD provider:"
    echo "  1) GitHub Actions"
    echo "  2) GitLab CI"
    echo "  3) Skip CI/CD setup"
    read -p "Choose [1-3]: " ci_choice
    
    case $ci_choice in
        1) CI_PROVIDER="github" ;;
        2) CI_PROVIDER="gitlab" ;;
        3) CI_PROVIDER="none" ;;
        *) CI_PROVIDER="github" ;;
    esac
fi

print_section "Environment Configuration"
echo "  Tool: ${TOOL:-'Full Local Setup'}"
echo "  CI/CD: ${CI_PROVIDER:-'None'}"
echo "  Local Setup: $LOCAL_SETUP"
echo

# Laravel Herd setup
setup_herd() {
    print_section "Laravel Herd Setup (macOS)"
    
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_message "$RED" "❌ Laravel Herd is only available on macOS"
        return 1
    fi
    
    echo "Installing Laravel Herd..."
    echo "# Download from https://herd.laravel.com"
    echo "# Or install via Homebrew:"
    echo "brew install --cask herd"
    
    echo
    echo "Starting Herd services..."
    echo "herd start"
    
    echo
    echo "Configuring Herd for this project..."
    echo "# Link current project:"
    echo "herd link $(basename $(pwd))"
    
    echo
    echo "# Secure with HTTPS:"
    echo "herd secure $(basename $(pwd))"
    
    echo
    echo "# Set PHP version:"
    echo "herd use php@8.3"
    
    echo
    echo "Enabling Herd services..."
    echo "herd service enable mysql@8.0"
    echo "herd service enable redis"
    echo "herd service enable minio"
    
    echo
    echo "Database management:"
    echo "# Create database:"
    echo "herd db:create $(basename $(pwd))"
    
    print_message "$GREEN" "✅ Laravel Herd configured!"
    print_message "$CYAN" "Access your app at: https://$(basename $(pwd)).test"
}

# Docker setup
setup_docker() {
    print_section "Docker Development Environment"
    
    echo "Creating Docker configuration files..."
    
    echo
    echo "Creating docker-compose.yml..."
    cat << 'EOF'
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: laravel-app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./:/var/www
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
    volumes:
      - ./:/var/www
      - ./docker/nginx:/etc/nginx/conf.d
    networks:
      - laravel

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

networks:
  laravel:
    driver: bridge

volumes:
  dbdata:
    driver: local
EOF
    
    echo
    echo "Creating Dockerfile..."
    cat << 'EOF'
FROM php:8.3-fpm

ARG user=laravel
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev \
    zip unzip nodejs npm

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd
RUN pecl install redis && docker-php-ext-enable redis

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user

WORKDIR /var/www
USER $user
EOF
    
    echo
    echo "Docker commands:"
    echo "docker-compose up -d --build    # Start containers"
    echo "docker-compose down             # Stop containers"
    echo "docker-compose exec app bash    # Shell access"
    
    print_message "$GREEN" "✅ Docker configuration created!"
}

# Git configuration
setup_git() {
    print_section "Git Configuration"
    
    echo "Setting up Git user information..."
    echo "git config --global user.name \"Your Name\""
    echo "git config --global user.email \"your.email@example.com\""
    
    echo
    echo "Setting default branch and aliases..."
    echo "git config --global init.defaultBranch main"
    echo "git config --global alias.co checkout"
    echo "git config --global alias.br branch"
    echo "git config --global alias.ci commit"
    echo "git config --global alias.st status"
    
    echo
    echo "Creating .gitignore..."
    cat << 'EOF'
# Laravel
/vendor/
/node_modules/
/public/hot
/public/storage
/storage/*.key
/.env
/.env.backup
/.phpunit.result.cache
.php-cs-fixer.cache

# IDEs
/.idea
/.vscode
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Testing
/coverage
/tests/Browser/screenshots
EOF
    
    echo
    echo "Setting up Git hooks..."
    echo "Creating pre-commit hook..."
    cat << 'EOF'
#!/bin/sh
# Run tests before commit
php artisan test --stop-on-failure

# Run code formatting
./vendor/bin/pint --test

# Check for debug statements
if grep -r "dd(\|dump(\|var_dump(" app/ resources/; then
    echo "Debug statements found. Please remove them."
    exit 1
fi
EOF
    
    print_message "$GREEN" "✅ Git configuration completed!"
}

# GitHub Actions setup
setup_github_actions() {
    print_section "GitHub Actions CI/CD"
    
    echo "Creating .github/workflows/ci.yml..."
    cat << 'EOF'
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
      
      - name: Install Dependencies
        run: |
          composer install --no-interaction --prefer-dist
          npm ci
      
      - name: Generate key
        run: php artisan key:generate
      
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
          php artisan test --parallel --coverage

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

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      - name: Run Security Check
        run: |
          composer audit
          npm audit
EOF
    
    echo
    echo "Creating Dependabot configuration (.github/dependabot.yml)..."
    cat << 'EOF'
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
EOF
    
    print_message "$GREEN" "✅ GitHub Actions configured!"
}

# GitLab CI setup
setup_gitlab_ci() {
    print_section "GitLab CI/CD"
    
    echo "Creating .gitlab-ci.yml..."
    cat << 'EOF'
image: php:8.3

variables:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_DATABASE: testing
  MYSQL_USER: laravel
  MYSQL_PASSWORD: laravel

services:
  - mysql:8.0
  - redis:alpine

cache:
  paths:
    - vendor/
    - node_modules/

stages:
  - test
  - lint
  - security
  - deploy

before_script:
  - apt-get update -qq && apt-get install -y -qq git curl libmcrypt-dev libjpeg-dev libpng-dev libfreetype6-dev libbz2-dev
  - docker-php-ext-install pdo_mysql
  - curl -sS https://getcomposer.org/installer | php
  - php composer.phar install --no-interaction --prefer-dist --no-ansi
  - cp .env.example .env
  - php artisan key:generate
  - php artisan migrate

test:
  stage: test
  script:
    - php artisan test --coverage

lint:
  stage: lint
  script:
    - ./vendor/bin/pint --test
    - ./vendor/bin/phpstan analyse

security:
  stage: security
  script:
    - composer audit
EOF
    
    print_message "$GREEN" "✅ GitLab CI configured!"
}

# VS Code configuration
setup_vscode() {
    print_section "VS Code Configuration"
    
    echo "Creating .vscode/settings.json..."
    cat << 'EOF'
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.validate": ["javascript", "typescript", "vue"],
  "php.validate.executablePath": "/usr/local/bin/php",
  "[php]": {
    "editor.defaultFormatter": "bmewburn.vscode-intelephense-client"
  },
  "[vue]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
EOF
    
    echo
    echo "Creating .vscode/extensions.json..."
    cat << 'EOF'
{
  "recommendations": [
    "bmewburn.vscode-intelephense-client",
    "onecentlin.laravel-blade",
    "vue.volar",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-azuretools.vscode-docker"
  ]
}
EOF
    
    print_message "$GREEN" "✅ VS Code configuration created!"
}

# Environment variables setup
setup_env_vars() {
    print_section "Environment Variables"
    
    echo "Setting up development .env variables..."
    echo
    echo "# Application"
    echo "APP_ENV=local"
    echo "APP_DEBUG=true"
    echo "APP_URL=http://localhost:8000"
    echo
    echo "# Database"
    echo "DB_CONNECTION=mysql"
    echo "DB_HOST=127.0.0.1"
    echo "DB_PORT=3306"
    echo "DB_DATABASE=laravel"
    echo "DB_USERNAME=root"
    echo "DB_PASSWORD="
    echo
    echo "# Cache & Session"
    echo "CACHE_DRIVER=redis"
    echo "SESSION_DRIVER=redis"
    echo "QUEUE_CONNECTION=redis"
    echo
    echo "# Mail (Development)"
    echo "MAIL_MAILER=smtp"
    echo "MAIL_HOST=localhost"
    echo "MAIL_PORT=1025"
    echo
    echo "# AWS (MinIO for local)"
    echo "AWS_ACCESS_KEY_ID=minio"
    echo "AWS_SECRET_ACCESS_KEY=minio123"
    echo "AWS_ENDPOINT=http://localhost:9000"
    echo "AWS_USE_PATH_STYLE_ENDPOINT=true"
}

# Laravel Sail setup
setup_sail() {
    print_section "Laravel Sail (Alternative to Docker)"
    
    echo "Installing Laravel Sail..."
    echo "composer require laravel/sail --dev"
    
    echo
    echo "Publishing Sail configuration..."
    echo "php artisan sail:install"
    
    echo
    echo "Sail commands:"
    echo "./vendor/bin/sail up -d      # Start containers"
    echo "./vendor/bin/sail down       # Stop containers"
    echo "./vendor/bin/sail artisan    # Run artisan commands"
    echo "./vendor/bin/sail composer   # Run composer commands"
    echo "./vendor/bin/sail npm        # Run npm commands"
    
    print_message "$GREEN" "✅ Laravel Sail configured!"
}

# Execute setup based on selected tool
case $TOOL in
    "herd") setup_herd ;;
    "docker") setup_docker ;;
    "git") setup_git ;;
    "ci") 
        case $CI_PROVIDER in
            "github") setup_github_actions ;;
            "gitlab") setup_gitlab_ci ;;
        esac
        ;;
esac

# Full local setup
if [[ "$LOCAL_SETUP" == true ]]; then
    print_section "Complete Local Development Environment"
    
    # Detect operating system
    OS="$(uname)"
    if [[ "$OS" == "Darwin" ]]; then
        print_message "$CYAN" "macOS detected - setting up Laravel Herd..."
        setup_herd
    else
        print_message "$CYAN" "Linux/Windows detected - setting up Docker..."
        setup_docker
    fi
    
    setup_git
    setup_vscode
    setup_env_vars
    
    if [[ "$CI_PROVIDER" != "none" ]]; then
        case $CI_PROVIDER in
            "github") setup_github_actions ;;
            "gitlab") setup_gitlab_ci ;;
        esac
    fi
fi

print_section "Development Workflow"

echo "Recommended development workflow:"
echo
echo "1. Daily Development:"
echo "   - Start development environment"
echo "   - Pull latest changes"
echo "   - Run tests before coding"
echo "   - Make changes and commit regularly"
echo
echo "2. Before Push:"
echo "   - Run full test suite"
echo "   - Check code formatting"
echo "   - Update documentation"
echo "   - Push to feature branch"
echo
echo "3. Deployment:"
echo "   - Create pull/merge request"
echo "   - Wait for CI/CD pipeline"
echo "   - Review and merge"
echo "   - Deploy to staging/production"

print_section "Useful Commands"

echo "Environment management commands:"
echo
if [[ "$TOOL" == "herd" || "$LOCAL_SETUP" == true ]]; then
    echo "# Laravel Herd:"
    echo "herd start                    # Start Herd services"
    echo "herd stop                     # Stop Herd services"
    echo "herd open                     # Open project in browser"
    echo "herd link                     # Link current directory"
fi

if [[ "$TOOL" == "docker" || "$LOCAL_SETUP" == true ]]; then
    echo "# Docker:"
    echo "docker-compose up -d          # Start containers"
    echo "docker-compose down           # Stop containers"
    echo "docker-compose exec app bash  # Shell access"
fi

echo
echo "# Laravel development:"
echo "php artisan serve             # Start development server"
echo "php artisan migrate           # Run migrations"
echo "php artisan test              # Run tests"
echo "npm run dev                   # Start frontend dev server"
echo
echo "# Code quality:"
echo "./vendor/bin/pint             # Format code"
echo "./vendor/bin/phpstan analyse  # Static analysis"
echo "composer audit                # Security audit"

print_message "$GREEN" "✅ Development environment setup completed!"
echo
print_message "$CYAN" "Next steps:"
echo "  1. Start your development environment"
echo "  2. Set up your database connection"
echo "  3. Install project dependencies"
echo "  4. Run initial migrations and seeds"
echo "  5. Start coding!"
echo
print_message "$YELLOW" "Environment access:"
if [[ "$TOOL" == "herd" || "$LOCAL_SETUP" == true ]]; then
    echo "  🌐 Application: https://$(basename $(pwd)).test (Herd)"
fi
if [[ "$TOOL" == "docker" || "$LOCAL_SETUP" == true ]]; then
    echo "  🌐 Application: http://localhost:8000 (Docker)"
    echo "  📧 MailHog: http://localhost:8025"
fi
echo
print_message "$GREEN" "Development environment ready for Laravel development!"