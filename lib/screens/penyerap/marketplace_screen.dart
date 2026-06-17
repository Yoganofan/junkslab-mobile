import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketplaceScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const MarketplaceScreen({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Map<String, dynamic>> _limbahList = [];
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Minyak', 'Plastik', 'Organik'];

  @override
  void initState() {
    super.initState();
    _refreshLimbah();
  }

  // READ: Mengambil data dari SQLite
  Future<void> _refreshLimbah() async {
    final data = await DatabaseHelper.instance.getAllLimbah();
    // Filter biar yang tampil di Marketplace cuma yang belum di-scan (misal statusnya Tersedia)
    final limbahTersedia = data
        .where((item) => item['status'] == 'Tersedia')
        .toList();

    setState(() {
      _limbahList = limbahTersedia;
    });
  }

  // CREATE: Tambah Dummy Data buat Demo (3 items sekaligus)
  Future<void> _tambahDataDummy() async {
    final dummyData = [
      {'nama_limbah': 'Minyak Jelantah', 'berat_kg': 15, 'tanggal': DateTime.now().toString(), 'status': 'Tersedia'},
      {'nama_limbah': 'Sisa Sayuran & Buah', 'berat_kg': 45, 'tanggal': DateTime.now().toString(), 'status': 'Tersedia'},
      {'nama_limbah': 'Plastik Bekas Kemasan', 'berat_kg': 20, 'tanggal': DateTime.now().toString(), 'status': 'Tersedia'},
    ];

    for (final item in dummyData) {
      await DatabaseHelper.instance.insertLimbah(item);
    }
    _refreshLimbah();
  }

  Future<void> _ambilLimbah(Map<String, dynamic> limbah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('status_tugas', 'aktif');
    await prefs.setString('tugas_nama', limbah['nama_limbah']);
    await prefs.setString('tugas_berat', '${limbah['berat_kg']} Liter/Kg');

    await prefs.setString('tugas_penyedia', 'Penyedia ${limbah['id']}');
    await prefs.setString(
      'tugas_lokasi',
      'Jl. Bojongsoang No. ${limbah['id']}',
    );

    await DatabaseHelper.instance.deleteLimbah(limbah['id']);
    _refreshLimbah();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Limbah berhasil diajukan! Menuju Dashboard...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF0F7A44),
      ),
    );

    // Auto-switch to Dashboard tab
    Future.delayed(const Duration(milliseconds: 600), () {
      widget.onNavigateToTab?.call(0);
    });
  }

  List<Map<String, dynamic>> get _filteredList {
    var list = _limbahList;
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) =>
        (item['nama_limbah'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    if (_selectedFilter != 'Semua') {
      list = list.where((item) =>
        (item['nama_limbah'] ?? '').toString().toLowerCase().contains(_selectedFilter.toLowerCase())
      ).toList();
    }
    return list;
  }

  IconData _getLimbahIcon(String nama) {
    final lower = nama.toLowerCase();
    if (lower.contains('minyak') || lower.contains('jelantah')) return Icons.water_drop_rounded;
    if (lower.contains('plastik')) return Icons.shopping_bag_rounded;
    if (lower.contains('sayur') || lower.contains('buah') || lower.contains('organik')) return Icons.eco_rounded;
    return Icons.delete_outline_rounded;
  }

  Color _getLimbahColor(String nama) {
    final lower = nama.toLowerCase();
    if (lower.contains('minyak') || lower.contains('jelantah')) return const Color(0xFFE65100);
    if (lower.contains('plastik')) return const Color(0xFF1565C0);
    if (lower.contains('sayur') || lower.contains('buah') || lower.contains('organik')) return const Color(0xFF0F7A44);
    return const Color(0xFF455A64);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Marketplace Limbah',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFF0F7A44), size: 22),
            ),
            onPressed: _tambahDataDummy,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari jenis limbah...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F7A44) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0F7A44) : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Limbah List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshLimbah,
                    color: const Color(0xFF0F7A44),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final limbah = filtered[index];
                        return _buildLimbahCard(limbah);
                      },
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
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F7A44).withValues(alpha: 0.06),
                  ),
                ),
                Icon(Icons.storefront_outlined, size: 32, color: Colors.grey.shade400),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada limbah tersedia',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + di atas untuk menambahkan\ndata dummy (mode demo).',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLimbahCard(Map<String, dynamic> limbah) {
    final nama = limbah['nama_limbah'] ?? 'Limbah';
    final berat = limbah['berat_kg'] ?? 0;
    final id = limbah['id'] ?? 0;
    final icon = _getLimbahIcon(nama);
    final color = _getLimbahColor(nama);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penyedia $id',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Jl. Bojongsoang No. $id',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tersedia',
                  style: TextStyle(
                    color: Color(0xFF0F7A44),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Info row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  '$nama • $berat kg',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  'Hari ini',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Action button
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F7A44), Color(0xFF14A05A)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F7A44).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _ambilLimbah(limbah),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Center(
                      child: Text(
                        'Ambil Koleksi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
