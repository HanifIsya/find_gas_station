import 'package:flutter/material.dart';
import '../models/spbu.dart';
import '../services/api_service.dart';
import '../widgets/spbu_item.dart';
import 'detail_screen.dart'; // Pastikan kamu sudah membuat file detail_screen.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Spbu>> _futureSpbu;

  @override
  void initState() {
    super.initState();
    // Memanggil API saat aplikasi pertama kali dibuka
    _futureSpbu = _apiService.fetchSpbu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari SPBU Terdekat"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Spbu>>(
        future: _futureSpbu,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Error: ${snapshot.error}\n\nPastikan Laravel sudah jalan dengan --host=0.0.0.0",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data SPBU"));
          }

          final listSpbu = snapshot.data!;
          return ListView.builder(
            itemCount: listSpbu.length,
            itemBuilder: (context, index) {
              return SpbuItem(
                spbu: listSpbu[index],
                onTap: () {
                  // Perintah navigasi untuk pindah halaman
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(spbu: listSpbu[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}