import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_limbah_card.dart';
import 'detail_penjemputan.dart';

class DashboardPenyerap extends StatefulWidget {
  const DashboardPenyerap({Key? key}) : super(key: key);

  @override
  State<DashboardPenyerap> createState() => _DashboardPenyerapState();
}

class _DashboardPenyerapState extends State<DashboardPenyerap> {
  int _saldoAsli = 12450;
  int _saldoTampil = 12450;

  String _statusTugas = 'kosong';
  String _namaLimbah = '';
  String _beratLimbah = '';
  String _namaPenyedia = '';
  String _lokasiPenyedia = '';

  // --- VARIABEL DUMMY UNTUK DATA DAMPAK ---
  int _limbahTerserap = 300; // Basis awal sebelum penjemputan hari ini
  double _co2Dicegah = 1.0;  // Basis awal CO2

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final prefs = await SharedPreferences.getInstance();
    String status = prefs.getString('status_tugas') ?? 'kosong';

    if (mounted) {
      setState(() {
        _statusTugas = status;
        _namaLimbah = prefs.getString('tugas_nama') ?? 'Minyak Jelantah';
        _beratLimbah = prefs.getString('tugas_berat') ?? '15 Liter';
        
        _namaPenyedia = prefs.getString('tugas_penyedia') ?? 'Menunggu Data...';
        _lokasiPenyedia = prefs.getString('tugas_lokasi') ?? 'Menunggu lokasi...';

        // Jika status selesai, potong saldo dan tambahkan dampak penjemputan hari ini
        if (_statusTugas == 'selesai') {
          _saldoTampil = _saldoAsli - 150;
          
          // Ambil angka dari string berat (misal '45 Liter/Kg' diambil 45)
          int beratHariIni = int.tryParse(_beratLimbah.replaceAll(RegExp(r'[^0-9]'), '')) ?? 15;
          _limbahTerserap = 300 + beratHariIni;
          _co2Dicegah = 1.0 + (beratHariIni * 0.0044); // Simulasi hitungan dampak CO2
        } else {
          _saldoTampil = _saldoAsli;
          _limbahTerserap = 300;
          _co2Dicegah = 1.0;
        }
      });
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('id');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(
                'https://ui-avatars.com/api/?name=Yoga+Nofan&background=E8F5E9&color=2E7D32',
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Text(
                  'Yoga Nofan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              _refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sistem Direset (Mode Demo)')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.green.shade700,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CARD SALDO BARU (SAMA KAYA FIGMA/PROTOTYPE) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F7A44), // Warna hijau solid khas JunksLab
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row Atas: Ikon + Teks Judul Saldo
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saldo JunksPoint',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Angka Saldo Utama
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          numberFormat.format(_saldoTampil),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'JP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Row Bawah: Konversi Rupiah + Tombol Tarik Saldo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Setara Rp ${numberFormat.format(_saldoTampil * 10)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur Tarik Saldo sedang dikembangkan!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text(
                            'Tarik Saldo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- SECTON: KARTU DAMPAK LINGKUNGAN DENGAN BORDER HIJAU TIPIS ---
              Row(
                children: [
                  // Kartu 1: Limbah Terserap
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF0F7A44).withOpacity(0.2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F7A44).withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                            child: const Icon(Icons.recycling, color: Color(0xFF0F7A44), size: 20),
                          ),
                          const SizedBox(height: 12),
                          const Text('Limbah Terserap', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('$_limbahTerserap kg', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Kartu 2: CO2 Dicegah
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF0F7A44).withOpacity(0.2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F7A44).withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
                            child: Icon(Icons.eco_outlined, color: Colors.purple.shade700, size: 20),
                          ),
                          const SizedBox(height: 12),
                          const Text('CO2 Dicegah', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('${_co2Dicegah.toStringAsFixed(1)} ton', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tugas Penjemputan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  TextButton(
                    onPressed: () {},
                    child: Text('Lihat Semua', style: TextStyle(color: Colors.green.shade700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3 WUJUD DASHBOARD
              if (_statusTugas == 'kosong')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Belum ada tugas aktif.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Cari limbah di Marketplace untuk\nmemulai penjemputan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                    ],
                  ),
                )
              else if (_statusTugas == 'aktif')
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DetailPenjemputan()),
                    ).then((_) => _refreshData());
                  },
                  child: CustomLimbahCard(
                    namaPenyedia: _namaPenyedia,
                    jenisLimbah: _namaLimbah,
                    berat: _beratLimbah,
                    lokasi: _lokasiPenyedia,
                    status: 'Menunggu Penjemputan',
                    onAmbil: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DetailPenjemputan()),
                      ).then((_) => _refreshData());
                    },
                  ),
                )
              else if (_statusTugas == 'selesai')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.task_alt, color: Colors.green.shade600, size: 40),
                      const SizedBox(height: 12),
                      const Text('Semua tugas hari ini selesai!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Data telah diverifikasi dan masuk ke riwayat.', style: TextStyle(color: Colors.green.shade800, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}