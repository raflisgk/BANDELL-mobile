<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProjectAssignment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProjectAssignmentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'user_id' => ['nullable', 'integer', 'exists:users,id'],
        ]);

        // Cegah IDOR: Gunakan user yang sedang login, kecuali jika pemanggil adalah admin
        $authUser = $request->user();
        $targetUserId = ($authUser && !in_array($authUser->role, ['admin', 'superadmin']))
            ? $authUser->id
            : ($request->user_id ?? $authUser?->id);

        if (!$targetUserId) {
            return response()->json([
                'success' => false,
                'message' => 'Parameter user_id diperlukan.',
            ], 422);
        }

        $assignments = ProjectAssignment::with([
            'project.districts',
        ])
            ->where('user_id', $targetUserId)
            ->orderBy('project_id')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data project yang ditugaskan berhasil diambil.',
            'data' => $assignments,
        ]);
    }
}