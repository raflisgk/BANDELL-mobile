<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Installation;
use App\Models\InstallationPhoto;
use App\Models\District;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InstallationController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'project_id' => ['required', 'integer', 'exists:projects,id'],
            'user_id' => ['required', 'integer', 'exists:users,id'],
            'lamp_type_id' => ['required', 'integer', 'exists:lamp_types,id'],
            'district_id' => ['required', 'integer', 'exists:districts,id'],
            'id_lcu' => ['nullable', 'string', 'max:12'],
            'input_method' => [
            'required',
            'string',
            'in:realtime,manual,REALTIME,MANUAL',
            ],
            'latitude' => ['required', 'numeric'],
            'longitude' => ['required', 'numeric'],
            'address' => ['nullable', 'string'],
            'code_panel' => ['nullable', 'string', 'max:12'],
            'installed_at' => ['nullable', 'date'],
            'photos' => ['nullable', 'array'],
            'photos.*' => [
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],
        ]);

        // Pastikan area memang milik project yang dipilih.
        $district = District::where('id', $validated['district_id'])
            ->where('project_id', $validated['project_id'])
            ->first();

        if (!$district) {
            return response()->json([
                'success' => false,
                'message' => 'Area operasional tidak sesuai dengan project.',
            ], 422);
        }

        $authUserId = $request->user()?->id ?? $validated['user_id'];

        $installation = DB::transaction(function () use ($request, $validated, $authUserId) {
            $installation = Installation::create([
                'project_id' => $validated['project_id'],
                'user_id' => $authUserId,
                'lamp_type_id' => $validated['lamp_type_id'],
                'district_id' => $validated['district_id'],
                'id_lcu' => isset($validated['id_lcu']) ? strip_tags(trim($validated['id_lcu'])) : null,
                'input_method' => strtoupper($validated['input_method']),
                'verification_status' => 'Menunggu Verifikasi',
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
                'address' => isset($validated['address']) ? strip_tags(trim($validated['address'])) : null,
                'code_panel' => isset($validated['code_panel']) ? strip_tags(trim($validated['code_panel'])) : null,
                'installed_at' => $validated['installed_at']
                    ?? now()->toDateString(),
            ]);

            if ($request->hasFile('photos')) {
                foreach ($request->file('photos') as $photo) {
                    $path = $photo->store(
                        'installations',
                        'public'
                    );

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

    public function update(
        Request $request,
        Installation $installation
    ): JsonResponse {
        $currentStatus = strtolower((string) $installation->verification_status);
        if ($currentStatus === 'terverifikasi' || $currentStatus === 'verified' || $currentStatus === 'terinput') {
            return response()->json([
                'success' => false,
                'message' => 'Data pemasangan yang sudah Terverifikasi tidak dapat diubah.',
            ], 422);
        }

        // Cegah IDOR: Pastikan hanya pemilik data (atau admin) yang dapat mengubah data ini
        $authUserId = $request->user()?->id;
        if ($authUserId && (int) $installation->user_id !== (int) $authUserId && !in_array($request->user()?->role, ['admin', 'superadmin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki hak akses untuk mengubah data pemasangan ini.',
            ], 403);
        }

        $validated = $request->validate([
            'project_id' => [
                'sometimes',
                'integer',
                'exists:projects,id',
            ],
            'user_id' => [
                'sometimes',
                'integer',
                'exists:users,id',
            ],
            'lamp_type_id' => [
                'sometimes',
                'integer',
                'exists:lamp_types,id',
            ],
            'district_id' => [
                'sometimes',
                'integer',
                'exists:districts,id',
            ],
            'id_lcu' => [
                'nullable',
                'string',
                'max:12',
            ],
            'input_method' => [
                'sometimes',
                'string',
                'in:realtime,manual,REALTIME,MANUAL',
            ],
            'latitude' => [
                'sometimes',
                'numeric',
            ],
            'longitude' => [
                'sometimes',
                'numeric',
            ],
            'address' => [
                'nullable',
                'string',
            ],
            'code_panel' => [
                'nullable',
                'string',
                'max:12',
            ],
            'installed_at' => [
                'nullable',
                'date',
            ],
            'photos' => [
                'nullable',
                'array',
            ],
            'photos.*' => [
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:5120',
            ],
        ]);

        $projectId = $validated['project_id']
            ?? $installation->project_id;

        $districtId = $validated['district_id']
            ?? $installation->district_id;

        $district = District::where('id', $districtId)
            ->where('project_id', $projectId)
            ->first();

        if (!$district) {
            $district = District::find($districtId);
            if ($district) {
                $projectId = $district->project_id;
            }
        }

        if (!$district) {
            return response()->json([
                'success' => false,
                'message' => 'Area yang dipilih tidak valid.',
            ], 422);
        }

        // Transaksi atomik: memastikan pembaruan data dan berkas foto tersimpan secara konsisten
        return DB::transaction(function () use ($installation, $projectId, $districtId, $validated, $request) {
            $installation->update([
                'project_id' => $projectId,
                'user_id' => $validated['user_id']
                    ?? $installation->user_id,
                'lamp_type_id' => $validated['lamp_type_id']
                    ?? $installation->lamp_type_id,
                'district_id' => $districtId,
                'id_lcu' => isset($validated['id_lcu'])
                    ? strip_tags(trim($validated['id_lcu']))
                    : $installation->id_lcu,
                'input_method' => $validated['input_method']
                    ?? $installation->input_method,
                'latitude' => $validated['latitude']
                    ?? $installation->latitude,
                'longitude' => $validated['longitude']
                    ?? $installation->longitude,
                'address' => isset($validated['address'])
                    ? strip_tags(trim($validated['address']))
                    : $installation->address,
                'code_panel' => isset($validated['code_panel'])
                    ? strip_tags(trim($validated['code_panel']))
                    : $installation->code_panel,
                'installed_at' => (!empty($validated['installed_at']))
                    ? $validated['installed_at']
                    : $installation->installed_at,
                'verification_status' => 'Menunggu Verifikasi',
            ]);

            if ($request->hasFile('photos')) {
                foreach ($request->file('photos') as $photo) {
                    $path = $photo->store(
                        'installations',
                        'public'
                    );

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
        });
    }

    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => [
                'required',
                'integer',
                'exists:users,id',
            ],
            'project_id' => [
                'required',
                'integer',
                'exists:projects,id',
            ],
            'district_id' => [
                'nullable',
                'integer',
                'exists:districts,id',
            ],
            'start_date' => [
                'nullable',
                'date',
            ],
            'end_date' => [
                'nullable',
                'date',
                'after_or_equal:start_date',
            ],
        ]);

        $authUser = $request->user();
        $targetUserId = ($authUser && !in_array($authUser->role, ['admin', 'superadmin']))
            ? $authUser->id
            : ($validated['user_id'] ?? $authUser?->id);

        $query = Installation::with([
            'project',
            'user',
            'district',
            'lampType',
            'photos',
        ])
            ->where('user_id', $targetUserId)
            ->where('project_id', $validated['project_id']);

        if (!empty($validated['district_id'])) {
            $query->where(
                'district_id',
                $validated['district_id']
            );
        }

        if (!empty($validated['start_date'])) {
            $query->whereDate(
                'created_at',
                '>=',
                $validated['start_date']
            );
        }

        if (!empty($validated['end_date'])) {
            $query->whereDate(
                'created_at',
                '<=',
                $validated['end_date']
            );
        }

        $installations = $query
            ->orderByDesc('id')
            ->get();

        if ($installations->isNotEmpty()) {
            $notes = DB::table('notifications')
                ->whereIn('installation_id', $installations->pluck('id'))
                ->whereIn(DB::raw('LOWER(type)'), ['rejected', 'rejection', 'ditolak'])
                ->orderByDesc('id')
                ->get()
                ->unique('installation_id')
                ->keyBy('installation_id');

            $installations->each(function ($inst) use ($notes) {
                $notif = $notes->get($inst->id);
                $inst->setAttribute('note_by_admin', $notif ? ($notif->note_by_admin ?? $notif->message) : null);
            });
        }

        return response()->json([
            'success' => true,
            'message' => 'Data pemasangan berhasil diambil.',
            'data' => $installations,
        ]);
    }

    public function show(Request $request, Installation $installation): JsonResponse
    {
        // Cegah IDOR: Pastikan hanya pemilik data (atau admin) yang dapat melihat detail data pemasangan ini
        $authUserId = $request->user()?->id;
        if ($authUserId && (int) $installation->user_id !== (int) $authUserId && !in_array($request->user()?->role, ['admin', 'superadmin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki hak akses untuk melihat data pemasangan ini.',
            ], 403);
        }

        $installation->load([
            'project',
            'user',
            'district',
            'lampType',
            'photos',
        ]);

        $notif = DB::table('notifications')
            ->where('installation_id', $installation->id)
            ->whereIn(DB::raw('LOWER(type)'), ['rejected', 'rejection', 'ditolak'])
            ->orderByDesc('id')
            ->first();

        $installation->setAttribute('note_by_admin', $notif ? ($notif->note_by_admin ?? $notif->message) : null);

        return response()->json([
            'success' => true,
            'message' => 'Detail data pemasangan berhasil diambil.',
            'data' => $installation,
        ]);
    }

    public function destroy(Request $request, Installation $installation): JsonResponse
    {
        $currentStatus = strtolower((string) $installation->verification_status);
        if ($currentStatus === 'terverifikasi' || $currentStatus === 'verified' || $currentStatus === 'terinput') {
            return response()->json([
                'success' => false,
                'message' => 'Data pemasangan yang sudah Terverifikasi tidak dapat dihapus.',
            ], 422);
        }

        // Cegah IDOR: Pastikan hanya pemilik data (atau admin) yang dapat menghapus data ini
        $authUserId = $request->user()?->id;
        if ($authUserId && (int) $installation->user_id !== (int) $authUserId && !in_array($request->user()?->role, ['admin', 'superadmin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki hak akses untuk menghapus data pemasangan ini.',
            ], 403);
        }

        return DB::transaction(function () use ($installation) {
            if ($installation->photos) {
                foreach ($installation->photos as $photo) {
                    if ($photo->photo_path && \Illuminate\Support\Facades\Storage::disk('public')->exists($photo->photo_path)) {
                        \Illuminate\Support\Facades\Storage::disk('public')->delete($photo->photo_path);
                    }
                    $photo->delete();
                }
            }

            $installation->delete();

            return response()->json([
                'success' => true,
                'message' => 'Data pemasangan berhasil dihapus.',
            ]);
        });
    }
}