#!/bin/bash

# Backend Packages Wizard
# Add and manage Laravel backend packages with intelligent recommendations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
CATEGORY="${1:-}"
LIST_MODE=false
POPULAR_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --category)
            CATEGORY="$2"
            shift 2
            ;;
        --list)
            LIST_MODE=true
            shift
            ;;
        --popular)
            POPULAR_MODE=true
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
    print_message "$BLUE" "📦 $1"
    echo
}

# List all available categories
list_categories() {
    print_message "$BLUE" "📋 Available Package Categories"
    echo
    echo "  auth          - Authentication & Authorization"
    echo "  api           - API Development"
    echo "  admin         - Admin Panels"
    echo "  database      - Database & ORM"
    echo "  media         - Media & Files"
    echo "  performance   - Performance & Optimization"
    echo "  security      - Security"
    echo "  testing       - Testing & Development"
    echo "  payment       - Payment & E-commerce"
    echo "  notification  - Notifications & Communication"
    echo "  seo           - SEO & Marketing"
    echo "  localization  - Localization & Multi-tenancy"
    echo
}

if [[ "$LIST_MODE" == true ]]; then
    list_categories
    exit 0
fi

# Install popular packages
install_popular_packages() {
    print_section "Installing Popular Laravel Packages"
    
    echo "composer require spatie/laravel-permission"
    echo "composer require laravel/sanctum"
    echo "composer require spatie/laravel-data"
    echo "composer require spatie/laravel-query-builder"
    echo "composer require --dev pestphp/pest"
    echo "composer require --dev pestphp/pest-plugin-laravel"
    echo "composer require --dev barryvdh/laravel-debugbar"
    echo "composer require --dev laravel/telescope"
    
    print_message "$GREEN" "✅ Popular packages configured!"
    return
}

if [[ "$POPULAR_MODE" == true ]]; then
    install_popular_packages
    exit 0
fi

# Interactive category selection if not specified
if [[ -z "$CATEGORY" ]]; then
    print_message "$BLUE" "🔧 Backend Packages Wizard"
    echo
    echo "Choose a package category:"
    echo "  1) Authentication & Authorization"
    echo "  2) API Development"
    echo "  3) Admin Panels"
    echo "  4) Database & ORM"
    echo "  5) Media & Files"
    echo "  6) Performance & Optimization"
    echo "  7) Security"
    echo "  8) Testing & Development"
    echo "  9) Payment & E-commerce"
    echo "  10) All popular packages"
    read -p "Choose [1-10]: " category_choice
    
    case $category_choice in
        1) CATEGORY="auth" ;;
        2) CATEGORY="api" ;;
        3) CATEGORY="admin" ;;
        4) CATEGORY="database" ;;
        5) CATEGORY="media" ;;
        6) CATEGORY="performance" ;;
        7) CATEGORY="security" ;;
        8) CATEGORY="testing" ;;
        9) CATEGORY="payment" ;;
        10) install_popular_packages; exit 0 ;;
        *) CATEGORY="auth" ;;
    esac
fi

# Package installation functions
install_auth_packages() {
    print_section "Authentication & Authorization Packages"
    
    echo "Choose authentication packages:"
    echo "  1) Laravel Sanctum (Token-based API auth)"
    echo "  2) Laravel Passport (Full OAuth2 server)"
    echo "  3) Laravel Fortify (Backend auth)"
    echo "  4) Spatie Laravel Permission (Roles & permissions)"
    echo "  5) Laravel Socialite (OAuth providers)"
    echo "  6) All authentication packages"
    read -p "Choose [1-6]: " auth_choice
    
    case $auth_choice in
        1)
            echo "composer require laravel/sanctum"
            echo "php artisan vendor:publish --provider=\"Laravel\Sanctum\SanctumServiceProvider\""
            echo "php artisan migrate"
            ;;
        2)
            echo "composer require laravel/passport"
            echo "php artisan migrate"
            echo "php artisan passport:install"
            ;;
        3)
            echo "composer require laravel/fortify"
            echo "php artisan vendor:publish --provider=\"Laravel\Fortify\FortifyServiceProvider\""
            ;;
        4)
            echo "composer require spatie/laravel-permission"
            echo "php artisan vendor:publish --provider=\"Spatie\Permission\PermissionServiceProvider\""
            echo "php artisan migrate"
            ;;
        5)
            echo "composer require laravel/socialite"
            ;;
        6)
            echo "composer require laravel/sanctum spatie/laravel-permission laravel/socialite"
            echo "php artisan vendor:publish --provider=\"Laravel\Sanctum\SanctumServiceProvider\""
            echo "php artisan vendor:publish --provider=\"Spatie\Permission\PermissionServiceProvider\""
            echo "php artisan migrate"
            ;;
    esac
}

install_api_packages() {
    print_section "API Development Packages"
    
    echo "Installing API development packages..."
    echo "composer require spatie/laravel-data"
    echo "composer require spatie/laravel-query-builder"
    echo "composer require spatie/laravel-fractal"
    echo "composer require barryvdh/laravel-cors"
    echo "composer require spatie/laravel-json-api-paginate"
    
    echo
    echo "Configuring CORS..."
    echo "php artisan vendor:publish --tag=\"cors\""
    
    print_message "$GREEN" "✅ API packages installed!"
}

install_admin_packages() {
    print_section "Admin Panel Packages"
    
    echo "Choose an admin panel:"
    echo "  1) Filament (Modern admin panel)"
    echo "  2) Laravel Nova (Official admin panel)"
    echo "  3) Orchid Platform (RAD platform)"
    echo "  4) Laravel Backpack CRUD"
    read -p "Choose [1-4]: " admin_choice
    
    case $admin_choice in
        1)
            echo "composer require filament/filament"
            echo "php artisan filament:install --panels"
            echo "php artisan migrate"
            echo "php artisan make:filament-user"
            ;;
        2)
            echo "composer require laravel/nova"
            echo "php artisan nova:install"
            echo "php artisan migrate"
            ;;
        3)
            echo "composer require orchid/platform"
            echo "php artisan orchid:install"
            ;;
        4)
            echo "composer require backpack/crud"
            echo "php artisan backpack:install"
            ;;
    esac
    
    echo "composer require spatie/laravel-permission spatie/laravel-activitylog"
}

install_database_packages() {
    print_section "Database & ORM Packages"
    
    echo "Installing database packages..."
    echo "composer require spatie/laravel-sluggable"
    echo "composer require spatie/laravel-tags"
    echo "composer require spatie/laravel-model-states"
    echo "composer require owen-it/laravel-auditing"
    echo "composer require spatie/laravel-searchable"
    
    echo
    echo "Publishing configurations..."
    echo "php artisan vendor:publish --provider=\"Spatie\Tags\TagsServiceProvider\" --tag=\"migrations\""
    echo "php artisan vendor:publish --provider=\"OwenIt\Auditing\AuditingServiceProvider\" --tag=\"config\""
    echo "php artisan migrate"
    
    print_message "$GREEN" "✅ Database packages installed!"
}

install_media_packages() {
    print_section "Media & File Packages"
    
    echo "Installing media packages..."
    echo "composer require spatie/laravel-medialibrary"
    echo "composer require intervention/image"
    echo "composer require spatie/laravel-image-optimizer"
    echo "composer require maatwebsite/excel"
    echo "composer require barryvdh/laravel-dompdf"
    
    echo
    echo "Publishing configurations..."
    echo "php artisan vendor:publish --provider=\"Spatie\MediaLibrary\MediaLibraryServiceProvider\" --tag=\"migrations\""
    echo "php artisan migrate"
    
    print_message "$GREEN" "✅ Media packages installed!"
}

install_performance_packages() {
    print_section "Performance & Optimization Packages"
    
    echo "Installing performance packages..."
    echo "composer require laravel/horizon"
    echo "composer require laravel/telescope --dev"
    echo "composer require spatie/laravel-responsecache"
    echo "composer require barryvdh/laravel-httpcache"
    
    echo
    echo "Publishing configurations..."
    echo "php artisan horizon:install"
    echo "php artisan telescope:install"
    echo "php artisan migrate"
    
    print_message "$GREEN" "✅ Performance packages installed!"
}

install_security_packages() {
    print_section "Security Packages"
    
    echo "Installing security packages..."
    echo "composer require spatie/laravel-csp"
    echo "composer require spatie/laravel-honeypot"
    echo "composer require spatie/laravel-backup"
    echo "composer require spatie/laravel-activitylog"
    echo "composer require pragmarx/firewall"
    
    echo
    echo "Publishing configurations..."
    echo "php artisan vendor:publish --provider=\"Spatie\Csp\CspServiceProvider\""
    echo "php artisan vendor:publish --provider=\"Spatie\Backup\BackupServiceProvider\""
    echo "php artisan vendor:publish --provider=\"Spatie\Activitylog\ActivitylogServiceProvider\" --tag=\"activitylog-migrations\""
    echo "php artisan migrate"
    
    print_message "$GREEN" "✅ Security packages installed!"
}

install_testing_packages() {
    print_section "Testing & Development Packages"
    
    echo "Installing testing packages..."
    echo "composer require --dev pestphp/pest"
    echo "composer require --dev pestphp/pest-plugin-laravel"
    echo "composer require --dev barryvdh/laravel-debugbar"
    echo "composer require --dev barryvdh/laravel-ide-helper"
    echo "composer require --dev laravel/dusk"
    echo "composer require --dev spatie/laravel-ray"
    
    echo
    echo "Installing Pest..."
    echo "php artisan pest:install"
    
    echo
    echo "Installing Dusk..."
    echo "php artisan dusk:install"
    
    print_message "$GREEN" "✅ Testing packages installed!"
}

install_payment_packages() {
    print_section "Payment & E-commerce Packages"
    
    echo "Choose payment provider:"
    echo "  1) Laravel Cashier (Stripe)"
    echo "  2) Laravel Cashier (Paddle)"
    echo "  3) Both providers"
    echo "  4) Basic e-commerce packages"
    read -p "Choose [1-4]: " payment_choice
    
    case $payment_choice in
        1)
            echo "composer require laravel/cashier"
            echo "composer require spatie/laravel-stripe-webhooks"
            ;;
        2)
            echo "composer require laravel/cashier-paddle"
            echo "composer require spatie/laravel-paddle"
            ;;
        3)
            echo "composer require laravel/cashier laravel/cashier-paddle"
            echo "composer require spatie/laravel-stripe-webhooks spatie/laravel-paddle"
            ;;
        4)
            echo "composer require bavix/laravel-wallet treestoneit/shopping-cart"
            ;;
    esac
    
    echo
    echo "Publishing migrations..."
    echo "php artisan vendor:publish --tag=\"cashier-migrations\""
    echo "php artisan migrate"
    
    print_message "$GREEN" "✅ Payment packages installed!"
}

# Install packages based on category
case $CATEGORY in
    "auth") install_auth_packages ;;
    "api") install_api_packages ;;
    "admin") install_admin_packages ;;
    "database") install_database_packages ;;
    "media") install_media_packages ;;
    "performance") install_performance_packages ;;
    "security") install_security_packages ;;
    "testing") install_testing_packages ;;
    "payment") install_payment_packages ;;
    *)
        print_message "$RED" "❌ Unknown category: $CATEGORY"
        list_categories
        exit 1
        ;;
esac

print_section "Post-Installation Steps"

echo "Running post-installation commands..."
echo "php artisan cache:clear"
echo "php artisan config:clear"
echo "php artisan optimize"

print_message "$GREEN" "✅ Backend packages installation completed!"
echo
print_message "$CYAN" "Next steps:"
echo "  1. Review published configuration files"
echo "  2. Update your .env file with required settings"
echo "  3. Run 'php artisan migrate' if new migrations were added"
echo "  4. Configure service providers and middleware"
echo "  5. Update your application logic to use new packages"
echo
print_message "$YELLOW" "Useful commands:"
echo "  composer outdated         # Check for package updates"
echo "  composer audit            # Security audit"
echo "  php artisan optimize      # Optimize application"
echo "  php artisan config:cache  # Cache configuration"
echo
print_message "$GREEN" "Package category '$CATEGORY' installed successfully!"