<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'status' => 'online',
        'service' => 'BANDELL PJU REST API',
        'version' => '1.0.0',
    ]);
});
