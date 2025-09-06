#!/bin/bash

# Laravel Starter Wizard - Master Orchestrator
# Runs all setup wizards in systematic order

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
PROJECT_NAME=""
PRESET=""
SKIP_STEPS=""
RESUME=false
ROLLBACK=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --preset)
            PRESET="$2"
            shift 2
            ;;
        --skip)
            SKIP_STEPS="$2"
            shift 2
            ;;
        --resume)
            RESUME=true
            shift
            ;;
        --rollback)
            ROLLBACK=true
            shift
            ;;
        *)
            PROJECT_NAME="$1"
            shift
            ;;
    esac
done

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print step header
print_step() {
    echo
    print_message "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_message "$CYAN" "  $1"
    print_message "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
}

# Function to check if step should be skipped
should_skip() {
    local step=$1
    if [[ -n "$SKIP_STEPS" ]]; then
        if echo "$SKIP_STEPS" | grep -q "$step"; then
            return 0
        fi
    fi
    return 1
}

# Function to run a wizard
run_wizard() {
    local wizard_name=$1
    local wizard_path=$2
    shift 2
    local args="$@"

    if should_skip "$wizard_name"; then
        print_message "$YELLOW" "⏭️  Skipping $wizard_name (--skip specified)"
        return 0
    fi

    print_message "$BLUE" "▶️  Running $wizard_name wizard..."

    if [[ -f "$wizard_path" ]]; then
        bash "$wizard_path" $args
        if [[ $? -eq 0 ]]; then
            print_message "$GREEN" "✅ $wizard_name completed successfully"
        else
            print_message "$RED" "❌ $wizard_name failed"
            return 1
        fi
    else
        print_message "$YELLOW" "⚠️  $wizard_name script not found, using interactive mode"
        return 0
    fi
}

# Welcome message
clear
print_message "$CYAN" "🚀 Laravel Starter Wizard"
print_message "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Get project name if not provided
if [[ -z "$PROJECT_NAME" ]]; then
    read -p "Enter project name: " PROJECT_NAME
fi

# Select preset if not provided
if [[ -z "$PRESET" ]]; then
    echo
    print_message "$CYAN" "Select a preset configuration:"
    echo "  1) SaaS Application"
    echo "  2) API Service"
    echo "  3) Admin Dashboard"
    echo "  4) Minimal Setup"
    echo "  5) Custom (interactive)"
    echo
    read -p "Choose [1-5]: " preset_choice

    case $preset_choice in
        1) PRESET="saas" ;;
        2) PRESET="api" ;;
        3) PRESET="admin" ;;
        4) PRESET="minimal" ;;
        5) PRESET="custom" ;;
        *) PRESET="custom" ;;
    esac
fi

# Set wizard base path
WIZARD_BASE=".claude/commands/wizard"

# Progress tracking
TOTAL_STEPS=9
CURRENT_STEP=0

# Function to update progress
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    print_message "$GREEN" "📊 Progress: [$CURRENT_STEP/$TOTAL_STEPS] - $percentage%"
}

# Configure based on preset
if [[ "$PRESET" == "custom" ]]; then
    # Interactive custom configuration
    
    # Phase 1: Development Environment
    print_step "Phase 1: Development Environment"
    echo
    print_message "$CYAN" "Choose your local development tool:"
    echo "  1) Laravel Herd (Recommended for macOS)"
    echo "  2) Docker Compose"
    echo "  3) Laravel Sail"
    echo "  4) XAMPP/MAMP/WAMP"
    echo "  5) Manual setup (PHP, MySQL, etc.)"
    echo
    read -p "Choose [1-5]: " dev_tool_choice
    
    case $dev_tool_choice in
        1) DEV_TOOL="herd" ;;
        2) DEV_TOOL="docker" ;;
        3) DEV_TOOL="sail" ;;
        4) DEV_TOOL="xampp" ;;
        5) DEV_TOOL="manual" ;;
        *) DEV_TOOL="manual" ;;
    esac
    update_progress
    
    # Phase 2: Laravel Configuration
    print_step "Phase 2: Laravel Configuration"
    echo
    print_message "$CYAN" "Choose Laravel version:"
    echo "  1) Laravel 12.x (Latest)"
    echo "  2) Laravel 11.x (LTS)"
    echo "  3) Laravel 10.x"
    echo
    read -p "Choose [1-3]: " laravel_version_choice
    
    case $laravel_version_choice in
        1) LARAVEL_VERSION="^12.0" ;;
        2) LARAVEL_VERSION="^11.0" ;;
        3) LARAVEL_VERSION="^10.0" ;;
        *) LARAVEL_VERSION="^12.0" ;;
    esac
    
    echo
    print_message "$CYAN" "Choose authentication type:"
    echo "  1) Laravel Breeze (Simple, lightweight)"
    echo "  2) Laravel Jetstream (Full-featured with teams)"
    echo "  3) Laravel Sanctum (API authentication)"
    echo "  4) None"
    echo
    read -p "Choose [1-4]: " auth_choice
    
    case $auth_choice in
        1) AUTH_TYPE="breeze" ;;
        2) AUTH_TYPE="jetstream" ;;
        3) AUTH_TYPE="sanctum" ;;
        4) AUTH_TYPE="none" ;;
        *) AUTH_TYPE="breeze" ;;
    esac
    update_progress
    
    # Phase 3: Database Configuration
    print_step "Phase 3: Database Configuration"
    echo
    print_message "$CYAN" "Choose database system:"
    echo "  1) MySQL 8.0"
    echo "  2) PostgreSQL 15"
    echo "  3) SQLite"
    echo "  4) MariaDB"
    echo "  5) MongoDB"
    echo
    read -p "Choose [1-5]: " db_choice
    
    case $db_choice in
        1) DATABASE="mysql" ;;
        2) DATABASE="pgsql" ;;
        3) DATABASE="sqlite" ;;
        4) DATABASE="mariadb" ;;
        5) DATABASE="mongodb" ;;
        *) DATABASE="mysql" ;;
    esac
    update_progress
    
    # Phase 4: Frontend Stack
    print_step "Phase 4: Frontend Stack"
    echo
    print_message "$CYAN" "Choose frontend framework:"
    echo "  1) Blade + Alpine.js (Traditional)"
    echo "  2) Inertia.js + Vue 3"
    echo "  3) Inertia.js + React"
    echo "  4) Livewire + Alpine.js"
    echo "  5) API Only (no frontend)"
    echo
    read -p "Choose [1-5]: " frontend_choice
    
    case $frontend_choice in
        1) FRONTEND="blade" ;;
        2) FRONTEND="vue" ;;
        3) FRONTEND="react" ;;
        4) FRONTEND="livewire" ;;
        5) FRONTEND="api" ;;
        *) FRONTEND="blade" ;;
    esac
    update_progress
    
    # Phase 5: Additional Packages
    print_step "Phase 5: Additional Packages"
    echo
    print_message "$CYAN" "Select additional features (space-separated numbers):"
    echo "  1) Admin Panel (Filament)"
    echo "  2) Payment Processing (Stripe)"
    echo "  3) Multi-tenancy"
    echo "  4) Media Library"
    echo "  5) Activity Logging"
    echo "  6) API Documentation"
    echo "  7) Debugging Tools (Telescope/Debugbar)"
    echo "  8) None"
    echo
    read -p "Enter choices (e.g., 1 2 4): " package_choices
    
    PACKAGES=""
    for choice in $package_choices; do
        case $choice in
            1) PACKAGES="$PACKAGES filament" ;;
            2) PACKAGES="$PACKAGES cashier" ;;
            3) PACKAGES="$PACKAGES tenancy" ;;
            4) PACKAGES="$PACKAGES media" ;;
            5) PACKAGES="$PACKAGES activity" ;;
            6) PACKAGES="$PACKAGES apidoc" ;;
            7) PACKAGES="$PACKAGES debug" ;;
            8) break ;;
        esac
    done
    update_progress
    
    # Phase 6: Testing Framework
    print_step "Phase 6: Testing Configuration"
    echo
    print_message "$CYAN" "Choose testing framework:"
    echo "  1) PHPUnit (Default)"
    echo "  2) Pest (Modern, elegant)"
    echo "  3) Both"
    echo
    read -p "Choose [1-3]: " test_choice
    
    case $test_choice in
        1) TESTING="phpunit" ;;
        2) TESTING="pest" ;;
        3) TESTING="both" ;;
        *) TESTING="phpunit" ;;
    esac
    update_progress
    
    # Phase 7: CI/CD
    print_step "Phase 7: CI/CD Configuration"
    echo
    print_message "$CYAN" "Setup CI/CD pipeline?"
    echo "  1) GitHub Actions"
    echo "  2) GitLab CI"
    echo "  3) Bitbucket Pipelines"
    echo "  4) None"
    echo
    read -p "Choose [1-4]: " ci_choice
    
    case $ci_choice in
        1) CI_CD="github" ;;
        2) CI_CD="gitlab" ;;
        3) CI_CD="bitbucket" ;;
        4) CI_CD="none" ;;
        *) CI_CD="none" ;;
    esac
    update_progress
    
else
    # Use preset configurations
    case $PRESET in
        "saas")
            DEV_TOOL="docker"
            LARAVEL_VERSION="^12.0"
            AUTH_TYPE="jetstream"
            DATABASE="pgsql"
            FRONTEND="vue"
            PACKAGES="filament cashier tenancy media activity telescope"
            TESTING="pest"
            CI_CD="github"
            ;;
        "api")
            DEV_TOOL="docker"
            LARAVEL_VERSION="^12.0"
            AUTH_TYPE="sanctum"
            DATABASE="pgsql"
            FRONTEND="api"
            PACKAGES="apidoc telescope"
            TESTING="pest"
            CI_CD="github"
            ;;
        "admin")
            DEV_TOOL="herd"
            LARAVEL_VERSION="^12.0"
            AUTH_TYPE="breeze"
            DATABASE="mysql"
            FRONTEND="blade"
            PACKAGES="filament media activity"
            TESTING="phpunit"
            CI_CD="github"
            ;;
        "minimal")
            DEV_TOOL="manual"
            LARAVEL_VERSION="^12.0"
            AUTH_TYPE="breeze"
            DATABASE="sqlite"
            FRONTEND="blade"
            PACKAGES=""
            TESTING="phpunit"
            CI_CD="none"
            ;;
    esac
    
    # Show preset configuration
    print_message "$GREEN" "Using $PRESET preset configuration"
    echo "  Development Tool: $DEV_TOOL"
    echo "  Laravel Version: $LARAVEL_VERSION"
    echo "  Authentication: $AUTH_TYPE"
    echo "  Database: $DATABASE"
    echo "  Frontend: $FRONTEND"
    echo "  Packages: ${PACKAGES:-none}"
    echo "  Testing: $TESTING"
    echo "  CI/CD: $CI_CD"
    echo
    
    # Update all progress at once for presets
    for i in {1..7}; do
        update_progress
    done
fi

# Phase 8: Create Laravel Project
print_step "Phase 8: Creating Laravel Project"
print_message "$YELLOW" "Installing Laravel $LARAVEL_VERSION..."

# Create the Laravel project
composer create-project laravel/laravel "$PROJECT_NAME" "$LARAVEL_VERSION" --prefer-dist
cd "$PROJECT_NAME"

# Configure database in .env
if [[ "$DATABASE" != "sqlite" ]]; then
    print_message "$YELLOW" "Configuring database connection..."
    sed -i '' "s/DB_CONNECTION=.*/DB_CONNECTION=$DATABASE/" .env
fi

# Install authentication
if [[ "$AUTH_TYPE" != "none" ]]; then
    print_message "$YELLOW" "Installing $AUTH_TYPE authentication..."
    
    case $AUTH_TYPE in
        "breeze")
            composer require laravel/breeze --dev
            if [[ "$FRONTEND" == "blade" ]]; then
                php artisan breeze:install blade
            elif [[ "$FRONTEND" == "vue" ]]; then
                php artisan breeze:install vue
            elif [[ "$FRONTEND" == "react" ]]; then
                php artisan breeze:install react
            elif [[ "$FRONTEND" == "api" ]]; then
                php artisan breeze:install api
            fi
            ;;
        "jetstream")
            composer require laravel/jetstream
            if [[ "$FRONTEND" == "vue" ]] || [[ "$FRONTEND" == "blade" ]]; then
                php artisan jetstream:install inertia --teams
            elif [[ "$FRONTEND" == "livewire" ]]; then
                php artisan jetstream:install livewire --teams
            fi
            ;;
        "sanctum")
            composer require laravel/sanctum
            php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
            ;;
    esac
fi

# Install additional packages
if [[ -n "$PACKAGES" ]]; then
    print_message "$YELLOW" "Installing additional packages..."
    
    for package in $PACKAGES; do
        case $package in
            "filament")
                composer require filament/filament
                php artisan filament:install --panels
                ;;
            "cashier")
                composer require laravel/cashier
                php artisan vendor:publish --tag="cashier-migrations"
                ;;
            "tenancy")
                composer require spatie/laravel-multitenancy
                ;;
            "media")
                composer require spatie/laravel-medialibrary
                php artisan vendor:publish --provider="Spatie\MediaLibrary\MediaLibraryServiceProvider" --tag="medialibrary-migrations"
                ;;
            "activity")
                composer require spatie/laravel-activitylog
                php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="activitylog-migrations"
                ;;
            "apidoc")
                composer require --dev knuckleswtf/scribe
                php artisan vendor:publish --tag=scribe-config
                ;;
            "telescope")
                composer require laravel/telescope
                php artisan telescope:install
                ;;
            "debug")
                composer require --dev barryvdh/laravel-debugbar
                ;;
        esac
    done
fi

# Setup testing framework
if [[ "$TESTING" == "pest" ]] || [[ "$TESTING" == "both" ]]; then
    print_message "$YELLOW" "Installing Pest testing framework..."
    composer require pestphp/pest pestphp/pest-plugin-laravel --dev --with-all-dependencies
    php artisan pest:install
fi

# Install npm dependencies if not API only
if [[ "$FRONTEND" != "api" ]]; then
    print_message "$YELLOW" "Installing frontend dependencies..."
    npm install
    npm run build
fi

update_progress

# Phase 9: Setup CI/CD
if [[ "$CI_CD" != "none" ]]; then
    print_step "Phase 9: CI/CD Setup"
    
    if [[ "$CI_CD" == "github" ]]; then
        mkdir -p .github/workflows
        cat > .github/workflows/tests.yml << 'EOF'
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: testing
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup PHP
      uses: shivammathur/setup-php@v2
      with:
        php-version: '8.3'
        extensions: mbstring, dom, fileinfo, mysql
        coverage: xdebug
    
    - name: Copy .env
      run: php -r "file_exists('.env') || copy('.env.example', '.env');"
    
    - name: Install Composer Dependencies
      run: composer install --no-interaction --prefer-dist --optimize-autoloader
    
    - name: Generate key
      run: php artisan key:generate
    
    - name: Directory Permissions
      run: chmod -R 777 storage bootstrap/cache
    
    - name: Create Database
      run: |
        mysql -h127.0.0.1 -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS testing;"
    
    - name: Run Migrations
      env:
        DB_CONNECTION: mysql
        DB_HOST: 127.0.0.1
        DB_PORT: 3306
        DB_DATABASE: testing
        DB_USERNAME: root
        DB_PASSWORD: password
      run: php artisan migrate --force
    
    - name: Install NPM Dependencies
      run: npm ci
    
    - name: Build Assets
      run: npm run build
    
    - name: Execute tests
      env:
        DB_CONNECTION: mysql
        DB_HOST: 127.0.0.1
        DB_PORT: 3306
        DB_DATABASE: testing
        DB_USERNAME: root
        DB_PASSWORD: password
      run: php artisan test
EOF
        print_message "$GREEN" "✅ GitHub Actions workflow created"
    fi
fi
update_progress

# Final summary
echo
print_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message "$GREEN" "🎉 Setup Complete!"
print_message "$GREEN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
print_message "$CYAN" "📁 Project: $PROJECT_NAME"
print_message "$CYAN" "🎯 Preset: $PRESET"
echo
print_message "$YELLOW" "Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. php artisan serve"
echo "  3. npm run dev"
echo "  4. Open http://localhost:8000"
echo
print_message "$GREEN" "Happy coding! 🚀"