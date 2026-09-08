    <?php

    namespace App\Models;

    use Illuminate\Database\Eloquent\Factories\HasFactory;
    use Illuminate\Database\Eloquent\Model;
    use Illuminate\Database\Eloquent\Relations\BelongsToMany;
    use Illuminate\Database\Eloquent\Relations\HasMany;

    class Project extends Model
    {
        use HasFactory;

        /**
         * The table associated with the model.
         *
         * @var string
         */
        protected $table = 'projects';

        /**
         * The attributes that are mass assignable.
         *
         * @var list<string>
         */
        protected $fillable = [
            'name',
        ];

        /**
         * Get the districts in this project.
         */
        public function districts(): HasMany
        {
            return $this->hasMany(District::class, 'project_id');
        }

        /**
         * Get the project assignments for this project.
         */
        public function projectAssignments(): HasMany
        {
            return $this->hasMany(ProjectAssignment::class, 'project_id');
        }

        /**
         * Get the users assigned to this project.
         */
        public function users(): BelongsToMany
        {
            return $this->belongsToMany(User::class, 'project_assignments', 'project_id', 'user_id')
                ->withPivot(['district_id', 'notes', 'assigned_at', 'unassigned_at'])
                ->withTimestamps();
        }

        /**
         * Get the installations under this project.
         */
        public function installations(): HasMany
        {
            return $this->hasMany(Installation::class, 'project_id');
        }
    }
