<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\LampTypeController;
use App\Http\Controllers\Api\InstallationController;
use App\Http\Controllers\Api\ProjectAssignmentController;
use App\Http\Controllers\Api\NotificationController;

Route::post('/login', [AuthController::class, 'login']);
Route::get('/projects', [ProjectController::class, 'index']);
Route::get('/projects/{project}/areas', [ProjectController::class, 'areas']);
Route::get('/lamp-types', [LampTypeController::class, 'index']);
Route::post('/installations', [InstallationController::class, 'store']);
Route::get('/project-assignments', [ProjectAssignmentController::class, 'index']);
Route::get('/installations', [InstallationController::class, 'index']);
Route::get('/installations/{installation}', [InstallationController::class, 'show']);
Route::put('/installations/{installation}', [InstallationController::class, 'update']);
Route::delete('/installations/{installation}', [InstallationController::class, 'destroy']);
Route::get('/notifications', [NotificationController::class, 'index']);