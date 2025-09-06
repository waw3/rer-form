<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RerTransferee extends Model
{
    protected $fillable = [
        'rer_filing_id', 'type', 'legal_name', 'alternate_name',
        'total_consideration', 'no_consideration', 'foreign_no_us_location',
        'address_type', 'street_address', 'city', 'country', 'state',
        'postal_code', 'id_type', 'id_number', 'issuing_jurisdiction',
        'trust_execution_date', 'is_revocable'
    ];

    protected $casts = [
        'no_consideration' => 'boolean',
        'foreign_no_us_location' => 'boolean',
        'is_revocable' => 'boolean',
        'trust_execution_date' => 'date',
        'total_consideration' => 'decimal:2',
    ];

    public function filing(): BelongsTo
    {
        return $this->belongsTo(RerFiling::class, 'rer_filing_id');
    }

    public function persons(): HasMany
    {
        return $this->hasMany(RerTransfereePerson::class, 'rer_transferee_id');
    }
}