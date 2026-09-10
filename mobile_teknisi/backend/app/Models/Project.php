<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Project extends Model
{
    use HasFactory;

    protected $table = 'projects';

    protected $fillable = [
        'name',
    ];

    public function districts(): HasMany
    {
        return $this->hasMany(District::class, 'project_id');
    }

    public function projectAssignments(): HasMany
    {
        return $this->hasMany(ProjectAssignment::class, 'project_id');
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'project_assignments', 'project_id', 'user_id')
            ->withPivot([
                'district_id',
                'notes',
                'assigned_at',
            ])
            ->withTimestamps();
    }

    public function installations(): HasMany
    {
        return $this->hasMany(Installation::class, 'project_id');
    }
}