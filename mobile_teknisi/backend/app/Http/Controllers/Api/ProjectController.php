<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Project;
use Illuminate\Http\JsonResponse;

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

    public function areas(Project $project): JsonResponse
    {
        $areas = $project->districts()
            ->orderBy('id')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data area operasional berhasil diambil.',
            'data' => $areas,
        ]);
    }
}