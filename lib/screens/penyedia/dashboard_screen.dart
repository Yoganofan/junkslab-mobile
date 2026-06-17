import 'package:junkslab/screens/admin/admin_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:junkslab/helpers/preferences_helper.dart'; 
import 'input_waste_screen.dart';
import 'riwayat_screen.dart';
import 'wallet_screen.dart';
import 'package:junkslab/main.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:junkslab/models/waste_item.dart'; 
import 'package:junkslab/helpers/penyedia_database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _displayName = 'Andi Wijaya'; 

  @override
  void initState() {
    super.initState();
    _loadUserGreeting();
  }

  Future<void> _loadUserGreeting() async {
    final prefsHelper = PreferencesHelper();
    
    // Paksa inisialisasi SharedPreferences jika belum aktif
    await prefsHelper.init(); 
    
    String? savedName = prefsHelper.getUserName();
    String? activeEmail = prefsHelper.getUserEmail();

    setState(() {
      if (savedName != null && savedName.isNotEmpty) {
        _displayName = savedName;
      } else if (activeEmail != null && activeEmail.isNotEmpty) {
        // Jika nama kosong, potong email bagian depan sebagai fallback
        _displayName = activeEmail.split('@').first;
      } else {
        _displayName = 'Penyedia';
      }
    });
  }

  // Fungsi mengambil transaksi yang sudah dipublikasikan (isListed == 1)
  Future<List<Map<String, dynamic>>> _loadActiveTransactions() async {
    final prefsHelper = PreferencesHelper();
    await prefsHelper.init();
    String activeEmail = prefsHelper.getUserEmail() ?? 'guest';
    
    final dbHelper = DatabaseHelper();
    final allData = await dbHelper.getWasteHistoryWithStatus(activeEmail);
    
    // Filter hanya data yang sudah dipublikasikan
    return allData.where((item) => item['is_listed'] == 1).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF5),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuArEe5ZyGaVDm-zDnG2yB0j5tEGVY-_Klk7SHk70Zfv6w7n9chyXRdgrKvbWiEAn4y6JF8lAm7pmMiu--XUltuQux4Tvfj3y9tLyonKwIm807YVYzzvx1RTKcD35B9lz2lKjoT7OP3vo654ZQqsHrZjWtbfXasgr_6SjN8pei-Cm6euZRVoEB1U8W5aJjJpFQys-BHR1QEY1pJAzqXmX5j07lyUqbJXr6JrK51BW8XAzCTGiQCaEP69QpmtiVdwhYMAMl_LIMrfZb4K'
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Halo, Penyedia',
                  style: TextStyle(fontSize: 11, color: Color(0xFF3F4A3D)),
                ),
                Text(
                  _displayName, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1A)),
                ),
              ],
            )
          ],
        ),
        
        actions: [
            IconButton(
                onPressed: () => context.read<AdminProvider>().toggleTheme(),
                icon: Icon(
                  context.watch<AdminProvider>().isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: const Color(0xFF006B23),
                ),
            ),
                IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF006B23)),
                onPressed: () {},
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saldo JunksPoint Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF006B23),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF006B23).withOpacity(0.05),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Saldo JunksPoint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '0',
                            style: TextStyle(fontSize: 32, fontFamily: 'Hanken Grotesk', fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Text('JP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Setara Rp 0', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            ),
                            child: const Text('Tarik Saldo', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions Block
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      // Menunggu respons jika ada pembaruan dari form input
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InputWasteScreen()),
                      );
                      
                      if (result == true) {
                        _loadUserGreeting();
                      }
                    },
                    child: Container(
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C8634),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                          SizedBox(height: 8),
                          Text(
                            'Input Limbah Makanan',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RiwayatScreen()),).then((_) => setState(() {}));
                    },
                    child: Container(
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFBECABA)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, color: Color(0xFF006B23), size: 28),
                          SizedBox(height: 8),
                          Text(
                            'Riwayat',
                            style: TextStyle(color: Color(0xFF006B23), fontWeight: FontWeight.bold, fontSize: 13),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transaksi Aktif Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transaksi Aktif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191C1A))),
                TextButton(
                  onPressed: () {},
                  child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF006B23))),
                )
              ],
            ),
            const SizedBox(height: 10),

            // Transaction Cards (SEKARANG DINAMIS)
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadActiveTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF006B23)),
                  ));
                }
                
                // Jika tidak ada transaksi aktif yang dipublikasikan
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBECABA)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFBECABA)),
                        SizedBox(height: 8),
                        Text('Belum ada transaksi aktif', style: TextStyle(color: Color(0xFF636360), fontWeight: FontWeight.bold)),
                        Text('Publikasikan limbahmu di menu Riwayat', style: TextStyle(color: Color(0xFF636360), fontSize: 12)),
                      ],
                    ),
                  );
                }

                final activeData = snapshot.data!;

                // Membangun daftar kartu transaksi aktif
                return ListView.builder(
                  shrinkWrap: true, // Agar listview tidak error di dalam scrollview
                  physics: const NeverScrollableScrollPhysics(), // Scroll mengikuti halaman utama
                  itemCount: activeData.length,
                  itemBuilder: (context, index) {
                    final rawItem = activeData[index];
                    final item = WasteItem.fromMap(rawItem);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          // Tampilkan Pop-Up QR Code dengan Custom Drawing
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
                                      Text('ID Transaksi: TRX-${item.id}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 28),
                                      
                                      // CUSTOM DRAWING FRAME
                                      CustomPaint(
                                        foregroundPainter: QRScannerFramePainter(),
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          child: QrImageView(
                                            data: 'TRX-${item.id}-JUNKS', // QR Dinamis sesuai ID
                                            version: QrVersions.auto,
                                            size: 180.0,
                                            foregroundColor: const Color(0xFF191C1A),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      
                                      // TOMBOL BYPASS SEMENTARA
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context); // Tutup pop-up
                                            walletState.prosesBypass(item.weightKg, item.id.toString());
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('BYPASS SUKSES: Limbah TRX-${item.id} seberat ${item.weightKg}Kg berhasil dipindai mitra!'),
                                                backgroundColor: const Color(0xFF006B23),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 18),
                                          label: const Text('Bypass: Simulasi Ter-Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent, 
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Tombol Tutup Asli
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
                        },
                        // DESAIN KARTU LIMBAH (Dikembalikan ke tempat asalnya)
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF006B23).withOpacity(0.03), blurRadius: 20)
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        // Foto Limbah Dinamis
                                        Container(
                                          width: 48, height: 48,
                                          decoration: BoxDecoration(color: const Color(0xFFF0F4EF), borderRadius: BorderRadius.circular(8)),
                                          child: (item.imagePath != null && item.imagePath!.isNotEmpty)
                                              ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(item.imagePath!), fit: BoxFit.cover))
                                              : const Icon(Icons.recycling, color: Color(0xFF006B23)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                                              Text('ID: #TRX-${item.id} (Ketuk QR)', style: const TextStyle(color: Color(0xFF3F4A3D), fontSize: 11)),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(30)),
                                    child: Text('Menunggu', style: TextStyle(color: Colors.green.shade900, fontSize: 11, fontWeight: FontWeight.w600)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.scale_outlined, size: 18, color: Color(0xFF3F4A3D)),
                                      const SizedBox(width: 4),
                                      Text('${item.weightKg} Kg', style: const TextStyle(fontSize: 12, color: Color(0xFF3F4A3D))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF3F4A3D)),
                                      const SizedBox(width: 4),
                                      Text('${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}', style: const TextStyle(fontSize: 12, color: Color(0xFF3F4A3D))),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(
                                  value: 0.3, // Animasi statis menunggu
                                  backgroundColor: Color(0xFFECEFEA),
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006B23)),
                                  minHeight: 4,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                );
              },
            ),

            const SizedBox(height: 16), // Jarak sebelum Tips Eco

            // Bento Quick Tips Eco
            const Text('Tips Eco-Tech', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191C1A))),
            const SizedBox(height: 14),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFE4E2DE), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cara sortir plastik PET yang benar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B1C1A))),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF006B23),
                            child: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class QRScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {      
    final paint = Paint()
      ..color = const Color(0xFF006B23) // Warna hijau JunksLab
      ..strokeWidth = 6.0               // Ketebalan garis
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;    // Ujung garis membulat

    const double length = 40.0; // Panjang siku-siku bingkai

    // Lukis Bingkai Kiri Atas
    canvas.drawPath(Path()..moveTo(0, length)..lineTo(0, 0)..lineTo(length, 0), paint);
    // Lukis Bingkai Kanan Atas
    canvas.drawPath(Path()..moveTo(size.width - length, 0)..lineTo(size.width, 0)..lineTo(size.width, length), paint);
    // Lukis Bingkai Kiri Bawah
    canvas.drawPath(Path()..moveTo(0, size.height - length)..lineTo(0, size.height)..lineTo(length, size.height), paint);
    // Lukis Bingkai Kanan Bawah
    canvas.drawPath(Path()..moveTo(size.width, size.height - length)..lineTo(size.width, size.height)..lineTo(size.width - length, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}