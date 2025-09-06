<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RerPayment extends Model
{
    protected $fillable = [
        'rer_filing_id', 'amount', 'method', 'method_other',
        'currency_code', 'currency_description', 'not_from_institution',
        'account_number', 'institution_name', 'for_all_transferees',
        'transferee_name', 'all_payers_transferees'
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'not_from_institution' => 'boolean',
        'for_all_transferees' => 'boolean',
        'all_payers_transferees' => 'boolean',
    ];

    public function filing(): BelongsTo
    {
        return $this->belongsTo(RerFiling::class, 'rer_filing_id');
    }
}