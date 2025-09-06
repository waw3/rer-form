---
allowed-tools: all
argument-hint: [--category <category>] [--list]
description: Add and manage Laravel backend packages with intelligent recommendations
---

# Backend Packages Wizard

Add, configure, and manage Laravel backend packages with category-based recommendations and automatic configuration.

## Usage

```bash
# Interactive package selection
/wizard:backend:packages

# List available categories
/wizard:backend:packages --list

# Install by category
/wizard:backend:packages --category auth

# Quick install popular packages
/wizard:backend:packages --popular
```

## Examples

```bash
# Example 1: Add authentication packages
/wizard:backend:packages --category auth

# Example 2: Add API development packages
/wizard:backend:packages --category api

# Example 3: Add admin panel
/wizard:backend:packages --category admin

# Example 4: Performance packages
/wizard:backend:packages --category performance
```

## Command Execution

```bash
bash .claude/commands/wizard/backend/scripts/packages.sh "$@"
```

## Package Categories

### Authentication & Authorization
- **laravel/sanctum** - Token-based API auth
- **laravel/passport** - Full OAuth2 server
- **laravel/fortify** - Backend auth implementation
- **spatie/laravel-permission** - Roles & permissions
- **laravel/socialite** - OAuth providers
- **spatie/laravel-2fa** - Two-factor auth
- **pragmarx/google2fa-laravel** - Google 2FA

### API Development
- **spatie/laravel-data** - Data transfer objects
- **spatie/laravel-query-builder** - API query builder
- **spatie/laravel-fractal** - API transformers
- **laravel/sanctum** - API authentication
- **barryvdh/laravel-cors** - CORS handling
- **spatie/laravel-json-api-paginate** - JSON API pagination
- **spatie/laravel-route-discovery** - Auto route discovery

### Admin Panels
- **filament/filament** - Modern admin panel
- **laravel/nova** - Official admin panel
- **orchid/platform** - RAD platform
- **laravel-backpack/crud** - CRUD interface
- **tcg/voyager** - Admin & BREAD
- **encore/laravel-admin** - Grid/Form builder

### Database & ORM
- **spatie/laravel-sluggable** - Generate slugs
- **spatie/laravel-tags** - Taggable models
- **spatie/laravel-model-states** - State machines
- **spatie/laravel-schemaless-attributes** - NoSQL attributes
- **owen-it/laravel-auditing** - Model auditing
- **spatie/laravel-searchable** - Search multiple models
- **staudenmeir/eloquent-has-many-deep** - Deep relationships

### Media & Files
- **spatie/laravel-medialibrary** - File associations
- **intervention/image** - Image manipulation
- **spatie/laravel-image-optimizer** - Image optimization
- **maatwebsite/excel** - Excel import/export
- **barryvdh/laravel-dompdf** - PDF generation
- **spatie/laravel-pdf** - PDF creation
- **league/flysystem-aws-s3-v3** - S3 storage

### Performance & Optimization
- **laravel/octane** - High performance
- **laravel/horizon** - Queue dashboard
- **laravel/telescope** - Debug assistant
- **laravel/pulse** - Performance monitoring
- **spatie/laravel-responsecache** - Response caching
- **barryvdh/laravel-httpcache** - HTTP caching
- **spatie/laravel-query-builder** - Efficient queries

### Security
- **spatie/laravel-csp** - Content Security Policy
- **spatie/laravel-honeypot** - Spam protection
- **spatie/laravel-backup** - Backup solution
- **spatie/laravel-activitylog** - Activity logging
- **pragmarx/firewall** - IP firewall
- **spatie/laravel-rate-limited-job-middleware** - Rate limiting
- **emargareten/eloquent-encryption** - Model encryption

### Testing & Development
- **pestphp/pest** - Elegant testing
- **pestphp/pest-plugin-laravel** - Laravel plugin
- **barryvdh/laravel-debugbar** - Debug toolbar
- **barryvdh/laravel-ide-helper** - IDE support
- **laravel/dusk** - Browser testing
- **spatie/laravel-ray** - Debug with Ray
- **beyondcode/laravel-dump-server** - Dump server

### Payment & E-commerce
- **laravel/cashier-stripe** - Stripe subscriptions
- **laravel/cashier-paddle** - Paddle subscriptions
- **spatie/laravel-stripe-webhooks** - Stripe webhooks
- **spatie/laravel-paddle** - Paddle integration
- **bavix/laravel-wallet** - Wallet system
- **treestoneit/shopping-cart** - Shopping cart

### Notifications & Communication
- **laravel/vonage-notification-channel** - SMS
- **laravel-notification-channels/telegram** - Telegram
- **laravel-notification-channels/discord** - Discord
- **laravel-notification-channels/slack** - Slack
- **spatie/laravel-webhook-server** - Send webhooks
- **spatie/laravel-webhook-client** - Receive webhooks
- **pusher/pusher-php-server** - Real-time events

### SEO & Marketing
- **spatie/laravel-sitemap** - Generate sitemaps
- **spatie/laravel-feed** - RSS/Atom feeds
- **artesaos/seotools** - SEO meta tags
- **spatie/laravel-analytics** - Google Analytics
- **spatie/laravel-newsletter** - Newsletter subscriptions
- **spatie/laravel-cookie-consent** - Cookie consent

### Localization & Multi-tenancy
- **spatie/laravel-translatable** - Translatable models
- **mcamara/laravel-localization** - Route localization
- **spatie/laravel-translation-loader** - DB translations
- **spatie/laravel-multitenancy** - Multi-tenancy
- **stancl/tenancy** - Automatic tenancy
- **hyn/multi-tenant** - Multi-tenant

## Package Configuration

The wizard automatically:

### 1. Installs packages
```bash
composer require package/name
```

### 2. Publishes configuration
```bash
php artisan vendor:publish --provider="Provider"
```

### 3. Runs migrations
```bash
php artisan migrate
```

### 4. Creates configuration files
- Config files in `config/`
- Environment variables in `.env`
- Service provider registration

### 5. Sets up middleware
- Registers in kernel
- Configures routes
- Sets up guards

## Smart Recommendations

Based on your project type:

### For APIs
- Sanctum + API Resources
- Query Builder + Data DTOs
- OpenAPI documentation
- Rate limiting

### For Admin Panels
- Filament or Nova
- Permission system
- Activity logging
- Media library

### For E-commerce
- Payment gateway
- Shopping cart
- Inventory management
- Order processing

### For SaaS
- Multi-tenancy
- Subscription billing
- Team management
- Usage tracking

## Post-Installation

After package installation:

```bash
# Clear caches
php artisan cache:clear
php artisan config:clear

# Optimize
php artisan optimize

# Run migrations
php artisan migrate

# Seed if needed
php artisan db:seed
```

## Package Management

### Update packages
```bash
composer update
```

### Remove packages
```bash
composer remove package/name
```

### Check outdated
```bash
composer outdated
```

### Security audit
```bash
composer audit
```

## Requirements

- PHP 8.2+
- Composer 2.0+
- Laravel 10.0+