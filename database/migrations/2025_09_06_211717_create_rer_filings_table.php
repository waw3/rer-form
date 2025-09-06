<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rer_filings', function (Blueprint $table) {
            $table->id();
            $table->string('filing_number')->unique()->nullable();
            
            // Filing Information
            $table->enum('filing_type', ['initial_report', 'correct_amend', 'fincen_directed']);
            $table->string('prior_bsa_id', 14)->nullable();
            $table->date('date_prepared');
            $table->text('note_to_fincen')->nullable();
            $table->date('closing_date');
            
            // Reporting Person Information
            $table->enum('reporting_person_category', [
                'closing_agent', 'statement_preparer', 'deed_filer', 
                'title_insurer', 'fund_disburser', 'title_evaluator', 'deed_preparer'
            ]);
            $table->boolean('reporting_person_is_entity')->default(false);
            $table->string('reporting_person_name', 150);
            $table->string('reporting_person_first_name', 50)->nullable();
            $table->string('reporting_person_middle_name', 50)->nullable();
            $table->string('reporting_person_suffix', 10)->nullable();
            $table->string('reporting_person_street_address', 100);
            $table->string('reporting_person_city', 50);
            $table->string('reporting_person_state', 2);
            $table->string('reporting_person_zip', 10);
            
            // Payment Summary
            $table->decimal('total_consideration', 15, 2)->nullable();
            $table->boolean('no_consideration_transfer')->default(false);
            $table->boolean('has_private_loan')->default(false);
            $table->enum('private_loan_type', [
                'hard_money', 'private_money', 'seller_financed', 'other'
            ])->nullable();
            $table->string('private_loan_other', 100)->nullable();
            
            // Status and Metadata
            $table->enum('status', ['draft', 'validated', 'submitted', 'accepted', 'rejected'])->default('draft');
            $table->json('validation_errors')->nullable();
            $table->timestamp('submitted_at')->nullable();
            $table->string('submission_confirmation')->nullable();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->timestamps();
            
            $table->index('status');
            $table->index('filing_type');
            $table->index('user_id');
        });

        // Properties table
        Schema::create('rer_properties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('rer_filing_id')->constrained()->onDelete('cascade');
            $table->string('street_address', 100)->nullable();
            $table->boolean('no_street_address')->default(false);
            $table->string('city', 50);
            $table->string('state', 2);
            $table->string('zip', 10);
            $table->enum('legal_description_type', [
                'lot_block', 'subdivision', 'government_survey', 
                'metes_bounds', 'other'
            ]);
            $table->string('legal_description_other', 100)->nullable();
            $table->text('legal_description');
            $table->timestamps();
            
            $table->index('rer_filing_id');
        });

        // Transferees (Buyers) table
        Schema::create('rer_transferees', function (Blueprint $table) {
            $table->id();
            $table->foreignId('rer_filing_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['entity', 'trust']);
            $table->string('legal_name', 150);
            $table->string('alternate_name', 150)->nullable();
            $table->decimal('total_consideration', 15, 2)->nullable();
            $table->boolean('no_consideration')->default(false);
            $table->boolean('foreign_no_us_location')->default(false);
            $table->enum('address_type', [
                'us_principal', 'foreign_principal', 'us_location'
            ])->nullable();
            $table->string('street_address', 100)->nullable();
            $table->string('city', 50)->nullable();
            $table->string('country', 2)->nullable();
            $table->string('state', 2)->nullable();
            $table->string('postal_code', 10)->nullable();
            $table->enum('id_type', [
                'ein', 'ssn_itin', 'foreign_tax_id', 
                'foreign_entity_reg', 'no_id'
            ]);
            $table->string('id_number', 50)->nullable();
            $table->string('issuing_jurisdiction', 50)->nullable();
            $table->date('trust_execution_date')->nullable();
            $table->boolean('is_revocable')->default(false);
            $table->timestamps();
            
            $table->index('rer_filing_id');
        });

        // Transferee Persons table
        Schema::create('rer_transferee_persons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('rer_transferee_id')->constrained()->onDelete('cascade');
            $table->enum('type', ['beneficial_owner', 'signing_individual', 'trustee_entity']);
            $table->boolean('is_parent_guardian')->default(false);
            $table->string('last_name', 150);
            $table->string('alternate_name', 150)->nullable();
            $table->string('first_name', 50)->nullable();
            $table->string('middle_name', 50)->nullable();
            $table->string('suffix', 10)->nullable();
            $table->date('date_of_birth')->nullable();
            $table->boolean('foreign_no_us_location')->default(false);
            $table->enum('address_type', [
                'us_principal', 'foreign_principal', 'us_location'
            ])->nullable();
            $table->string('street_address', 100);
            $table->string('city', 50);
            $table->string('country', 2);
            $table->string('state', 2)->nullable();
            $table->string('postal_code', 10);
            $table->enum('id_type', [
                'ein', 'ssn_itin', 'foreign_tax_id', 
                'foreign_passport', 'foreign_entity_reg', 'no_id'
            ]);
            $table->string('id_number', 50)->nullable();
            $table->string('issuing_jurisdiction', 50)->nullable();
            $table->json('beneficial_owner_categories')->nullable();
            $table->json('citizenship_countries')->nullable();
            $table->enum('authorization_capacity', [
                'employee', 'agent', 'partner', 'officer', 
                'counsel', 'trustee', 'other'
            ])->nullable();
            $table->string('authorization_other', 100)->nullable();
            $table->string('employer_name', 150)->nullable();
            $table->timestamps();
            
            $table->index('rer_transferee_id');
        });

        // Transferors (Sellers) table
        Schema::create('rer_transferors', function (Blueprint $table) {
            $table->id();
            $table->foreignId('rer_filing_id')->constrained()->onDelete('cascade');
            $table->enum('entity_type', ['entity', 'trust'])->nullable();
            $table->string('last_name', 150);
            $table->string('alternate_name', 150)->nullable();
            $table->string('first_name', 50)->nullable();
            $table->string('middle_name', 50)->nullable();
            $table->string('suffix', 10)->nullable();
            $table->date('date_of_birth')->nullable();
            $table->boolean('foreign_no_us_location')->default(false);
            $table->enum('address_type', [
                'us_principal', 'foreign_principal', 'us_location'
            ])->nullable();
            $table->string('street_address', 100);
            $table->string('city', 50);
            $table->string('country', 2);
            $table->string('state', 2)->nullable();
            $table->string('postal_code', 10);
            $table->enum('id_type', [
                'ein', 'ssn_itin', 'foreign_tax_id', 
                'foreign_passport', 'foreign_entity_reg', 'no_id'
            ]);
            $table->string('id_number', 50)->nullable();
            $table->string('issuing_jurisdiction', 50)->nullable();
            $table->date('trust_execution_date')->nullable();
            $table->timestamps();
            
            $table->index('rer_filing_id');
        });

        // Payments table
        Schema::create('rer_payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('rer_filing_id')->constrained()->onDelete('cascade');
            $table->decimal('amount', 15, 2);
            $table->enum('method', [
                'wire', 'cashiers_check', 'personal_check', 'money_order',
                'us_currency', 'foreign_currency', 'digital_assets', 
                'stocks_bonds', 'other'
            ]);
            $table->string('method_other', 100)->nullable();
            $table->string('currency_code', 3)->nullable();
            $table->string('currency_description', 100)->nullable();
            $table->boolean('not_from_institution')->default(false);
            $table->string('account_number', 50)->nullable();
            $table->string('institution_name', 150)->nullable();
            $table->boolean('for_all_transferees')->default(false);
            $table->string('transferee_name', 150)->nullable();
            $table->boolean('all_payers_transferees')->default(false);
            $table->timestamps();
            
            $table->index('rer_filing_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rer_payments');
        Schema::dropIfExists('rer_transferors');
        Schema::dropIfExists('rer_transferee_persons');
        Schema::dropIfExists('rer_transferees');
        Schema::dropIfExists('rer_properties');
        Schema::dropIfExists('rer_filings');
    }
};