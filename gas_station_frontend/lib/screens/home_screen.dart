import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import package lokasi
import '../models/spbu.dart';
import '../services/api_service.dart';
import '../widgets/spbu_item.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Menyimpan semua data dari API
  List<Spbu> _allSpbu = [];
  // Menyimpan data yang sudah difilter untuk ditampilkan
  List<Spbu> _filteredSpbu = [];

  // Variabel untuk menyimpan pilihan filter user
  String _selectedBbm = 'Semua';
  final List<String> _opsiBbm = ['Semua', 'Pertalite', 'Pertamax', 'Super', 'V-Power'];

  @override
  void initState() {
    super.initState();
    // 1. Saat layar dibuka, langsung minta lokasi user terlebih dahulu
    _getUserLocation();
  }

  // Fungsi untuk meminta izin dan mengambil koordinat GPS HP
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah GPS di HP nyala
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = "Harap aktifkan GPS / Lokasi di HP Anda.";
        _isLoading = false;
      });
      return;
    }

    // Cek izin aplikasi untuk mengakses lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = "Izin lokasi ditolak oleh pengguna.";
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = "Izin lokasi diblokir permanen. Buka pengaturan HP.";
        _isLoading = false;
      });
      return;
    }

    // Jika izin diberikan, ambil koordinat saat ini
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // 2. Setelah dapat koordinat, baru ambil data dari Laravel
    _loadData(position.latitude, position.longitude);
  }

  // Fungsi untuk mengambil data dari API berdasarkan lokasi
  Future<void> _loadData(double lat, double lng) async {
    try {
      final data = await _apiService.fetchSpbu(lat, lng);
      setState(() {
        _allSpbu = data;
        _filteredSpbu = data; // Awalnya tampilkan semua
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Fungsi Logika Filter (Bisa kamu modifikasi untuk filter jarak/fasilitas nanti)
  void _applyFilter(String newValue) {
    setState(() {
      _selectedBbm = newValue;
      
      if (_selectedBbm == 'Semua') {
        _filteredSpbu = _allSpbu;
      } else {
        // Menyaring data jika string jenisBbm mengandung kata yang dipilih
        _filteredSpbu = _allSpbu.where((spbu) {
          return spbu.jenisBbm.toLowerCase().contains(_selectedBbm.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari SPBU Terdekat"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteScreen()),
              );
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading muter-muter
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Error: $_errorMessage\n\nPastikan Laravel jalan, IP sesuai, dan GPS nyala.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: [
                    // --- BAGIAN FILTER UI ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.grey[200],
                      child: Row(
                        children: [
                          const Text("Filter BBM: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedBbm,
                              items: _opsiBbm.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  _applyFilter(newValue);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // --- BAGIAN LIST SPBU ---
                    Expanded(
                      child: _filteredSpbu.isEmpty
                          ? const Center(child: Text("Tidak ada SPBU dengan kriteria tersebut."))
                          : ListView.builder(
                              itemCount: _filteredSpbu.length,
                              itemBuilder: (context, index) {
                                return SpbuItem(
                                  spbu: _filteredSpbu[index],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(spbu: _filteredSpbu[index]),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}