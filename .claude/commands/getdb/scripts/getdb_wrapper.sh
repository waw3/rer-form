#!/bin/bash

# Database Documentation Generator Wrapper
# Intelligently routes between Laravel and MySQL methods

# Default values
METHOD="laravel"
OUTPUT=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --method)
            METHOD="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--method laravel|mysql] [--output file]"
            echo ""
            echo "Options:"
            echo "  --method   Documentation generation method (default: laravel)"
            echo "             laravel: Uses Laravel's database abstraction"
            echo "             mysql: Direct database interrogation"
            echo "  --output   Output file path (default: varies by method)"
            echo "  --help     Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Function to check if Laravel is available
check_laravel() {
    if [ -f "$PROJECT_ROOT/api/artisan" ]; then
        cd "$PROJECT_ROOT/api"
        if php artisan list 2>/dev/null | grep -q "claude:getdb"; then
            return 0
        fi
    fi
    return 1
}

# Function to check if MySQL is available
check_mysql() {
    if command -v mysql &> /dev/null; then
        # Test connection
        if mysql -u root -h 127.0.0.1 rer -e "SELECT 1;" &> /dev/null; then
            return 0
        fi
    fi
    return 1
}

echo -e "${GREEN}Database Documentation Generator${NC}"
echo "Method: $METHOD"

# Handle Laravel method
if [ "$METHOD" = "laravel" ]; then
    echo -e "${YELLOW}Checking Laravel availability...${NC}"
    
    if check_laravel; then
        echo -e "${GREEN}✓ Laravel artisan command found${NC}"
        
        # Set default output for Laravel if not specified
        if [ -z "$OUTPUT" ]; then
            OUTPUT="docs/database.md"
        fi
        
        echo "Generating documentation with Laravel..."
        echo "Output: api/$OUTPUT"
        
        cd "$PROJECT_ROOT/api"
        php artisan claude:getdb --output="$OUTPUT"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Documentation generated successfully${NC}"
            echo "Location: $PROJECT_ROOT/api/$OUTPUT"
        else
            echo -e "${RED}✗ Failed to generate documentation${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠ Laravel command not available, falling back to MySQL method${NC}"
        METHOD="mysql"
    fi
fi

# Handle MySQL method (also used as fallback)
if [ "$METHOD" = "mysql" ]; then
    echo -e "${YELLOW}Checking MySQL availability...${NC}"
    
    if check_mysql; then
        echo -e "${GREEN}✓ MySQL connection successful${NC}"
        
        # Run the MySQL script
        if [ -z "$OUTPUT" ]; then
            # Output to stdout if no file specified
            echo "Generating documentation to stdout..."
            bash "$SCRIPT_DIR/get_db_structure.sh"
        else
            # Output to file
            echo "Generating documentation to file..."
            echo "Output: $OUTPUT"
            
            # Ensure output directory exists
            OUTPUT_DIR=$(dirname "$OUTPUT")
            mkdir -p "$OUTPUT_DIR"
            
            bash "$SCRIPT_DIR/get_db_structure.sh" > "$OUTPUT"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Documentation generated successfully${NC}"
                echo "Location: $OUTPUT"
            else
                echo -e "${RED}✗ Failed to generate documentation${NC}"
                exit 1
            fi
        fi
    else
        echo -e "${RED}✗ MySQL connection failed${NC}"
        echo "Please check:"
        echo "  1. MySQL is running: mysql.server status"
        echo "  2. Database exists: mysql -u root -e 'SHOW DATABASES;'"
        echo "  3. Credentials are correct in get_db_structure.sh"
        exit 1
    fi
fi

# Invalid method
if [ "$METHOD" != "laravel" ] && [ "$METHOD" != "mysql" ]; then
    echo -e "${RED}✗ Invalid method: $METHOD${NC}"
    echo "Valid methods: laravel, mysql"
    exit 1
fi