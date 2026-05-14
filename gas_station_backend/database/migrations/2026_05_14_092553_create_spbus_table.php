<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('spbus', function (Blueprint $table) {
            $table->id();
            $table->string('nama');
            // Gunakan decimal dengan presisi tinggi untuk koordinat peta
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            
            // Menyimpan data sebagai string/text (nantinya bisa difilter di query)
            $table->string('jenis_bbm'); // Contoh: "Pertalite, Pertamax, Dexlite"
            $table->string('fasilitas'); // Contoh: "Toilet, Musholla, Minimarket"
            $table->string('jam_operasional'); // Contoh: "24 Jam" atau "06:00 - 22:00"
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('spbus');
    }
};