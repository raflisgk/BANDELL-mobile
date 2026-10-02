<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
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

        if (!Schema::hasTable('notifications')) {
            return response()->json([
                'success' => true,
                'message' => 'Data notifikasi berhasil diambil.',
                'data' => [],
            ]);
        }

        $notifications = DB::table('notifications')
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
            ->leftJoinSub(
                DB::table('project_assignments')
                    ->select('project_id', 'user_id', 'notes as assignment_notes', 'assigned_at as assignment_assigned_at')
                    ->whereIn('id', function ($query) use ($userId) {
                        $query->selectRaw('MAX(id)')
                            ->from('project_assignments')
                            ->where('user_id', $userId)
                            ->groupBy('project_id', 'user_id');
                    }),
                'latest_assignment',
                function ($join) {
                    $join->on('notifications.project_id', '=', 'latest_assignment.project_id')
                        ->on('notifications.user_id', '=', 'latest_assignment.user_id');
                }
            )
            ->select(
                'notifications.*',
                'projects.name as project_name',
                'installations.verification_status as inst_verification_status',
                'installations.id_lcu as inst_id_lcu',
                'districts.name as district_name',
                'latest_assignment.assignment_notes',
                'latest_assignment.assignment_assigned_at'
            )
            ->orderByDesc('notifications.created_at')
            ->orderByDesc('notifications.id')
            ->get()
            ->map(function ($notif) {
                $typeLower = strtolower((string) $notif->type);
                $isRejection = in_array($typeLower, ['rejected', 'rejection', 'ditolak']);
                $adminNote = $notif->note_by_admin ?? ($isRejection ? $notif->message : null);

                return [
                    'id' => (int) $notif->id,
                    'user_id' => (int) $notif->user_id,
                    'type' => $notif->type,
                    'title' => $notif->title,
                    'message' => $notif->message,
                    'note_by_admin' => $adminNote,

                    'project_id' => $notif->project_id ? (int) $notif->project_id : null,
                    'project_name' => $notif->project_name ?? '-',

                    'notes' => $notif->assignment_notes,
                    'assigned_at' => $notif->assignment_assigned_at,

                    'installation_id' => $notif->installation_id ? (int) $notif->installation_id : null,

                    'installation' => $notif->installation_id
                        ? [
                            'id' => (int) $notif->installation_id,
                            'id_installation' => (int) $notif->installation_id,
                            'verification_status' => $notif->inst_verification_status,
                            'status' => $notif->inst_verification_status,
                            'note_by_admin' => $adminNote,
                            'id_lcu' => $notif->inst_id_lcu,
                            'district' => $notif->district_name,
                        ]
                        : null,

                    'is_read' => (bool) $notif->is_read,
                    'created_at' => $notif->created_at,
                    'updated_at' => $notif->updated_at,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Data notifikasi berhasil diambil.',
            'data' => $notifications,
        ]);
    }

    public function markAsRead(int $id): JsonResponse
    {
        $notification = Notification::find($id);

        if (!$notification) {
            return response()->json([
                'success' => false,
                'message' => 'Notifikasi tidak ditemukan.',
            ], 404);
        }

        $notification->update([
            'is_read' => 1,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi telah ditandai dibaca.',
            'data' => [
                'id' => $notification->id,
                'is_read' => true,
            ],
        ]);
    }
}