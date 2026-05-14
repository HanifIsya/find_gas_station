import 'package:flutter/material.dart';
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
    _loadData();
  }

  // Fungsi untuk mengambil data dari API
  Future<void> _loadData() async {
    try {
      final data = await _apiService.fetchSpbu();
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

  // Fungsi Logika Filter
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
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text("Error: $_errorMessage"))
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