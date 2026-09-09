<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'password'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{

    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Get the project assignments for the user.
     */
    public function projectAssignments(): HasMany
    {
        return $this->hasMany(ProjectAssignment::class, 'user_id');
    }

    /**
     * Get the projects assigned to the user.
     */
    public function projects(): BelongsToMany
    {
        return $this->belongsToMany(Project::class, 'project_assignments', 'user_id', 'project_id')
            ->withPivot(['district_id', 'notes', 'assigned_at', 'unassigned_at'])
            ->withTimestamps();
    }

    /**
     * Get the installations recorded by the user.
     */
    public function installations(): HasMany
    {
        return $this->hasMany(Installation::class, 'user_id');
    }
}
