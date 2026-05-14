<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Spbu extends Model
{
    use HasFactory;

    // Menentukan kolom mana saja yang boleh diisi secara massal
    protected $fillable = [
        'nama',
        'latitude',
        'longitude',
        'jenis_bbm',
        'fasilitas',
        'jam_operasional',
    ];
}