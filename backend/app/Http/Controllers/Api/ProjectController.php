<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Project;
use App\Models\ProjectAssignment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProjectController extends Controller
{
    public function index(): JsonResponse
    {
        $projects = Project::with('districts')
            ->orderBy('id')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data project berhasil diambil.',
            'data' => $projects,
        ]);
    }

    public function areas(Request $request, Project $project): JsonResponse
    {
        $userId = $request->query('user_id');

        $areas = $project->districts()
            ->orderBy('id')
            ->get()
            ->map(function ($district) use ($project, $userId) {
                $assignmentQuery = ProjectAssignment::where('project_id', $project->id)
                    ->where('district_id', $district->id);

                if ($userId) {
                    $userAssignment = (clone $assignmentQuery)
                        ->where('user_id', $userId)
                        ->latest('assigned_at')
                        ->first();

                    $assignment = $userAssignment ?: $assignmentQuery->latest('assigned_at')->first();
                } else {
                    $assignment = $assignmentQuery->latest('assigned_at')->first();
                }

                $assignedAt = null;
                if ($assignment && $assignment->assigned_at) {
                    $assignedAt = $assignment->assigned_at instanceof \DateTimeInterface
                        ? $assignment->assigned_at->format('Y-m-d H:i:s')
                        : \Carbon\Carbon::parse($assignment->assigned_at)->format('Y-m-d H:i:s');
                }

                $districtArray = $district->toArray();
                $districtArray['status'] = $district->status ?? 'aktif';
                $districtArray['assigned_at'] = $assignedAt;

                return $districtArray;
            });

        return response()->json([
            'success' => true,
            'message' => 'Data area operasional berhasil diambil.',
            'data' => $areas,
        ]);
    }
}