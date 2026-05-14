import 'package:flutter/material.dart';
import '../services/db_helper.dart';

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
                return ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(_favorites[index]['nama']),
                  subtitle: Text(_favorites[index]['fasilitas']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await DBHelper().removeFavorite(_favorites[index]['id']);
                      _loadFavorites(); // Refresh list
                    },
                  ),
                );
              },
            ),
    );
  }
}