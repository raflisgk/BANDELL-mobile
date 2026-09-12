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
        $validated = $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
        ]);

        $user = User::findOrFail($validated['user_id']);

        return response()->json([
            'success' => true,
            'message' => 'Data profile berhasil diambil.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone_number' => $user->phone_number,
                'placement_area' => $user->placement_area,
            ],
        ]);
    }

    public function updatePhone(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => ['required', 'integer', 'exists:users,id'],
            'phone_number' => ['nullable', 'string', 'max:20'],
        ]);

        $user = User::findOrFail($validated['user_id']);

        $user->phone_number = $validated['phone_number'] ?? null;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Nomor HP berhasil diperbarui.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone_number' => $user->phone_number,
                'placement_area' => $user->placement_area,
            ],
        ]);
    }
}