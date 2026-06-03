import 'package:flutter/material.dart';

class DetailPenjemputan extends StatefulWidget {
  const DetailPenjemputan({Key? key}) : super(key: key);

  @override
  State<DetailPenjemputan> createState() => _DetailPenjemputanState();
}

class _DetailPenjemputanState extends State<DetailPenjemputan> {
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penjemputan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Konten Detail (Bisa kamu kembangkan pakai Card seperti di UI)
            const Text('Informasi Penyedia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Nama: Budi Santoso\nLokasi: Bojongsoang, Kab. Bandung'),
            const Spacer(),
            
            // CUSTOM WIDGET & GESTURE (Swipe to Confirm)
            _isConfirmed
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Penjemputan Berhasil Terkonfirmasi!',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                : Dismissible(
                    key: const Key('confirm_slider'),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      setState(() {
                        _isConfirmed = true;
                      });
                      // Di sini nanti bisa panggil fungsi update status ke SQLite
                    },
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward_ios, color: Colors.green, size: 16),
                          Icon(Icons.arrow_forward_ios, color: Colors.green, size: 16),
                          SizedBox(width: 10),
                          Text(
                            'Geser ke kanan untuk Konfirmasi',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}