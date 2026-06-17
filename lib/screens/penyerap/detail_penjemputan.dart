import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'qr_scanner_screen.dart';

class DetailPenjemputan extends StatefulWidget {
  const DetailPenjemputan({Key? key}) : super(key: key);

  @override
  State<DetailPenjemputan> createState() => _DetailPenjemputanState();
}

class _DetailPenjemputanState extends State<DetailPenjemputan> {
  String _namaPenyedia = 'Memuat...';
  String _namaLimbah = 'Memuat...';
  String _beratLimbah = 'Memuat...';
  String _lokasi = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadDetailData();
  }

  Future<void> _loadDetailData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaPenyedia =
          prefs.getString('tugas_penyedia') ?? 'Data Tidak Ditemukan';
      _namaLimbah = prefs.getString('tugas_nama') ?? '-';
      _beratLimbah = prefs.getString('tugas_berat') ?? '-';
      _lokasi = prefs.getString('tugas_lokasi') ?? '-';
    });
  }

  void _tampilkanPeringatanScan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 64, color: Colors.green.shade600),
              const SizedBox(height: 16),
              const Text(
                'Sudah di Lokasi?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan Anda telah bertemu dengan penyedia limbah dan berada di lokasi penjemputan sebelum melakukan scan QR Code.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrScannerScreen(
                          jenisLimbah: _namaLimbah,
                          berat:
                              int.tryParse(
                                _beratLimbah.replaceAll(RegExp(r'[^0-9]'), ''),
                              ) ??
                              0,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Ya, Buka Scanner',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Detail Penjemputan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: const Text(
                      'Menunggu Diambil',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.orange.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _namaPenyedia,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$_lokasi, Kab. Bandung',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Rincian Informasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Jenis Limbah', _namaLimbah),
                  const Divider(height: 30),
                  _buildDetailRow('Volume / Berat', _beratLimbah),
                  const Divider(height: 30),
                  _buildDetailRow(
                    'Biaya Penjemputan',
                    '-150 JP',
                    isMinus: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Catatan Tambahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Minyak/Limbah sudah siap diangkut di depan lokasi.',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          label: const Text(
            'Scan QR Penyedia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => _tampilkanPeringatanScan(context),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isMinus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isMinus ? Colors.red.shade700 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
