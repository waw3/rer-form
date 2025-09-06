<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RerFiling extends Model
{
    protected $fillable = [
        'filing_type', 'prior_bsa_id', 'date_prepared', 'note_to_fincen',
        'closing_date', 'reporting_person_category', 'reporting_person_is_entity',
        'reporting_person_name', 'reporting_person_first_name', 
        'reporting_person_middle_name', 'reporting_person_suffix',
        'reporting_person_street_address', 'reporting_person_city',
        'reporting_person_state', 'reporting_person_zip',
        'total_consideration', 'no_consideration_transfer',
        'has_private_loan', 'private_loan_type', 'private_loan_other',
        'status', 'validation_errors', 'submitted_at', 'submission_confirmation',
        'user_id'
    ];

    protected $casts = [
        'date_prepared' => 'date',
        'closing_date' => 'date',
        'submitted_at' => 'datetime',
        'reporting_person_is_entity' => 'boolean',
        'no_consideration_transfer' => 'boolean',
        'has_private_loan' => 'boolean',
        'total_consideration' => 'decimal:2',
        'validation_errors' => 'array',
    ];

    public function properties(): HasMany
    {
        return $this->hasMany(RerProperty::class);
    }

    public function transferees(): HasMany
    {
        return $this->hasMany(RerTransferee::class);
    }

    public function transferors(): HasMany
    {
        return $this->hasMany(RerTransferor::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(RerPayment::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function generateFilingNumber(): string
    {
        if (!$this->filing_number) {
            $year = now()->year;
            $count = static::whereYear('created_at', $year)->count() + 1;
            $this->filing_number = sprintf('RER-%d-%06d', $year, $count);
            $this->save();
        }
        return $this->filing_number;
    }

    public function canEdit(): bool
    {
        return in_array($this->status, ['draft', 'rejected']);
    }

    public function getCompleteDataAttribute(): array
    {
        return [
            'filing_number' => $this->filing_number,
            'filing_information' => [
                'filing_type' => $this->filing_type,
                'prior_bsa_id' => $this->prior_bsa_id,
                'date_prepared' => $this->date_prepared?->format('Y-m-d'),
                'note_to_fincen' => $this->note_to_fincen,
                'closing_date' => $this->closing_date?->format('Y-m-d'),
            ],
            'reporting_person' => [
                'category' => $this->reporting_person_category,
                'is_entity' => $this->reporting_person_is_entity,
                'name' => $this->reporting_person_name,
                'first_name' => $this->reporting_person_first_name,
                'middle_name' => $this->reporting_person_middle_name,
                'suffix' => $this->reporting_person_suffix,
                'address' => [
                    'street' => $this->reporting_person_street_address,
                    'city' => $this->reporting_person_city,
                    'state' => $this->reporting_person_state,
                    'zip' => $this->reporting_person_zip,
                ]
            ],
            'properties' => $this->properties->map(fn($p) => $p->toArray())->toArray(),
            'transferees' => $this->transferees->map(fn($t) => array_merge(
                $t->toArray(),
                ['persons' => $t->persons->toArray()]
            ))->toArray(),
            'transferors' => $this->transferors->map(fn($t) => $t->toArray())->toArray(),
            'payment_summary' => [
                'total_consideration' => $this->total_consideration,
                'no_consideration_transfer' => $this->no_consideration_transfer,
                'has_private_loan' => $this->has_private_loan,
                'private_loan_type' => $this->private_loan_type,
                'private_loan_other' => $this->private_loan_other,
            ],
            'payments' => $this->payments->map(fn($p) => $p->toArray())->toArray(),
            'status' => $this->status,
            'submitted_at' => $this->submitted_at?->format('Y-m-d H:i:s'),
        ];
    }
}