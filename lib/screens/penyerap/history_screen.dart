import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Fungsi penarik data super kebal (Pakai Batas Waktu / Timeout)
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      // Kita kasih waktu maksimal 2 detik. Kalau nyangkut, paksa lompat ke error!
      final data = await DatabaseHelper.instance.getAllLimbah().timeout(
        const Duration(seconds: 2),
      );

      // --- INI LOGIKA FILTERNYA ---
      // Cuma ambil data yang statusnya beneran udah di-scan
      final riwayatAsli = data.where((item) => item['status'] == 'Selesai (Scanned)').toList();

      if (mounted) {
        setState(() {
          // Masukin data yang udah difilter ke list tampilan
          _historyList = riwayatAsli;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Database nyangkut / Error: $e');
      // Matikan loading paksa
      if (mounted) {
        setState(() {
          _historyList = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _hapusRiwayat(int id) async {
    try {
      await DatabaseHelper.instance.deleteLimbah(id);
      _loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Riwayat berhasil dihapus'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Abaikan Hapus Error SQLite Web: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text(
          'Riwayat Penjemputan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _historyList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat penjemputan.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                final item = _historyList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                      ),
                    ),
                    title: Text(
                      item['nama_limbah'] ?? 'Limbah',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Berat/Volume: ${item['berat_kg']}\nStatus: ${item['status']}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                      onPressed: () => _hapusRiwayat(item['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}