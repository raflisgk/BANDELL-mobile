<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Installation;
use App\Models\InstallationPhoto;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\District;

class InstallationController extends Controller
{

    public function destroy(Installation $installation): JsonResponse
{
    // Project yang sudah selesai tidak boleh dihapus.
    if ($installation->project && $installation->project->status === 'selesai') {
        return response()->json([
            'success' => false,
            'message' => 'Data pada project yang sudah selesai tidak dapat dihapus.',
        ], 403);
    }

    // Hapus foto terlebih dahulu.
    $installation->photos()->delete();

    // Hapus data installation.
    $installation->delete();

    return response()->json([
        'success' => true,
        'message' => 'Data pemasangan berhasil dihapus.',
    ]);
}
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'project_id' => ['required', 'integer', 'exists:projects,id'],
            'user_id' => ['required', 'integer', 'exists:users,id'],
            'lamp_type_id' => ['required', 'integer', 'exists:lamp_types,id'],
            'district_id' => ['required', 'integer', 'exists:districts,id'],
            'id_barcode' => ['nullable', 'string', 'max:12'],
            'input_method' => ['required', 'string', 'in:realtime,manual'],
            'latitude' => ['required', 'numeric'],
            'longitude' => ['required', 'numeric'],
            'address' => ['nullable', 'string'],
            'code_panel' => ['nullable', 'string', 'max:12'],
            'installed_at' => ['nullable', 'date'],
            'photos' => ['nullable', 'array'],
            'photos.*' => ['image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
        ]);

        $districtValid = District::where('id', $validated['district_id'])
    ->where('project_id', $validated['project_id'])
    ->exists();

if (!$districtValid) {
    return response()->json([
        'success' => false,
        'message' => 'Area operasional tidak sesuai dengan project.',
    ], 422);
}

        $project = \App\Models\Project::findOrFail($validated['project_id']);

if ($project->status === 'selesai') {
    return response()->json([
        'success' => false,
        'message' => 'Data pada project yang sudah selesai tidak dapat ditambahkan.',
    ], 403);
}

        $installation = DB::transaction(function () use ($request, $validated) {
            $installation = Installation::create([
                'project_id' => $validated['project_id'],
                'user_id' => $validated['user_id'],
                'lamp_type_id' => $validated['lamp_type_id'],
                'district_id' => $validated['district_id'],
                'id_barcode' => $validated['id_barcode'] ?? null,
                'input_method' => $validated['input_method'],
                'verification_status' => 'Menunggu Verifikasi',
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'address' => $validated['address'] ?? null,
                'code_panel' => $validated['code_panel'] ?? null,
                'installed_at' => $validated['installed_at'] ?? now()->toDateString(),
            ]);

            if ($request->hasFile('photos')) {
                foreach ($request->file('photos') as $photo) {
                    $path = $photo->store('installations', 'public');

                    InstallationPhoto::create([
                        'installation_id' => $installation->id,
                        'photo_path' => $path,
                    ]);
                }
            }

            return $installation;
        });

        $installation->load([
            'project',
            'user',
            'district',
            'lampType',
            'photos',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Data pemasangan berhasil disimpan.',
            'data' => $installation,
        ], 201);
    }

    public function update(Request $request, Installation $installation): JsonResponse
{
    // Project yang sudah selesai tidak boleh diedit.
    if ($installation->project && $installation->project->status === 'selesai') {
        return response()->json([
            'success' => false,
            'message' => 'Data pada project yang sudah selesai tidak dapat diedit.',
        ], 403);
    }

    $validated = $request->validate([
        'project_id' => ['sometimes', 'integer', 'exists:projects,id'],
        'user_id' => ['sometimes', 'integer', 'exists:users,id'],
        'lamp_type_id' => ['sometimes', 'integer', 'exists:lamp_types,id'],
        'district_id' => ['sometimes', 'integer', 'exists:districts,id'],
        'id_barcode' => ['nullable', 'string', 'max:12'],
        'input_method' => ['sometimes', 'string', 'in:realtime,manual,REALTIME,MANUAL'],
        'latitude' => ['sometimes', 'numeric'],
        'longitude' => ['sometimes', 'numeric'],
        'address' => ['nullable', 'string'],
        'code_panel' => ['nullable', 'string', 'max:12'],
        'installed_at' => ['nullable', 'date'],
        'photos' => ['nullable', 'array'],
        'photos.*' => ['image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
    ]);

    $projectId = $validated['project_id'] ?? $installation->project_id;
    $districtId = $validated['district_id'] ?? $installation->district_id;

    $districtValid = District::where('id', $districtId)
        ->where('project_id', $projectId)
        ->exists();

        \Log::info('DEBUG UPDATE INSTALLATION', [
    'projectId' => $projectId,
    'districtId' => $districtId,
    'districtValid' => $districtValid,
]);

    if (!$districtValid) {
        return response()->json([
            'success' => false,
            'message' => 'Area operasional tidak sesuai dengan project.',
        ], 422);
    }

    $project = \App\Models\Project::findOrFail($projectId);

if ($project->status === 'selesai') {
    return response()->json([
        'success' => false,
        'message' => 'Data pada project yang sudah selesai tidak dapat diedit.',
    ], 403);
}

    $installation->update([
        'project_id' => $projectId,
        'user_id' => $validated['user_id'] ?? $installation->user_id,
        'lamp_type_id' => $validated['lamp_type_id'] ?? $installation->lamp_type_id,
        'district_id' => $districtId,
        'id_barcode' => $validated['id_barcode'] ?? $installation->id_barcode,
        'input_method' => $validated['input_method'] ?? $installation->input_method,
        'latitude' => $validated['latitude'] ?? $installation->latitude,
        'longitude' => $validated['longitude'] ?? $installation->longitude,
        'address' => $validated['address'] ?? $installation->address,
        'code_panel' => $validated['code_panel'] ?? $installation->code_panel,
        'installed_at' => $validated['installed_at'] ?? $installation->installed_at,
    ]);


    if ($request->hasFile('photos')) {
        foreach ($request->file('photos') as $photo) {
            $path = $photo->store('installations', 'public');

            InstallationPhoto::create([
                'installation_id' => $installation->id,
                'photo_path' => $path,
            ]);
        }
    }

    $installation->load([
        'project',
        'user',
        'district',
        'lampType',
        'photos',
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Data pemasangan berhasil diperbarui.',
        'data' => $installation,
    ]);
}

    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
            'project_id' => ['required', 'integer', 'exists:projects,id'],
            'district_id' => ['nullable', 'integer', 'exists:districts,id'],
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date', 'after_or_equal:start_date'],
        ]);


        $query = Installation::with([
            'project',
            'user',
            'district',
            'lampType',
            'photos',
        ])
            ->where('user_id', $validated['user_id'])
            ->where('project_id', $validated['project_id']);

        if (!empty($validated['district_id'])) {
            $query->where('district_id', $validated['district_id']);
        }

        if (!empty($validated['start_date'])) {
            $query->whereDate('installed_at', '>=', $validated['start_date']);
        }

        if (!empty($validated['end_date'])) {
            $query->whereDate('installed_at', '<=', $validated['end_date']);
        }

        $installations = $query
            ->orderByDesc('id')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Data pemasangan berhasil diambil.',
            'data' => $installations,
        ]);
    }

    public function show(Installation $installation): JsonResponse
    {
        $installation->load([
            'project',
            'user',
            'district',
            'lampType',
            'photos',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Detail data pemasangan berhasil diambil.',
            'data' => $installation,
        ]);
    }
}