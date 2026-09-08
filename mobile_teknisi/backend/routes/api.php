<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\LampTypeController;
use App\Http\Controllers\Api\InstallationController;
use App\Http\Controllers\Api\ProjectAssignmentController;


Route::post('/login', [AuthController::class, 'login']);
Route::get('/projects', [ProjectController::class, 'index']);
Route::get('/projects/{project}/areas', [ProjectController::class, 'areas']);
Route::get('/lamp-types', [LampTypeController::class, 'index']);
Route::post('/installations', [InstallationController::class, 'store']);
Route::get('/project-assignments', [ProjectAssignmentController::class, 'index']);
Route::get('/installations', [InstallationController::class, 'index']);
Route::get('/installations/{installation}', [InstallationController::class, 'show']);