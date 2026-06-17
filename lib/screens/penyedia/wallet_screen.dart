import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF5),
        elevation: 0,
        title: const Text('Dompet Sirkular', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: Colors.black))
        ],
      ),
      // MEMBUNGKUS BODY DENGAN LISTENABLE BUILDER
      body: ListenableBuilder(
        listenable: walletState, // Menghubungkan ke otak global
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Wallet Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF006B23), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total JunksPoint', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Icon(Icons.account_balance_wallet, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          // ANGKA DIAMBIL DARI STATE!
                          Text(walletState.totalJunksPoint.toInt().toString(), 
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 4),
                          const Text('JP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // ... (KODE TOMBOL TOPUP & REDEEM TETAP SAMA) ...
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Impact Bento Group
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100, padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.co2, color: Color(0xFF006B23)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ANGKA DIAMBIL DARI STATE!
                                Text(walletState.co2Saved.toStringAsFixed(1), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006B23))),
                                const Text('kg CO2 Saved', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 100, padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.recycling, color: Color(0xFF006B23)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ANGKA DIAMBIL DARI STATE!
                                Text(walletState.totalLimbah.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006B23))),
                                const Text('Limbah Disalurkan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text('Riwayat Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // MELOOPING DATA HISTORY DARI STATE
                ...walletState.riwayatTransaksi.map((item) {
                  bool isIncome = item['type'] == 'in';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), shape: BoxShape.circle),
                          child: Icon(item['icon'], color: isIncome ? const Color(0xFF006B23) : Colors.red, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(item['date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(item['amount'], style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? const Color(0xFF006B23) : Colors.red)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }
      ),
    );
  }
}

final walletState = WalletState(); // Singleton yang bisa dipanggil dari layar mana saja

class WalletState extends ChangeNotifier {
  double totalJunksPoint = 12840.0;
  double co2Saved = 42.5;
  int totalLimbah = 128;

  // Data History awal
  List<Map<String, dynamic>> riwayatTransaksi = [
    {"title": "Setor Limbah 2.5 kg", "date": "14 Jun 2026", "type": "in", "amount": "+375 JP", "icon": Icons.recycling},
    {"title": "Tukar Voucher Ongkir", "date": "12 Jun 2026", "type": "out", "amount": "-1500 JP", "icon": Icons.local_activity},
  ];

  // Fungsi saat Bypass Ditekan
  void prosesBypass(double beratLimbah, String idTransaksi) {
    int earnedJP = (beratLimbah * 150).toInt(); // 1 kg = 150 JP
    
    totalJunksPoint += earnedJP;
    co2Saved += (beratLimbah * 0.5);
    totalLimbah += 1;

    // Menambahkan riwayat baru di urutan paling atas (index 0)
    riwayatTransaksi.insert(0, {
      "title": "Setor Limbah $beratLimbah kg (TRX-$idTransaksi)",
      "date": "Hari Ini", // Bisa diganti format tanggal dinamis nanti
      "type": "in",
      "amount": "+$earnedJP JP",
      "icon": Icons.recycling
    });

    // Ini kunci sihirnya: Menyuruh semua layar yang terhubung untuk REFRESH!
    notifyListeners(); 
  }
}