#!/bin/bash

# Database Setup Wizard
# Configure database connections, migrations, and seeders for Laravel

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
DRIVER="${1:-}"
CREATE_MIGRATIONS=false
CREATE_SEEDERS=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --driver)
            DRIVER="$2"
            shift 2
            ;;
        --migrations)
            CREATE_MIGRATIONS=true
            shift
            ;;
        --seeders)
            CREATE_SEEDERS=true
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
    print_message "$BLUE" "🗄️ $1"
    echo
}

# Interactive driver selection if not specified
if [[ -z "$DRIVER" ]]; then
    print_message "$BLUE" "🗄️ Database Setup Wizard"
    echo
    echo "Choose a database driver:"
    echo "  1) MySQL / MariaDB"
    echo "  2) PostgreSQL"
    echo "  3) SQLite"
    echo "  4) SQL Server"
    echo "  5) MongoDB"
    read -p "Choose [1-5]: " driver_choice
    
    case $driver_choice in
        1) DRIVER="mysql" ;;
        2) DRIVER="pgsql" ;;
        3) DRIVER="sqlite" ;;
        4) DRIVER="sqlsrv" ;;
        5) DRIVER="mongodb" ;;
        *) DRIVER="mysql" ;;
    esac
fi

# Interactive options if not specified
if [[ "$CREATE_MIGRATIONS" != true && "$CREATE_SEEDERS" != true ]]; then
    echo
    echo "Additional setup options:"
    read -p "Create example migrations? [y/N]: " create_migrations
    read -p "Create example seeders? [y/N]: " create_seeders
    
    [[ "$create_migrations" =~ ^[Yy]$ ]] && CREATE_MIGRATIONS=true
    [[ "$create_seeders" =~ ^[Yy]$ ]] && CREATE_SEEDERS=true
fi

print_section "Database Configuration"
echo "  Driver: $DRIVER"
echo "  Create Migrations: $CREATE_MIGRATIONS"
echo "  Create Seeders: $CREATE_SEEDERS"
echo

# Configure database connection
configure_mysql() {
    print_section "Configuring MySQL/MariaDB"
    
    echo "Updating .env configuration..."
    echo "DB_CONNECTION=mysql"
    echo "DB_HOST=127.0.0.1"
    echo "DB_PORT=3306"
    echo "DB_DATABASE=laravel"
    echo "DB_USERNAME=root"
    echo "DB_PASSWORD="
    
    echo
    echo "# Add to .env file:"
    echo "sed -i '' 's/DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env"
    echo "sed -i '' 's/DB_HOST=.*/DB_HOST=127.0.0.1/' .env"
    echo "sed -i '' 's/DB_PORT=.*/DB_PORT=3306/' .env"
    echo "sed -i '' 's/DB_DATABASE=.*/DB_DATABASE=laravel/' .env"
    echo "sed -i '' 's/DB_USERNAME=.*/DB_USERNAME=root/' .env"
    echo "sed -i '' 's/DB_PASSWORD=.*/DB_PASSWORD=/' .env"
    
    print_message "$YELLOW" "💡 Don't forget to create the database: CREATE DATABASE laravel;"
}

configure_postgresql() {
    print_section "Configuring PostgreSQL"
    
    echo "Updating .env configuration..."
    echo "DB_CONNECTION=pgsql"
    echo "DB_HOST=127.0.0.1"
    echo "DB_PORT=5432"
    echo "DB_DATABASE=laravel"
    echo "DB_USERNAME=postgres"
    echo "DB_PASSWORD="
    
    echo
    echo "# Add to .env file:"
    echo "sed -i '' 's/DB_CONNECTION=.*/DB_CONNECTION=pgsql/' .env"
    echo "sed -i '' 's/DB_HOST=.*/DB_HOST=127.0.0.1/' .env"
    echo "sed -i '' 's/DB_PORT=.*/DB_PORT=5432/' .env"
    echo "sed -i '' 's/DB_DATABASE=.*/DB_DATABASE=laravel/' .env"
    echo "sed -i '' 's/DB_USERNAME=.*/DB_USERNAME=postgres/' .env"
    
    print_message "$YELLOW" "💡 PostgreSQL supports advanced features like JSON columns and full-text search"
}

configure_sqlite() {
    print_section "Configuring SQLite"
    
    echo "Creating SQLite database file..."
    echo "touch database/database.sqlite"
    
    echo
    echo "Updating .env configuration..."
    echo "sed -i '' 's/DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env"
    echo "sed -i '' '/DB_HOST=/d' .env"
    echo "sed -i '' '/DB_PORT=/d' .env"
    echo "sed -i '' '/DB_USERNAME=/d' .env"
    echo "sed -i '' '/DB_PASSWORD=/d' .env"
    echo "sed -i '' 's|DB_DATABASE=.*|DB_DATABASE=/absolute/path/to/database.sqlite|' .env"
    
    print_message "$YELLOW" "💡 SQLite is perfect for development and testing"
}

configure_sqlserver() {
    print_section "Configuring SQL Server"
    
    echo "Updating .env configuration..."
    echo "DB_CONNECTION=sqlsrv"
    echo "DB_HOST=localhost"
    echo "DB_PORT=1433"
    echo "DB_DATABASE=laravel"
    echo "DB_USERNAME=sa"
    echo "DB_PASSWORD="
    
    echo
    echo "# Add to .env file:"
    echo "sed -i '' 's/DB_CONNECTION=.*/DB_CONNECTION=sqlsrv/' .env"
    echo "sed -i '' 's/DB_HOST=.*/DB_HOST=localhost/' .env"
    echo "sed -i '' 's/DB_PORT=.*/DB_PORT=1433/' .env"
    
    print_message "$YELLOW" "💡 Make sure you have SQL Server drivers installed"
}

configure_mongodb() {
    print_section "Configuring MongoDB"
    
    echo "Installing MongoDB Laravel package..."
    echo "composer require mongodb/laravel-mongodb"
    
    echo
    echo "Updating .env configuration..."
    echo "DB_CONNECTION=mongodb"
    echo "DB_HOST=127.0.0.1"
    echo "DB_PORT=27017"
    echo "DB_DATABASE=laravel"
    echo "DB_USERNAME="
    echo "DB_PASSWORD="
    
    echo
    echo "# Add to .env file:"
    echo "sed -i '' 's/DB_CONNECTION=.*/DB_CONNECTION=mongodb/' .env"
    echo "sed -i '' 's/DB_HOST=.*/DB_HOST=127.0.0.1/' .env"
    echo "sed -i '' 's/DB_PORT=.*/DB_PORT=27017/' .env"
    
    print_message "$YELLOW" "💡 MongoDB offers flexible schema and horizontal scaling"
}

# Configure database based on driver
case $DRIVER in
    "mysql") configure_mysql ;;
    "pgsql") configure_postgresql ;;
    "sqlite") configure_sqlite ;;
    "sqlsrv") configure_sqlserver ;;
    "mongodb") configure_mongodb ;;
esac

# Create example migrations
if [[ "$CREATE_MIGRATIONS" == true ]]; then
    print_section "Creating Example Migrations"
    
    echo "Creating users table migration..."
    echo "php artisan make:migration create_users_table --create=users"
    
    echo "Creating posts table migration..."
    echo "php artisan make:migration create_posts_table --create=posts"
    
    echo "Creating categories table migration..."
    echo "php artisan make:migration create_categories_table --create=categories"
    
    echo "Creating pivot table migration..."
    echo "php artisan make:migration create_post_category_table --create=post_category"
    
    echo
    echo "# Example migration content for posts:"
    echo "Schema::create('posts', function (Blueprint \$table) {"
    echo "    \$table->id();"
    echo "    \$table->foreignId('user_id')->constrained()->onDelete('cascade');"
    echo "    \$table->string('title');"
    echo "    \$table->string('slug')->unique();"
    echo "    \$table->text('content');"
    echo "    \$table->text('excerpt')->nullable();"
    echo "    \$table->enum('status', ['draft', 'published', 'archived'])->default('draft');"
    echo "    \$table->timestamp('published_at')->nullable();"
    echo "    \$table->timestamps();"
    echo "    "
    echo "    \$table->index(['status', 'published_at']);"
    echo "    \$table->index('slug');"
    echo "});"
fi

# Create example seeders
if [[ "$CREATE_SEEDERS" == true ]]; then
    print_section "Creating Example Seeders"
    
    echo "Creating UserSeeder..."
    echo "php artisan make:seeder UserSeeder"
    
    echo "Creating PostSeeder..."
    echo "php artisan make:seeder PostSeeder"
    
    echo "Creating CategorySeeder..."
    echo "php artisan make:seeder CategorySeeder"
    
    echo "Creating factories..."
    echo "php artisan make:factory PostFactory"
    echo "php artisan make:factory CategoryFactory"
    
    echo
    echo "# Example UserSeeder content:"
    echo "User::factory()->create(["
    echo "    'name' => 'Admin User',"
    echo "    'email' => 'admin@example.com',"
    echo "]);"
    echo ""
    echo "User::factory(10)->create();"
    
    echo
    echo "# Update DatabaseSeeder.php:"
    echo "\$this->call(["
    echo "    UserSeeder::class,"
    echo "    CategorySeeder::class,"
    echo "    PostSeeder::class,"
    echo "]);"
fi

print_section "Database Optimization"

echo "Setting up database indexes and optimization..."
echo
echo "# Common index patterns:"
echo "# Foreign keys"
echo "\$table->index('user_id');"
echo "# Compound indexes"
echo "\$table->index(['status', 'created_at']);"
echo "# Unique constraints"
echo "\$table->unique('email');"
echo "# Full-text search (MySQL/PostgreSQL)"
echo "\$table->fullText('title');"

print_section "Multiple Database Connections"

echo "To configure multiple database connections:"
echo
echo "# Add to config/database.php connections array:"
echo "'mysql_analytics' => ["
echo "    'driver' => 'mysql',"
echo "    'host' => env('DB_ANALYTICS_HOST', '127.0.0.1'),"
echo "    'database' => env('DB_ANALYTICS_DATABASE', 'analytics'),"
echo "    // ... other config"
echo "],"
echo
echo "# Add to .env:"
echo "DB_ANALYTICS_HOST=127.0.0.1"
echo "DB_ANALYTICS_DATABASE=analytics"
echo "DB_ANALYTICS_USERNAME=root"
echo "DB_ANALYTICS_PASSWORD="

print_section "Testing Database Configuration"

echo "Setting up testing database..."
echo
echo "# Update phpunit.xml:"
echo "<env name=\"DB_CONNECTION\" value=\"sqlite\"/>"
echo "<env name=\"DB_DATABASE\" value=\":memory:\"/>"
echo
echo "# Or create separate testing database:"
echo "<env name=\"DB_CONNECTION\" value=\"mysql\"/>"
echo "<env name=\"DB_DATABASE\" value=\"laravel_testing\"/>"

print_section "Database Commands"

echo "Useful database commands:"
echo
echo "# Migration commands:"
echo "php artisan migrate                    # Run migrations"
echo "php artisan migrate:fresh             # Drop all tables and re-run"
echo "php artisan migrate:rollback          # Rollback last batch"
echo "php artisan migrate:reset             # Rollback all migrations"
echo "php artisan migrate:refresh           # Reset and re-run all"
echo "php artisan migrate:status            # Show migration status"
echo
echo "# Seeder commands:"
echo "php artisan db:seed                   # Run all seeders"
echo "php artisan db:seed --class=UserSeeder  # Run specific seeder"
echo "php artisan migrate:fresh --seed      # Fresh migration + seed"
echo
echo "# Database inspection:"
echo "php artisan db:show                   # Show database info"
echo "php artisan db:table posts           # Show table structure"

if [[ "$DRIVER" != "sqlite" ]]; then
    print_section "Database Connection Test"
    
    echo "Testing database connection..."
    echo "php artisan migrate --pretend"
    echo
    print_message "$YELLOW" "💡 Run 'php artisan migrate' to apply migrations once database is ready"
fi

print_section "Backup Configuration"

echo "Setting up database backups..."
echo "composer require spatie/laravel-backup"
echo "php artisan vendor:publish --provider=\"Spatie\Backup\BackupServiceProvider\""
echo "php artisan backup:run"

print_message "$GREEN" "✅ Database setup completed!"
echo
print_message "$CYAN" "Next steps:"
echo "  1. Create your database (if not SQLite)"
echo "  2. Update .env with your database credentials"
echo "  3. Run 'php artisan migrate' to create tables"
echo "  4. Run 'php artisan db:seed' to populate data"
echo "  5. Test your database connection"
echo
print_message "$YELLOW" "Database maintenance commands:"
echo "  php artisan migrate:fresh --seed    # Reset database"
echo "  php artisan db:show                 # Database info"
echo "  php artisan backup:run              # Create backup"
echo "  composer audit                      # Security audit"
echo
print_message "$GREEN" "Database driver '$DRIVER' configured successfully!"