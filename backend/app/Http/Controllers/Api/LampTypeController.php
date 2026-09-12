<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\LampType;
use Illuminate\Http\JsonResponse;

class LampTypeController extends Controller
{
    public function index(): JsonResponse
    {
        $lampTypes = LampType::orderBy('id')->get();

        return response()->json([
            'success' => true,
            'message' => 'Data jenis lampu berhasil diambil.',
            'data' => $lampTypes,
        ]);
    }
}