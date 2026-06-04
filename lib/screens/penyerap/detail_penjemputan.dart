import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';

class DetailPenjemputan extends StatelessWidget {
  const DetailPenjemputan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Detail Penjemputan', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
                    child: Text('Menunggu Diambil', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Warung Makmur (Cabang Bojongsoang)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Jl. Terusan Buah Batu No. 45, Kab. Bandung', style: TextStyle(color: Colors.grey, fontSize: 14))),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),
                  const Text('Rincian Limbah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDetailRow('Jenis Limbah', 'Minyak Jelantah'),
                  _buildDetailRow('Volume / Berat', '15 Liter'),
                  
                  // Logika biaya tebus limbah (Minus JP)
                  _buildDetailRow('Biaya Penjemputan', '-150 JP', isMinus: true),
                  
                  _buildDetailRow('Catatan', 'Minyak sudah dimasukkan ke dalam jerigen hijau di depan warung.'),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text('Scan QR Penyedia', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrScannerScreen(
                        jenisLimbah: 'Minyak Jelantah',
                        berat: 15,
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isMinus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: 14,
                color: isMinus ? Colors.red.shade700 : Colors.black87
              )
            ),
          ),
        ],
      ),
    );
  }
}