<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Models\ProjectAssignment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProjectController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $authUser = $request->user();
        $query = Project::with('districts')->orderBy('id');

        if ($authUser && !in_array($authUser->role, ['admin', 'superadmin'])) {
            $assignedProjectIds = ProjectAssignment::where('user_id', $authUser->id)
                ->pluck('project_id');
            $query->whereIn('id', $assignedProjectIds);
        }

        $projects = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Data project berhasil diambil.',
            'data' => $projects,
        ]);
    }

    public function areas(Request $request, Project $project): JsonResponse
    {
        $authUser = $request->user();
        if ($authUser && !in_array($authUser->role, ['admin', 'superadmin'])) {
            $isAssigned = ProjectAssignment::where('user_id', $authUser->id)
                ->where('project_id', $project->id)
                ->exists();

            if (!$isAssigned) {
                return response()->json([
                    'success' => false,
                    'message' => 'Anda tidak memiliki akses ke project ini.',
                ], 403);
            }
        }

        $areas = $project->districts()
            ->orderBy('id')
            ->get()
            ->map(function ($district) {
                $districtArray = $district->toArray();

                $districtArray['status'] = $district->status ?? 'aktif';

                return $districtArray;
            });

        return response()->json([
            'success' => true,
            'message' => 'Data area operasional berhasil diambil.',
            'data' => $areas,
        ]);
    }
}