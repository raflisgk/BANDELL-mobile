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
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\HasApiTokens;

#[Fillable([
    'name',
    'email',
    'password',
    'phone',
    'placement_area',
    'joined_at',
    'status',
])]
#[Hidden([
    'password',
    'remember_token',
])]
class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'joined_at' => 'date',
            'deleted_at' => 'datetime',
        ];
    }

    public function setPasswordAttribute($value): void
    {
        if (empty($value)) {
            return;
        }

        // Jika sudah berbentuk hash Bcrypt/Argon ($2y$... / $argon2...) simpan langsung
        if (str_starts_with($value, '$2y$') || str_starts_with($value, '$2a$') || str_starts_with($value, '$argon2')) {
            $this->attributes['password'] = $value;
        } else {
            // Jika string belum berupa SHA-256 (bukan 64 hex characters), hash SHA-256 dulu
            $sha256 = (strlen($value) === 64 && ctype_xdigit($value)) ? $value : hash('sha256', $value);
            $this->attributes['password'] = Hash::make($sha256);
        }
    }

    public function getRoleAttribute(): ?string
    {
        if (isset($this->attributes['role']) && !empty($this->attributes['role'])) {
            return $this->attributes['role'];
        }

        return DB::table('model_has_roles')
            ->join('roles', 'model_has_roles.role_id', '=', 'roles.id')
            ->where('model_has_roles.model_id', $this->id)
            ->value('roles.name');
    }

    public function getPhoneNumberAttribute(): ?string
    {
        return $this->attributes['phone'] ?? null;
    }

    public function setPhoneNumberAttribute(?string $value): void
    {
        $this->attributes['phone'] = $value;
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
            'notes',
            'assigned_at',
        ])->withTimestamps();
    }

    public function installations(): HasMany
    {
        return $this->hasMany(Installation::class, 'user_id');
    }
}