<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RerProperty extends Model
{
    protected $fillable = [
        'rer_filing_id', 'street_address', 'no_street_address',
        'city', 'state', 'zip',
        'legal_description_type', 'legal_description_other',
        'legal_description'
    ];

    protected $casts = [
        'no_street_address' => 'boolean',
    ];

    public function filing(): BelongsTo
    {
        return $this->belongsTo(RerFiling::class, 'rer_filing_id');
    }
}