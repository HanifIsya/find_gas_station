import 'package:flutter/material.dart';
import '../models/spbu.dart';

class SpbuItem extends StatelessWidget {
  final Spbu spbu;
  final VoidCallback onTap;

  const SpbuItem({super.key, required this.spbu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.local_gas_station, color: Colors.white),
        ),
        title: Text(spbu.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(spbu.fasilitas),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}