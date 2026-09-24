<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\DB;

class ProjectAssignment extends Model
{
    use HasFactory;

    protected $table = 'project_assignments';

    protected $fillable = [
        'project_id',
        'user_id',
        'notes',
        'assigned_at',
    ];

    protected function casts(): array
    {
        return [
            'assigned_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::created(function (ProjectAssignment $assignment) {
            DB::transaction(function () use ($assignment) {
                $project = $assignment->project ?? Project::find($assignment->project_id);
                $projectName = $project?->name ?? 'Proyek';

                $notificationTime = $assignment->assigned_at ?? now();

                // Cek duplikasi: jangan buat jika notification assignment untuk assignment ini sudah ada
                $alreadyExists = Notification::where('user_id', $assignment->user_id)
                    ->where('project_id', $assignment->project_id)
                    ->where('type', 'assignment')
                    ->where('created_at', $notificationTime)
                    ->exists();

                if (!$alreadyExists) {
                    Notification::create([
                        'user_id' => $assignment->user_id,
                        'type' => 'assignment',
                        'title' => 'Penugasan Baru Diterima',
                        'message' => "Anda telah ditugaskan untuk proyek {$projectName}.",
                        'project_id' => $assignment->project_id,
                        'installation_id' => null,
                        'is_read' => 0,
                        'created_at' => $notificationTime,
                        'updated_at' => $notificationTime,
                    ]);
                }
            });
        });
    }

    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class, 'project_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}