# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Laravel 12 application with Vue 3/Inertia.js frontend using Vite for asset bundling. The application uses Laravel Breeze for authentication scaffolding and Tailwind CSS for styling.

## Development Commands

### Running the Application
```bash
# Start all services (server, queue, logs, vite)
composer run dev

# Or start services individually
php artisan serve       # Laravel server
npm run dev            # Vite dev server
php artisan queue:listen --tries=1  # Queue worker
php artisan pail       # Real-time log viewer
```

### Building Assets
```bash
npm run build          # Production build with Vite
```

### Testing
```bash
# Run all tests
composer test
# or
php artisan test

# Run specific test file
php artisan test tests/Feature/ExampleTest.php

# Run with Pest (installed)
./vendor/bin/pest
```

### Code Quality
```bash
# Format PHP code with Laravel Pint
./vendor/bin/pint

# Generate API documentation
php artisan scribe:generate
```

### Database
```bash
php artisan migrate              # Run migrations
php artisan migrate:fresh --seed # Fresh migration with seeders
php artisan tinker              # Interactive REPL
```

## Architecture

### Backend Structure
- **app/Http/Controllers** - HTTP controllers for web and API routes
- **app/Http/Middleware** - Custom middleware (HandleInertiaRequests for Inertia.js)
- **app/Models** - Eloquent models (User model with Sanctum)
- **routes/web.php** - Web routes using Inertia responses
- **routes/auth.php** - Authentication routes (Breeze)

### Frontend Structure
- **resources/js/Pages** - Vue components for Inertia pages
- **resources/js/Components** - Reusable Vue components
- **resources/js/Layouts** - Layout components (AuthenticatedLayout, GuestLayout)
- **resources/js/app.js** - Main entry point, configures Inertia and Ziggy for route helpers

### Key Technologies
- **Inertia.js** - Bridges Laravel backend with Vue frontend without building an API
- **Ziggy** - Provides Laravel route helpers in JavaScript
- **Vite** - Fast frontend build tool configured via vite.config.js
- **Tailwind CSS** - Utility-first CSS framework with forms plugin

### Testing
- Uses PHPUnit and Pest for testing
- Tests use SQLite in-memory database
- Feature tests in tests/Feature/
- Unit tests in tests/Unit/