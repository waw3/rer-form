---
allowed-tools: all
argument-hint: [--update] [--remove] [--check] [--audit]
description: Manage, update, and audit Laravel project packages
---

# Package Management Wizard

Ongoing package management for Laravel projects including updates, security audits, and dependency optimization.

## Usage

```bash
# Interactive package management
/wizard:package:manage

# Update all packages
/wizard:package:manage --update

# Remove unused packages
/wizard:package:manage --remove

# Security audit
/wizard:package:manage --audit

# Check outdated packages
/wizard:package:manage --check
```

## Examples

```bash
# Example 1: Update all packages safely
/wizard:package:manage --update safe

# Example 2: Remove development packages for production
/wizard:package:manage --remove dev

# Example 3: Full security audit
/wizard:package:manage --audit full

# Example 4: Check and update outdated packages
/wizard:package:manage --check --update
```

## Command Execution

```bash
bash .claude/commands/wizard/package/scripts/manage.sh "$@"
```

## Management Operations

### Package Updates

#### Safe Update Strategy
```bash
# Update within allowed version constraints
composer update --with-dependencies

# Update only security patches
composer update --prefer-stable --prefer-lowest

# Update specific package
composer update vendor/package

# Dry run to preview changes
composer update --dry-run
```

#### Major Version Updates
```bash
# Check outdated packages
composer outdated --direct

# Update to latest major versions
composer require vendor/package:^2.0

# Update Laravel framework
composer require laravel/framework:^12.0
```

### Package Removal

#### Clean Unused Dependencies
```bash
# Remove package and dependencies
composer remove vendor/package

# Remove dev dependencies for production
composer install --no-dev

# Clean vendor directory
rm -rf vendor
composer install
```

#### Identify Unused Packages
- Analyze usage with static analysis
- Check for orphaned dependencies
- Review autoload entries
- Audit require-dev packages

### Security Auditing

#### Composer Audit
```bash
# Check for security vulnerabilities
composer audit

# Check with details
composer audit --format=json

# Only show advisories (no dev dependencies)
composer audit --no-dev
```

#### Additional Security Tools
- **roave/security-advisories** - Prevent vulnerable versions
- **enlightn/enlightn** - Laravel security scanner
- **symfony/security-checker** - Security vulnerability checker

### Dependency Analysis

#### Check Dependencies
```bash
# Show dependency tree
composer show --tree

# Show package details
composer show vendor/package

# Check why package is installed
composer why vendor/package

# Check what depends on package
composer depends vendor/package
```

#### Optimize Dependencies
```bash
# Remove unused packages
composer install --no-dev --optimize-autoloader

# Lock file validation
composer validate --strict

# Diagnose issues
composer diagnose
```

## Version Management

### Semantic Versioning

#### Version Constraints
- `^1.0` - Compatible with 1.x (>=1.0.0 <2.0.0)
- `~1.0` - Next significant release (>=1.0.0 <1.1.0)
- `1.0.*` - Patch releases only (>=1.0.0 <1.1.0)
- `>=1.0` - Minimum version
- `<2.0` - Maximum version
- `1.0.0 - 2.0.0` - Range

#### Lock File Management
```bash
# Update lock file only
composer update --lock

# Install exact versions from lock
composer install

# Refresh lock file
rm composer.lock
composer install
```

## Package Categories

### Core Laravel Packages
Regularly update these packages:
- laravel/framework
- laravel/tinker
- guzzlehttp/guzzle
- symfony components

### Development Packages
Manage in require-dev:
- Testing frameworks
- Debug tools
- Code quality tools
- Documentation generators

### Production Packages
Critical for production:
- Caching libraries
- Queue drivers
- Database drivers
- Security packages

## Automation Scripts

### Update Script
```bash
#!/bin/bash
# update-packages.sh

# Backup current state
cp composer.lock composer.lock.backup

# Update packages
composer update --with-dependencies

# Run tests
php artisan test

# If tests fail, restore
if [ $? -ne 0 ]; then
    mv composer.lock.backup composer.lock
    composer install
    echo "Update failed, restored previous state"
fi
```

### Audit Script
```bash
#!/bin/bash
# audit-packages.sh

# Run security audit
composer audit

# Check outdated packages
composer outdated --direct

# Validate composer files
composer validate --strict

# Generate report
composer show --tree > package-report.txt
```

### Cleanup Script
```bash
#!/bin/bash
# cleanup-packages.sh

# Clear composer cache
composer clear-cache

# Remove vendor directory
rm -rf vendor

# Remove node_modules
rm -rf node_modules

# Reinstall dependencies
composer install --optimize-autoloader
npm ci
```

## Best Practices

### Regular Maintenance
1. **Weekly**: Check for security updates
2. **Bi-weekly**: Update patch versions
3. **Monthly**: Review and update minor versions
4. **Quarterly**: Plan major version updates

### Update Strategy
1. Always backup before updates
2. Update dev dependencies first
3. Test thoroughly after updates
4. Update production dependencies carefully
5. Document breaking changes

### Production Deployment
```bash
# Optimize for production
composer install --no-dev --optimize-autoloader

# Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Troubleshooting

### Common Issues

#### Memory Limit Errors
```bash
# Increase memory limit
php -d memory_limit=-1 composer update

# Or set in composer.json
"config": {
    "process-timeout": 0,
    "memory-limit": "2G"
}
```

#### Conflicting Dependencies
```bash
# Show conflicts
composer why-not vendor/package:^2.0

# Force update with conflicts
composer update --with-all-dependencies
```

#### Platform Requirements
```bash
# Ignore platform requirements
composer install --ignore-platform-reqs

# Check platform requirements
composer check-platform-reqs
```

#### Cache Issues
```bash
# Clear all caches
composer clear-cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

## Monitoring Tools

### Package Monitoring Services
- **Dependabot** - Automated dependency updates
- **Renovate** - Dependency update automation
- **Snyk** - Security monitoring
- **Libraries.io** - Dependency tracking

### Laravel-Specific Tools
- **Laravel Shift** - Automated upgrade tool
- **Laravel Envoyer** - Deployment with health checks
- **Laravel Forge** - Server management with package updates

## CI/CD Integration

### GitHub Actions
```yaml
name: Package Audit
on:
  schedule:
    - cron: '0 0 * * 0'
  push:
    branches: [main]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Composer Audit
        run: composer audit
      - name: NPM Audit
        run: npm audit
```

### GitLab CI
```yaml
package-audit:
  script:
    - composer audit
    - npm audit
  only:
    - schedules
    - merge_requests
```

## Requirements

- PHP 8.2+
- Composer 2.0+
- Git for version control
- Node.js for npm packages