<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProjectAssignment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
        ]);

        $userId = $validated['user_id'];
        $notifications = collect();

        /*
        |--------------------------------------------------------------------------
        | 1. Ambil notification dari tabel notifications
        |--------------------------------------------------------------------------
        */
        if (Schema::hasTable('notifications')) {
            $dbNotifs = DB::table('notifications')
                ->where('notifications.user_id', $userId)
                ->leftJoin(
                    'projects',
                    'notifications.project_id',
                    '=',
                    'projects.id'
                )
                ->leftJoin(
                    'installations',
                    'notifications.installation_id',
                    '=',
                    'installations.id'
                )
                ->leftJoin(
                    'districts',
                    'installations.district_id',
                    '=',
                    'districts.id'
                )
                ->select(
                    'notifications.*',
                    'projects.name as project_name',
                    'installations.verification_status as inst_verification_status',
                    'installations.note_by_admin as inst_note_by_admin',
                    'installations.id_lcu as inst_id_lcu',
                    'districts.name as district_name'
                )
                ->orderByDesc('notifications.created_at')
                ->get()
                ->map(function ($notif) {
                    return [
                        'id' => $notif->id,
                        'type' => $notif->type,
                        'title' => $notif->title,
                        'message' => $notif->message,

                        'project_id' => $notif->project_id,
                        'project_name' => $notif->project_name ?? '-',

                        'installation_id' => $notif->installation_id,

                        'installation' => $notif->installation_id
                            ? [
                                'id' => $notif->installation_id,
                                'id_installation' => $notif->installation_id,
                                'verification_status' => $notif->inst_verification_status,
                                'status' => $notif->inst_verification_status,
                                'note_by_admin' => $notif->inst_note_by_admin,
                                'id_lcu' => $notif->inst_id_lcu,
                                'district' => $notif->district_name,
                            ]
                            : null,

                        'is_read' => (bool) $notif->is_read,
                        'created_at' => $notif->created_at,
                    ];
                });

            $notifications = $notifications->concat($dbNotifs);
        }

        /*
        |--------------------------------------------------------------------------
        | 2. Ambil penugasan dari project_assignments
        |--------------------------------------------------------------------------
        */
        $assignments = ProjectAssignment::with(['project'])
            ->where('user_id', $userId)
            ->orderByDesc('assigned_at')
            ->get()
            ->map(function ($assignment) {
                return [
                    'id' => $assignment->id,
                    'type' => 'assignment',
                    'title' => 'Penugasan Baru Diterima',

                    'message' => 'Anda telah ditugaskan untuk proyek '
                        . ($assignment->project?->name ?? '-')
                        . '.',

                    'project_id' => $assignment->project_id,
                    'project_name' => $assignment->project?->name ?? '-',

                    'notes' => $assignment->notes,

                    'assigned_at' => $assignment->assigned_at?->toIso8601String()
                        ?? $assignment->created_at?->toIso8601String(),

                    'created_at' => $assignment->created_at?->toIso8601String(),

                    'is_read' => false,
                ];
            });

        /*
        |--------------------------------------------------------------------------
        | Gabungkan penugasan yang belum ada di notifications
        |--------------------------------------------------------------------------
        */
        $existingProjectIds = $notifications
            ->where('type', 'assignment')
            ->pluck('project_id')
            ->filter()
            ->all();

        $filteredAssignments = $assignments->filter(function ($item) use ($existingProjectIds) {
            return !in_array($item['project_id'], $existingProjectIds);
        });

        $notifications = $notifications->concat($filteredAssignments);

        /*
        |--------------------------------------------------------------------------
        | 3. Ambil installation yang statusnya Ditolak
        |--------------------------------------------------------------------------
        |
        | Database menggunakan:
        | verification_status = "Ditolak"
        |
        | API mengubahnya menjadi:
        | type = "rejected"
        |--------------------------------------------------------------------------
        */
        if (Schema::hasTable('installations')) {

            $existingInstIds = $notifications
                ->where('type', 'rejected')
                ->pluck('installation_id')
                ->filter()
                ->all();

            $rejectedInstallations = DB::table('installations')
                ->where('installations.user_id', $userId)
                ->whereRaw(
                    'LOWER(installations.verification_status) = ?',
                    ['ditolak']
                )
                ->leftJoin(
                    'projects',
                    'installations.project_id',
                    '=',
                    'projects.id'
                )
                ->leftJoin(
                    'districts',
                    'installations.district_id',
                    '=',
                    'districts.id'
                )
                ->select(
                    'installations.*',
                    'projects.name as project_name',
                    'districts.name as district_name'
                )
                ->get()
                ->filter(function ($installation) use ($existingInstIds) {
                    return !in_array(
                        $installation->id,
                        $existingInstIds
                    );
                })
                ->map(function ($installation) {
                    return [
                        /*
                        | ID sementara untuk membedakan
                        | notification hasil generate dari installation.
                        */
                        'id' => 100000 + $installation->id,

                        'type' => 'rejected',
                        'title' => 'Laporan Ditolak',
                        'message' => 'Laporan penugasan ditolak.',

                        'project_id' => $installation->project_id,
                        'project_name' => $installation->project_name ?? '-',

                        'installation_id' => $installation->id,

                        'installation' => [
                            'id' => $installation->id,
                            'id_installation' => $installation->id,

                            'verification_status' =>
                                $installation->verification_status,

                            'status' =>
                                $installation->verification_status,

                            'note_by_admin' =>
                                $installation->note_by_admin,

                            'id_lcu' =>
                                $installation->id_lcu,

                            'district' =>
                                $installation->district_name,
                        ],

                        'is_read' => false,

                        'created_at' =>
                            $installation->updated_at
                            ?? $installation->created_at,
                    ];
                });

            $notifications = $notifications->concat(
                $rejectedInstallations
            );
        }

        /*
        |--------------------------------------------------------------------------
        | 4. Urutkan notification berdasarkan tanggal terbaru
        |--------------------------------------------------------------------------
        */
        $sorted = $notifications
            ->sortByDesc(function ($item) {
                return $item['assigned_at']
                    ?? $item['created_at']
                    ?? '';
            })
            ->values();

        /*
        |--------------------------------------------------------------------------
        | Response
        |--------------------------------------------------------------------------
        */
        return response()->json([
            'success' => true,
            'message' => 'Data notifikasi berhasil diambil.',
            'data' => $sorted,
        ]);
    }

    /*
    |--------------------------------------------------------------------------
    | Tandai notification sebagai sudah dibaca
    |--------------------------------------------------------------------------
    */
    public function markAsRead(int $id): JsonResponse
    {
        if (Schema::hasTable('notifications')) {
            DB::table('notifications')
                ->where('id', $id)
                ->update([
                    'is_read' => 1,
                    'updated_at' => now(),
                ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi telah ditandai dibaca.',
        ]);
    }
}