<?php

namespace App\Policies;

use App\Models\RerFiling;
use App\Models\User;

class RerFilingPolicy
{
    public function view(User $user, RerFiling $filing): bool
    {
        return $user->id === $filing->user_id;
    }

    public function update(User $user, RerFiling $filing): bool
    {
        return $user->id === $filing->user_id && $filing->canEdit();
    }

    public function delete(User $user, RerFiling $filing): bool
    {
        return $user->id === $filing->user_id && $filing->status === 'draft';
    }
}