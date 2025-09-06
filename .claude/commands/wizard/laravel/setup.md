---
allowed-tools: all
argument-hint: [project-name] [--preset <preset-name>]
description: Complete Laravel project setup wizard with all packages and configurations
---

# Laravel Setup Wizard

Complete Laravel project setup wizard that guides you through creating a production-ready Laravel application with your choice of packages, frontend framework, and development tools.

## Usage

```bash
# Interactive wizard
/wizard:laravel:setup

# With project name
/wizard:laravel:setup my-app

# Load a preset configuration
/wizard:laravel:setup my-app --preset enterprise

# Quick setup with defaults
/wizard:laravel:setup my-app --quick
```

## Examples

```bash
# Example 1: Full interactive setup
/wizard:laravel:setup

# Example 2: Named project with enterprise preset
/wizard:laravel:setup saas-platform --preset enterprise

# Example 3: Quick API setup
/wizard:laravel:setup api-service --preset api

# Example 4: Inertia + Vue setup
/wizard:laravel:setup spa-app --preset inertia-vue
```

## Command Execution

```bash
bash .claude/commands/wizard/laravel/scripts/setup.sh "$@"
```

## Available Presets

### enterprise
- Laravel 12.x
- Inertia.js + Vue 3 + TypeScript
- Spatie Permission, Activity Log, Media Library
- Laravel Telescope, Horizon
- PHPStan Level 9, Laravel Pint
- Full testing suite (Pest + Vitest)

### api
- Laravel 12.x  
- Laravel Sanctum, API Resources
- Spatie Query Builder, Laravel Data
- OpenAPI documentation
- Rate limiting, API versioning
- PHPStan, Pest for testing

### inertia-vue
- Laravel 12.x
- Inertia.js + Vue 3 + TypeScript
- Quasar UI Framework
- Pinia state management
- Vite, ESLint, Prettier
- Vitest for frontend testing

### minimal
- Laravel 12.x
- No additional packages
- Basic authentication
- File-based cache and sessions
- SQLite database
- Minimal tooling

## Interactive Mode Options

### 1. Laravel Version
- 12.x (Latest Stable)
- 11.x (LTS)
- 10.x (Previous LTS)
- Custom version

### 2. Project Type
- Full-Stack Application (Blade/Inertia)
- API Only
- Admin Panel
- E-commerce Platform
- SaaS Application
- Custom

### 3. Authentication
- Laravel Breeze
- Laravel Jetstream
- Laravel Sanctum (API)
- Laravel Passport
- Custom implementation
- None

### 4. Frontend Framework
- Inertia.js + Vue 3
- Inertia.js + React
- Livewire + Alpine.js
- Blade + Alpine.js
- API Only (no frontend)
- Custom

### 5. Database
- MySQL 8.0+
- PostgreSQL 14+
- SQLite
- MariaDB 10.5+
- SQL Server
- MongoDB

### 6. Popular Packages
#### Admin & Dashboard
- Filament Admin Panel
- Laravel Nova
- Orchid Platform
- Voyager Admin

#### API Development
- Laravel Sanctum
- Spatie Laravel Data
- Spatie Query Builder
- Laravel API Resources

#### Media & Files
- Spatie Media Library
- Laravel File Manager
- Intervention Image
- Laravel Excel

#### Security & Auth
- Spatie Permission
- Laravel 2FA
- Laravel Socialite
- Laravel Fortify

#### Performance
- Laravel Octane
- Laravel Horizon
- Laravel Telescope
- Laravel Pulse

### 7. Development Tools
- PHPStan / Larastan
- Laravel Pint
- PHP CS Fixer
- Laravel IDE Helper
- Laravel Debugbar

### 8. Testing
- PHPUnit
- Pest PHP
- Laravel Dusk
- Database factories & seeders

## Output Files

The wizard generates:

### install.sh
Complete installation script with all selections

### composer.json
Updated with selected packages

### package.json  
Frontend dependencies and scripts

### .env.example
Environment configuration template

### Configuration Files
- phpstan.neon
- pint.json
- .eslintrc.js
- prettier.config.js
- tsconfig.json
- vite.config.js

### Documentation
- README.md with setup instructions
- API.md for API documentation
- DEPLOYMENT.md for deployment guide

## Post-Installation

After the wizard completes:

```bash
# Navigate to project
cd <project-name>

# Install dependencies
composer install
npm install

# Set up environment
cp .env.example .env
php artisan key:generate

# Run migrations
php artisan migrate

# Start development
php artisan serve
npm run dev
```

## Customization

The wizard supports:
- Saving custom presets
- Loading team configurations
- Exporting setup as JSON
- Version control integration
- Docker configuration
- CI/CD pipeline setup

## Requirements

- PHP 8.2+
- Composer 2.0+
- Node.js 18+
- Git