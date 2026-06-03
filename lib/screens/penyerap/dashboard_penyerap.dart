import 'package:flutter/material.dart';
import '../../widgets/custom_limbah_card.dart';

class DashboardPenyerap extends StatelessWidget {
  const DashboardPenyerap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.person, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Penyerap',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
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
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Saldo JunksPoint
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade800, Colors.green.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Saldo JunksPoint',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '12,450 JP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Limbah Tersedia Terdekat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Menggunakan Custom Widget Limbah Card
            CustomLimbahCard(
              namaPenyedia: 'Warung Makmur',
              jenisLimbah: 'Sisa Makanan',
              berat: '15 kg',
              lokasi: 'Jl. Melati No. 45, Jakarta',
              status: 'Tersedia',
              onAmbil: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Memproses penjemputan limbah...'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
