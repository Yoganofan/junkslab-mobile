import 'package:flutter/material.dart';
import 'dart:io';
import 'package:junkslab/helpers/penyedia_database_helper.dart';
import 'package:junkslab/screens/penyedia/input_waste_screen.dart'; 
import 'package:junkslab/helpers/preferences_helper.dart';
import 'package:junkslab/models/waste_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

// Fungsi baru untuk mengambil email sebelum memanggil database
  Future<List<Map<String, dynamic>>> _loadHistoryData() async {
    final prefsHelper = PreferencesHelper();
    await prefsHelper.init();
    String activeEmail = prefsHelper.getUserEmail() ?? 'guest';
    
    // Panggil database dan berikan email yang sedang aktif
    return await _databaseHelper.getWasteHistoryWithStatus(activeEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF7FAF5),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadHistoryData(), // Memanggil fungsi JOIN dengan email aktif
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada transaksi limbah.'));
          }

          final listData = snapshot.data!;

          return ListView.builder(
            itemCount: listData.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final rawItem = listData[index];
              final String status = rawItem['status'];
              
              // Konversi map kembali ke Objek Model agar mudah dikirim ke form edit
              final wasteItem = WasteItem.fromMap(rawItem);

              // JIKA STATUS MASIH 'MENUNGGU', AKTIFKAN FITUR DISMISSIBLE (SLIDE TO DELETE)
              if (status == 'Menunggu') {
                return Dismissible(
                  key: Key(wasteItem.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    // Dialog konfirmasi sebelum menghapus
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Data?'),
                        content: const Text('Apakah Anda yakin ingin membatalkan dan menghapus input limbah ini?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true), 
                            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    // Eksekusi fungsi delete dari database_helper Anda
                    await _databaseHelper.deleteWasteItem(wasteItem.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data limbah berhasil dihapus')),
                    );
                  },
                  child: _buildTransactionCard(context, wasteItem, status),
                );
              }

              // JIKA STATUS SUDAH BUKAN 'MENUNGGU' (MISAL: DIAMBIL/SELESAI), TAMPILKAN KARTU BIASA
              return _buildTransactionCard(context, wasteItem, status);
            },
          );
        },
      ),
    );
  }
  // Fungsi untuk membuka Google Maps dari teks deskripsi
Future<void> _openMap(String description) async {
  if (description.contains('Lokasi:')) {
    try {
      // Memotong teks untuk mengambil angka koordinatnya saja
      final locString = description.split('Lokasi:')[1].trim(); 
      final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$locString');

      // Buka aplikasi Google Maps bawaan HP
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Tidak dapat membuka peta');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka peta!'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

Future<void> _publishData(WasteItem item) async {
    final updatedItem = WasteItem(
      id: item.id,
      userEmail: item.userEmail,
      category: item.category,
      weightKg: item.weightKg,
      description: item.description,
      imagePath: item.imagePath,
      createdAt: item.createdAt,
      isListed: true, 
    );
    await _databaseHelper.updateWasteItem(updatedItem);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limbah berhasil dipublikasikan!'), backgroundColor: Color(0xFF006B23)),
      );
      setState(() {}); 
    }
  }
  
Future<void> _unpublishData(WasteItem item) async {
    final updatedItem = WasteItem(
      id: item.id,
      userEmail: item.userEmail,
      category: item.category,
      weightKg: item.weightKg,
      description: item.description,
      imagePath: item.imagePath,
      createdAt: item.createdAt,
      isListed: false, // <-- KEMBALI JADI FALSE (DRAFT)
    );

    await _databaseHelper.updateWasteItem(updatedItem);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publikasi dibatalkan. Data kembali ke Draft.'), backgroundColor: Colors.red),
      );
      setState(() {}); // Refresh layar
    }
  }

  void _showQRPopup(BuildContext context, WasteItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('QR Penjemputan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1A))),
                const SizedBox(height: 8),
                Text('ID Transaksi: TRX-${item.id}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                CustomPaint(
                  foregroundPainter: QRScannerFramePainter(),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: QrImageView(
                      data: 'TRX-${item.id}-JUNKS', // <-- Data QR kini berisi ID unik dari SQLite!
                      version: QrVersions.auto,
                      size: 180.0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B23),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
 // Desain kartu item riwayat Anda
 Widget _buildTransactionCard(BuildContext context, WasteItem item, String status) {
    // Cek apakah data ini masih draft (belum dipublikasi)
    bool isDraft = !item.isListed;
    
    // Atur teks dan warna berdasarkan status
    String displayStatus = isDraft ? 'Draft (Belum Dipublikasi)' : 'Menunggu Penjemputan';
    Color statusBgColor = isDraft ? Colors.orange.shade100 : Colors.green.shade100;
    Color statusTextColor = isDraft ? Colors.orange.shade900 : Colors.green.shade900;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO LIMBAH
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4EF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBECABA)),
                  ),
                  child: (item.imagePath != null && item.imagePath!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(File(item.imagePath!), fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.image_outlined, color: Color(0xFF006B23)),
                ),
                const SizedBox(width: 16),
                
                // INFORMASI TEKS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(item.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          Text('${item.weightKg} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item.description, style: const TextStyle(fontSize: 13)),
                      
                      // TOMBOL MAPS JIKA ADA KOORDINAT
                      if (item.description.contains('Lokasi:'))
                        GestureDetector(
                          onTap: () => _openMap(item.description),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map, size: 16, color: Colors.blue),
                                SizedBox(width: 6),
                                Text('Buka di Maps', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        
                      const SizedBox(height: 8),
                      // BADGE STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(6)),
                        child: Text(displayStatus, style: TextStyle(color: statusTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                
                // TOMBOL EDIT (HANYA MUNCUL JIKA DRAFT)
                if (isDraft)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InputWasteScreen(wasteItem: item)),
                      ).then((value) => setState(() {}));
                    },
                  )
              ],
            ),
            
            const SizedBox(height: 16),
            
            
            // TOMBOL AKSI UTAMA (PUBLIKASI / TAMPILKAN QR)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isDraft) {
                    _publishData(item);
                  } else {
                    _showQRPopup(context, item);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDraft ? Colors.orange.shade600 : const Color(0xFF006B23),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(isDraft ? Icons.cloud_upload : Icons.qr_code_scanner, size: 20),
                label: Text(isDraft ? 'Publikasikan Sekarang' : 'Tampilkan QR Code', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (!isDraft) ...[
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Munculkan dialog konfirmasi sebelum membatalkan
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Batalkan Publikasi?'),
                        content: const Text('Data limbah ini akan ditarik dari bursa penjemputan dan dikembalikan menjadi Draft. Anda yakin?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _unpublishData(item); // Panggil fungsi unpublish
                            }, 
                            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Batalkan Publikasi', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              )
            ]
            // ==========================================================

          ], // <-- Ini penutup dari Column utama kartu
        ),
      ),
    );
  }  
}

class QRScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF006B23)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const double length = 40.0;
    canvas.drawPath(Path()..moveTo(0, length)..lineTo(0, 0)..lineTo(length, 0), paint);
    canvas.drawPath(Path()..moveTo(size.width - length, 0)..lineTo(size.width, 0)..lineTo(size.width, length), paint);
    canvas.drawPath(Path()..moveTo(0, size.height - length)..lineTo(0, size.height)..lineTo(length, size.height), paint);
    canvas.drawPath(Path()..moveTo(size.width, size.height - length)..lineTo(size.width, size.height)..lineTo(size.width - length, size.height), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}