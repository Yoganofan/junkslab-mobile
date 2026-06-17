import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import 'detail_riwayat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Fungsi penarik data super kebal (Pakai Batas Waktu / Timeout)
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      // Kita kasih waktu maksimal 2 detik. Kalau nyangkut, paksa lompat ke error!
      final data = await DatabaseHelper.instance.getAllLimbah().timeout(
        const Duration(seconds: 2),
      );

      // --- INI LOGIKA FILTERNYA ---
      // Cuma ambil data yang statusnya beneran udah di-scan
      final riwayatAsli = data.where((item) => item['status'] == 'Selesai (Scanned)').toList();

      if (mounted) {
        setState(() {
          // Masukin data yang udah difilter ke list tampilan
          _historyList = riwayatAsli;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Database nyangkut / Error: $e');
      // Matikan loading paksa
      if (mounted) {
        setState(() {
          _historyList = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _hapusRiwayat(int id) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Riwayat?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'Data riwayat ini akan dihapus secara permanen.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await DatabaseHelper.instance.deleteLimbah(id);
      _loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Riwayat berhasil dihapus'),
            backgroundColor: const Color(0xFF333333),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Abaikan Hapus Error SQLite Web: $e');
    }
  }

  int get _totalBerat {
    int total = 0;
    for (final item in _historyList) {
      total += (item['berat_kg'] as int?) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Riwayat Penjemputan',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F7A44)))
          : _historyList.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: const Color(0xFF0F7A44),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      // Summary stats
                      _buildSummaryRow(),
                      const SizedBox(height: 20),

                      // Timeline list
                      ..._historyList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isLast = index == _historyList.length - 1;
                        return _buildTimelineItem(item, isLast);
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _buildSummaryCard(
          Icons.assignment_turned_in_rounded,
          '${_historyList.length}',
          'Total Selesai',
          const Color(0xFF0F7A44),
          const Color(0xFFE8F5E9),
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          Icons.scale_rounded,
          '$_totalBerat kg',
          'Total Berat',
          const Color(0xFF1565C0),
          const Color(0xFFE3F2FD),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(IconData icon, String value, String label, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, bool isLast) {
    final nama = item['nama_limbah'] ?? 'Limbah';
    final berat = item['berat_kg'] ?? 0;
    String formattedDate = '-';
    try {
      final dt = DateTime.parse(item['tanggal'] ?? '');
      formattedDate = '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {}

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F7A44), Color(0xFF22C55E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFF0F7A44).withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailRiwayatScreen(item: item),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$berat kg • $formattedDate',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delete & arrow
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 20),
                      onPressed: () => _hapusRiwayat(item['id']),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F7A44).withValues(alpha: 0.08),
                  ),
                ),
                Icon(Icons.history_toggle_off_rounded, size: 36, color: Colors.grey.shade400),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada riwayat penjemputan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat akan muncul setelah kamu\nmenyelesaikan penjemputan limbah.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}