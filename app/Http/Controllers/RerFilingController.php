<?php

namespace App\Http\Controllers;

use App\Models\RerFiling;
use App\Models\RerProperty;
use App\Models\RerTransferee;
use App\Models\RerTransfereePerson;
use App\Models\RerTransferor;
use App\Models\RerPayment;
use App\Services\RerValidationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;

class RerFilingController extends Controller
{
    protected RerValidationService $validationService;
    
    public function __construct(RerValidationService $validationService)
    {
        $this->validationService = $validationService;
    }
    
    public function index()
    {
        $filings = RerFiling::where('user_id', auth()->id())
            ->orderBy('created_at', 'desc')
            ->paginate(10);
            
        return Inertia::render('RER/Index', [
            'filings' => $filings
        ]);
    }
    
    public function create()
    {
        return Inertia::render('RER/Create', [
            'formOptions' => $this->getFormOptions()
        ]);
    }
    
    public function store(Request $request)
    {
        DB::beginTransaction();
        
        try {
            $filing = RerFiling::create(array_merge(
                $request->only([
                    'filing_type', 'prior_bsa_id', 'date_prepared', 'note_to_fincen',
                    'closing_date', 'reporting_person_category', 'reporting_person_is_entity',
                    'reporting_person_name', 'reporting_person_first_name',
                    'reporting_person_middle_name', 'reporting_person_suffix',
                    'reporting_person_street_address', 'reporting_person_city',
                    'reporting_person_state', 'reporting_person_zip',
                    'total_consideration', 'no_consideration_transfer',
                    'has_private_loan', 'private_loan_type', 'private_loan_other'
                ]),
                ['user_id' => auth()->id(), 'status' => 'draft']
            ));
            
            // Save properties
            foreach ($request->properties ?? [] as $property) {
                $filing->properties()->create($property);
            }
            
            // Save transferees with persons
            foreach ($request->transferees ?? [] as $transfereeData) {
                $persons = $transfereeData['persons'] ?? [];
                unset($transfereeData['persons']);
                
                $transferee = $filing->transferees()->create($transfereeData);
                
                foreach ($persons as $person) {
                    $transferee->persons()->create($person);
                }
            }
            
            // Save transferors
            foreach ($request->transferors ?? [] as $transferor) {
                $filing->transferors()->create($transferor);
            }
            
            // Save payments
            foreach ($request->payments ?? [] as $payment) {
                $filing->payments()->create($payment);
            }
            
            DB::commit();
            
            return redirect()->route('rer.edit', $filing->id)
                ->with('success', 'Filing created successfully.');
                
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->withErrors(['error' => 'Failed to create filing: ' . $e->getMessage()]);
        }
    }
    
    public function edit(RerFiling $filing)
    {
        $this->authorize('update', $filing);
        
        $filing->load(['properties', 'transferees.persons', 'transferors', 'payments']);
        
        return Inertia::render('RER/Edit', [
            'filing' => $filing,
            'formOptions' => $this->getFormOptions()
        ]);
    }
    
    public function update(Request $request, RerFiling $filing)
    {
        $this->authorize('update', $filing);
        
        if (!$filing->canEdit()) {
            return back()->withErrors(['error' => 'This filing cannot be edited.']);
        }
        
        DB::beginTransaction();
        
        try {
            $filing->update($request->only([
                'filing_type', 'prior_bsa_id', 'date_prepared', 'note_to_fincen',
                'closing_date', 'reporting_person_category', 'reporting_person_is_entity',
                'reporting_person_name', 'reporting_person_first_name',
                'reporting_person_middle_name', 'reporting_person_suffix',
                'reporting_person_street_address', 'reporting_person_city',
                'reporting_person_state', 'reporting_person_zip',
                'total_consideration', 'no_consideration_transfer',
                'has_private_loan', 'private_loan_type', 'private_loan_other'
            ]));
            
            // Update properties
            $filing->properties()->delete();
            foreach ($request->properties ?? [] as $property) {
                $filing->properties()->create($property);
            }
            
            // Update transferees with persons
            $filing->transferees()->delete();
            foreach ($request->transferees ?? [] as $transfereeData) {
                $persons = $transfereeData['persons'] ?? [];
                unset($transfereeData['persons']);
                
                $transferee = $filing->transferees()->create($transfereeData);
                
                foreach ($persons as $person) {
                    $transferee->persons()->create($person);
                }
            }
            
            // Update transferors
            $filing->transferors()->delete();
            foreach ($request->transferors ?? [] as $transferor) {
                $filing->transferors()->create($transferor);
            }
            
            // Update payments
            $filing->payments()->delete();
            foreach ($request->payments ?? [] as $payment) {
                $filing->payments()->create($payment);
            }
            
            DB::commit();
            
            return back()->with('success', 'Filing updated successfully.');
            
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->withErrors(['error' => 'Failed to update filing: ' . $e->getMessage()]);
        }
    }
    
    public function validate(RerFiling $filing)
    {
        $this->authorize('update', $filing);
        
        $filing->load(['properties', 'transferees.persons', 'transferors', 'payments']);
        
        $errors = $this->validationService->validate($filing);
        
        if (empty($errors)) {
            $filing->update([
                'status' => 'validated',
                'validation_errors' => null
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Filing validated successfully.',
                'data' => $filing->complete_data
            ]);
        } else {
            $filing->update([
                'validation_errors' => $errors
            ]);
            
            return response()->json([
                'success' => false,
                'errors' => $errors
            ], 422);
        }
    }
    
    public function submit(RerFiling $filing)
    {
        $this->authorize('update', $filing);
        
        if ($filing->status !== 'validated') {
            return response()->json([
                'success' => false,
                'message' => 'Filing must be validated before submission.'
            ], 422);
        }
        
        $filing->generateFilingNumber();
        $filing->update([
            'status' => 'submitted',
            'submitted_at' => now(),
            'submission_confirmation' => 'RER-CONF-' . uniqid()
        ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Filing submitted successfully.',
            'filing_number' => $filing->filing_number,
            'confirmation' => $filing->submission_confirmation,
            'data' => $filing->complete_data
        ]);
    }
    
    public function autosave(Request $request, RerFiling $filing)
    {
        $this->authorize('update', $filing);
        
        if (!$filing->canEdit()) {
            return response()->json(['success' => false], 403);
        }
        
        try {
            $filing->update($request->only([
                'filing_type', 'prior_bsa_id', 'date_prepared', 'note_to_fincen',
                'closing_date', 'reporting_person_category', 'reporting_person_is_entity',
                'reporting_person_name', 'reporting_person_first_name',
                'reporting_person_middle_name', 'reporting_person_suffix',
                'reporting_person_street_address', 'reporting_person_city',
                'reporting_person_state', 'reporting_person_zip',
                'total_consideration', 'no_consideration_transfer',
                'has_private_loan', 'private_loan_type', 'private_loan_other'
            ]));
            
            return response()->json(['success' => true]);
        } catch (\Exception $e) {
            return response()->json(['success' => false], 500);
        }
    }
    
    private function getFormOptions()
    {
        return [
            'filing_types' => [
                ['value' => 'initial_report', 'label' => 'Initial Report'],
                ['value' => 'correct_amend', 'label' => 'Correct/Amend Prior Report'],
                ['value' => 'fincen_directed', 'label' => 'FinCEN Directed Back-filing']
            ],
            'reporting_categories' => [
                ['value' => 'closing_agent', 'label' => 'Closing Agent'],
                ['value' => 'statement_preparer', 'label' => 'Statement Preparer'],
                ['value' => 'deed_filer', 'label' => 'Deed Filer'],
                ['value' => 'title_insurer', 'label' => 'Title Insurer'],
                ['value' => 'fund_disburser', 'label' => 'Fund Disburser'],
                ['value' => 'title_evaluator', 'label' => 'Title Evaluator'],
                ['value' => 'deed_preparer', 'label' => 'Deed Preparer']
            ],
            'legal_description_types' => [
                ['value' => 'lot_block', 'label' => 'Lot and Block'],
                ['value' => 'subdivision', 'label' => 'Subdivision'],
                ['value' => 'government_survey', 'label' => 'Government Rectangular Survey'],
                ['value' => 'metes_bounds', 'label' => 'Metes and Bounds'],
                ['value' => 'other', 'label' => 'Other']
            ],
            'id_types' => [
                ['value' => 'ein', 'label' => 'EIN'],
                ['value' => 'ssn_itin', 'label' => 'SSN/ITIN'],
                ['value' => 'foreign_tax_id', 'label' => 'Foreign Tax ID'],
                ['value' => 'foreign_passport', 'label' => 'Foreign Passport'],
                ['value' => 'foreign_entity_reg', 'label' => 'Foreign Entity Registration'],
                ['value' => 'no_id', 'label' => 'No Identification']
            ],
            'payment_methods' => [
                ['value' => 'wire', 'label' => 'Wire Transfer'],
                ['value' => 'cashiers_check', 'label' => "Cashier's Check"],
                ['value' => 'personal_check', 'label' => 'Personal Check'],
                ['value' => 'money_order', 'label' => 'Money Order'],
                ['value' => 'us_currency', 'label' => 'US Currency'],
                ['value' => 'foreign_currency', 'label' => 'Foreign Currency'],
                ['value' => 'digital_assets', 'label' => 'Digital Assets'],
                ['value' => 'stocks_bonds', 'label' => 'Stocks/Bonds'],
                ['value' => 'other', 'label' => 'Other']
            ],
            'states' => $this->getStates()
        ];
    }
    
    private function getStates()
    {
        return [
            ['value' => 'AL', 'label' => 'Alabama'],
            ['value' => 'AK', 'label' => 'Alaska'],
            ['value' => 'AZ', 'label' => 'Arizona'],
            ['value' => 'AR', 'label' => 'Arkansas'],
            ['value' => 'CA', 'label' => 'California'],
            ['value' => 'CO', 'label' => 'Colorado'],
            ['value' => 'CT', 'label' => 'Connecticut'],
            ['value' => 'DE', 'label' => 'Delaware'],
            ['value' => 'FL', 'label' => 'Florida'],
            ['value' => 'GA', 'label' => 'Georgia'],
            ['value' => 'HI', 'label' => 'Hawaii'],
            ['value' => 'ID', 'label' => 'Idaho'],
            ['value' => 'IL', 'label' => 'Illinois'],
            ['value' => 'IN', 'label' => 'Indiana'],
            ['value' => 'IA', 'label' => 'Iowa'],
            ['value' => 'KS', 'label' => 'Kansas'],
            ['value' => 'KY', 'label' => 'Kentucky'],
            ['value' => 'LA', 'label' => 'Louisiana'],
            ['value' => 'ME', 'label' => 'Maine'],
            ['value' => 'MD', 'label' => 'Maryland'],
            ['value' => 'MA', 'label' => 'Massachusetts'],
            ['value' => 'MI', 'label' => 'Michigan'],
            ['value' => 'MN', 'label' => 'Minnesota'],
            ['value' => 'MS', 'label' => 'Mississippi'],
            ['value' => 'MO', 'label' => 'Missouri'],
            ['value' => 'MT', 'label' => 'Montana'],
            ['value' => 'NE', 'label' => 'Nebraska'],
            ['value' => 'NV', 'label' => 'Nevada'],
            ['value' => 'NH', 'label' => 'New Hampshire'],
            ['value' => 'NJ', 'label' => 'New Jersey'],
            ['value' => 'NM', 'label' => 'New Mexico'],
            ['value' => 'NY', 'label' => 'New York'],
            ['value' => 'NC', 'label' => 'North Carolina'],
            ['value' => 'ND', 'label' => 'North Dakota'],
            ['value' => 'OH', 'label' => 'Ohio'],
            ['value' => 'OK', 'label' => 'Oklahoma'],
            ['value' => 'OR', 'label' => 'Oregon'],
            ['value' => 'PA', 'label' => 'Pennsylvania'],
            ['value' => 'RI', 'label' => 'Rhode Island'],
            ['value' => 'SC', 'label' => 'South Carolina'],
            ['value' => 'SD', 'label' => 'South Dakota'],
            ['value' => 'TN', 'label' => 'Tennessee'],
            ['value' => 'TX', 'label' => 'Texas'],
            ['value' => 'UT', 'label' => 'Utah'],
            ['value' => 'VT', 'label' => 'Vermont'],
            ['value' => 'VA', 'label' => 'Virginia'],
            ['value' => 'WA', 'label' => 'Washington'],
            ['value' => 'WV', 'label' => 'West Virginia'],
            ['value' => 'WI', 'label' => 'Wisconsin'],
            ['value' => 'WY', 'label' => 'Wyoming']
        ];
    }
}