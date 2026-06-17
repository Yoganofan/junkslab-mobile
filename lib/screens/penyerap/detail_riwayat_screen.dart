import 'package:flutter/material.dart';

class DetailRiwayatScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailRiwayatScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final namaLimbah = item['nama_limbah'] ?? 'Limbah';
    final beratKg = item['berat_kg'] ?? 0;
    final tanggal = item['tanggal'] ?? '-';
    final status = item['status'] ?? '-';

    // Parse tanggal for display
    String formattedDate = tanggal;
    try {
      final dt = DateTime.parse(tanggal);
      formattedDate = '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    // Simulate CO2 impact
    final co2Impact = (beratKg * 0.0044).toStringAsFixed(2);

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
          'Detail Riwayat',
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
            // --- STATUS BADGE CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F7A44), Color(0xFF22C55E)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    namaLimbah,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, color: Color(0xFF0F7A44), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: const TextStyle(
                            color: Color(0xFF0F7A44),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- DETAIL INFO ---
            _buildSectionLabel('Informasi Penjemputan', Icons.info_outline_rounded),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
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
                  _buildInfoRow(Icons.delete_outline_rounded, 'Jenis Limbah', namaLimbah, const Color(0xFF0F7A44)),
                  _buildDivider(),
                  _buildInfoRow(Icons.scale_rounded, 'Volume / Berat', '$beratKg kg', const Color(0xFF1565C0)),
                  _buildDivider(),
                  _buildInfoRow(Icons.calendar_today_rounded, 'Tanggal', formattedDate, const Color(0xFFE65100)),
                  _buildDivider(),
                  _buildInfoRow(Icons.monetization_on_outlined, 'Biaya Penjemputan', '-150 JP', const Color(0xFFEF4444)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- ENVIRONMENTAL IMPACT ---
            _buildSectionLabel('Dampak Lingkungan', Icons.eco_rounded),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildImpactCard(
                    Icons.cloud_off_rounded,
                    'CO2 Dicegah',
                    '$co2Impact ton',
                    const Color(0xFF7B1FA2),
                    const Color(0xFFF3E5F5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImpactCard(
                    Icons.water_drop_rounded,
                    'Air Diselamatkan',
                    '${beratKg * 1000} L',
                    const Color(0xFF1565C0),
                    const Color(0xFFE3F2FD),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F7A44)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: label.contains('Biaya') ? const Color(0xFFEF4444) : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 24, color: Colors.grey.shade100);
  }

  Widget _buildImpactCard(IconData icon, String label, String value, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
