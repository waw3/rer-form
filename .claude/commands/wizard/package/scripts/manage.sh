#!/bin/bash

# Package Management Wizard
# Manage, update, and audit Laravel project packages

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
UPDATE_MODE=false
REMOVE_MODE=false
CHECK_MODE=false
AUDIT_MODE=false
UPDATE_TYPE=""
REMOVE_TYPE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE_MODE=true
            UPDATE_TYPE="${2:-all}"
            shift 2
            ;;
        --remove)
            REMOVE_MODE=true
            REMOVE_TYPE="${2:-unused}"
            shift 2
            ;;
        --check)
            CHECK_MODE=true
            shift
            ;;
        --audit)
            AUDIT_MODE=true
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

# Interactive mode if no options specified
if [[ "$UPDATE_MODE" != true && "$REMOVE_MODE" != true && "$CHECK_MODE" != true && "$AUDIT_MODE" != true ]]; then
    print_message "$BLUE" "📦 Package Management Wizard"
    echo
    echo "Choose a package management operation:"
    echo "  1) Update packages"
    echo "  2) Remove unused packages"
    echo "  3) Check outdated packages"
    echo "  4) Security audit"
    echo "  5) Full package maintenance"
    read -p "Choose [1-5]: " operation_choice
    
    case $operation_choice in
        1) UPDATE_MODE=true ;;
        2) REMOVE_MODE=true ;;
        3) CHECK_MODE=true ;;
        4) AUDIT_MODE=true ;;
        5) 
            UPDATE_MODE=true
            CHECK_MODE=true
            AUDIT_MODE=true
            ;;
    esac
fi

# Check if composer is installed
if ! command -v composer &> /dev/null; then
    print_message "$RED" "❌ Composer is not installed"
    exit 1
fi

# Backup current state before operations
create_backup() {
    print_section "Creating Backup"
    echo "cp composer.lock composer.lock.backup.$(date +%Y%m%d_%H%M%S)"
    print_message "$YELLOW" "💾 Backup created for rollback if needed"
}

# Update packages
if [[ "$UPDATE_MODE" == true ]]; then
    create_backup
    
    print_section "Package Updates"
    
    if [[ -z "$UPDATE_TYPE" ]]; then
        echo "Choose update strategy:"
        echo "  1) Safe updates (within constraints)"
        echo "  2) Minor version updates"
        echo "  3) All updates (including major)"
        echo "  4) Security updates only"
        read -p "Choose [1-4]: " update_choice
        
        case $update_choice in
            1) UPDATE_TYPE="safe" ;;
            2) UPDATE_TYPE="minor" ;;
            3) UPDATE_TYPE="all" ;;
            4) UPDATE_TYPE="security" ;;
        esac
    fi
    
    case $UPDATE_TYPE in
        "safe")
            echo "Performing safe updates within version constraints..."
            echo "composer update --with-dependencies --prefer-stable"
            ;;
        "minor")
            echo "Updating to latest minor versions..."
            echo "composer update --with-dependencies"
            ;;
        "all")
            echo "Checking for major version updates..."
            echo "composer outdated --direct --major-only"
            echo "# Review and manually update major versions:"
            echo "# composer require vendor/package:^2.0"
            ;;
        "security")
            echo "Checking for security updates..."
            echo "composer audit"
            echo "composer update --with-dependencies --dry-run"
            ;;
    esac
    
    echo
    echo "Running post-update commands..."
    echo "composer dump-autoload --optimize"
    echo "php artisan cache:clear"
    echo "php artisan config:clear"
fi

# Remove packages
if [[ "$REMOVE_MODE" == true ]]; then
    print_section "Package Removal"
    
    if [[ -z "$REMOVE_TYPE" ]]; then
        echo "Choose removal operation:"
        echo "  1) Remove unused dependencies"
        echo "  2) Remove dev dependencies (production)"
        echo "  3) Clean vendor directory"
        echo "  4) Remove specific package"
        read -p "Choose [1-4]: " remove_choice
        
        case $remove_choice in
            1) REMOVE_TYPE="unused" ;;
            2) REMOVE_TYPE="dev" ;;
            3) REMOVE_TYPE="clean" ;;
            4) REMOVE_TYPE="specific" ;;
        esac
    fi
    
    case $REMOVE_TYPE in
        "unused")
            echo "Analyzing unused dependencies..."
            echo "composer show --tree"
            echo "# Review output and remove unused packages manually:"
            echo "# composer remove vendor/unused-package"
            ;;
        "dev")
            echo "Removing development dependencies..."
            echo "composer install --no-dev --optimize-autoloader"
            ;;
        "clean")
            echo "Cleaning vendor directory..."
            echo "rm -rf vendor"
            echo "composer install --optimize-autoloader"
            ;;
        "specific")
            read -p "Enter package name to remove: " package_name
            if [[ -n "$package_name" ]]; then
                echo "composer remove $package_name"
            fi
            ;;
    esac
fi

# Check outdated packages
if [[ "$CHECK_MODE" == true ]]; then
    print_section "Checking Outdated Packages"
    
    echo "Checking for outdated packages..."
    echo "composer outdated --direct"
    
    echo
    echo "Checking for major version updates..."
    echo "composer outdated --direct --major-only"
    
    echo
    echo "Checking for minor version updates..."
    echo "composer outdated --direct --minor-only"
    
    echo
    echo "Showing dependency tree..."
    echo "composer show --tree --no-dev"
fi

# Security audit
if [[ "$AUDIT_MODE" == true ]]; then
    print_section "Security Audit"
    
    echo "Running Composer security audit..."
    echo "composer audit"
    
    echo
    echo "Running detailed security check..."
    echo "composer audit --format=json | jq ."
    
    echo
    echo "Checking NPM packages for vulnerabilities..."
    echo "npm audit"
    
    echo
    echo "Installing security advisories package..."
    echo "composer require --dev roave/security-advisories:dev-latest"
    
    echo
    echo "Validating composer.json..."
    echo "composer validate --strict"
fi

print_section "Package Analysis"

echo "Analyzing package dependencies..."
echo
echo "# Show all installed packages:"
echo "composer show"
echo
echo "# Show package details:"
echo "composer show vendor/package"
echo
echo "# Why is package installed:"
echo "composer why vendor/package"
echo
echo "# What depends on package:"
echo "composer depends vendor/package"
echo
echo "# Check platform requirements:"
echo "composer check-platform-reqs"

print_section "Optimization"

echo "Optimizing package installation..."
echo "composer install --optimize-autoloader --no-dev"
echo "composer dump-autoload --optimize --apcu"
echo
echo "Clearing caches..."
echo "composer clear-cache"
echo "php artisan optimize:clear"
echo "php artisan optimize"

print_section "Version Lock Management"

echo "Version lock file operations:"
echo
echo "# Update lock file without changing dependencies:"
echo "composer update --lock"
echo
echo "# Install from exact lock file versions:"
echo "composer install"
echo
echo "# Show lock file differences:"
echo "composer show --locked"
echo
echo "# Refresh lock file:"
echo "rm composer.lock && composer install"

print_section "CI/CD Integration"

echo "Setting up automated package management..."
echo
echo "# GitHub Actions example for package updates:"
echo "name: Update Dependencies"
echo "on:"
echo "  schedule:"
echo "    - cron: '0 0 * * 1'  # Weekly on Monday"
echo "jobs:"
echo "  update:"
echo "    runs-on: ubuntu-latest"
echo "    steps:"
echo "      - uses: actions/checkout@v4"
echo "      - name: Update Composer packages"
echo "        run: |"
echo "          composer update --with-dependencies"
echo "          php artisan test"
echo "      - name: Create Pull Request"
echo "        if: success()"
echo "        # Create PR with updated packages"

echo
echo "# Dependabot configuration (.github/dependabot.yml):"
echo "version: 2"
echo "updates:"
echo "  - package-ecosystem: composer"
echo "    directory: /"
echo "    schedule:"
echo "      interval: weekly"
echo "    open-pull-requests-limit: 10"

print_section "Monitoring & Alerts"

echo "Package monitoring setup..."
echo
echo "# Services to monitor packages:"
echo "# - Dependabot (GitHub)"
echo "# - Renovate"
echo "# - Libraries.io"
echo "# - Snyk"
echo
echo "# Laravel-specific monitoring:"
echo "# - Laravel Shift (automated upgrades)"
echo "# - Laravel Security Advisories"

print_section "Troubleshooting"

echo "Common package management issues and solutions:"
echo
echo "# Memory limit errors:"
echo "php -d memory_limit=-1 composer update"
echo
echo "# Platform requirement conflicts:"
echo "composer install --ignore-platform-reqs"
echo
echo "# Dependency conflicts:"
echo "composer why-not vendor/package:^2.0"
echo "composer update --with-all-dependencies"
echo
echo "# Cache issues:"
echo "composer clear-cache"
echo "rm -rf vendor composer.lock"
echo "composer install"
echo
echo "# Lock file corruption:"
echo "rm composer.lock"
echo "composer update"

print_section "Best Practices"

echo "Package management best practices:"
echo
echo "1. Regular Maintenance Schedule:"
echo "   - Weekly: Security updates"
echo "   - Bi-weekly: Patch updates"
echo "   - Monthly: Minor updates"
echo "   - Quarterly: Major updates"
echo
echo "2. Testing Strategy:"
echo "   - Always backup before updates"
echo "   - Run tests after updates"
echo "   - Use staging environment"
echo "   - Document breaking changes"
echo
echo "3. Production Deployment:"
echo "   - Use exact versions (composer.lock)"
echo "   - No dev dependencies"
echo "   - Optimize autoloader"
echo "   - Cache configuration"

print_section "Automation Scripts"

echo "Creating package management automation scripts..."
echo
echo "# weekly-update.sh"
echo "#!/bin/bash"
echo "composer update --with-dependencies"
echo "php artisan test"
echo "if [ $? -eq 0 ]; then"
echo "  git add composer.lock"
echo "  git commit -m \"Weekly package updates\""
echo "  git push"
echo "fi"
echo
echo "# security-audit.sh"
echo "#!/bin/bash"
echo "composer audit"
echo "npm audit"
echo "composer outdated --direct"
echo
echo "# cleanup.sh"
echo "#!/bin/bash"
echo "composer clear-cache"
echo "rm -rf vendor node_modules"
echo "composer install --optimize-autoloader"
echo "npm ci"

print_message "$GREEN" "✅ Package management operations completed!"
echo
print_message "$CYAN" "Next steps:"
echo "  1. Review any package updates or changes"
echo "  2. Run your test suite to ensure compatibility"
echo "  3. Update documentation if needed"
echo "  4. Deploy changes to staging for testing"
echo "  5. Set up automated monitoring"
echo
print_message "$YELLOW" "Regular maintenance commands:"
echo "  composer outdated           # Check for updates"
echo "  composer audit             # Security check"
echo "  composer validate          # Validate composer.json"
echo "  composer diagnose          # Diagnose issues"
echo "  composer show --tree       # Dependency tree"
echo
print_message "$GREEN" "Package management wizard completed successfully!"