# Claude Code Prompt: Implement RER Validation Rules Test Coverage System

## Project Context

You are implementing a comprehensive test coverage system for RER (Real Estate Report) validation rules in a Laravel application. The system has 97 validation rule classes with only 2% test coverage (2 out of 97 rules tested). Your goal is to achieve 100% test coverage following FinCEN compliance requirements while adhering to established validation patterns.

## Critical Validation Patterns to Follow

### ⚠️ MANDATORY: Follow These Patterns from PR #182

1. **Enum Value Handling**
   ```php
   // ALWAYS use getEnumValue() helper
   $entityType = $this->getEnumValue($entity->type);
   if (EntityType::PERSON->value === $entityType) {
	   // Never compare enums directly
   }
   ```

2. **Collection Reindexing**
   ```php
   // ALWAYS call ->values() after filtering
   $buyers = $this->getTopLevelBuyers($report->entities)->values();
   ```

3. **Entity Loading**
   ```php
   // ALWAYS use loadEntitiesForRule()
   $report = $this->loadEntitiesForRule($report);
   // Never use loadMissing('entities')
   ```

4. **Safe String Operations**
   ```php
   // ALWAYS use toString() helper
   $trimmed = trim($this->toString($report->fincen_note));
   ```

5. **Date Validation**
   ```php
   // ALWAYS handle parsing errors
   try {
	   $dob = $entity->dob instanceof Carbon
		   ? $entity->dob
		   : Carbon::parse((string)$entity->dob);
   } catch (Throwable $e) {
	   return ValidationResult::failure(...);
   }
   ```

6. **ZIP Code Pattern**
   ```php
   // MUST accept both ZIP and ZIP+4
   preg_match('/^\d{5}(-\d{4})?$/', $zip)
   ```

## Implementation Phases

### Phase 1: Test Infrastructure Setup [PRIORITY: CRITICAL]

**Task 1.1: Create Enhanced Base Test Class**
```
Path: tests/Unit/Validators/Reports/Rules/RuleTestCase.php
```

Create an abstract base test class that:
- Extends Laravel's TestCase
- Uses RefreshDatabase trait
- Includes helper methods that mirror validation rule helpers:
  - `getEnumValue()` for test enum handling
  - `toString()` for safe string operations
  - Methods for creating properly indexed entity collections
- Sets up reports with tree-ified entities
- Provides assertion helpers for ValidationResult objects

```php
abstract class RuleTestCase extends TestCase
{
	use RefreshDatabase;

	protected function setupBaseReport(): RerReport
	{
		$report = RerReport::factory()->create([
			'type' => 'rer',
			'filing_type' => 'initial_report',
		]);

		// Ensure entities are properly loaded with tree structure
		return $this->loadEntitiesForRule($report);
	}

	protected function addBuyer(array $attributes = []): Entity
	{
		// IMPORTANT: Use enum ->value for database storage
		return Entity::factory()->create(array_merge([
			'report_id' => $this->report->id,
			'type' => EntityType::PERSON->value, // Always use ->value
			'transfer_role' => TransferRole::BUYER->value,
		], $attributes));
	}

	protected function assertValidationFailure(
		ValidationResult $result,
		string $expectedField,
		string $expectedMessage = null
	): void {
		$this->assertFalse($result->isSuccess());
		$this->assertEquals($expectedField, $result->getField());
		if ($expectedMessage) {
			$this->assertStringContainsString($expectedMessage, $result->getMessage());
		}
	}
}
```

**Task 1.2: Create Pattern-Aware Test Generator**
```
Path: app/Services/Testing/ValidationRuleTestGenerator.php
```

Build a service that:
- Analyzes rule classes for common patterns (enum usage, entity filtering, date handling)
- Generates test cases that properly handle these patterns
- Creates tests with reindexed collections
- Includes tests for edge cases identified in validation-patterns.md

### Phase 2: Test Generation Templates with Pattern Compliance [PRIORITY: HIGH]

**Task 2.1: Create Pattern-Compliant Test Templates**

Each template MUST follow these patterns:

```php
// Template for Buyer Rules
class BuyerRuleTestTemplate
{
	const TEMPLATE = <<<'PHP'
	public function test_it_validates_buyer_field_correctly(): void
	{
		// Arrange - Create report with tree-ified entities
		$report = $this->setupBaseReport();

		// Create buyers with proper enum values
		$buyer1 = $this->addBuyer([
			'type' => EntityType::PERSON->value, // Always use ->value
			'required_field' => 'valid_value',
		]);

		// Reload report to ensure tree structure
		$report = $this->loadEntitiesForRule($report);

		// Act
		$rule = new {RuleName}();
		$result = $rule($report);

		// Assert - Check reindexed collection paths
		$this->assertTrue($result->isSuccess());
	}

	public function test_it_handles_enum_values_correctly(): void
	{
		$report = $this->setupBaseReport();

		// Test both enum instance and string value
		$buyer = $this->addBuyer([
			'type' => 'person', // String value
		]);

		$rule = new {RuleName}();
		$result = $rule($report);

		// Should handle both formats
		$this->assertTrue($result->isSuccess());
	}

	public function test_it_reindexes_collections_properly(): void
	{
		$report = $this->setupBaseReport();

		// Create buyers with gaps in indices
		$buyer1 = $this->addBuyer(['id' => 1]);
		$buyer2 = $this->addBuyer(['id' => 5]);
		$buyer3 = $this->addBuyer(['id' => 10]);

		// Delete middle buyer to create gap
		$buyer2->delete();

		$rule = new {RuleName}();
		$result = $rule($report->fresh());

		// Error paths should be reindexed (0, 1) not (1, 10)
		if (!$result->isSuccess()) {
			$this->assertMatchesRegularExpression(
				'/entities\.[0-1]\./',
				$result->getField()
			);
		}
	}
	PHP;
}
```

### Phase 3: Pattern-Specific Test Cases [PRIORITY: CRITICAL]

**Task 3.1: Create Pattern Test Suite**
```
Path: tests/Unit/Validators/Reports/Rules/Patterns/
```

Create specific test classes for each pattern:

1. **EnumHandlingTest.php** - Verify all rules handle enum/string conversion
2. **CollectionIndexingTest.php** - Verify proper reindexing after filtering
3. **EntityLoadingTest.php** - Verify tree structure is maintained
4. **StringHandlingTest.php** - Verify safe string operations
5. **DateValidationTest.php** - Verify proper date parsing and error handling
6. **ZipCodeValidationTest.php** - Verify ZIP and ZIP+4 acceptance

### Phase 4: Coverage Matrix with Pattern Tracking [PRIORITY: HIGH]

**Task 4.1: Enhanced Coverage Matrix Builder**
```
Path: app/Services/Testing/ValidationRuleCoverageMatrix.php
```

```php
class ValidationRuleCoverageMatrix
{
	public function generate(): array
	{
		return [
			'buyer_rules' => $this->mapBuyerRules(),
			'pattern_compliance' => $this->checkPatternCompliance(),
			'common_pitfalls' => $this->identifyPitfalls(),
		];
	}

	private function checkPatternCompliance(): array
	{
		return [
			'enum_handling' => $this->findRulesUsingEnums(),
			'collection_filtering' => $this->findRulesFilteringCollections(),
			'entity_loading' => $this->findRulesLoadingEntities(),
			'string_operations' => $this->findRulesWithStringOps(),
			'date_parsing' => $this->findRulesParsingDates(),
			'zip_validation' => $this->findRulesValidatingZips(),
		];
	}

	private function identifyPitfalls(): array
	{
		return [
			'missing_values_call' => $this->findMissingValuesCall(),
			'direct_enum_comparison' => $this->findDirectEnumComparison(),
			'unsafe_string_ops' => $this->findUnsafeStringOperations(),
			'unhandled_date_parsing' => $this->findUnhandledDateParsing(),
		];
	}
}
```

### Phase 5: Test Generation Priority Based on Patterns [PRIORITY: CRITICAL]

**Week 1: Critical Rules with Pattern Compliance**

Generate tests focusing on proper pattern usage:

1. **Payment Rules (16 rules)**
   - Ensure amount string handling uses `toString()`
   - Validate enum payment methods properly
   - Test collection reindexing for multiple payments

2. **Buyer Identification Rules (10 rules)**
   - Test enum handling for EntityType and TransferRole
   - Verify collection reindexing after filtering
   - Test entity tree structure preservation

3. **Seller Identification Rules (8 rules)**
   - Similar pattern compliance as buyer rules
   - Test foreign address ZIP+4 handling

**Week 2: Date and String-Heavy Rules**

4. **Property Rules (12 rules)**
   - ZIP code validation with both formats
   - Safe string operations on addresses
   - Date parsing for closing dates

5. **Entity TIN/SSN Rules (5 rules)**
   - Safe string operations on TIN/SSN
   - Pattern matching with proper error handling

### Phase 6: Pattern Validation Command [PRIORITY: HIGH]

**Task 6.1: Create Pattern Compliance Checker**
```
Path: app/Console/Commands/ValidatePatternComplianceCommand.php
```

```php
class ValidatePatternComplianceCommand extends Command
{
	protected $signature = 'validate:patterns {--fix}';

	public function handle(): void
	{
		$violations = [];

		// Check for direct enum comparisons
		$violations['enum'] = $this->findDirectEnumComparisons();

		// Check for missing ->values() calls
		$violations['reindex'] = $this->findMissingReindexing();

		// Check for loadMissing usage
		$violations['loading'] = $this->findImproperEntityLoading();

		// Check for unsafe string operations
		$violations['strings'] = $this->findUnsafeStringOps();

		// Check for unhandled date parsing
		$violations['dates'] = $this->findUnhandledDateParsing();

		// Check ZIP regex patterns
		$violations['zip'] = $this->findIncorrectZipPatterns();

		if ($this->option('fix')) {
			$this->fixViolations($violations);
		} else {
			$this->reportViolations($violations);
		}
	}
}
```

### Phase 7: CI/CD with Pattern Enforcement [PRIORITY: HIGH]

**Task 7.1: Enhanced GitHub Actions Workflow**
```yaml
name: Validation Rule Testing and Pattern Compliance

on:
  push:
	paths:
	  - 'app/Validators/Reports/Rules/**'
	  - 'tests/Unit/Validators/Reports/Rules/**'

jobs:
  pattern-compliance:
	runs-on: ubuntu-latest
	steps:
	  - name: Check pattern compliance
		run: php artisan validate:patterns

	  - name: Verify enum handling
		run: |
		  if grep -r "EntityType::" --include="*Rule.php" | grep -v "->value"; then
			echo "Direct enum comparison found!"
			exit 1
		  fi

	  - name: Verify collection reindexing
		run: |
		  if grep -r "filter(" --include="*Rule.php" | grep -v "->values()"; then
			echo "Missing ->values() after filter!"
			exit 1
		  fi

  test-coverage:
	needs: pattern-compliance
	runs-on: ubuntu-latest
	steps:
	  - name: Run validation rule tests
		run: php artisan test --testsuite="Validation Rules"

	  - name: Check coverage
		run: |
		  coverage=$(php artisan test:rule-coverage --json | jq '.percentage')
		  if (( $(echo "$coverage < 100" | bc -l) )); then
			exit 1
		  fi
```

## Critical Questions Before Implementation

### Pattern-Specific Questions

1. **Enum Handling**
   - Are there custom enums beyond EntityType and TransferRole?
   - Should tests handle both BackedEnum and string values?
   - Are there any enums that shouldn't use the ->value pattern?

2. **Collection Indexing**
   - Are there scenarios where preserving original keys is intended?
   - How should nested entity collections be handled?
   - Should error paths always use numeric indices?

3. **Entity Loading**
   - Is the tree structure always required for validation?
   - Are there performance implications of reloading entities?
   - Should tests verify the tree structure explicitly?

4. **String Operations**
   - Which fields might contain non-string values?
   - Should empty strings be treated as null?
   - Are there fields that should preserve whitespace?

5. **Date Handling**
   - What timezone should be used for date comparisons?
   - How should partial dates be handled?
   - Are there date fields that allow future dates?

6. **ZIP Validation**
   - Should international postal codes be supported?
   - Are there specific states with unique ZIP patterns?
   - Should ZIP+4 be required or optional?

### Testing Strategy Questions

1. Should tests mock the `loadEntitiesForRule()` method or use real database?
2. How should tests handle the entity tree structure?
3. Should pattern compliance be tested separately or within each rule test?
4. What level of test isolation is required?
5. Should tests verify logging behavior?

## Test Structure Following Patterns

```php
namespace Tests\Unit\Validators\Reports\Rules\RER\Buyer;

use App\Enums\EntityType;
use App\Enums\TransferRole;
use App\Models\Entity;
use App\Models\Report;
use App\Validators\Reports\Rules\RER\Buyer\BuyerAddressRequiredRule;
use Tests\Unit\Validators\Reports\Rules\RuleTestCase;

class BuyerAddressRequiredRuleTest extends RuleTestCase
{
	private BuyerAddressRequiredRule $rule;

	protected function setUp(): void
	{
		parent::setUp();
		$this->rule = new BuyerAddressRequiredRule();
	}

	/**
	 * @test
	 * @covers BuyerAddressRequiredRule
	 * @dataProvider validAddressProvider
	 */
	public function it_passes_with_valid_addresses($addressData): void
	{
		// Arrange - Create report with proper entity loading
		$report = $this->setupBaseReport();

		// Create buyer with enum values as strings (database format)
		$buyer = Entity::factory()->create([
			'report_id' => $report->id,
			'type' => EntityType::PERSON->value,
			'transfer_role' => TransferRole::BUYER->value,
			...$addressData,
		]);

		// Ensure entities are tree-ified
		$report = $this->loadEntitiesForRule($report);

		// Act
		$result = ($this->rule)($report);

		// Assert
		$this->assertTrue($result->isSuccess());
	}

	/**
	 * @test
	 */
	public function it_handles_filtered_and_reindexed_collections(): void
	{
		$report = $this->setupBaseReport();

		// Create multiple buyers with gaps
		$buyer1 = $this->createBuyerAtIndex($report, 0);
		$buyer2 = $this->createBuyerAtIndex($report, 5);
		$buyer3 = $this->createBuyerAtIndex($report, 10);

		// Delete middle buyer to create gap
		$buyer2->delete();

		// Reload with tree structure
		$report = $this->loadEntitiesForRule($report->fresh());

		// Act
		$result = ($this->rule)($report);

		// Assert - Error paths should be reindexed
		if (!$result->isSuccess()) {
			$field = $result->getField();
			$this->assertMatchesRegularExpression(
				'/^entities\.[0-1]\./',
				$field,
				"Field path should use reindexed keys, got: {$field}"
			);
		}
	}

	/**
	 * @test
	 */
	public function it_handles_zip_plus_four_format(): void
	{
		$report = $this->setupBaseReport();

		$buyer = $this->addBuyer([
			'us_address_zip' => '12345-6789', // ZIP+4 format
		]);

		$report = $this->loadEntitiesForRule($report);
		$result = ($this->rule)($report);

		$this->assertTrue(
			$result->isSuccess(),
			'Should accept ZIP+4 format'
		);
	}

	/**
	 * @test
	 */
	public function it_safely_handles_null_and_non_string_values(): void
	{
		$report = $this->setupBaseReport();

		$buyer = $this->addBuyer([
			'us_address_street' => null,
			'us_address_city' => 123, // Non-string
		]);

		$report = $this->loadEntitiesForRule($report);
		$result = ($this->rule)($report);

		// Should handle without TypeErrors
		$this->assertInstanceOf(ValidationResult::class, $result);
	}

	public function validAddressProvider(): array
	{
		return [
			'US address with ZIP' => [[
				'us_address_street' => '123 Main St',
				'us_address_city' => 'New York',
				'us_address_state' => 'NY',
				'us_address_zip' => '10001',
			]],
			'US address with ZIP+4' => [[
				'us_address_street' => '456 Oak Ave',
				'us_address_city' => 'Los Angeles',
				'us_address_state' => 'CA',
				'us_address_zip' => '90001-1234',
			]],
			'Foreign address' => [[
				'foreign_address_street' => '789 King St',
				'foreign_address_city' => 'Toronto',
				'foreign_address_province' => 'ON',
				'foreign_address_country' => 'CA',
				'foreign_address_postal_code' => 'M5V 3A8',
			]],
		];
	}
}
```

## Implementation Checklist

### Pattern Compliance Checklist
- [ ] All enum comparisons use `getEnumValue()` helper
- [ ] All filtered collections call `->values()` for reindexing
- [ ] All entity loading uses `loadEntitiesForRule()`
- [ ] All string operations use `toString()` helper
- [ ] All date parsing includes try-catch error handling
- [ ] All ZIP validations accept both ZIP and ZIP+4 formats
- [ ] No direct use of `loadMissing('entities')`
- [ ] Stack traces limited to 5 frames in logging

### Test Quality Checklist
- [ ] Tests use enum `->value` for database operations
- [ ] Tests verify collection reindexing behavior
- [ ] Tests check entity tree structure preservation
- [ ] Tests include edge cases from validation-patterns.md
- [ ] Tests use proper assertions for ValidationResult
- [ ] Tests include data providers for multiple scenarios
- [ ] Tests document FinCEN field mappings

### CI/CD Integration Checklist
- [ ] Pattern compliance check in pre-commit hook
- [ ] Automated pattern violation detection
- [ ] Coverage report includes pattern compliance metrics
- [ ] GitHub Actions workflow validates patterns
- [ ] Documentation updated with pattern requirements

## Execution Commands

```bash
# Check pattern compliance
php artisan validate:patterns

# Fix pattern violations automatically
php artisan validate:patterns --fix

# Generate tests with pattern compliance
php artisan test:generate --with-patterns

# Run pattern-specific test suite
php artisan test --testsuite="Pattern Compliance"

# Generate pattern compliance report
php artisan test:pattern-report

# Check for specific pattern violations
grep -r "EntityType::" --include="*Rule.php" app/Validators/
grep -r "filter(" --include="*Rule.php" app/Validators/ | grep -v "->values()"
grep -r "loadMissing" --include="*Rule.php" app/Validators/
```

## Expected Outcomes

After implementation:
1. **100% test coverage** with pattern-compliant tests
2. **Zero pattern violations** in validation rules
3. **Consistent error handling** across all rules
4. **Predictable collection indexing** for UI integration
5. **Robust enum handling** for database/model interactions
6. **Safe string operations** preventing TypeErrors
7. **Comprehensive date validation** with proper error messages
8. **ZIP+4 support** across all address validations

## Notes for Claude Code

1. **Always check existing patterns** - Reference BuyerExemptionValidationRuleTest.php and PaymentTotalValidationRuleTest.php
2. **Follow PR #182 fixes** - These patterns solved real production issues
3. **Test both success and failure paths** - Including edge cases
4. **Verify error field paths** - Must match UI expectations with reindexed collections
5. **Use factories properly** - Always use enum ->value for database storage
6. **Document pattern usage** - Include comments explaining why patterns are used

This implementation ensures not just coverage, but correct, maintainable, and production-ready validation rule tests.

**Thread Remaining: 75%**