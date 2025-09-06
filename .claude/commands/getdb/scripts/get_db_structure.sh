#!/bin/bash

# Database connection details
DB_HOST="127.0.0.1"
DB_USER="root"
DB_NAME="rer"

echo "# Database Structure - RER Application"
echo ""
echo "Generated: $(date)"
echo ""
echo "## Tables Overview"
echo ""

# Get list of tables with row counts
mysql -u $DB_USER -h $DB_HOST $DB_NAME -e "
SELECT
    TABLE_NAME as 'Table',
    ENGINE as 'Engine',
    TABLE_ROWS as 'Rows (Approx)',
    ROUND(DATA_LENGTH/1024/1024, 2) as 'Data Size (MB)'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = '$DB_NAME'
ORDER BY TABLE_NAME;" 2>/dev/null | sed 's/\t/|/g' | awk 'NR==1{print "|" $0 "|"; print "|---|---|---|---|"} NR>1{print "|" $0 "|"}'

echo ""
echo "## Table Structures"
echo ""

# Get all tables
TABLES=$(mysql -u $DB_USER -h $DB_HOST $DB_NAME -e "SHOW TABLES;" 2>/dev/null | tail -n +2)

for TABLE in $TABLES; do
    echo "### $TABLE"
    echo ""

    # Get column information
    echo "#### Columns"
    echo ""
    mysql -u $DB_USER -h $DB_HOST $DB_NAME -e "
    SELECT
        COLUMN_NAME as 'Column',
        COLUMN_TYPE as 'Type',
        IS_NULLABLE as 'Nullable',
        COLUMN_KEY as 'Key',
        COLUMN_DEFAULT as 'Default',
        EXTRA as 'Extra'
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = '$DB_NAME' AND TABLE_NAME = '$TABLE'
    ORDER BY ORDINAL_POSITION;" 2>/dev/null | sed 's/\t/|/g' | awk 'NR==1{print "|" $0 "|"; print "|---|---|---|---|---|---|"} NR>1{print "|" $0 "|"}'

    echo ""

    # Get indexes
    INDEXES=$(mysql -u $DB_USER -h $DB_HOST $DB_NAME -e "SHOW INDEX FROM $TABLE WHERE Key_name != 'PRIMARY';" 2>/dev/null | tail -n +2 | cut -f3 | sort -u)

    if [ -n "$INDEXES" ]; then
        echo "#### Indexes"
        echo ""
        for INDEX in $INDEXES; do
            COLUMNS=$(mysql -u $DB_USER -h $DB_HOST $DB_NAME -e "SHOW INDEX FROM $TABLE WHERE Key_name = '$INDEX';" 2>/dev/null | tail -n +2 | cut -f5 | tr '\n' ', ' | sed 's/,$//')
            echo "- **$INDEX**: $COLUMNS"
        done
        echo ""
    fi

    # Get foreign keys
    FK=$(mysql -u $DB_USER -h $DB_HOST $DB_NAME -e "
    SELECT
        CONSTRAINT_NAME,
        COLUMN_NAME,
        REFERENCED_TABLE_NAME,
        REFERENCED_COLUMN_NAME
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = '$DB_NAME'
        AND TABLE_NAME = '$TABLE'
        AND REFERENCED_TABLE_NAME IS NOT NULL;" 2>/dev/null | tail -n +2)

    if [ -n "$FK" ]; then
        echo "#### Foreign Keys"
        echo ""
        echo "$FK" | while IFS=$'\t' read -r CONSTRAINT COL REF_TABLE REF_COL; do
            echo "- **$CONSTRAINT**: $COL → $REF_TABLE($REF_COL)"
        done
        echo ""
    fi

    echo "---"
    echo ""
done

echo "## Relationships Summary"
echo ""
echo "### Key Relationships"
echo ""

# Get all foreign key relationships
mysql -u $DB_USER -h $DB_HOST $DB_NAME -e "
SELECT
    CONCAT(TABLE_NAME, '.', COLUMN_NAME) as 'From',
    CONCAT(REFERENCED_TABLE_NAME, '.', REFERENCED_COLUMN_NAME) as 'To',
    CONSTRAINT_NAME as 'Constraint'
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = '$DB_NAME'
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;" 2>/dev/null | sed 's/\t/|/g' | awk 'NR==1{print "|" $0 "|"; print "|---|---|---|"} NR>1{print "|" $0 "|"}'