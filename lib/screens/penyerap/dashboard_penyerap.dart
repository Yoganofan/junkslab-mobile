import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_limbah_card.dart';
import 'detail_penjemputan.dart';

class DashboardPenyerap extends StatelessWidget {
  const DashboardPenyerap({Key? key}) : super(key: key);

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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Yoga+Nofan&background=E8F5E9&color=2E7D32'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Text('Yoga Nofan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade800, Colors.green.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Saldo JunksPoint', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('${numberFormat.format(12450)} JP', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.trending_down, color: Colors.red.shade200, size: 16),
                      const SizedBox(width: 4),
                      // Logika Pengeluaran Poin
                      Text('-150 JP hari ini', style: TextStyle(color: Colors.red.shade100, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tugas Penjemputan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                TextButton(
                  onPressed: () {}, 
                  child: Text('Lihat Semua', style: TextStyle(color: Colors.green.shade700)),
                )
              ],
            ),
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailPenjemputan()));
              },
              child: CustomLimbahCard(
                namaPenyedia: 'Warung Makmur (Cabang Bojongsoang)',
                jenisLimbah: 'Minyak Jelantah',
                berat: '15 Liter',
                lokasi: 'Jl. Terusan Buah Batu No. 45',
                status: 'Menunggu Diambil',
                onAmbil: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailPenjemputan()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}