#!/bin/bash

# Testing Setup Wizard
# Configure testing frameworks, coverage tools, and E2E testing for Laravel

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
FRAMEWORK="${1:-}"
COVERAGE=false
E2E_TOOL=""
FRONTEND_TESTING=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --framework)
            FRAMEWORK="$2"
            shift 2
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --e2e)
            E2E_TOOL="$2"
            shift 2
            ;;
        --frontend)
            FRONTEND_TESTING="$2"
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

# Function to print section header
print_section() {
    echo
    print_message "$BLUE" "🧪 $1"
    echo
}

# Interactive framework selection if not specified
if [[ -z "$FRAMEWORK" ]]; then
    print_message "$BLUE" "🧪 Testing Setup Wizard"
    echo
    echo "Choose a testing framework:"
    echo "  1) Pest PHP (Recommended)"
    echo "  2) PHPUnit (Traditional)"
    echo "  3) Both frameworks"
    read -p "Choose [1-3]: " framework_choice
    
    case $framework_choice in
        1) FRAMEWORK="pest" ;;
        2) FRAMEWORK="phpunit" ;;
        3) FRAMEWORK="both" ;;
        *) FRAMEWORK="pest" ;;
    esac
fi

# Interactive coverage selection if not specified
if [[ "$COVERAGE" != true ]]; then
    echo
    read -p "Set up code coverage reporting? [y/N]: " coverage_choice
    [[ "$coverage_choice" =~ ^[Yy]$ ]] && COVERAGE=true
fi

# Interactive E2E selection if not specified
if [[ -z "$E2E_TOOL" ]]; then
    echo
    echo "Choose E2E testing tool:"
    echo "  1) Laravel Dusk"
    echo "  2) Playwright"
    echo "  3) Cypress"
    echo "  4) Skip E2E testing"
    read -p "Choose [1-4]: " e2e_choice
    
    case $e2e_choice in
        1) E2E_TOOL="dusk" ;;
        2) E2E_TOOL="playwright" ;;
        3) E2E_TOOL="cypress" ;;
        4) E2E_TOOL="none" ;;
        *) E2E_TOOL="none" ;;
    esac
fi

# Interactive frontend testing if not specified
if [[ -z "$FRONTEND_TESTING" ]]; then
    echo
    echo "Choose frontend testing framework:"
    echo "  1) Vitest (Vue/React)"
    echo "  2) Jest"
    echo "  3) Skip frontend testing"
    read -p "Choose [1-3]: " frontend_choice
    
    case $frontend_choice in
        1) FRONTEND_TESTING="vitest" ;;
        2) FRONTEND_TESTING="jest" ;;
        3) FRONTEND_TESTING="none" ;;
        *) FRONTEND_TESTING="none" ;;
    esac
fi

print_section "Testing Configuration"
echo "  Framework: $FRAMEWORK"
echo "  Coverage: $COVERAGE"
echo "  E2E Tool: $E2E_TOOL"
echo "  Frontend: $FRONTEND_TESTING"
echo

# Install Pest PHP
install_pest() {
    print_section "Installing Pest PHP"
    
    echo "Installing Pest packages..."
    echo "composer require --dev pestphp/pest"
    echo "composer require --dev pestphp/pest-plugin-laravel"
    echo "composer require --dev pestphp/pest-plugin-faker"
    
    echo
    echo "Initializing Pest..."
    echo "php artisan pest:install"
    
    echo
    echo "Creating Pest configuration (tests/Pest.php):"
    echo "<?php"
    echo ""
    echo "uses("
    echo "    Tests\TestCase::class,"
    echo "    Illuminate\Foundation\Testing\RefreshDatabase::class,"
    echo ")->in('Feature');"
    echo ""
    echo "uses()->in('Unit');"
    echo ""
    echo "uses()"
    echo "    ->group('api')"
    echo "    ->in('Feature/Api');"
    echo ""
    echo "expect()->extend('toBeOne', function () {"
    echo "    return \$this->toBe(1);"
    echo "});"
    
    echo
    echo "Example Pest test (tests/Feature/ExampleTest.php):"
    echo "<?php"
    echo ""
    echo "it('has welcome page', function () {"
    echo "    \$response = \$this->get('/');"
    echo "    \$response->assertStatus(200);"
    echo "});"
    echo ""
    echo "it('can create a user', function () {"
    echo "    \$user = User::factory()->create();"
    echo "    "
    echo "    expect(\$user)"
    echo "        ->toBeInstanceOf(User::class)"
    echo "        ->and(\$user->email)->toBeString();"
    echo "});"
}

# Install PHPUnit
install_phpunit() {
    print_section "Installing PHPUnit"
    
    echo "PHPUnit is included with Laravel by default"
    echo
    echo "Installing additional PHPUnit packages..."
    echo "composer require --dev phpunit/php-code-coverage"
    echo "composer require --dev phpunit/php-timer"
    
    echo
    echo "Example PHPUnit test (tests/Feature/ExampleTest.php):"
    echo "<?php"
    echo ""
    echo "namespace Tests\Feature;"
    echo ""
    echo "use Illuminate\Foundation\Testing\RefreshDatabase;"
    echo "use Tests\TestCase;"
    echo ""
    echo "class ExampleTest extends TestCase"
    echo "{"
    echo "    use RefreshDatabase;"
    echo ""
    echo "    public function test_the_application_returns_a_successful_response(): void"
    echo "    {"
    echo "        \$response = \$this->get('/');"
    echo "        \$response->assertStatus(200);"
    echo "    }"
    echo ""
    echo "    public function test_user_creation(): void"
    echo "    {"
    echo "        \$user = User::factory()->create();"
    echo "        \$this->assertInstanceOf(User::class, \$user);"
    echo "    }"
    echo "}"
}

# Install testing frameworks
case $FRAMEWORK in
    "pest") install_pest ;;
    "phpunit") install_phpunit ;;
    "both") 
        install_pest
        install_phpunit
        ;;
esac

# Set up code coverage
if [[ "$COVERAGE" == true ]]; then
    print_section "Setting Up Code Coverage"
    
    echo "Choose coverage driver:"
    echo "  1) Xdebug (most compatible)"
    echo "  2) PCOV (faster)"
    read -p "Choose [1-2]: " coverage_choice
    
    case $coverage_choice in
        1)
            echo "Installing Xdebug..."
            echo "pecl install xdebug"
            echo "echo 'zend_extension=xdebug.so' >> php.ini"
            ;;
        2)
            echo "Installing PCOV..."
            echo "pecl install pcov"
            echo "echo 'extension=pcov.so' >> php.ini"
            ;;
    esac
    
    echo
    echo "Updating phpunit.xml for coverage:"
    echo "  <coverage processUncoveredFiles=\"true\">"
    echo "    <include>"
    echo "      <directory suffix=\".php\">./app</directory>"
    echo "    </include>"
    echo "    <report>"
    echo "      <html outputDirectory=\"tests/coverage\" lowUpperBound=\"50\" highLowerBound=\"90\"/>"
    echo "      <text outputFile=\"tests/coverage.txt\"/>"
    echo "      <clover outputFile=\"tests/coverage.xml\"/>"
    echo "    </report>"
    echo "  </coverage>"
    
    echo
    echo "Running tests with coverage:"
    if [[ "$FRAMEWORK" == "pest" ]]; then
        echo "XDEBUG_MODE=coverage ./vendor/bin/pest --coverage"
        echo "./vendor/bin/pest --coverage --min=80"
    else
        echo "XDEBUG_MODE=coverage php artisan test --coverage"
        echo "php artisan test --coverage --min=80"
    fi
fi

# Set up E2E testing
case $E2E_TOOL in
    "dusk")
        print_section "Installing Laravel Dusk"
        
        echo "Installing Dusk..."
        echo "composer require --dev laravel/dusk"
        echo "php artisan dusk:install"
        
        echo
        echo "Creating example Dusk test (tests/Browser/ExampleTest.php):"
        echo "<?php"
        echo ""
        echo "namespace Tests\Browser;"
        echo ""
        echo "use Laravel\Dusk\Browser;"
        echo "use Tests\DuskTestCase;"
        echo ""
        echo "class ExampleTest extends DuskTestCase"
        echo "{"
        echo "    public function testBasicExample(): void"
        echo "    {"
        echo "        \$this->browse(function (Browser \$browser) {"
        echo "            \$browser->visit('/')"
        echo "                    ->assertSee('Laravel');"
        echo "        });"
        echo "    }"
        echo "}"
        
        echo
        echo "Running Dusk tests:"
        echo "php artisan dusk"
        ;;
    "playwright")
        print_section "Installing Playwright"
        
        echo "Installing Playwright..."
        echo "npm install --save-dev @playwright/test"
        echo "npx playwright install"
        
        echo
        echo "Creating Playwright config (playwright.config.js):"
        echo "import { defineConfig } from '@playwright/test';"
        echo ""
        echo "export default defineConfig({"
        echo "  testDir: './tests/e2e',"
        echo "  timeout: 30000,"
        echo "  use: {"
        echo "    baseURL: 'http://localhost:8000',"
        echo "    trace: 'on-first-retry',"
        echo "    screenshot: 'only-on-failure',"
        echo "  },"
        echo "  projects: ["
        echo "    { name: 'chromium', use: { browserName: 'chromium' } },"
        echo "    { name: 'firefox', use: { browserName: 'firefox' } },"
        echo "  ],"
        echo "});"
        
        echo
        echo "Example Playwright test (tests/e2e/example.spec.js):"
        echo "import { test, expect } from '@playwright/test';"
        echo ""
        echo "test('homepage loads', async ({ page }) => {"
        echo "  await page.goto('/');"
        echo "  await expect(page).toHaveTitle(/Laravel/);"
        echo "});"
        ;;
    "cypress")
        print_section "Installing Cypress"
        
        echo "Installing Cypress..."
        echo "npm install --save-dev cypress"
        
        echo
        echo "Initializing Cypress..."
        echo "npx cypress open"
        
        echo
        echo "Example Cypress test (cypress/e2e/example.cy.js):"
        echo "describe('Homepage', () => {"
        echo "  it('loads successfully', () => {"
        echo "    cy.visit('/')"
        echo "    cy.contains('Laravel')"
        echo "  })"
        echo "})"
        ;;
esac

# Set up frontend testing
case $FRONTEND_TESTING in
    "vitest")
        print_section "Installing Vitest"
        
        echo "Installing Vitest packages..."
        echo "npm install --save-dev vitest @vue/test-utils happy-dom"
        echo "npm install --save-dev @testing-library/vue @testing-library/jest-dom"
        
        echo
        echo "Creating Vitest config (vitest.config.js):"
        echo "import { defineConfig } from 'vitest/config'"
        echo "import vue from '@vitejs/plugin-vue'"
        echo ""
        echo "export default defineConfig({"
        echo "  plugins: [vue()],"
        echo "  test: {"
        echo "    globals: true,"
        echo "    environment: 'happy-dom',"
        echo "    coverage: {"
        echo "      provider: 'v8',"
        echo "      reporter: ['text', 'json', 'html'],"
        echo "    },"
        echo "  },"
        echo "})"
        
        echo
        echo "Example component test (tests/components/Button.test.js):"
        echo "import { describe, it, expect } from 'vitest'"
        echo "import { mount } from '@vue/test-utils'"
        echo "import Button from '@/components/Button.vue'"
        echo ""
        echo "describe('Button', () => {"
        echo "  it('renders properly', () => {"
        echo "    const wrapper = mount(Button, {"
        echo "      props: { label: 'Click me' }"
        echo "    })"
        echo "    expect(wrapper.text()).toContain('Click me')"
        echo "  })"
        echo "})"
        ;;
    "jest")
        print_section "Installing Jest"
        
        echo "Installing Jest packages..."
        echo "npm install --save-dev jest @types/jest"
        echo "npm install --save-dev @vue/vue3-jest babel-jest"
        
        echo
        echo "Creating Jest config (jest.config.js):"
        echo "module.exports = {"
        echo "  testEnvironment: 'jsdom',"
        echo "  transform: {"
        echo "    '^.+\\.vue$': '@vue/vue3-jest',"
        echo "    '^.+\\.js$': 'babel-jest',"
        echo "  },"
        echo "  moduleNameMapping: {"
        echo "    '^@/(.*)$': '<rootDir>/resources/js/$1',"
        echo "  },"
        echo "  collectCoverageFrom: ["
        echo "    'resources/js/**/*.{js,vue}',"
        echo "  ],"
        echo "};"
        ;;
esac

print_section "Database Testing"

echo "Setting up database testing..."
echo
echo "Update phpunit.xml for testing database:"
echo "  <env name=\"DB_CONNECTION\" value=\"sqlite\"/>"
echo "  <env name=\"DB_DATABASE\" value=\":memory:\"/>"
echo
echo "Using test traits:"
echo "<?php"
echo ""
echo "use Illuminate\Foundation\Testing\RefreshDatabase;"
echo "use Illuminate\Foundation\Testing\DatabaseTransactions;"
echo ""
echo "class UserTest extends TestCase"
echo "{"
echo "    use RefreshDatabase; // Recommended"
echo "    "
echo "    public function test_user_creation(): void"
echo "    {"
echo "        \$user = User::factory()->create();"
echo "        \$this->assertDatabaseHas('users', ["
echo "            'email' => \$user->email,"
echo "        ]);"
echo "    }"
echo "}"

print_section "API Testing"

echo "Setting up API testing..."
echo
if [[ "$FRAMEWORK" == "pest" ]]; then
    echo "it('returns user data', function () {"
    echo "    \$user = User::factory()->create();"
    echo "    "
    echo "    \$response = \$this->actingAs(\$user)"
    echo "        ->getJson('/api/user');"
    echo "    "
    echo "    \$response->assertOk()"
    echo "        ->assertJson(["
    echo "            'id' => \$user->id,"
    echo "            'email' => \$user->email,"
    echo "        ]);"
    echo "});"
else
    echo "public function test_returns_user_data(): void"
    echo "{"
    echo "    \$user = User::factory()->create();"
    echo "    "
    echo "    \$response = \$this->actingAs(\$user)"
    echo "        ->getJson('/api/user');"
    echo "    "
    echo "    \$response->assertOk()"
    echo "        ->assertJson(["
    echo "            'id' => \$user->id,"
    echo "            'email' => \$user->email,"
    echo "        ]);"
    echo "}"
fi

print_section "Mocking & Fakes"

echo "Setting up Laravel fakes and mocks..."
echo
echo "Using Laravel Fakes:"
echo "Mail::fake();"
echo "Queue::fake();"
echo "Storage::fake('public');"
echo "Event::fake();"
echo "Notification::fake();"
echo
echo "Testing with fakes:"
echo "Mail::assertSent(WelcomeEmail::class);"
echo "Queue::assertPushed(ProcessPayment::class);"
echo "Storage::disk('public')->assertExists('file.txt');"

print_section "CI/CD Integration"

echo "Creating GitHub Actions workflow (.github/workflows/tests.yml):"
echo "name: Tests"
echo ""
echo "on: [push, pull_request]"
echo ""
echo "jobs:"
echo "  test:"
echo "    runs-on: ubuntu-latest"
echo "    "
echo "    services:"
echo "      mysql:"
echo "        image: mysql:8.0"
echo "        env:"
echo "          MYSQL_ROOT_PASSWORD: password"
echo "          MYSQL_DATABASE: testing"
echo "        ports:"
echo "          - 3306:3306"
echo "    "
echo "    steps:"
echo "      - uses: actions/checkout@v4"
echo "      "
echo "      - name: Setup PHP"
echo "        uses: shivammathur/setup-php@v2"
echo "        with:"
echo "          php-version: '8.3'"
echo "          extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite, bcmath, soap, intl, gd, exif, iconv"
echo "          coverage: pcov"
echo "      "
echo "      - name: Install Dependencies"
echo "        run: |"
echo "          composer install --no-interaction"
echo "          npm ci"
echo "          npm run build"
echo "      "
echo "      - name: Run Tests"
echo "        run: |"
echo "          php artisan test --parallel --coverage"
echo "          npm run test"

print_section "Test Commands"

echo "Common testing commands:"
echo
if [[ "$FRAMEWORK" == "pest" ]]; then
    echo "# Run all tests:"
    echo "./vendor/bin/pest"
    echo
    echo "# Run specific test file:"
    echo "./vendor/bin/pest tests/Feature/UserTest.php"
    echo
    echo "# Run with coverage:"
    echo "./vendor/bin/pest --coverage"
    echo
    echo "# Run parallel tests:"
    echo "./vendor/bin/pest --parallel"
    echo
    echo "# Run tests by group:"
    echo "./vendor/bin/pest --group=api"
    echo
    echo "# Stop on first failure:"
    echo "./vendor/bin/pest --bail"
fi

echo "# Laravel Artisan test commands:"
echo "php artisan test"
echo "php artisan test --parallel"
echo "php artisan test --coverage"
echo "php artisan test --testsuite=Feature"

if [[ "$E2E_TOOL" != "none" ]]; then
    echo
    echo "# E2E test commands:"
    case $E2E_TOOL in
        "dusk") echo "php artisan dusk" ;;
        "playwright") echo "npx playwright test" ;;
        "cypress") echo "npx cypress run" ;;
    esac
fi

if [[ "$FRONTEND_TESTING" != "none" ]]; then
    echo
    echo "# Frontend test commands:"
    case $FRONTEND_TESTING in
        "vitest") echo "npm run test" ;;
        "jest") echo "npm run test" ;;
    esac
fi

print_message "$GREEN" "✅ Testing setup completed!"
echo
print_message "$CYAN" "Next steps:"
echo "  1. Write your first tests"
echo "  2. Set up your CI/CD pipeline"
echo "  3. Configure code coverage reporting"
echo "  4. Add testing to your development workflow"
echo "  5. Set up test database"
echo
print_message "$YELLOW" "Testing workflow:"
echo "  1. Write failing test (Red)"
echo "  2. Make test pass (Green)"
echo "  3. Refactor code (Refactor)"
echo "  4. Repeat TDD cycle"
echo
print_message "$GREEN" "Testing framework '$FRAMEWORK' configured successfully!"