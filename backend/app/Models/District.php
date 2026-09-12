<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

    class District extends Model
    {
        use HasFactory;

        /**
         * The table associated with the model.
         *
         * @var string
         */
        protected $table = 'districts';

        /**
         * The attributes that are mass assignable.
         *
         * @var list<string>
         */
        protected $fillable = [
        'project_id',
        'name',
        'status',
    ];

        /**
         * Get the project that this district belongs to.
         */
        public function project(): BelongsTo
        {
            return $this->belongsTo(Project::class, 'project_id');
        }

        /**
         * Get the project assignments for this district.
         */
        public function projectAssignments(): HasMany
        {
            return $this->hasMany(ProjectAssignment::class, 'district_id');
        }

        /**
         * Get the installations located in this district.
         */
        public function installations(): HasMany
        {
            return $this->hasMany(Installation::class, 'district_id');
        }
    }
