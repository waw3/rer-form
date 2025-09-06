#!/bin/bash

# Laravel Setup Wizard
# Creates and configures a new Laravel project

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
PROJECT_NAME="$1"
PRESET="${2:-custom}"
LARAVEL_VERSION="^12.0"
AUTH_TYPE="breeze"
PROJECT_TYPE="web"

# Parse arguments
shift || true
shift || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --preset)
            PRESET="$2"
            shift 2
            ;;
        --version)
            LARAVEL_VERSION="$2"
            shift 2
            ;;
        --auth)
            AUTH_TYPE="$2"
            shift 2
            ;;
        --type)
            PROJECT_TYPE="$2"
            shift 2
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

# Apply preset configurations
apply_preset() {
    case $PRESET in
        "enterprise"|"saas")
            LARAVEL_VERSION="^12.0"
            AUTH_TYPE="jetstream"
            PROJECT_TYPE="saas"
            ;;
        "api")
            LARAVEL_VERSION="^12.0"
            AUTH_TYPE="sanctum"
            PROJECT_TYPE="api"
            ;;
        "admin")
            LARAVEL_VERSION="^12.0"
            AUTH_TYPE="breeze"
            PROJECT_TYPE="admin"
            ;;
        "minimal")
            LARAVEL_VERSION="^12.0"
            AUTH_TYPE="breeze"
            PROJECT_TYPE="web"
            ;;
    esac
}

# Apply preset if specified
if [[ "$PRESET" != "custom" ]]; then
    apply_preset
fi

# Interactive mode if no project name
if [[ -z "$PROJECT_NAME" ]]; then
    print_message "$BLUE" "🚀 Laravel Setup Wizard"
    echo
    read -p "Project name: " PROJECT_NAME
    
    echo
    echo "Laravel version:"
    echo "  1) 12.x (Latest)"
    echo "  2) 11.x (LTS)"
    echo "  3) 10.x (Previous LTS)"
    read -p "Choose [1-3]: " version_choice
    
    case $version_choice in
        2) LARAVEL_VERSION="^11.0" ;;
        3) LARAVEL_VERSION="^10.0" ;;
        *) LARAVEL_VERSION="^12.0" ;;
    esac
    
    echo
    echo "Project type:"
    echo "  1) Full-Stack Web Application"
    echo "  2) API Service"
    echo "  3) Admin Panel"
    echo "  4) SaaS Application"
    read -p "Choose [1-4]: " type_choice
    
    case $type_choice in
        2) PROJECT_TYPE="api" ;;
        3) PROJECT_TYPE="admin" ;;
        4) PROJECT_TYPE="saas" ;;
        *) PROJECT_TYPE="web" ;;
    esac
    
    echo
    echo "Authentication:"
    echo "  1) Laravel Breeze"
    echo "  2) Laravel Jetstream"
    echo "  3) Laravel Sanctum (API)"
    echo "  4) None"
    read -p "Choose [1-4]: " auth_choice
    
    case $auth_choice in
        2) AUTH_TYPE="jetstream" ;;
        3) AUTH_TYPE="sanctum" ;;
        4) AUTH_TYPE="none" ;;
        *) AUTH_TYPE="breeze" ;;
    esac
fi

print_message "$BLUE" "📦 Creating Laravel project..."
echo "  Project: $PROJECT_NAME"
echo "  Version: Laravel $LARAVEL_VERSION"
echo "  Type: $PROJECT_TYPE"
echo "  Auth: $AUTH_TYPE"
echo

# Check if composer is installed
if ! command -v composer &> /dev/null; then
    print_message "$RED" "❌ Composer is not installed"
    exit 1
fi

# Create Laravel project
print_message "$YELLOW" "Installing Laravel..."
composer create-project laravel/laravel "$PROJECT_NAME" "$LARAVEL_VERSION" --prefer-dist

# Navigate to project
cd "$PROJECT_NAME"

# Install authentication package
case $AUTH_TYPE in
    "breeze")
        print_message "$YELLOW" "Installing Laravel Breeze..."
        composer require laravel/breeze --dev
        
        if [[ "$PROJECT_TYPE" == "api" ]]; then
            php artisan breeze:install api
        else
            php artisan breeze:install blade
        fi
        ;;
    
    "jetstream")
        print_message "$YELLOW" "Installing Laravel Jetstream..."
        composer require laravel/jetstream
        
        echo "Choose Jetstream stack:"
        echo "  1) Livewire"
        echo "  2) Inertia"
        read -p "Choose [1-2]: " stack_choice
        
        if [[ "$stack_choice" == "2" ]]; then
            php artisan jetstream:install inertia --teams
        else
            php artisan jetstream:install livewire --teams
        fi
        ;;
    
    "sanctum")
        print_message "$YELLOW" "Installing Laravel Sanctum..."
        composer require laravel/sanctum
        php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
        ;;
esac

# Install common packages based on project type
case $PROJECT_TYPE in
    "api")
        print_message "$YELLOW" "Installing API packages..."
        composer require spatie/laravel-data
        composer require spatie/laravel-query-builder
        ;;
    
    "admin")
        print_message "$YELLOW" "Installing admin packages..."
        composer require filament/filament
        composer require spatie/laravel-permission
        ;;
    
    "saas")
        print_message "$YELLOW" "Installing SaaS packages..."
        composer require laravel/cashier
        composer require spatie/laravel-permission
        ;;
esac

# Install development packages
print_message "$YELLOW" "Installing development packages..."
composer require --dev pestphp/pest pestphp/pest-plugin-laravel
composer require --dev laravel/telescope
composer require --dev barryvdh/laravel-debugbar
composer require --dev laravel/pint
composer require --dev nunomaduro/larastan

# Configure environment
print_message "$YELLOW" "Configuring environment..."
cp .env.example .env
php artisan key:generate

# Set up database
if [[ "$PROJECT_TYPE" != "api" ]]; then
    print_message "$YELLOW" "Setting up database..."
    touch database/database.sqlite
    sed -i '' 's/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/' .env
    sed -i '' '/DB_DATABASE=/d' .env
    echo "DB_DATABASE=$(pwd)/database/database.sqlite" >> .env
fi

# Run migrations
if [[ "$AUTH_TYPE" != "none" ]]; then
    print_message "$YELLOW" "Running migrations..."
    php artisan migrate --force
fi

# Install NPM dependencies if not API
if [[ "$PROJECT_TYPE" != "api" ]]; then
    print_message "$YELLOW" "Installing NPM dependencies..."
    npm install
    npm run build
fi

# Initialize Git repository
print_message "$YELLOW" "Initializing Git repository..."
git init
git add .
git commit -m "Initial Laravel $LARAVEL_VERSION setup with $AUTH_TYPE"

# Final message
echo
print_message "$GREEN" "✅ Laravel project created successfully!"
echo
print_message "$CYAN" "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  php artisan serve"
if [[ "$PROJECT_TYPE" != "api" ]]; then
    echo "  npm run dev"
fi
echo
print_message "$GREEN" "Project ready at: $(pwd)"