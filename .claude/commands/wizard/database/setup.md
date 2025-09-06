---
allowed-tools: all
argument-hint: [--driver <driver>] [--migrations] [--seeders]
description: Configure database connections, migrations, and seeders for Laravel
---

# Database Setup Wizard

Configure database drivers, connections, migrations, and seeders for Laravel projects.

## Usage

```bash
# Interactive database setup
/wizard:database:setup

# Specify database driver
/wizard:database:setup --driver mysql

# Generate migrations
/wizard:database:setup --migrations

# Create seeders
/wizard:database:setup --seeders
```

## Examples

```bash
# Example 1: MySQL with migrations
/wizard:database:setup --driver mysql --migrations

# Example 2: PostgreSQL setup
/wizard:database:setup --driver pgsql

# Example 3: SQLite for testing
/wizard:database:setup --driver sqlite --seeders

# Example 4: MongoDB configuration
/wizard:database:setup --driver mongodb
```

## Command Execution

```bash
bash .claude/commands/wizard/database/scripts/setup.sh "$@"
```

## Database Drivers

### MySQL / MariaDB
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=
```

#### Configuration
```php
'mysql' => [
    'driver' => 'mysql',
    'url' => env('DATABASE_URL'),
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_DATABASE', 'forge'),
    'username' => env('DB_USERNAME', 'forge'),
    'password' => env('DB_PASSWORD', ''),
    'unix_socket' => env('DB_SOCKET', ''),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'prefix_indexes' => true,
    'strict' => true,
    'engine' => null,
    'options' => extension_loaded('pdo_mysql') ? array_filter([
        PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
    ]) : [],
],
```

### PostgreSQL
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=laravel
DB_USERNAME=postgres
DB_PASSWORD=
```

#### Features
- JSON/JSONB columns
- Full-text search
- Advanced indexing
- UUID support
- Array columns

### SQLite
```env
DB_CONNECTION=sqlite
DB_DATABASE=/absolute/path/to/database.sqlite
```

#### Benefits
- Zero configuration
- Portable
- Great for testing
- File-based

### SQL Server
```env
DB_CONNECTION=sqlsrv
DB_HOST=localhost
DB_PORT=1433
DB_DATABASE=laravel
DB_USERNAME=sa
DB_PASSWORD=
```

### MongoDB
```bash
composer require mongodb/laravel-mongodb
```

```env
DB_CONNECTION=mongodb
DB_HOST=127.0.0.1
DB_PORT=27017
DB_DATABASE=laravel
DB_USERNAME=
DB_PASSWORD=
```

## Migration Management

### Creating Migrations
```bash
# Create a new migration
php artisan make:migration create_users_table

# Create with table
php artisan make:migration create_posts_table --create=posts

# Modify existing table
php artisan make:migration add_votes_to_posts_table --table=posts
```

### Migration Structure
```php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
            
            // Indexes
            $table->index('email');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
```

### Running Migrations
```bash
# Run all migrations
php artisan migrate

# Run with seed
php artisan migrate --seed

# Fresh migration (drop all tables)
php artisan migrate:fresh

# Rollback migrations
php artisan migrate:rollback

# Rollback all
php artisan migrate:reset

# Rollback and migrate
php artisan migrate:refresh
```

## Seeder Configuration

### Creating Seeders
```bash
# Create seeder
php artisan make:seeder UserSeeder

# Create factory
php artisan make:factory PostFactory
```

### Seeder Example
```php
namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create admin user
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'password' => Hash::make('password'),
            'email_verified_at' => now(),
        ]);
        
        // Create test users
        User::factory(10)->create();
    }
}
```

### Factory Example
```php
namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => Hash::make('password'),
            'remember_token' => Str::random(10),
        ];
    }
}
```

### Running Seeders
```bash
# Run all seeders
php artisan db:seed

# Run specific seeder
php artisan db:seed --class=UserSeeder

# Fresh with seed
php artisan migrate:fresh --seed
```

## Performance Optimization

### Indexing Strategy
```php
// Add indexes in migrations
$table->index('email');
$table->index(['user_id', 'created_at']);
$table->unique('slug');
$table->fullText('description');
```

### Query Optimization
```php
// Eager loading
User::with('posts.comments')->get();

// Select specific columns
User::select('id', 'name', 'email')->get();

// Use chunks for large datasets
User::chunk(100, function ($users) {
    foreach ($users as $user) {
        // Process user
    }
});
```

### Connection Pooling
```php
'mysql' => [
    // ... other config
    'options' => [
        PDO::ATTR_PERSISTENT => true,
    ],
],
```

## Database Transactions

### Basic Transactions
```php
use Illuminate\Support\Facades\DB;

DB::transaction(function () {
    DB::table('users')->update(['votes' => 1]);
    DB::table('posts')->delete();
});
```

### Manual Transactions
```php
DB::beginTransaction();

try {
    // Database operations
    DB::commit();
} catch (\Exception $e) {
    DB::rollBack();
    throw $e;
}
```

## Multiple Database Connections

### Configuration
```php
'connections' => [
    'mysql' => [
        // Primary database
    ],
    
    'mysql_analytics' => [
        // Analytics database
    ],
    
    'mysql_legacy' => [
        // Legacy database
    ],
],
```

### Usage
```php
// Using specific connection
$users = DB::connection('mysql_analytics')
    ->table('users')
    ->get();

// In models
class User extends Model
{
    protected $connection = 'mysql_analytics';
}
```

## Backup & Recovery

### Database Backup
```bash
# Install backup package
composer require spatie/laravel-backup

# Publish config
php artisan vendor:publish --provider="Spatie\Backup\BackupServiceProvider"

# Run backup
php artisan backup:run
```

### Backup Configuration
```php
'backup' => [
    'name' => env('APP_NAME'),
    'source' => [
        'databases' => [
            'mysql',
        ],
    ],
    'destination' => [
        'disks' => [
            'local',
            's3',
        ],
    ],
],
```

## Testing Database

### Configuration
```xml
<!-- phpunit.xml -->
<env name="DB_CONNECTION" value="sqlite"/>
<env name="DB_DATABASE" value=":memory:"/>
```

### Test Traits
```php
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Foundation\Testing\DatabaseTransactions;

class ExampleTest extends TestCase
{
    use RefreshDatabase; // Fresh database for each test
    // or
    use DatabaseMigrations; // Run migrations
    // or
    use DatabaseTransactions; // Wrap in transaction
}
```

## Monitoring & Debugging

### Query Logging
```php
// Enable query log
DB::enableQueryLog();

// Get queries
$queries = DB::getQueryLog();
```

### Laravel Debugbar
```bash
composer require barryvdh/laravel-debugbar --dev
```

### Laravel Telescope
```bash
composer require laravel/telescope --dev
php artisan telescope:install
php artisan migrate
```

## Requirements

- PHP 8.2+
- PDO PHP Extension
- Database server (MySQL/PostgreSQL/SQLite/etc)
- Composer for package management