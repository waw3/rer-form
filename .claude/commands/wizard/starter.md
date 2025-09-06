---
allowed-tools: all
argument-hint: [project-name] [--preset <preset>] [--skip <steps>]
description: Master wizard that orchestrates all setup wizards in systematic order for complete Laravel project setup
---

# Laravel Starter Wizard

Master orchestration wizard that runs all setup wizards in the optimal order to create a complete, production-ready Laravel application.

## Usage

```bash
# Full interactive setup
/wizard:starter

# Named project with all wizards
/wizard:starter my-awesome-app

# Use a preset configuration
/wizard:starter my-app --preset saas

# Skip certain steps
/wizard:starter my-app --skip testing,docker
```

## Examples

```bash
# Example 1: Complete SaaS application
/wizard:starter saas-platform --preset saas

# Example 2: API-only project
/wizard:starter api-service --preset api

# Example 3: Admin panel project
/wizard:starter admin-dashboard --preset admin

# Example 4: Minimal setup, skip optional steps
/wizard:starter simple-app --preset minimal --skip docker,testing
```

## Command Execution

```bash
bash .claude/commands/wizard/scripts/starter.sh "$@"
```

## Execution Order

The starter wizard executes sub-wizards in this systematic order:

### Phase 1: Environment Setup
1. **Environment Setup** (`/wizard:environment:setup`)
   - Configure development environment
   - Choose between Herd, Docker, or Sail
   - Set up Git repository
   - Initialize version control

### Phase 2: Core Laravel
2. **Laravel Setup** (`/wizard:laravel:setup`)
   - Create Laravel project
   - Choose Laravel version
   - Select project type
   - Configure authentication
   - Set up database connection

### Phase 3: Backend Configuration
3. **Database Setup** (`/wizard:database:setup`)
   - Configure database driver
   - Create initial migrations
   - Set up seeders
   - Configure multiple connections if needed

4. **Backend Packages** (`/wizard:backend:packages`)
   - Install Laravel packages
   - Configure package settings
   - Publish vendor files
   - Run package migrations

### Phase 4: Frontend Setup
5. **Frontend Setup** (`/wizard:frontend:setup`)
   - Choose frontend framework
   - Select UI component library
   - Configure build tools
   - Set up hot module replacement

### Phase 5: Development Tools
6. **Composer Setup** (`/wizard:composer:setup`)
   - Optimize autoloading
   - Configure repositories
   - Set up scripts
   - Add development tools

7. **Testing Setup** (`/wizard:testing:setup`)
   - Choose testing framework
   - Configure coverage tools
   - Set up E2E testing
   - Create initial tests

### Phase 6: CI/CD & Deployment
8. **GitHub Workflows** (`/wizard:environment:setup --ci`)
   - Create CI/CD pipelines
   - Set up automated testing
   - Configure deployment workflows
   - Add security scanning

### Phase 7: Final Configuration
9. **Package Management** (`/wizard:package:manage`)
   - Audit dependencies
   - Update packages
   - Configure security policies
   - Optimize for production

## Preset Configurations

### SaaS Preset
```yaml
preset: saas
steps:
  environment:
    tool: docker
    ci: github
  laravel:
    version: 12.x
    type: saas
    auth: jetstream
  database:
    driver: postgresql
    cache: redis
    queue: redis
  backend:
    packages:
      - laravel/cashier-stripe
      - spatie/laravel-permission
      - spatie/laravel-multitenancy
      - laravel/horizon
      - laravel/telescope
  frontend:
    framework: vue3
    ui: quasar
    typescript: true
  testing:
    framework: pest
    coverage: true
    e2e: playwright
```

### API Preset
```yaml
preset: api
steps:
  environment:
    tool: docker
    ci: github
  laravel:
    version: 12.x
    type: api
    auth: sanctum
  database:
    driver: postgresql
    cache: redis
  backend:
    packages:
      - laravel/sanctum
      - spatie/laravel-data
      - spatie/laravel-query-builder
      - laravel/horizon
      - spatie/laravel-route-discovery
  frontend:
    skip: true
  testing:
    framework: pest
    coverage: true
```

### Admin Preset
```yaml
preset: admin
steps:
  environment:
    tool: herd
    ci: github
  laravel:
    version: 12.x
    type: admin
    auth: breeze
  database:
    driver: mysql
    cache: file
  backend:
    packages:
      - filament/filament
      - spatie/laravel-permission
      - spatie/laravel-activitylog
      - spatie/laravel-medialibrary
      - maatwebsite/excel
  frontend:
    framework: alpine
    ui: tailwind
  testing:
    framework: phpunit
    e2e: dusk
```

### Minimal Preset
```yaml
preset: minimal
steps:
  environment:
    tool: herd
    ci: none
  laravel:
    version: 12.x
    type: web
    auth: breeze
  database:
    driver: sqlite
    cache: file
  backend:
    packages: []
  frontend:
    framework: blade
    ui: tailwind
  testing:
    framework: phpunit
```

## Interactive Mode Flow

### Step 1: Project Information
```
🚀 Laravel Starter Wizard

Project name: my-awesome-app
Project type:
  1. SaaS Application
  2. API Service
  3. Admin Dashboard
  4. E-commerce Platform
  5. Blog/CMS
  6. Custom

Choose [1-6]: _
```

### Step 2: Development Environment
```
🛠️ Development Environment

Local development tool:
  1. Laravel Herd (Recommended for macOS)
  2. Docker Compose
  3. Laravel Sail
  4. Manual setup

Choose [1-4]: _

Version control:
  1. GitHub
  2. GitLab
  3. Bitbucket
  4. None

Choose [1-4]: _
```

### Step 3: Technology Stack
```
🎯 Technology Stack

Backend:
  ✓ Laravel 12.x
  ✓ PHP 8.3
  
Database:
  1. MySQL 8.0
  2. PostgreSQL 15
  3. SQLite
  4. MongoDB

Choose [1-4]: _

Frontend:
  1. Inertia.js + Vue 3
  2. Inertia.js + React
  3. Livewire + Alpine.js
  4. API Only (no frontend)
  5. Blade + Alpine.js

Choose [1-5]: _
```

### Step 4: Feature Selection
```
📦 Features & Packages

Authentication:
  1. Laravel Breeze
  2. Laravel Jetstream
  3. Laravel Sanctum (API)
  4. Custom
  5. None

Choose [1-5]: _

Admin Panel:
  1. Filament
  2. Laravel Nova
  3. Custom
  4. None

Choose [1-4]: _

Payment Processing:
  1. Stripe (Laravel Cashier)
  2. Paddle
  3. Custom
  4. None

Choose [1-4]: _
```

### Step 5: Development Tools
```
🔧 Development Tools

Code Quality:
  ✓ Laravel Pint
  ✓ PHPStan (Level 8)
  ✓ ESLint + Prettier
  ✓ TypeScript

Testing:
  1. Pest + Vitest
  2. PHPUnit + Jest
  3. Minimal testing

Choose [1-3]: _

CI/CD:
  ✓ GitHub Actions
  ✓ Automated testing
  ✓ Security scanning
  ✓ Deployment pipeline
```

## Progress Tracking

```
📊 Setup Progress

[✓] Environment Setup
[✓] Laravel Installation
[✓] Database Configuration
[⏳] Installing Backend Packages...
[ ] Frontend Setup
[ ] Composer Optimization
[ ] Testing Configuration
[ ] CI/CD Pipeline
[ ] Final Steps

Estimated time remaining: 5 minutes
```

## Generated Project Structure

```
my-awesome-app/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── deploy.yml
│   │   └── security.yml
│   └── dependabot.yml
├── app/
│   ├── Http/
│   ├── Models/
│   └── Services/
├── bootstrap/
├── config/
├── database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
├── docker/
│   ├── nginx/
│   ├── php/
│   └── mysql/
├── public/
├── resources/
│   ├── js/
│   │   ├── Components/
│   │   ├── Pages/
│   │   └── app.ts
│   ├── css/
│   └── views/
├── routes/
├── storage/
├── tests/
│   ├── Feature/
│   ├── Unit/
│   └── E2E/
├── .env.example
├── .gitignore
├── composer.json
├── docker-compose.yml
├── package.json
├── phpstan.neon
├── pint.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## Post-Setup Commands

```bash
# Navigate to project
cd my-awesome-app

# Start development environment
# If using Herd:
herd link
herd open

# If using Docker:
docker-compose up -d

# If using Sail:
./vendor/bin/sail up -d

# Start development servers
php artisan serve
npm run dev

# Run initial tests
php artisan test
npm run test

# View in browser
open http://localhost:8000
```

## Customization Options

### Skip Steps
```bash
# Skip specific wizards
/wizard:starter my-app --skip docker,testing

# Skip multiple steps
/wizard:starter my-app --skip frontend,testing,ci
```

### Override Defaults
```bash
# Force specific options
/wizard:starter my-app \
  --laravel-version 11.x \
  --php-version 8.2 \
  --database mysql \
  --frontend vue3
```

### Save Configuration
```bash
# Save configuration for reuse
/wizard:starter my-app --save-preset my-preset

# Use saved preset
/wizard:starter another-app --preset my-preset
```

## Error Recovery

If the wizard fails at any step:

1. **Resume from last step**
   ```bash
   /wizard:starter --resume
   ```

2. **Skip failed step**
   ```bash
   /wizard:starter --skip-failed
   ```

3. **Rollback changes**
   ```bash
   /wizard:starter --rollback
   ```

## Requirements

- PHP 8.2+
- Composer 2.0+
- Node.js 18+
- Git 2.0+
- Docker Desktop (optional)
- Laravel Herd (optional)
- 4GB RAM minimum
- 2GB free disk space