import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/spbu.dart'; // Import ini
import 'detail_screen.dart';  // Import ini

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> _favorites = [];

  void _loadFavorites() async {
    final data = await DBHelper().getFavorites();
    setState(() {
      _favorites = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SPBU Favorit Saya")),
      body: _favorites.isEmpty
          ? const Center(child: Text("Belum ada favorit."))
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final item = _favorites[index];
                
                // Konversi Map dari Sqflite kembali menjadi objek Spbu
                final spbuObj = Spbu(
                  id: item['id'],
                  nama: item['nama'],
                  latitude: item['latitude'],
                  longitude: item['longitude'],
                  jenisBbm: item['jenis_bbm'],
                  fasilitas: item['fasilitas'],
                  jamOperasional: item['jam_operasional'],
                );

                return ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(spbuObj.nama),
                  subtitle: Text(spbuObj.fasilitas),
                  onTap: () {
                    // Navigasi ke DetailScreen (Peta)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(spbu: spbuObj),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await DBHelper().removeFavorite(spbuObj.id);
                      _loadFavorites();
                    },
                  ),
                );
              },
            ),
    );
  }
}