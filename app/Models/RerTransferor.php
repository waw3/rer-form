<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RerTransferor extends Model
{
    protected $fillable = [
        'rer_filing_id', 'entity_type', 'last_name', 'alternate_name',
        'first_name', 'middle_name', 'suffix', 'date_of_birth',
        'foreign_no_us_location', 'address_type', 'street_address',
        'city', 'country', 'state', 'postal_code', 'id_type',
        'id_number', 'issuing_jurisdiction', 'trust_execution_date'
    ];

    protected $casts = [
        'foreign_no_us_location' => 'boolean',
        'date_of_birth' => 'date',
        'trust_execution_date' => 'date',
    ];

    public function filing(): BelongsTo
    {
        return $this->belongsTo(RerFiling::class, 'rer_filing_id');
    }

    public function isIndividual(): bool
    {
        return is_null($this->entity_type);
    }
}