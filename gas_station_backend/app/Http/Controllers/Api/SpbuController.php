<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Spbu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class SpbuController extends Controller
{
    public function index(Request $request)
    {
        $lat = $request->lat ?? -7.2504;
        $lng = $request->lng ?? 112.7688;

        // 1. Query OSM diperbaiki: Gunakan 'nwr' (node, way, relation) karena SPBU sering berupa area bangunan.
        // Ditambah 'out center' agar jika bentuknya area, kita tetap dapat titik tengah (lat/lng)-nya.
        $queryOverpass = "[out:json][timeout:25];nwr(around:5000,{$lat},{$lng})[\"amenity\"=\"fuel\"];out center;";

        // 2. Tembak API dengan Headers User-Agent (PENTING: Overpass memblokir request tanpa nama)
        $response = Http::withHeaders([
            'User-Agent' => 'AplikasiSPBUMahasiswa/1.0' // Beri tahu OSM siapa kita
        ])->get('https://overpass-api.de/api/interpreter', [
            'data' => $queryOverpass // Laravel akan otomatis URL-Encode query ini
        ]);

        // 3. Cek apakah OSM marah/menolak (Error 4xx atau 5xx)
        if ($response->failed()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Ditolak oleh OSM: ' . $response->body()
            ], 500);
        }

        $osmData = $response->json()['elements'] ?? [];

        // 4. Masukkan ke database
        foreach ($osmData as $element) {
            // Jika SPBU berupa 'way' (area), koordinatnya ada di dalam ['center']
            $elLat = $element['lat'] ?? $element['center']['lat'] ?? null;
            $elLng = $element['lon'] ?? $element['center']['lon'] ?? null;
            $tags = $element['tags'] ?? [];

            // Hanya simpan jika punya nama dan koordinat
            if ($elLat && $elLng && isset($tags['name'])) {
                Spbu::updateOrCreate(
                    ['nama' => $tags['name']], 
                    [
                        'latitude' => $elLat,
                        'longitude' => $elLng,
                        'jenis_bbm' => $tags['fuel:pertalite'] ?? 'Pertalite, Pertamax, Dexlite', 
                        'fasilitas' => $tags['amenity'] ?? 'Toilet, Musholla',
                        'jam_operasional' => $tags['opening_hours'] ?? '24 Jam',
                    ]
                );
            }
        }

      
        $spbuTerdekat = Spbu::selectRaw("*, ( 6371 * acos( cos( radians(?) ) * cos( radians( latitude ) ) * cos( radians( longitude ) - radians(?) ) + sin( radians(?) ) * sin( radians( latitude ) ) ) ) AS jarak", [$lat, $lng, $lat])
            ->having('jarak', '<', 50) 
            ->orderBy('jarak', 'asc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $spbuTerdekat
        ]);
    }
}