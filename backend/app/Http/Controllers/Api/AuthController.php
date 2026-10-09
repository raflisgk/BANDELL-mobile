<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        // Cari user (termasuk yang di-soft delete agar dapat mendeteksi kondisi deleted_at)
        $user = User::withTrashed()->where('email', $credentials['email'])->first();

        $inputPassword = $credentials['password'];
        $isPasswordValid = false;

        if ($user && !empty($user->password)) {
            // 1. Cek Bcrypt standar Laravel / Filament / Seeder (plaintext input)
            if (Hash::check($inputPassword, $user->password)) {
                $isPasswordValid = true;
            }
            // 2. Cek Bcrypt dari hash SHA-256 (format akun lama seperti Rafli)
            elseif (Hash::check(hash('sha256', $inputPassword), $user->password)) {
                $isPasswordValid = true;
                // Otomatis sinkronkan password ke format Bcrypt standar
                DB::table('users')->where('id', $user->id)->update([
                    'password' => Hash::make($inputPassword),
                ]);
            }
        }

        // 1. Verifikasi kredensial (user ada & password benar)
        if (!$user || !$isPasswordValid) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah.',
            ], 401);
        }

        // 2. Validasi deleted_at (soft delete)
        if ($user->deleted_at !== null) {
            return response()->json([
                'success' => false,
                'message' => 'Akun tidak ditemukan atau sudah tidak aktif.',
            ], 403);
        }

        // 3. Validasi status akun (harus aktif)
        if (strtolower((string) $user->status) !== 'aktif') {
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda sedang nonaktif. Silakan hubungi administrator.',
            ], 403);
        }

        // 4. Validasi role (harus teknisi)
        if (strtolower((string) $user->role) !== 'teknisi') {
            return response()->json([
                'success' => false,
                'message' => 'Akun ini tidak dapat digunakan pada aplikasi teknisi.',
            ], 403);
        }

        // 5. Jika semua kondisi terpenuhi: cabut token lama aplikasi agar tidak menumpuk, lalu buat token baru
        $user->tokens()->where('name', 'mobile_app')->delete();
        $token = $user->createToken('mobile_app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'token' => $token,
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'status' => $user->status,
                'phone' => $user->phone,
                'phone_number' => $user->phone,
                'placement_area' => $user->placement_area,
                'total_installations' => \App\Models\Installation::where('user_id', $user->id)->count(),
                'total_lamps' => \App\Models\Installation::where('user_id', $user->id)->count(),
                'total_projects' => \App\Models\ProjectAssignment::where('user_id', $user->id)->distinct('project_id')->count(),
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        if ($request->user()) {
            $request->user()->currentAccessToken()->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil.',
        ]);
    }
}