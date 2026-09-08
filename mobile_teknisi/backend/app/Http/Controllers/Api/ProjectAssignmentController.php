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
            'user_id' => ['required', 'integer', 'exists:users,id'],
        ]);

        $assignments = ProjectAssignment::with([
            'project',
            'district',
        ])
            ->where('user_id', $request->user_id)
            ->where(function ($query) {
                $query->whereNull('unassigned_at')
                    ->orWhere('unassigned_at', '>', now());
            })
            ->orderBy('project_id')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data project yang ditugaskan berhasil diambil.',
            'data' => $assignments,
        ]);
    }
}