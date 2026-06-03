import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _historyList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Menarik data dari SQLite yang sudah diambil
  Future<void> _loadHistory() async {
    final data = await DatabaseHelper.instance.getAllLimbah();
    setState(() {
      _historyList = data;
    });
  }

  // Fungsi hapus riwayat
  Future<void> _hapusRiwayat(int id) async {
    await DatabaseHelper.instance.deleteLimbah(id);
    _loadHistory(); // Refresh data setelah dihapus
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Riwayat berhasil dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penjemputan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _historyList.isEmpty
          ? const Center(child: Text('Belum ada riwayat penjemputan limbah.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                final item = _historyList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    title: Text(item['nama_limbah'] ?? 'Limbah'),
                    subtitle: Text('Berat: ${item['berat_kg']} kg\nStatus: Selesai'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _hapusRiwayat(item['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}