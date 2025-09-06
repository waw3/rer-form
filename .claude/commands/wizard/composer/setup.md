---
allowed-tools: all
argument-hint: [--autoload <type>] [--scripts] [--repositories]
description: Configure and optimize Composer for Laravel projects
---

# Composer Setup Wizard

Configure Composer settings, autoloading, scripts, and repositories for optimal Laravel development.

## Usage

```bash
# Interactive composer configuration
/wizard:composer:setup

# Configure autoloading
/wizard:composer:setup --autoload psr4

# Set up custom scripts
/wizard:composer:setup --scripts

# Add custom repositories
/wizard:composer:setup --repositories
```

## Examples

```bash
# Example 1: Optimize autoloading
/wizard:composer:setup --autoload optimize

# Example 2: Add development scripts
/wizard:composer:setup --scripts dev

# Example 3: Configure private repositories
/wizard:composer:setup --repositories private

# Example 4: Full composer optimization
/wizard:composer:setup --optimize
```

## Command Execution

```bash
bash .claude/commands/wizard/composer/scripts/setup.sh "$@"
```

## Configuration Options

### Autoloading Optimization
- **PSR-4 Autoloading** - Standard namespace mapping
- **Classmap Generation** - Pre-compiled class locations
- **APCu Optimization** - Cache autoloader in APCu
- **Authorized Classes** - Preload specific classes
- **Files Autoloading** - Include helper files

### Platform Requirements
- **PHP Version** - Specify minimum PHP version
- **Extensions** - Required PHP extensions
- **Library Versions** - Dependency constraints
- **Stability** - Minimum stability level

### Repository Management
- **Packagist** - Default PHP repository
- **Private Repositories** - Custom package sources
- **VCS Repositories** - Git/SVN sources
- **Path Repositories** - Local packages
- **Artifact Repositories** - ZIP archives

### Script Management

#### Pre/Post Install Scripts
```json
"scripts": {
    "post-root-package-install": [
        "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
    ],
    "post-create-project-cmd": [
        "@php artisan key:generate --ansi"
    ]
}
```

#### Development Scripts
```json
"scripts": {
    "dev": "php artisan serve",
    "test": "@php artisan test",
    "test-coverage": "XDEBUG_MODE=coverage php artisan test --coverage",
    "format": "./vendor/bin/pint",
    "analyse": "./vendor/bin/phpstan analyse"
}
```

#### Production Scripts
```json
"scripts": {
    "production": [
        "@php artisan config:cache",
        "@php artisan route:cache",
        "@php artisan view:cache",
        "@php artisan event:cache"
    ]
}
```

### Performance Optimization

#### Autoloader Optimization
```bash
composer install --optimize-autoloader --no-dev
composer dump-autoload --optimize --apcu
```

#### Platform Check
```json
"config": {
    "platform-check": false,
    "optimize-autoloader": true,
    "preferred-install": "dist",
    "sort-packages": true
}
```

#### Prestissimo (Parallel Downloads)
```bash
composer global require hirak/prestissimo
```

### Security Configuration

#### Disable Scripts
```json
"config": {
    "secure-http": true,
    "discard-changes": true,
    "process-timeout": 0
}
```

#### Audit Dependencies
```bash
composer audit
composer audit --advisory-only
```

### Development Tools

#### Code Quality
- **phpstan/phpstan** - Static analysis
- **laravel/pint** - Code formatting
- **nunomaduro/larastan** - Laravel PHPStan
- **rector/rector** - Code refactoring
- **phpmd/phpmd** - Mess detector
- **squizlabs/php_codesniffer** - Coding standards

#### Testing
- **phpunit/phpunit** - Unit testing
- **pestphp/pest** - Elegant testing
- **mockery/mockery** - Mock objects
- **fakerphp/faker** - Test data generation

#### Debugging
- **barryvdh/laravel-debugbar** - Debug toolbar
- **laravel/telescope** - Debug assistant
- **spatie/laravel-ray** - Debug with Ray
- **symfony/var-dumper** - Variable dumping

### Common Configuration

#### composer.json
```json
{
    "name": "laravel/laravel",
    "type": "project",
    "description": "The Laravel Framework.",
    "keywords": ["framework", "laravel"],
    "license": "MIT",
    "require": {
        "php": "^8.2",
        "laravel/framework": "^12.0"
    },
    "require-dev": {
        "fakerphp/faker": "^1.23",
        "laravel/pint": "^1.13",
        "laravel/sail": "^1.26",
        "mockery/mockery": "^1.6",
        "nunomaduro/collision": "^8.0",
        "pestphp/pest": "^3.0",
        "pestphp/pest-plugin-laravel": "^3.0",
        "phpstan/phpstan": "^1.10"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi",
            "@php -r \"file_exists('database/database.sqlite') || touch('database/database.sqlite');\"",
            "@php artisan migrate --graceful --ansi"
        ]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
```

## Advanced Features

### Private Package Repository
```json
"repositories": [
    {
        "type": "composer",
        "url": "https://packages.example.com"
    },
    {
        "type": "vcs",
        "url": "git@github.com:company/private-package.git"
    },
    {
        "type": "path",
        "url": "../local-package"
    }
]
```

### Authentication
```bash
# Add authentication for private repositories
composer config --global --auth http-basic.repo.example.com username password

# GitHub OAuth token
composer config --global github-oauth.github.com <token>
```

### Caching
```bash
# Clear composer cache
composer clear-cache

# Set cache directory
composer config cache-dir /path/to/cache
```

## Optimization Commands

```bash
# Install with optimization
composer install --optimize-autoloader --no-dev

# Update with optimization
composer update --optimize-autoloader

# Dump autoload with optimization
composer dump-autoload --optimize

# Check for issues
composer validate --strict
composer diagnose
```

## Requirements

- PHP 8.2+
- Composer 2.0+
- Git for VCS repositories