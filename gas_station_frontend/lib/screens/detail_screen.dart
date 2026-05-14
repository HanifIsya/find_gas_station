import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/spbu.dart';
import '../services/db_helper.dart';

class DetailScreen extends StatefulWidget {
  final Spbu spbu;
  const DetailScreen({super.key, required this.spbu});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spbu.nama),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bagian Peta
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.spbu.latitude, widget.spbu.longitude),
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.spbu_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.spbu.latitude, widget.spbu.longitude),
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bagian Informasi Detail
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Informasi SPBU", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text("BBM: ${widget.spbu.jenisBbm}"),
                  Text("Fasilitas: ${widget.spbu.fasilitas}"),
                  Text("Operasional: ${widget.spbu.jamOperasional}"),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
  // Sekarang kita lempar seluruh objek widget.spbu
  await DBHelper().addFavorite(widget.spbu); 
  
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("${widget.spbu.nama} berhasil jadi favorit!"),
      backgroundColor: Colors.green,
    ),
  );
},
                    icon: const Icon(Icons.favorite),
                    label: const Text("Simpan ke Favorit"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}