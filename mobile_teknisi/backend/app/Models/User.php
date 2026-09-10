<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Notifications\Notifiable;

#[Fillable([
    'name',
    'email',
    'password',
    'phone_number',
    'placement_area',
    'joined_at',
])]
#[Hidden([
    'password',
    'remember_token',
])]
class User extends Authenticatable
{
    use HasFactory, Notifiable;

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'joined_at' => 'date',
        ];
    }

    public function projectAssignments(): HasMany
    {
        return $this->hasMany(ProjectAssignment::class, 'user_id');
    }

    public function projects(): BelongsToMany
    {
        return $this->belongsToMany(
            Project::class,
            'project_assignments',
            'user_id',
            'project_id'
        )->withPivot([
            'district_id',
            'notes',
            'assigned_at',
        ])->withTimestamps();
    }

    public function installations(): HasMany
    {
        return $this->hasMany(Installation::class, 'user_id');
    }
}