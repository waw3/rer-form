#!/bin/bash

# Composer Setup Wizard
# Configure and optimize Composer for Laravel projects

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
AUTOLOAD_TYPE="${1:-}"
SETUP_SCRIPTS=false
SETUP_REPOSITORIES=false
OPTIMIZE_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --autoload)
            AUTOLOAD_TYPE="$2"
            shift 2
            ;;
        --scripts)
            SETUP_SCRIPTS=true
            shift
            ;;
        --repositories)
            SETUP_REPOSITORIES=true
            shift
            ;;
        --optimize)
            OPTIMIZE_MODE=true
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
    print_message "$BLUE" "🎼 $1"
    echo
}

# Interactive mode if no options specified
if [[ -z "$AUTOLOAD_TYPE" && "$SETUP_SCRIPTS" != true && "$SETUP_REPOSITORIES" != true && "$OPTIMIZE_MODE" != true ]]; then
    print_message "$BLUE" "🎼 Composer Setup Wizard"
    echo
    echo "Choose configuration options:"
    echo "  1) Optimize autoloading"
    echo "  2) Setup development scripts"
    echo "  3) Configure repositories"
    echo "  4) Full optimization"
    echo "  5) Interactive setup"
    read -p "Choose [1-5]: " setup_choice
    
    case $setup_choice in
        1) AUTOLOAD_TYPE="optimize" ;;
        2) SETUP_SCRIPTS=true ;;
        3) SETUP_REPOSITORIES=true ;;
        4) OPTIMIZE_MODE=true ;;
        5) 
            SETUP_SCRIPTS=true
            SETUP_REPOSITORIES=true
            AUTOLOAD_TYPE="optimize"
            ;;
    esac
fi

print_section "Composer Configuration"

# Check if composer is installed
if ! command -v composer &> /dev/null; then
    print_message "$RED" "❌ Composer is not installed"
    print_message "$YELLOW" "Install Composer from https://getcomposer.org"
    exit 1
fi

print_message "$GREEN" "✅ Composer $(composer --version | head -n1 | cut -d' ' -f3) found"

# Optimize autoloading
if [[ "$AUTOLOAD_TYPE" == "optimize" || "$OPTIMIZE_MODE" == true ]]; then
    print_section "Optimizing Autoloader"
    
    echo "Generating optimized autoloader..."
    echo "composer dump-autoload --optimize"
    
    echo
    echo "Enabling APCu optimization..."
    echo "composer dump-autoload --apcu"
    
    echo
    echo "Configuring composer.json for optimization:"
    echo '{'
    echo '  "config": {'
    echo '    "optimize-autoloader": true,'
    echo '    "preferred-install": "dist",'
    echo '    "sort-packages": true,'
    echo '    "apcu-autoloader": true,'
    echo '    "platform-check": false'
    echo '  }'
    echo '}'
fi

# Setup development scripts
if [[ "$SETUP_SCRIPTS" == true || "$OPTIMIZE_MODE" == true ]]; then
    print_section "Development Scripts"
    
    echo "Adding useful development scripts to composer.json:"
    echo
    echo '"scripts": {'
    echo '  "post-autoload-dump": ['
    echo '    "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",'
    echo '    "@php artisan package:discover --ansi"'
    echo '  ],'
    echo '  "post-update-cmd": ['
    echo '    "@php artisan vendor:publish --tag=laravel-assets --ansi --force"'
    echo '  ],'
    echo '  "post-root-package-install": ['
    echo '    "@php -r \"file_exists(\'.env\') || copy(\'.env.example\', \'.env\');\""'
    echo '  ],'
    echo '  "post-create-project-cmd": ['
    echo '    "@php artisan key:generate --ansi",'
    echo '    "@php artisan migrate --graceful --ansi"'
    echo '  ],'
    echo
    echo '  "dev": "php artisan serve",'
    echo '  "fresh": ['
    echo '    "php artisan migrate:fresh",'
    echo '    "php artisan db:seed"'
    echo '  ],'
    echo '  "test": "@php artisan test",'
    echo '  "test-coverage": "XDEBUG_MODE=coverage php artisan test --coverage",'
    echo '  "format": "./vendor/bin/pint",'
    echo '  "analyse": "./vendor/bin/phpstan analyse",'
    echo '  "insights": "./vendor/bin/phpinsights",'
    echo
    echo '  "production": ['
    echo '    "@php artisan config:cache",'
    echo '    "@php artisan route:cache",'
    echo '    "@php artisan view:cache",'
    echo '    "@php artisan event:cache"'
    echo '  ],'
    echo '  "production-clear": ['
    echo '    "@php artisan config:clear",'
    echo '    "@php artisan route:clear",'
    echo '    "@php artisan view:clear",'
    echo '    "@php artisan cache:clear"'
    echo '  ]'
    echo '}'
fi

# Setup repositories
if [[ "$SETUP_REPOSITORIES" == true || "$OPTIMIZE_MODE" == true ]]; then
    print_section "Repository Configuration"
    
    echo "Choose repository setup:"
    echo "  1) Add private repository"
    echo "  2) Add VCS repository"
    echo "  3) Add local path repository"
    echo "  4) Skip repository setup"
    read -p "Choose [1-4]: " repo_choice
    
    case $repo_choice in
        1)
            echo
            read -p "Enter private repository URL: " repo_url
            echo '"repositories": ['
            echo '  {'
            echo '    "type": "composer",'
            echo "    \"url\": \"$repo_url\""
            echo '  }'
            echo ']'
            ;;
        2)
            echo
            read -p "Enter VCS repository URL: " vcs_url
            echo '"repositories": ['
            echo '  {'
            echo '    "type": "vcs",'
            echo "    \"url\": \"$vcs_url\""
            echo '  }'
            echo ']'
            ;;
        3)
            echo
            read -p "Enter local package path: " local_path
            echo '"repositories": ['
            echo '  {'
            echo '    "type": "path",'
            echo "    \"url\": \"$local_path\""
            echo '  }'
            echo ']'
            ;;
    esac
fi

print_section "Security Configuration"

echo "Installing security advisories package..."
echo "composer require --dev roave/security-advisories:dev-latest"

echo
echo "Running security audit..."
echo "composer audit"

echo
echo "Security configuration options:"
echo '"config": {'
echo '  "secure-http": true,'
echo '  "disable-tls": false,'
echo '  "cafile": null,'
echo '  "process-timeout": 300'
echo '}'

print_section "Performance Optimization"

echo "Installing performance packages..."
echo "composer global require hirak/prestissimo"  # Parallel downloads

echo
echo "Cache configuration:"
echo "composer config cache-files-dir ~/.composer/cache/files"
echo "composer config cache-repo-dir ~/.composer/cache/repo"

echo
echo "Platform configuration:"
echo '"config": {'
echo '  "platform": {'
echo '    "php": "8.2.0"'
echo '  },'
echo '  "platform-check": false'
echo '}'

print_section "Development Tools"

echo "Installing essential development packages..."
echo "composer require --dev barryvdh/laravel-ide-helper"
echo "composer require --dev barryvdh/laravel-debugbar"
echo "composer require --dev laravel/pint"
echo "composer require --dev nunomaduro/phpinsights"
echo "composer require --dev phpstan/phpstan"
echo "composer require --dev nunomaduro/larastan"

echo
echo "Installing testing packages..."
echo "composer require --dev pestphp/pest"
echo "composer require --dev pestphp/pest-plugin-laravel"
echo "composer require --dev mockery/mockery"
echo "composer require --dev fakerphp/faker"

print_section "Autoload Configuration"

echo "Optimizing PSR-4 autoloading:"
echo '"autoload": {'
echo '  "psr-4": {'
echo '    "App\\\\": "app/",'
echo '    "Database\\\\Factories\\\\": "database/factories/",'
echo '    "Database\\\\Seeders\\\\": "database/seeders/"'
echo '  },'
echo '  "files": ['
echo '    "app/helpers.php"'
echo '  ]'
echo '},'
echo '"autoload-dev": {'
echo '  "psr-4": {'
echo '    "Tests\\\\": "tests/"'
echo '  }'
echo '}'

print_section "Plugin Management"

echo "Allowed plugins configuration:"
echo '"config": {'
echo '  "allow-plugins": {'
echo '    "pestphp/pest-plugin": true,'
echo '    "php-http/discovery": true,'
echo '    "dealerdirect/phpcodesniffer-composer-installer": true'
echo '  }'
echo '}'

print_section "Environment-Specific Configuration"

echo "Development environment:"
echo "composer install --optimize-autoloader"

echo
echo "Production environment:"
echo "composer install --no-dev --optimize-autoloader --no-scripts"

echo
echo "CI/CD environment:"
echo "composer install --no-interaction --no-progress --no-ansi --optimize-autoloader"

print_section "Maintenance Commands"

echo "Useful Composer commands:"
echo
echo "# Package management:"
echo "composer update                    # Update all packages"
echo "composer update --lock            # Update lock file only"
echo "composer require vendor/package   # Add package"
echo "composer remove vendor/package    # Remove package"
echo
echo "# Information:"
echo "composer show                      # List installed packages"
echo "composer show vendor/package      # Package details"
echo "composer outdated                 # Show outdated packages"
echo "composer why vendor/package       # Why is package installed"
echo "composer depends vendor/package   # What depends on package"
echo
echo "# Optimization:"
echo "composer dump-autoload --optimize # Optimize autoloader"
echo "composer clear-cache              # Clear cache"
echo "composer validate                 # Validate composer.json"
echo "composer diagnose                 # Diagnose issues"
echo
echo "# Security:"
echo "composer audit                    # Security audit"
echo "composer audit --format=json     # JSON output"

print_section "Authentication Setup"

echo "For private repositories, set up authentication:"
echo
echo "# HTTP Basic Auth:"
echo "composer config --global --auth http-basic.repo.example.com username password"
echo
echo "# GitHub OAuth token:"
echo "composer config --global github-oauth.github.com YOUR_TOKEN"
echo
echo "# GitLab OAuth token:"
echo "composer config --global gitlab-oauth.gitlab.example.com YOUR_TOKEN"

print_section "Complete composer.json Example"

echo "Complete optimized composer.json structure:"
echo '{'
echo '  "name": "laravel/laravel",'
echo '  "type": "project",'
echo '  "description": "The Laravel Framework.",'
echo '  "keywords": ["framework", "laravel"],'
echo '  "license": "MIT",'
echo '  "require": {'
echo '    "php": "^8.2",'
echo '    "laravel/framework": "^12.0"'
echo '  },'
echo '  "require-dev": {'
echo '    "fakerphp/faker": "^1.23",'
echo '    "laravel/pint": "^1.13",'
echo '    "mockery/mockery": "^1.6",'
echo '    "nunomaduro/collision": "^8.0",'
echo '    "pestphp/pest": "^3.0",'
echo '    "pestphp/pest-plugin-laravel": "^3.0"'
echo '  },'
echo '  "autoload": { /* ... */ },'
echo '  "autoload-dev": { /* ... */ },'
echo '  "scripts": { /* ... */ },'
echo '  "extra": {'
echo '    "laravel": {'
echo '      "dont-discover": []'
echo '    }'
echo '  },'
echo '  "config": {'
echo '    "optimize-autoloader": true,'
echo '    "preferred-install": "dist",'
echo '    "sort-packages": true,'
echo '    "allow-plugins": { /* ... */ }'
echo '  },'
echo '  "minimum-stability": "stable",'
echo '  "prefer-stable": true'
echo '}'

if [[ "$OPTIMIZE_MODE" == true ]]; then
    print_section "Final Optimization"
    
    echo "Running final optimization commands..."
    echo "composer install --optimize-autoloader --no-dev"
    echo "composer validate --strict"
    echo "composer diagnose"
    echo "composer audit"
fi

print_message "$GREEN" "✅ Composer setup completed!"
echo
print_message "$CYAN" "Next steps:"
echo "  1. Review and update your composer.json file"
echo "  2. Run 'composer install' to apply changes"
echo "  3. Set up authentication for private repositories"
echo "  4. Configure your CI/CD pipeline"
echo "  5. Run 'composer validate' to check configuration"
echo
print_message "$YELLOW" "Useful commands:"
echo "  composer dev              # Start development server"
echo "  composer test             # Run tests"
echo "  composer format           # Format code"
echo "  composer analyse          # Static analysis"
echo "  composer production       # Optimize for production"
echo
print_message "$GREEN" "Composer optimized for Laravel development!"