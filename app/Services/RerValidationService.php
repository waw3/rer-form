<?php

namespace App\Services;

use App\Models\RerFiling;
use Illuminate\Support\Facades\Validator;

class RerValidationService
{
    public function validate(RerFiling $filing): array
    {
        $errors = [];
        
        // Filing Information Validation
        $filingErrors = $this->validateFilingInformation($filing);
        if (!empty($filingErrors)) {
            $errors['filing_information'] = $filingErrors;
        }
        
        // Reporting Person Validation
        $reportingErrors = $this->validateReportingPerson($filing);
        if (!empty($reportingErrors)) {
            $errors['reporting_person'] = $reportingErrors;
        }
        
        // Property Validation
        $propertyErrors = $this->validateProperties($filing);
        if (!empty($propertyErrors)) {
            $errors['properties'] = $propertyErrors;
        }
        
        // Transferee Validation
        $transfereeErrors = $this->validateTransferees($filing);
        if (!empty($transfereeErrors)) {
            $errors['transferees'] = $transfereeErrors;
        }
        
        // Transferor Validation
        $transferorErrors = $this->validateTransferors($filing);
        if (!empty($transferorErrors)) {
            $errors['transferors'] = $transferorErrors;
        }
        
        // Payment Validation
        $paymentErrors = $this->validatePayments($filing);
        if (!empty($paymentErrors)) {
            $errors['payments'] = $paymentErrors;
        }
        
        // Cross-section validation
        $crossErrors = $this->validateCrossSections($filing);
        if (!empty($crossErrors)) {
            $errors['cross_validation'] = $crossErrors;
        }
        
        return $errors;
    }
    
    private function validateFilingInformation(RerFiling $filing): array
    {
        $rules = [
            'filing_type' => 'required|in:initial_report,correct_amend,fincen_directed',
            'date_prepared' => 'required|date|before_or_equal:today',
            'closing_date' => 'required|date|before_or_equal:today',
            'note_to_fincen' => 'nullable|string|max:4000',
        ];
        
        // Conditional BSA ID validation
        if ($filing->filing_type === 'correct_amend') {
            $rules['prior_bsa_id'] = 'required|regex:/^[A-Z0-9]{14}$/';
        } elseif (in_array($filing->filing_type, ['initial_report', 'fincen_directed'])) {
            if (!empty($filing->prior_bsa_id)) {
                return ['prior_bsa_id' => 'BSA ID must not be provided for initial reports or FinCEN directed filings.'];
            }
        }
        
        $validator = Validator::make($filing->toArray(), $rules);
        return $validator->errors()->toArray();
    }
    
    private function validateReportingPerson(RerFiling $filing): array
    {
        $rules = [
            'reporting_person_category' => 'required|in:closing_agent,statement_preparer,deed_filer,title_insurer,fund_disburser,title_evaluator,deed_preparer',
            'reporting_person_name' => 'required|string|max:150',
            'reporting_person_street_address' => 'required|string|max:100',
            'reporting_person_city' => 'required|string|max:50|regex:/^[a-zA-Z\s\-\.]+$/',
            'reporting_person_state' => 'required|string|size:2',
            'reporting_person_zip' => 'required|regex:/^\d{5}(-\d{4})?$/',
        ];
        
        // Entity vs Individual validation
        if ($filing->reporting_person_is_entity) {
            if (!empty($filing->reporting_person_first_name)) {
                return ['reporting_person_first_name' => 'First name must be blank when reporting person is an entity.'];
            }
        } else {
            $rules['reporting_person_first_name'] = 'required|string|max:50';
        }
        
        $validator = Validator::make($filing->toArray(), $rules);
        return $validator->errors()->toArray();
    }
    
    private function validateProperties(RerFiling $filing): array
    {
        $errors = [];
        
        if ($filing->properties->count() === 0) {
            return ['general' => 'At least one property is required.'];
        }
        
        foreach ($filing->properties as $index => $property) {
            $propertyRules = [
                'city' => 'required|string|max:50',
                'state' => 'required|string|size:2',
                'zip' => 'required|regex:/^\d{5}(-\d{4})?$/',
                'legal_description_type' => 'required|in:lot_block,subdivision,government_survey,metes_bounds,other',
                'legal_description' => 'required|string|max:4000',
            ];
            
            // Street address validation
            if (!$property->no_street_address) {
                $propertyRules['street_address'] = 'required|string|max:100';
            } elseif (!empty($property->street_address)) {
                $errors[$index]['street_address'] = 'Street address must be blank when "No street address" is checked.';
            }
            
            // Legal description type 'other' validation
            if ($property->legal_description_type === 'other') {
                $propertyRules['legal_description_other'] = 'required|string|max:100';
            }
            
            $validator = Validator::make($property->toArray(), $propertyRules);
            if ($validator->fails()) {
                $errors[$index] = $validator->errors()->toArray();
            }
        }
        
        return $errors;
    }
    
    private function validateTransferees(RerFiling $filing): array
    {
        $errors = [];
        
        if ($filing->transferees->count() === 0) {
            return ['general' => 'At least one transferee (buyer) is required.'];
        }
        
        foreach ($filing->transferees as $index => $transferee) {
            $transfereeRules = [
                'type' => 'required|in:entity,trust',
                'legal_name' => 'required|string|max:150',
                'id_type' => 'required|in:ein,ssn_itin,foreign_tax_id,foreign_entity_reg,no_id',
            ];
            
            // Consideration validation
            if (!$transferee->no_consideration) {
                $transfereeRules['total_consideration'] = 'required|numeric|min:0.01|regex:/^\d+(\.\d{1,2})?$/';
            } elseif (!empty($transferee->total_consideration)) {
                $errors[$index]['total_consideration'] = 'Total consideration must be blank when "No consideration paid" is checked.';
            }
            
            // Trust-specific validation
            if ($transferee->type === 'trust') {
                $transfereeRules['trust_execution_date'] = 'required|date|before_or_equal:today';
                if (!empty($transferee->alternate_name)) {
                    $errors[$index]['alternate_name'] = 'Alternate name must be blank for trusts.';
                }
            }
            
            // ID validation
            if ($transferee->id_type !== 'no_id') {
                $transfereeRules['id_number'] = 'required|string';
            }
            
            // Address validation for entities
            if ($transferee->type === 'entity') {
                $transfereeRules['street_address'] = 'required|string|max:100';
                $transfereeRules['city'] = 'required|string|max:50';
                $transfereeRules['country'] = 'required|string|size:2';
                $transfereeRules['postal_code'] = 'required|string|max:10';
                
                if ($transferee->country === 'US') {
                    $transfereeRules['state'] = 'required|string|size:2';
                }
            }
            
            $validator = Validator::make($transferee->toArray(), $transfereeRules);
            if ($validator->fails()) {
                $errors[$index]['fields'] = $validator->errors()->toArray();
            }
            
            // Validate associated persons
            if ($transferee->persons->count() === 0) {
                $errors[$index]['persons'] = ['general' => 'At least one associated person is required.'];
            } else {
                $personErrors = $this->validateTransfereePersons($transferee);
                if (!empty($personErrors)) {
                    $errors[$index]['persons'] = $personErrors;
                }
            }
        }
        
        return $errors;
    }
    
    private function validateTransfereePersons($transferee): array
    {
        $errors = [];
        
        foreach ($transferee->persons as $pIndex => $person) {
            $personRules = [
                'type' => 'required|in:beneficial_owner,signing_individual,trustee_entity',
                'last_name' => 'required|string|max:150',
                'street_address' => 'required|string|max:100',
                'city' => 'required|string|max:50',
                'country' => 'required|string|size:2',
                'postal_code' => 'required|string|max:10',
                'id_type' => 'required|in:ein,ssn_itin,foreign_tax_id,foreign_passport,foreign_entity_reg,no_id',
            ];
            
            if ($person->country === 'US') {
                $personRules['state'] = 'required|string|size:2';
            }
            
            // Type-specific validation
            if ($person->type === 'beneficial_owner') {
                $personRules['first_name'] = 'required|string|max:50';
                $personRules['date_of_birth'] = 'required|date|before:' . now()->subYears(18)->format('Y-m-d');
                $personRules['citizenship_countries'] = 'required|array|min:1';
            } elseif ($person->type === 'signing_individual') {
                $personRules['first_name'] = 'required|string|max:50';
                $personRules['authorization_capacity'] = 'required|in:employee,agent,partner,officer,counsel,trustee,other';
                
                if ($person->authorization_capacity === 'other') {
                    $personRules['authorization_other'] = 'required|string|max:100';
                }
            }
            
            // ID validation
            if ($person->id_type !== 'no_id') {
                $personRules['id_number'] = 'required|string';
            }
            
            $validator = Validator::make($person->toArray(), $personRules);
            if ($validator->fails()) {
                $errors[$pIndex] = $validator->errors()->toArray();
            }
        }
        
        return $errors;
    }
    
    private function validateTransferors(RerFiling $filing): array
    {
        $errors = [];
        
        if ($filing->transferors->count() === 0) {
            return ['general' => 'At least one transferor (seller) is required.'];
        }
        
        foreach ($filing->transferors as $index => $transferor) {
            $transferorRules = [
                'last_name' => 'required|string|max:150',
                'street_address' => 'required|string|max:100',
                'city' => 'required|string|max:50',
                'country' => 'required|string|size:2',
                'postal_code' => 'required|string|max:10',
                'id_type' => 'required|in:ein,ssn_itin,foreign_tax_id,foreign_passport,foreign_entity_reg,no_id',
            ];
            
            if ($transferor->country === 'US') {
                $transferorRules['state'] = 'required|string|size:2';
            }
            
            // Individual vs Entity validation
            if ($transferor->isIndividual()) {
                $transferorRules['first_name'] = 'required|string|max:50';
                $transferorRules['date_of_birth'] = 'required|date|before:today';
            } else {
                if (!empty($transferor->first_name)) {
                    $errors[$index]['first_name'] = 'First name must be blank for entities and trusts.';
                }
                
                if ($transferor->entity_type === 'trust') {
                    $transferorRules['trust_execution_date'] = 'required|date|before_or_equal:today';
                }
            }
            
            // ID validation
            if ($transferor->id_type !== 'no_id') {
                $transferorRules['id_number'] = 'required|string';
            }
            
            $validator = Validator::make($transferor->toArray(), $transferorRules);
            if ($validator->fails()) {
                $errors[$index] = $validator->errors()->toArray();
            }
        }
        
        return $errors;
    }
    
    private function validatePayments(RerFiling $filing): array
    {
        $errors = [];
        
        // No consideration transfer validation
        if ($filing->no_consideration_transfer) {
            if ($filing->payments->count() > 0) {
                return ['general' => 'No payments should be recorded for no consideration transfers.'];
            }
            return [];
        }
        
        // Required payment validation
        if (empty($filing->total_consideration)) {
            return ['total_consideration' => 'Total consideration is required unless transfer has no consideration.'];
        }
        
        if ($filing->payments->count() === 0) {
            return ['general' => 'Payment information is required unless no consideration transfer.'];
        }
        
        // Validate individual payments
        foreach ($filing->payments as $index => $payment) {
            $paymentRules = [
                'amount' => 'required|numeric|min:0.01',
                'method' => 'required|in:wire,cashiers_check,personal_check,money_order,us_currency,foreign_currency,digital_assets,stocks_bonds,other',
            ];
            
            if ($payment->method === 'other') {
                $paymentRules['method_other'] = 'required|string|max:100';
            }
            
            if ($payment->method === 'foreign_currency') {
                $paymentRules['currency_code'] = 'required|string|size:3';
            }
            
            if (!$payment->not_from_institution) {
                $paymentRules['account_number'] = 'required|string|max:50';
                $paymentRules['institution_name'] = 'required|string|max:150';
            }
            
            if (!$payment->for_all_transferees) {
                $paymentRules['transferee_name'] = 'required|string|max:150';
            }
            
            $validator = Validator::make($payment->toArray(), $paymentRules);
            if ($validator->fails()) {
                $errors[$index] = $validator->errors()->toArray();
            }
        }
        
        // Validate total matches
        $paymentTotal = $filing->payments->sum('amount');
        if (abs($paymentTotal - $filing->total_consideration) > 0.01) {
            $errors['total'] = 'Payment amounts must equal total consideration.';
        }
        
        return $errors;
    }
    
    private function validateCrossSections(RerFiling $filing): array
    {
        $errors = [];
        
        // Validate transferee consideration total matches filing total
        if (!$filing->no_consideration_transfer) {
            $transfereeTotal = $filing->transferees->sum('total_consideration');
            if ($transfereeTotal > 0 && abs($transfereeTotal - $filing->total_consideration) > 0.01) {
                $errors[] = 'Sum of transferee considerations must equal total consideration.';
            }
        }
        
        return $errors;
    }
}