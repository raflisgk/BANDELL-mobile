    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Factories\HasFactory;
    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsTo;
    use Illuminate\Database\Eloquent\Relations\HasMany;

    class Installation extends Model
    {
        use HasFactory;

        /**
         * The table associated with the model.
         *
         * @var string
         */
        protected $table = 'installations';

        /**
         * The attributes that are mass assignable.
         *
         * @var list<string>
         */
        protected $fillable = [
            'project_id',
            'user_id',
            'lamp_type_id',
            'district_id',
            'id_barcode',
            'input_method',
            'verification_status',
            'latitude',
            'longitude',
            'address',
            'code_panel',
            'installed_at',
        ];

        /**
         * Get the attributes that should be cast.
         *
         * @return array<string, string>
         */
        protected function casts(): array
        {
            return [
                'installed_at' => 'date',
                'latitude' => 'decimal:7',
                'longitude' => 'decimal:7',
            ];
        }

        /**
         * Get the project that this installation belongs to.
         */
        public function project(): BelongsTo
        {
            return $this->belongsTo(Project::class, 'project_id');
        }

        /**
         * Get the technician/user who recorded this installation.
         */
        public function user(): BelongsTo
        {
            return $this->belongsTo(User::class, 'user_id');
        }

        /**
         * Get the district where this installation is located.
         */
        public function district(): BelongsTo
        {
            return $this->belongsTo(District::class, 'district_id');
        }

        /**
         * Get the lamp type used in this installation.
         */
        public function lampType(): BelongsTo
        {
            return $this->belongsTo(LampType::class, 'lamp_type_id');
        }

        /**
         * Get the photos associated with this installation.
         */
        public function photos(): HasMany
        {
            return $this->hasMany(InstallationPhoto::class, 'installation_id');
        }

        /**
         * Alias for photos relationship.
         */
        public function installationPhotos(): HasMany
        {
            return $this->hasMany(InstallationPhoto::class, 'installation_id');
        }
    }
