import 'package:dio/dio.dart';
import '../models/spbu.dart';

class ApiService {
  final Dio _dio = Dio();
  // Pastikan IP ini sesuai dengan IP Wi-Fi laptopmu ya
  final String baseUrl = "http://192.168.1.8:8000/api"; 

  // Tambahkan parameter lat dan lng
  Future<List<Spbu>> fetchSpbu(double lat, double lng) async {
    try {
      // Mengirim lat dan lng ke Laravel sebagai query parameter (?lat=x&lng=y)
      final response = await _dio.get('$baseUrl/spbu', queryParameters: {
        'lat': lat,
        'lng': lng,
      });
      
      List data = response.data['data'];
      return data.map((json) => Spbu.fromJson(json)).toList();
    } catch (e) {
      print("Error mengambil data: $e");
      throw Exception('Gagal memuat data SPBU');
    }
  }
}