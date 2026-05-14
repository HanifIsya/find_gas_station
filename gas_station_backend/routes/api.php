<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SpbuController;

Route::get('/spbu', [SpbuController::class, 'index']);