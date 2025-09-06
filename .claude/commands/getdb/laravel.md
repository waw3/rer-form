---
allowed-tools: all
argument-hint: [--output file]
description: Generate database documentation using Laravel's schema introspection
---

# Laravel Database Documentation

Generate comprehensive database documentation using Laravel's schema introspection with Eloquent relationships and Mermaid diagrams.

## Usage

Generate database documentation with Laravel's artisan command:

```bash
# Basic usage (saves to api/docs/database.md)
/getdb:laravel

# Custom output location
/getdb:laravel --output docs/db-structure.md

# Save to Claude's reference location
/getdb:laravel --output ../claude/database.md
```

## Examples

```bash
# Example 1: Default documentation generation
/getdb:laravel

# Example 2: Custom documentation path
/getdb:laravel --output docs/database-v2.md

# Example 3: Generate for project documentation
/getdb:laravel --output ../docs/technical/database.md

# Example 4: Update Claude's database reference
/getdb:laravel --output ../.claude/database.md
```

## Command Execution

```bash
cd api && php artisan claude:getdb --output="${OUTPUT:-docs/database.md}"
```

## Parameters

### Optional Parameters
- `--output [file_path]`: Output file path relative to api/ directory (default: docs/database.md)

### Environment Variables
- Laravel uses database configuration from `api/.env`
- `DB_CONNECTION`: Database driver (mysql)
- `DB_DATABASE`: Database name
- `DB_USERNAME`: Database user
- `DB_PASSWORD`: Database password

## Features

- **Eloquent Awareness**: Includes model relationships and scopes
- **Mermaid Diagrams**: Visual entity relationship diagrams
- **Comprehensive Metadata**: Column types, defaults, nullable flags
- **Index Documentation**: All indexes with type and uniqueness
- **Foreign Key Mapping**: Complete FK relationships with cascade rules
- **Model Integration**: Can include model-specific documentation
- **Migration History**: References migration files
- **Automatic Formatting**: Clean markdown with TOC

## Requirements/Dependencies

### System Requirements
- PHP 8.1 or higher
- Laravel 10 or higher
- Composer dependencies installed
- Database connection configured

### Installation Verification

```bash
# Check Laravel installation
cd api && php artisan --version

# Verify command exists
php artisan list | grep claude:getdb

# Test database connection
php artisan tinker --execute="DB::connection()->getPdo()"
```

## Output

### Generated Documentation Structure

1. **Header Section**
   - Generation timestamp
   - Total table count
   - Database statistics

2. **Table of Contents**
   - Alphabetical table listing
   - Quick navigation links

3. **Entity Relationship Diagram**
   - Mermaid ER diagram
   - Visual foreign key relationships

4. **Per-Table Documentation**
   - Column specifications (name, type, nullable, default, auto-increment)
   - Index definitions (name, columns, type, unique, primary)
   - Foreign key constraints (name, columns, references, cascade rules)

### Sample Output

```markdown
# Database Structure

Generated on: 2024-01-15 10:30:00
Total tables: 165

## Table of Contents
- [entities](#entities)
- [reports](#reports)
...

## Entity Relationships

\```mermaid
erDiagram
    reports ||--o{ entities : has
    entities ||--o{ payments : has
\```

## reports

### Columns
| Column | Type | Nullable | Default | Auto Increment | Comment |
|--------|------|----------|---------|----------------|---------|
| id | char(26) | NO | NULL | NO | ULID primary key |
| firm_id | char(26) | NO | NULL | NO | Foreign key to firms |
...
```

## Advanced Usage

### Integration with Documentation
```bash
# Generate and commit documentation
/getdb:laravel --output docs/database.md
git add api/docs/database.md
git commit -m "Update database documentation"
```

### Comparison Workflow
```bash
# Before schema changes
/getdb:laravel --output docs/db-before.md

# Make migrations
php artisan migrate

# After schema changes
/getdb:laravel --output docs/db-after.md

# Compare
diff api/docs/db-before.md api/docs/db-after.md
```

## Notes

- Generation time: 10-30 seconds depending on table count
- Includes Laravel-specific metadata not available via raw SQL
- Respects Laravel's database abstraction layer
- Can include soft delete timestamps
- Mermaid diagrams require markdown viewer support
- File is saved relative to api/ directory

## Troubleshooting

### Common Issues

**Issue 1: Command not found**
- Solution: Ensure command is registered in Laravel
- Check: `php artisan list | grep claude`
- Fix: Run `composer dump-autoload`

**Issue 2: Database connection failed**
- Solution: Check .env configuration
- Verify: `php artisan config:cache`
- Test: `php artisan tinker` then `DB::connection()->getPdo()`

**Issue 3: Permission denied on output**
- Solution: Check write permissions
- Fix: `mkdir -p api/docs && chmod 755 api/docs`

**Issue 4: Memory exhausted**
- Solution: Increase PHP memory limit
- Fix: Add to .env: `PHP_MEMORY_LIMIT=512M`

## Related Commands

- `/getdb:mysql`: Direct MySQL documentation (faster, simpler)
- `/migrate`: Run database migrations
- `/check`: Validate database structure