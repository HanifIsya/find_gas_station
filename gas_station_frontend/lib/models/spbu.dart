class Spbu {
  final int id;
  final String nama;
  final double latitude;
  final double longitude;
  final String jenisBbm;
  final String fasilitas;
  final String jamOperasional;

  Spbu({
    required this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.jenisBbm,
    required this.fasilitas,
    required this.jamOperasional,
  });

  // Fungsi untuk mengubah JSON dari Laravel menjadi Object Dart
  factory Spbu.fromJson(Map<String, dynamic> json) {
    return Spbu(
      id: json['id'],
      nama: json['nama'],
      // Di-parse ke double untuk memastikan tidak error jika format angka dari DB berupa string
      latitude: double.parse(json['latitude'].toString()), 
      longitude: double.parse(json['longitude'].toString()),
      jenisBbm: json['jenis_bbm'],
      fasilitas: json['fasilitas'],
      jamOperasional: json['jam_operasional'],
    );
  }
}