import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  void _loadHistory() async {
    final data = await DBHelper().getSearchHistory();
    setState(() {
      _history = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pencarian"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await DBHelper().clearSearchHistory();
              _loadHistory();
            },
            tooltip: "Hapus Semua Riwayat",
          )
        ],
      ),
      body: _history.isEmpty
          ? const Center(child: Text("Belum ada riwayat pencarian."))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(_history[index]['keyword']),
                );
              },
            ),
    );
  }
}