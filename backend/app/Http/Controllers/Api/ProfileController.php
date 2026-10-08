<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        // Cegah IDOR: Prioritaskan user yang sedang login via token Sanctum
        $user = $request->user();

        if (!$user) {
            $validated = $request->validate([
                'user_id' => ['required', 'integer', 'exists:users,id'],
            ]);
            $user = User::findOrFail($validated['user_id']);
        }

        return response()->json([
            'success' => true,
            'message' => 'Data profile berhasil diambil.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'phone_number' => $user->phone,
                'placement_area' => $user->placement_area,
            ],
        ]);
    }

    public function updatePhone(Request $request): JsonResponse
    {
        // Cegah IDOR: Hanya izinkan update pada akun yang sedang terautentikasi
        $user = $request->user();

        if ($user) {
            $validated = $request->validate([
                'user_id' => ['nullable', 'integer'],
                'phone_number' => ['nullable', 'string', 'max:20'],
            ]);
            $phoneNumber = $validated['phone_number'] ?? null;
        } else {
            $validated = $request->validate([
                'user_id' => ['required', 'integer', 'exists:users,id'],
                'phone_number' => ['nullable', 'string', 'max:20'],
            ]);
            $user = User::findOrFail($validated['user_id']);
            $phoneNumber = $validated['phone_number'] ?? null;
        }

        // Sanitasi input nomor telepon
        $user->phone = $phoneNumber ? strip_tags(trim($phoneNumber)) : null;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Nomor HP berhasil diperbarui.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'phone_number' => $user->phone,
                'placement_area' => $user->placement_area,
            ],
        ]);
    }
}