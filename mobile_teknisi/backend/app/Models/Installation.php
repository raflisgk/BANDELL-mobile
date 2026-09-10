<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Installation extends Model
{
    use HasFactory;

    protected $table = 'installations';

    protected $fillable = [
        'project_id',
        'user_id',
        'lamp_type_id',
        'district_id',
        'id_lcu',
        'input_method',
        'verification_status',
        'latitude',
        'longitude',
        'address',
        'code_panel',
        'installed_at',
    ];

    protected function casts(): array
    {
        return [
            'installed_at' => 'date',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
        ];
    }

    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class, 'project_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function district(): BelongsTo
    {
        return $this->belongsTo(District::class, 'district_id');
    }

    public function lampType(): BelongsTo
    {
        return $this->belongsTo(LampType::class, 'lamp_type_id');
    }

    public function photos(): HasMany
    {
        return $this->hasMany(InstallationPhoto::class, 'installation_id');
    }

    public function installationPhotos(): HasMany
    {
        return $this->hasMany(InstallationPhoto::class, 'installation_id');
    }
}