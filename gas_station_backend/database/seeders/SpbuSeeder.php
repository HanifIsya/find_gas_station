<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Spbu;

class SpbuSeeder extends Seeder
{
    public function run(): void
    {
        // Data ini manual dulu agar kamu bisa ngetes fitur "Filter" dan "Jarak" di Flutter nanti
        Spbu::create([
            'nama' => 'SPBU Pertamina Kertajaya',
            'latitude' => -7.282862,
            'longitude' => 112.763809,
            'jenis_bbm' => 'Pertalite, Pertamax',
            'fasilitas' => 'Toilet, Musholla',
            'jam_operasional' => '24 Jam'
        ]);

        Spbu::create([
            'nama' => 'SPBU Shell Jemursari',
            'latitude' => -7.319766,
            'longitude' => 112.742355,
            'jenis_bbm' => 'Super, V-Power',
            'fasilitas' => 'Toilet, Kafe',
            'jam_operasional' => '06:00 - 22:00'
        ]);
    }
}