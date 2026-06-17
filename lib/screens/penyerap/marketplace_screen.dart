import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import '../../widgets/custom_limbah_card.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Wajib ada untuk komunikasi ke Dashboard

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Map<String, dynamic>> _limbahList = [];

  @override
  void initState() {
    super.initState();
    _refreshLimbah();
  }

  // READ: Mengambil data dari SQLite
  Future<void> _refreshLimbah() async {
    final data = await DatabaseHelper.instance.getAllLimbah();
    // Filter biar yang tampil di Marketplace cuma yang belum di-scan (misal statusnya Tersedia)
    final limbahTersedia = data
        .where((item) => item['status'] == 'Tersedia')
        .toList();

    setState(() {
      _limbahList = limbahTersedia;
    });
  }

  // CREATE: Tambah Dummy Data buat Demo
  Future<void> _tambahDataDummy() async {
    await DatabaseHelper.instance.insertLimbah({
      'nama_limbah': 'Sisa Sayuran & Buah',
      'berat_kg': 45,
      'tanggal': DateTime.now().toString(),
      'status': 'Tersedia',
    });
    _refreshLimbah();
  }

 
  Future<void> _ambilLimbah(Map<String, dynamic> limbah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('status_tugas', 'aktif');
    await prefs.setString('tugas_nama', limbah['nama_limbah']);
    await prefs.setString('tugas_berat', '${limbah['berat_kg']} Liter/Kg');

    await prefs.setString('tugas_penyedia', 'Penyedia ${limbah['id']}');
    await prefs.setString(
      'tugas_lokasi',
      'Jl. Bojongsoang No. ${limbah['id']}',
    );

    await DatabaseHelper.instance.deleteLimbah(limbah['id']);
    _refreshLimbah();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Limbah berhasil diajukan! Silakan pindah ke tab Dashboard.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Marketplace Limbah',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.green),
            onPressed:
                _tambahDataDummy, // Tombol rahasia untuk inject data saat demo
          ),
        ],
      ),
      body: _limbahList.isEmpty
          ? const Center(
              child: Text('Belum ada limbah tersedia. Klik icon + di atas.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _limbahList.length,
              itemBuilder: (context, index) {
                final limbah = _limbahList[index];
                return CustomLimbahCard(
                  namaPenyedia: 'Penyedia ${limbah['id']}',
                  jenisLimbah: limbah['nama_limbah'],
                  berat: '${limbah['berat_kg']} kg',
                  lokasi: 'Jl. Bojongsoang No. ${limbah['id']}',
                  status: limbah['status'],
                  // Panggil fungsi dengan mengirim data limbah secara utuh
                  onAmbil: () => _ambilLimbah(limbah),
                );
              },
            ),
    );
  }
}
