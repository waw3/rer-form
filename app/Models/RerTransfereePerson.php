<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RerTransfereePerson extends Model
{
    protected $fillable = [
        'rer_transferee_id', 'type', 'is_parent_guardian',
        'last_name', 'alternate_name', 'first_name', 'middle_name',
        'suffix', 'date_of_birth', 'foreign_no_us_location',
        'address_type', 'street_address', 'city', 'country', 'state',
        'postal_code', 'id_type', 'id_number', 'issuing_jurisdiction',
        'beneficial_owner_categories', 'citizenship_countries',
        'authorization_capacity', 'authorization_other', 'employer_name'
    ];

    protected $casts = [
        'is_parent_guardian' => 'boolean',
        'foreign_no_us_location' => 'boolean',
        'date_of_birth' => 'date',
        'beneficial_owner_categories' => 'array',
        'citizenship_countries' => 'array',
    ];

    public function transferee(): BelongsTo
    {
        return $this->belongsTo(RerTransferee::class, 'rer_transferee_id');
    }
}