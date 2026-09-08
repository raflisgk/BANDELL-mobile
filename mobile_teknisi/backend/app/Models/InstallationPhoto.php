    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Factories\HasFactory;
    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsTo;

    class InstallationPhoto extends Model
    {
        use HasFactory;

        /**
         * The table associated with the model.
         *
         * @var string
         */
        protected $table = 'installation_photos';

        /**
         * The attributes that are mass assignable.
         *
         * @var list<string>
         */
        protected $fillable = [
            'installation_id',
            'photo_path',
        ];

        /**
         * Get the installation that this photo belongs to.
         */
        public function installation(): BelongsTo
        {
            return $this->belongsTo(Installation::class, 'installation_id');
        }
    }
