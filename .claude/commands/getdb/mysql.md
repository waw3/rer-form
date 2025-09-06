---
allowed-tools: all
argument-hint: [--output file]
description: Generate database documentation using direct MySQL interrogation
---

# MySQL Database Documentation

Generate database structure documentation using direct MySQL CLI interrogation for fast, dependency-free documentation.

## Usage

Generate database documentation with direct MySQL access:

```bash
# Basic usage (outputs to stdout)
/getdb:mysql

# Save to file
/getdb:mysql --output database.md

# Save to Claude's reference
/getdb:mysql --output .claude/database.md
```

## Examples

```bash
# Example 1: Quick view in terminal
/getdb:mysql

# Example 2: Save to project docs
/getdb:mysql --output docs/database.md

# Example 3: Update Claude's database reference
/getdb:mysql --output .claude/database.md

# Example 4: Pipe to grep for specific table
/getdb:mysql | grep -A 20 "### reports"
```

## Command Execution

```bash
bash .claude/commands/getdb/scripts/get_db_structure.sh "$@"
```

## Parameters

### Optional Parameters
- `--output [file_path]`: Output file path (default: stdout)

### Environment Variables
- `DB_HOST`: MySQL host (default: 127.0.0.1)
- `DB_USER`: MySQL user (default: root)
- `DB_NAME`: Database name (default: rer)

### Configuration
Edit `.claude/commands/getdb/scripts/get_db_structure.sh`:
```bash
DB_HOST="127.0.0.1"
DB_USER="root"
DB_NAME="rer"
```

## Features

- **Fast Execution**: Direct MySQL queries, no framework overhead
- **No Dependencies**: Only requires MySQL CLI tools
- **Comprehensive Structure**: All tables, columns, indexes, and foreign keys
- **Table Statistics**: Row counts and storage sizes
- **Formatted Output**: Clean markdown tables
- **Stdout Support**: Can pipe to other commands
- **Lightweight**: Minimal resource usage
- **Always Current**: Real-time database interrogation

## Requirements/Dependencies

### System Requirements
- MySQL 5.7+ or MariaDB 10.3+
- MySQL CLI tools installed
- Database access credentials

### Installation Verification

```bash
# Check MySQL CLI availability
which mysql

# Verify MySQL is running
mysql.server status

# Test connection
mysql -u root -h 127.0.0.1 rer -e "SELECT 1;"

# Check database exists
mysql -u root -e "SHOW DATABASES;" | grep rer
```

## Output

### Generated Documentation Structure

1. **Tables Overview**
   - Table name
   - Storage engine
   - Approximate row count
   - Data size in MB

2. **Table Structures**
   - Column specifications
   - Data types and constraints
   - Indexes (non-primary)
   - Foreign key relationships

3. **Relationships Summary**
   - All foreign key mappings
   - Constraint names
   - Source and target columns

### Console Output Example

```
# Database Structure - RER Application

Generated: 2024-01-15 10:30:00

## Tables Overview

|Table|Engine|Rows (Approx)|Data Size (MB)|
|---|---|---|---|
|entities|InnoDB|15234|12.5|
|reports|InnoDB|8421|8.2|
|users|InnoDB|523|1.1|

## Table Structures

### reports

#### Columns
|Column|Type|Nullable|Key|Default|Extra|
|---|---|---|---|---|
|id|char(26)|NO|PRI|NULL||
|firm_id|char(26)|NO|MUL|NULL||

#### Indexes
- **idx_firm_id**: firm_id
- **idx_created_at**: created_at

#### Foreign Keys
- **fk_reports_firm**: firm_id → firms(id)
```

## Advanced Usage

### Quick Table Lookup
```bash
# Get specific table structure
/getdb:mysql | grep -A 30 "### entities"

# Count all tables
/getdb:mysql | grep "^### " | wc -l

# Extract just foreign keys
/getdb:mysql | grep "^- \*\*fk_"
```

### Database Statistics
```bash
# Get row counts for main tables
mysql -u root rer -e "
SELECT TABLE_NAME, TABLE_ROWS 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA='rer' 
ORDER BY TABLE_ROWS DESC 
LIMIT 10;"
```

### Export Operations
```bash
# Generate documentation and schema
/getdb:mysql --output docs/structure.md
mysqldump -u root --no-data rer > docs/schema.sql
```

### Monitoring Changes
```bash
# Save current structure
/getdb:mysql --output /tmp/db-before.md

# After changes
/getdb:mysql --output /tmp/db-after.md

# See what changed
diff /tmp/db-before.md /tmp/db-after.md
```

## Notes

- Execution time: 5-15 seconds for typical database
- Row counts are approximate for InnoDB tables
- Output is pure markdown, viewable anywhere
- No PHP or Laravel required
- Great for CI/CD environments
- Can be scheduled via cron for regular updates
- Useful when Laravel environment is broken

## Troubleshooting

### Common Issues

**Issue 1: MySQL access denied**
- Solution: Check credentials in script
- Test: `mysql -u root -p`
- Fix: Update DB_USER and DB_PASSWORD

**Issue 2: Command not found: mysql**
- Solution: Install MySQL client
- macOS: `brew install mysql-client`
- Linux: `apt-get install mysql-client`

**Issue 3: Database does not exist**
- Solution: Verify database name
- Check: `mysql -u root -e "SHOW DATABASES;"`
- Fix: Update DB_NAME in script

**Issue 4: Connection timeout**
- Solution: Check MySQL is running
- Start: `mysql.server start`
- Verify: `ps aux | grep mysql`

**Issue 5: Character encoding issues**
- Solution: Set UTF-8 in script
- Add: `--default-character-set=utf8mb4` to mysql commands

## Related Commands

- `/getdb:laravel`: Laravel-aware documentation with relationships
- `/backup`: Create database backup
- `/query`: Execute custom SQL queries