<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InstallationPhoto extends Model
{
    use HasFactory;

    protected $table = 'installation_photos';

    protected $fillable = [
        'installation_id',
        'photo_path',
    ];

    public function installation(): BelongsTo
    {
        return $this->belongsTo(Installation::class, 'installation_id');
    }
}