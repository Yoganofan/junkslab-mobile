import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String hasilScan;

  const SuccessScreen({Key? key, required this.hasilScan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 120),
              const SizedBox(height: 24),
              const Text(
                'Penjemputan Berhasil!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                'Data limbah telah diverifikasi dan masuk ke riwayatmu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade100)
                ),
                child: Column(
                  children: [
                    const Text('Poin Ditukarkan', style: TextStyle(color: Colors.red)),
                    const SizedBox(height: 4),
                    Text(
                      '-150 JunksPoint',
                      style: TextStyle(color: Colors.red.shade800, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Balik ke Dashboard bersih
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Kembali ke Dashboard', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}