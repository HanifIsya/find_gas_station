<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Spbu;
use Illuminate\Http\Request;

class SpbuController extends Controller
{
    public function index()
    {
        // Mengambil semua data SPBU dari database
        $spbu = Spbu::all();

        return response()->json([
            'status' => 'success',
            'data' => $spbu
        ]);
    }
}