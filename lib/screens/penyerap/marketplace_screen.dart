import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import '../../widgets/custom_limbah_card.dart';

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
    setState(() {
      _limbahList = data;
    });
  }

  // CREATE: Tambah Dummy Data buat Demo
  Future<void> _tambahDataDummy() async {
    await DatabaseHelper.instance.insertLimbah({
      'nama_limbah': 'Sisa Sayuran & Buah',
      'berat_kg': 45,
      'tanggal': DateTime.now().toString(),
      'status': 'Tersedia'
    });
    _refreshLimbah();
  }

  // DELETE: Saat limbah diambil
  Future<void> _ambilLimbah(int id) async {
    await DatabaseHelper.instance.deleteLimbah(id);
    _refreshLimbah();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil mengambil limbah! Masuk ke History.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Marketplace Limbah', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.green),
            onPressed: _tambahDataDummy, // Tombol rahasia untuk inject data saat demo
          )
        ],
      ),
      body: _limbahList.isEmpty
          ? const Center(child: Text('Belum ada limbah tersedia. Klik icon + di atas.'))
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
                  onAmbil: () => _ambilLimbah(limbah['id']),
                );
              },
            ),
    );
  }
}