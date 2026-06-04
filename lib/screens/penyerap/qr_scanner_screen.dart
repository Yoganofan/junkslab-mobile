import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../helpers/database_helper.dart';
import 'success_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final String jenisLimbah;
  final int berat;
  const QrScannerScreen({
    Key? key,
    required this.jenisLimbah,
    required this.berat,
  }) : super(key: key);
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _prosesDataSukses(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _prosesDataSukses(String hasilScan) async {
    setState(() => _isScanned = true);

    // Murni masuk ke SQLite yang sudah diperbaiki!
    await DatabaseHelper.instance.insertLimbah({
      'nama_limbah': widget.jenisLimbah,
      'berat_kg': widget.berat,
      'tanggal': DateTime.now().toString(),
      'status': 'Selesai (Scanned)',
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(hasilScan: hasilScan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arahkan ke QR Penyedia',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              formats: const [BarcodeFormat.qrCode],
              detectionSpeed: DetectionSpeed.normal,
            ),
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const Text(
                  'Pastikan QR Code di dalam kotak',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Simulasi Berhasil Scan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () =>
                      _prosesDataSukses('BYPASS-DATA-JUNKSLAB-001'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
