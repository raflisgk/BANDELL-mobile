<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
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
            // 1. Cek Bcrypt dari hash SHA-256 (format standar sistem)
            if (Hash::check($inputPassword, $user->password)) {
                $isPasswordValid = true;
            }
            // 2. Cek apakah di DB tersimpan string raw SHA-256
            elseif ($user->password === $inputPassword) {
                $isPasswordValid = true;
            }
            // 3. Cek jika request dikirim via plaintext biasa (di-hash SHA-256 lalu dicocokkan)
            elseif (Hash::check(hash('sha256', $inputPassword), $user->password)) {
                $isPasswordValid = true;
            }
            // 4. Cek langsung plaintext lama jika belum di-hash SHA-256
            elseif (Hash::check($inputPassword, $user->password)) {
                $isPasswordValid = true;
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

        // 5. Jika semua kondisi terpenuhi: login berhasil
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