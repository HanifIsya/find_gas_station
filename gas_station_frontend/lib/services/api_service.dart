import 'package:dio/dio.dart';
import '../models/spbu.dart';

class ApiService {
  final Dio _dio = Dio();
  
  // Gunakan 10.0.2.2 khusus untuk Emulator Android agar bisa menembak localhost laptop
  final String baseUrl = "http://192.168.1.8:8000/api";

  Future<List<Spbu>> fetchSpbu() async {
    try {
      final response = await _dio.get('$baseUrl/spbu');
      
      // Mengambil array "data" dari JSON response Laravel
      List data = response.data['data'];
      
      // Mengubah list of map menjadi list of Spbu object
      return data.map((json) => Spbu.fromJson(json)).toList();
    } catch (e) {
      print("Error mengambil data: $e");
      throw Exception('Gagal memuat data SPBU');
    }
  }
}