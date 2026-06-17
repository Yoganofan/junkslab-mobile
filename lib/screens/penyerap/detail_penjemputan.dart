import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'qr_scanner_screen.dart';

class DetailPenjemputan extends StatefulWidget {
  const DetailPenjemputan({Key? key}) : super(key: key);

  @override
  State<DetailPenjemputan> createState() => _DetailPenjemputanState();
}

class _DetailPenjemputanState extends State<DetailPenjemputan> {
  String _namaPenyedia = 'Memuat...';
  String _namaLimbah = 'Memuat...';
  String _beratLimbah = 'Memuat...';
  String _lokasi = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadDetailData();
  }

  Future<void> _loadDetailData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaPenyedia =
          prefs.getString('tugas_penyedia') ?? 'Data Tidak Ditemukan';
      _namaLimbah = prefs.getString('tugas_nama') ?? '-';
      _beratLimbah = prefs.getString('tugas_berat') ?? '-';
      _lokasi = prefs.getString('tugas_lokasi') ?? '-';
    });
  }

  void _tampilkanPeringatanScan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Location icon with gradient circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F7A44), Color(0xFF22C55E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.location_on_rounded, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sudah di Lokasi?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              Text(
                'Pastikan Anda telah bertemu dengan penyedia limbah dan berada di lokasi penjemputan sebelum melakukan scan QR Code.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 28),
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
                        color: const Color(0xFF0F7A44).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrScannerScreen(
                              jenisLimbah: _namaLimbah,
                              berat: int.tryParse(_beratLimbah.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                            ),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Ya, Buka Scanner',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Penjemputan',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STEPPER / TIMELINE ---
            _buildStepper(),
            const SizedBox(height: 24),

            // --- PROVIDER INFO CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFDBA74)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.shade600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Menunggu Diambil',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _namaPenyedia,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFF0F7A44), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$_lokasi, Kab. Bandung',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- DETAIL INFO ---
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF0F7A44)),
                const SizedBox(width: 8),
                const Text(
                  'Rincian Informasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.delete_outline_rounded, 'Jenis Limbah', _namaLimbah, const Color(0xFF0F7A44)),
                  Divider(height: 28, color: Colors.grey.shade100),
                  _buildDetailRow(Icons.scale_rounded, 'Volume / Berat', _beratLimbah, const Color(0xFF1565C0)),
                  Divider(height: 28, color: Colors.grey.shade100),
                  _buildDetailRow(Icons.monetization_on_outlined, 'Biaya Penjemputan', '-150 JP', const Color(0xFFEF4444)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- CATATAN ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF1565C0), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Minyak/Limbah sudah siap diangkut di depan lokasi.',
                      style: TextStyle(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- BOTTOM SCAN BUTTON ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F7A44), Color(0xFF14A05A)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F7A44).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _tampilkanPeringatanScan(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Scan QR Penyedia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- STEPPER VISUAL ---
  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepItem('Tugas\nDiterima', true, true),
          _buildStepConnector(true),
          _buildStepItem('Di\nPerjalanan', true, false),
          _buildStepConnector(false),
          _buildStepItem('Scan\nQR Code', false, false),
        ],
      ),
    );
  }

  Widget _buildStepItem(String label, bool isCompleted, bool isFirst) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCompleted
                  ? const LinearGradient(colors: [Color(0xFF0F7A44), Color(0xFF22C55E)])
                  : null,
              color: isCompleted ? null : Colors.grey.shade200,
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.circle_outlined,
              color: isCompleted ? Colors.white : Colors.grey.shade400,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isCompleted ? const Color(0xFF0F7A44) : Colors.grey.shade400,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: isCompleted ? const Color(0xFF22C55E) : Colors.grey.shade200,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: title.contains('Biaya') ? const Color(0xFFEF4444) : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
