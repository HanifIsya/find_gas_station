import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/spbu.dart';
import '../services/api_service.dart';
import '../services/db_helper.dart'; // Import DB Helper
import '../widgets/spbu_item.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';
import 'history_screen.dart'; // Import Halaman History

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController(); // Controller Search Bar
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  List<Spbu> _allSpbu = [];
  List<Spbu> _filteredSpbu = [];

  String _selectedBbm = 'Semua';
  String _searchKeyword = ''; // Menyimpan kata kunci pencarian
  final List<String> _opsiBbm = ['Semua', 'Pertalite', 'Pertamax', 'Super', 'V-Power'];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage = "Harap aktifkan GPS / Lokasi di HP Anda.";
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = "Izin lokasi ditolak.";
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = "Izin lokasi diblokir permanen.";
        _isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _loadData(position.latitude, position.longitude);
  }

  Future<void> _loadData(double lat, double lng) async {
    try {
      final data = await _apiService.fetchSpbu(lat, lng);
      setState(() {
        _allSpbu = data;
        _filteredSpbu = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // --- LOGIKA FILTER GABUNGAN (SEARCH BAR + DROPDOWN) ---
  void _applyFilters() {
    setState(() {
      _filteredSpbu = _allSpbu.where((spbu) {
        // Cek kecocokan nama (Search Bar)
        bool matchKeyword = _searchKeyword.isEmpty || 
            spbu.nama.toLowerCase().contains(_searchKeyword.toLowerCase());
        
        // Cek kecocokan BBM (Dropdown)
        bool matchBbm = _selectedBbm == 'Semua' || 
            spbu.jenisBbm.toLowerCase().contains(_selectedBbm.toLowerCase());
        
        return matchKeyword && matchBbm;
      }).toList();
    });
  }

  // Fungsi saat user menekan Enter/Search di keyboard
  void _onSearchSubmit(String keyword) {
    if (keyword.isNotEmpty) {
      DBHelper().addSearchHistory(keyword); // Simpan ke Sqflite
    }
    _searchKeyword = keyword;
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari SPBU Terdekat"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Riwayat Pencarian
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
            },
          ),
          // Tombol Favorit
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteScreen()));
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text("Error: $_errorMessage"))
              : Column(
                  children: [
                    // --- SEARCH BAR ---
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari nama SPBU...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchSubmit('');
                            },
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: _onSearchSubmit,
                      ),
                    ),
                    // --- DROPDOWN FILTER BBM ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      child: Row(
                        children: [
                          const Text("Filter BBM: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedBbm,
                              items: _opsiBbm.map((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value));
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  _selectedBbm = newValue;
                                  _applyFilters();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    // --- LIST SPBU ---
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