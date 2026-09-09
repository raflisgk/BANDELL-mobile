<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProjectAssignment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
        ]);

        $notifications = ProjectAssignment::with([
            'project',
            'district',
        ])
            ->where('user_id', $validated['user_id'])
            ->whereNotNull('notes')
            ->where('notes', '!=', '')
            ->where(function ($query) {
                $query->whereNull('unassigned_at')
                    ->orWhere('unassigned_at', '>', now());
            })
            ->orderByDesc('assigned_at')
            ->get()
            ->map(function ($assignment) {
                return [
                    'id' => $assignment->id,
                    'project_id' => $assignment->project_id,
                    'project_name' => $assignment->project?->name,
                    'district_id' => $assignment->district_id,
                    'district_name' => $assignment->district?->name,
                    'notes' => $assignment->notes,
                    'assigned_at' => $assignment->assigned_at,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Data notifikasi berhasil diambil.',
            'data' => $notifications,
        ]);
    }
}