---
allowed-tools: all
argument-hint: [--framework <framework>] [--coverage] [--e2e]
description: Configure testing frameworks, coverage tools, and E2E testing for Laravel
---

# Testing Setup Wizard

Configure comprehensive testing for Laravel projects including unit, feature, browser, and E2E testing.

## Usage

```bash
# Interactive testing setup
/wizard:testing:setup

# Specify testing framework
/wizard:testing:setup --framework pest

# With coverage tools
/wizard:testing:setup --coverage

# Add E2E testing
/wizard:testing:setup --e2e
```

## Examples

```bash
# Example 1: Pest with coverage
/wizard:testing:setup --framework pest --coverage

# Example 2: PHPUnit with Dusk
/wizard:testing:setup --framework phpunit --e2e dusk

# Example 3: Full testing suite
/wizard:testing:setup --framework pest --coverage --e2e playwright

# Example 4: Frontend testing with Vitest
/wizard:testing:setup --frontend vitest
```

## Command Execution

```bash
bash .claude/commands/wizard/testing/scripts/setup.sh "$@"
```

## Testing Frameworks

### Pest PHP (Recommended)
```bash
composer require pestphp/pest --dev
composer require pestphp/pest-plugin-laravel --dev
php artisan pest:install
```

#### Pest Configuration
```php
// tests/Pest.php
uses(
    Tests\TestCase::class,
    Illuminate\Foundation\Testing\RefreshDatabase::class,
)->in('Feature');

uses()
    ->in('Unit');

uses()
    ->group('api')
    ->in('Feature/Api');
```

#### Pest Test Example
```php
// tests/Feature/UserTest.php
use App\Models\User;

it('can create a user', function () {
    $user = User::factory()->create();
    
    expect($user)
        ->toBeInstanceOf(User::class)
        ->and($user->email)->toBeString();
});

it('validates email format', function () {
    $user = User::factory()->make(['email' => 'invalid']);
    
    expect($user->isValidEmail())->toBeFalse();
})->group('validation');
```

### PHPUnit
```xml
<!-- phpunit.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="vendor/phpunit/phpunit/phpunit.xsd"
         bootstrap="vendor/autoload.php"
         colors="true">
    <testsuites>
        <testsuite name="Unit">
            <directory>tests/Unit</directory>
        </testsuite>
        <testsuite name="Feature">
            <directory>tests/Feature</directory>
        </testsuite>
    </testsuites>
    <source>
        <include>
            <directory>app</directory>
        </include>
    </source>
    <php>
        <env name="APP_ENV" value="testing"/>
        <env name="BCRYPT_ROUNDS" value="4"/>
        <env name="CACHE_DRIVER" value="array"/>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
        <env name="MAIL_MAILER" value="array"/>
        <env name="PULSE_ENABLED" value="false"/>
        <env name="QUEUE_CONNECTION" value="sync"/>
        <env name="SESSION_DRIVER" value="array"/>
        <env name="TELESCOPE_ENABLED" value="false"/>
    </php>
</phpunit>
```

## Coverage Tools

### Xdebug Coverage
```bash
# Install Xdebug
pecl install xdebug

# Run with coverage
XDEBUG_MODE=coverage php artisan test --coverage
XDEBUG_MODE=coverage ./vendor/bin/pest --coverage
```

### PCOV (Faster Alternative)
```bash
# Install PCOV
pecl install pcov

# Configure php.ini
echo "extension=pcov.so" >> php.ini

# Run tests with PCOV
php artisan test --coverage
```

### Coverage Configuration
```xml
<!-- phpunit.xml -->
<coverage>
    <report>
        <html outputDirectory="tests/coverage"/>
        <text outputFile="tests/coverage.txt"/>
        <clover outputFile="tests/coverage.xml"/>
    </report>
</coverage>
```

## Browser Testing

### Laravel Dusk
```bash
composer require laravel/dusk --dev
php artisan dusk:install
```

#### Dusk Test Example
```php
// tests/Browser/LoginTest.php
namespace Tests\Browser;

use App\Models\User;
use Laravel\Dusk\Browser;
use Tests\DuskTestCase;

class LoginTest extends DuskTestCase
{
    public function testLogin(): void
    {
        $user = User::factory()->create();
        
        $this->browse(function (Browser $browser) use ($user) {
            $browser->visit('/login')
                    ->type('email', $user->email)
                    ->type('password', 'password')
                    ->press('Login')
                    ->assertPathIs('/dashboard')
                    ->assertAuthenticated();
        });
    }
}
```

### Playwright
```bash
# Install Playwright
npm install --save-dev @playwright/test

# Initialize
npx playwright install
```

#### Playwright Configuration
```javascript
// playwright.config.js
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  timeout: 30000,
  use: {
    baseURL: 'http://localhost:8000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { browserName: 'chromium' },
    },
    {
      name: 'firefox',
      use: { browserName: 'firefox' },
    },
  ],
});
```

### Cypress
```bash
# Install Cypress
npm install --save-dev cypress

# Open Cypress
npx cypress open
```

#### Cypress Test
```javascript
// cypress/e2e/login.cy.js
describe('Login', () => {
  it('successfully logs in', () => {
    cy.visit('/login')
    cy.get('input[name="email"]').type('user@example.com')
    cy.get('input[name="password"]').type('password')
    cy.get('button[type="submit"]').click()
    cy.url().should('include', '/dashboard')
  })
})
```

## Frontend Testing

### Vitest (Vue/React)
```bash
npm install --save-dev vitest @vue/test-utils happy-dom
```

#### Vitest Configuration
```javascript
// vitest.config.js
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'happy-dom',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
    },
  },
})
```

#### Component Test
```typescript
// tests/components/Button.test.ts
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Button from '@/components/Button.vue'

describe('Button', () => {
  it('renders properly', () => {
    const wrapper = mount(Button, {
      props: { label: 'Click me' }
    })
    expect(wrapper.text()).toContain('Click me')
  })
  
  it('emits click event', async () => {
    const wrapper = mount(Button)
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toHaveLength(1)
  })
})
```

### Jest
```bash
npm install --save-dev jest @types/jest ts-jest
```

#### Jest Configuration
```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/resources/js/$1',
  },
  transform: {
    '^.+\.vue$': '@vue/vue3-jest',
    '^.+\.tsx?$': 'ts-jest',
  },
  collectCoverageFrom: [
    'resources/js/**/*.{ts,tsx,vue}',
    '!resources/js/**/*.d.ts',
  ],
}
```

## API Testing

### HTTP Tests
```php
// tests/Feature/ApiTest.php
use App\Models\User;

it('returns user data', function () {
    $user = User::factory()->create();
    
    $response = $this->actingAs($user)
        ->getJson('/api/user');
    
    $response->assertOk()
        ->assertJson([
            'id' => $user->id,
            'email' => $user->email,
        ]);
});

it('validates request data', function () {
    $response = $this->postJson('/api/users', [
        'name' => '',
        'email' => 'invalid',
    ]);
    
    $response->assertStatus(422)
        ->assertJsonValidationErrors(['name', 'email']);
});
```

### API Documentation Testing
```bash
composer require --dev knuckleswtf/scribe
php artisan vendor:publish --tag=scribe-config
php artisan scribe:generate
```

## Database Testing

### Test Traits
```php
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Foundation\Testing\DatabaseTransactions;

class UserTest extends TestCase
{
    use RefreshDatabase; // Recommended
    
    public function test_user_creation(): void
    {
        $user = User::factory()->create();
        
        $this->assertDatabaseHas('users', [
            'email' => $user->email,
        ]);
    }
}
```

### Factory States
```php
// database/factories/UserFactory.php
public function admin(): static
{
    return $this->state(fn (array $attributes) => [
        'role' => 'admin',
    ]);
}

public function suspended(): static
{
    return $this->state(fn (array $attributes) => [
        'suspended_at' => now(),
    ]);
}
```

## Mocking & Fakes

### Laravel Fakes
```php
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Storage;

it('sends welcome email', function () {
    Mail::fake();
    
    $user = User::factory()->create();
    
    Mail::assertSent(WelcomeEmail::class, function ($mail) use ($user) {
        return $mail->hasTo($user->email);
    });
});

it('queues job', function () {
    Queue::fake();
    
    ProcessPayment::dispatch($order);
    
    Queue::assertPushed(ProcessPayment::class);
});
```

### Mockery
```php
use Mockery;

it('calls external service', function () {
    $mock = Mockery::mock(PaymentGateway::class);
    $mock->shouldReceive('charge')
        ->once()
        ->with(100)
        ->andReturn(true);
    
    $this->app->instance(PaymentGateway::class, $mock);
    
    // Test code that uses PaymentGateway
});
```

## Continuous Integration

### GitHub Actions
```yaml
# .github/workflows/tests.yml
name: Tests

on: [push, pull_request]

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
      - uses: actions/checkout@v4
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite, bcmath, soap, intl, gd, exif, iconv
          coverage: pcov
      
      - name: Install Dependencies
        run: |
          composer install --no-interaction
          npm ci
          npm run build
      
      - name: Run Tests
        run: |
          php artisan test --parallel --coverage
          npm run test
      
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./tests/coverage.xml
```

## Test Commands

```bash
# Run all tests
php artisan test
./vendor/bin/pest

# Run specific test suite
php artisan test --testsuite=Feature
./vendor/bin/pest --group=api

# Run with coverage
php artisan test --coverage --min=80
./vendor/bin/pest --coverage

# Run in parallel
php artisan test --parallel
./vendor/bin/pest --parallel

# Run specific test
php artisan test tests/Feature/UserTest.php
./vendor/bin/pest tests/Feature/UserTest.php

# Run and stop on failure
php artisan test --stop-on-failure
./vendor/bin/pest --bail
```

## Requirements

- PHP 8.2+
- Composer 2.0+
- Node.js 18+ (for frontend testing)
- Xdebug or PCOV (for coverage)
- Chrome/Chromium (for browser testing)