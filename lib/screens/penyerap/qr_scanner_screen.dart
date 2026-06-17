import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanned = false;
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

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

    try {
      // Masukin data ke SQLite History
      await DatabaseHelper.instance.insertLimbah({
        'nama_limbah': hasilScan, // Biar 'AGOY' atau teks QR lainnya MASUK
        'berat_kg': widget.berat,
        'tanggal': DateTime.now().toString(),
        'status': 'Selesai (Scanned)',
      });

      // --- TAMBAHAN UPDATE STATUS KE DASHBOARD ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('status_tugas', 'selesai');
      // -------------------------------------------
    } catch (e) {
      // Kalau error atau beku, cuekin aja biar aplikasinya tetep jalan pas demo!
      debugPrint('Abaikan error DB saat scan: $e');
    }

    if (!mounted) return;

    // Paksa pindah ke halaman Sukses
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: MobileScannerController(
              formats: const [BarcodeFormat.qrCode],
              detectionSpeed: DetectionSpeed.normal,
            ),
            onDetect: _onDetect,
          ),

          // Darkened overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.red, // This color doesn't matter
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Animated scan frame corners
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  // Corner decorations
                  ..._buildCorners(),
                  // Animated scan line
                  AnimatedBuilder(
                    animation: _scanLineController,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanLineController.value * 240 + 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFF22C55E).withValues(alpha: 0.8),
                                const Color(0xFF22C55E),
                                const Color(0xFF22C55E).withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Arahkan kamera ke QR Code penyedia',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Simulasi button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F7A44), Color(0xFF14A05A)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F7A44).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _prosesDataSukses('BYPASS-DATA-JUNKSLAB-001'),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Simulasi Berhasil Scan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const cornerSize = 30.0;
    const thickness = 4.0;
    const color = Color(0xFF22C55E);

    return [
      // Top-left
      Positioned(
        top: 0, left: 0,
        child: SizedBox(
          width: cornerSize, height: cornerSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: thickness),
                left: BorderSide(color: color, width: thickness),
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
            ),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: 0, right: 0,
        child: SizedBox(
          width: cornerSize, height: cornerSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: thickness),
                right: BorderSide(color: color, width: thickness),
              ),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(16)),
            ),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0, left: 0,
        child: SizedBox(
          width: cornerSize, height: cornerSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: thickness),
                left: BorderSide(color: color, width: thickness),
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16)),
            ),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0, right: 0,
        child: SizedBox(
          width: cornerSize, height: cornerSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: thickness),
                right: BorderSide(color: color, width: thickness),
              ),
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
          ),
        ),
      ),
    ];
  }
}
