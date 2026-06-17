import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/shared_pref_helper.dart';

import 'detail_penjemputan.dart';
import 'notifikasi_screen.dart';
import 'statistik_screen.dart';

class DashboardPenyerap extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const DashboardPenyerap({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  State<DashboardPenyerap> createState() => _DashboardPenyerapState();
}

class _DashboardPenyerapState extends State<DashboardPenyerap>
    with TickerProviderStateMixin {
  int _saldoAsli = 12450;
  int _saldoTampil = 12450;

  String _statusTugas = 'kosong';
  String _namaLimbah = '';
  String _beratLimbah = '';
  String _namaPenyedia = '';
  String _lokasiPenyedia = '';

  // --- VARIABEL STATISTIK DAMPAK (PERSISTED) ---
  int _limbahTerserap = 300;
  double _co2Dicegah = 1.0;
  int _totalTransaksi = 12;

  // --- ANIMATION CONTROLLERS ---
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for active task indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    _refreshData();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final prefs = await SharedPreferences.getInstance();
    final points = await SharedPrefHelper.getJunksPoint();
    final limbah = await SharedPrefHelper.getLimbahTerserap();
    final transaksi = await SharedPrefHelper.getTotalTransaksi();
    final co2Cents = await SharedPrefHelper.getCo2DicegahCents();

    setState(() {
      _saldoAsli = points;
      _saldoTampil = points;
      _statusTugas = prefs.getString('status_tugas') ?? 'kosong';
      _namaLimbah = prefs.getString('tugas_nama') ?? 'Minyak Jelantah';
      _beratLimbah = prefs.getString('tugas_berat') ?? '15 Liter';
      
      _namaPenyedia = prefs.getString('tugas_penyedia') ?? 'Menunggu Data...';
      _lokasiPenyedia = prefs.getString('tugas_lokasi') ?? 'Menunggu lokasi...';

      // Read persisted stats directly — these are updated by QR scanner on completion
      _limbahTerserap = limbah;
      _totalTransaksi = transaksi;
      _co2Dicegah = co2Cents / 100.0;
    });
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF0F7A44),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SALDO CARD PREMIUM ---
              _buildSaldoCard(numberFormat),

              const SizedBox(height: 24),

              // --- 2. QUICK ACTION BUTTONS ---
              _buildQuickActions(),

              const SizedBox(height: 28),

              // --- 3. DAMPAK LINGKUNGAN CARDS ---
              _buildSectionLabel('Dampak Lingkunganmu', Icons.eco_rounded),
              const SizedBox(height: 14),
              _buildDampakCards(numberFormat),

              const SizedBox(height: 28),

              // --- 4. TUGAS PENJEMPUTAN HEADER + CARDS ---
              _buildTugasHeader(),
              const SizedBox(height: 14),
              _buildTugasContent(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APPBAR — Upgraded with notification badge & online indicator
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 70,
      titleSpacing: 20,
      iconTheme: Theme.of(context).iconTheme,
      title: Row(
        children: [
          // Long-press avatar to reset demo data
          GestureDetector(
            onLongPress: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              _refreshData();
              if (!mounted) return;
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: const Text('Sistem Direset (Mode Demo)'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFF333333),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0F7A44).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=Yoga+Nofan&background=E8F5E9&color=2E7D32',
                    ),
                  ),
                ),
                // Green online dot
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF4F7F4), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Yoga Nofan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Notification button with red badge dot
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: Theme.of(context).iconTheme.color ?? const Color(0xFF1A1A1A),
                  size: 26,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
                  );
                },
              ),
              // Red notification dot
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF4F7F4), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 1. SALDO CARD — Gradient Premium + Decorative Circles
  // ============================================================
  Widget _buildSaldoCard(NumberFormat numberFormat) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A5C32),
            Color(0xFF0F7A44),
            Color(0xFF14A05A),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0F7A44).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 60,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row Atas: Ikon + Teks Judul Saldo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Saldo JunksPoint',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Angka Saldo Utama with AnimatedSwitcher
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      key: ValueKey<int>(_saldoTampil),
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          numberFormat.format(_saldoTampil),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'JP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Row Bawah: Konversi Rupiah + Tombol Tarik Saldo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.swap_horiz_rounded,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Setara Rp ${numberFormat.format(_saldoTampil * 10)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Glassmorphism Tarik Saldo button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Fitur Tarik Saldo sedang dikembangkan!'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: const Color(0xFF333333),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_upward_rounded,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Tarik Saldo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 2. QUICK ACTION BUTTONS
  // ============================================================
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem(
          Icons.search_rounded, 'Cari Limbah',
          const Color(0xFF0F7A44), const Color(0xFFE8F5E9),
          () => widget.onNavigateToTab?.call(1), // Navigate to Marketplace tab
        ),
        _buildQuickActionItem(
          Icons.assignment_outlined, 'Riwayat',
          const Color(0xFF1565C0), const Color(0xFFE3F2FD),
          () => widget.onNavigateToTab?.call(2), // Navigate to History tab
        ),
        _buildQuickActionItem(
          Icons.bar_chart_rounded, 'Statistik',
          const Color(0xFFE65100), const Color(0xFFFFF3E0),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StatistikScreen()),
          ),
        ),
        _buildQuickActionItem(
          Icons.monetization_on_outlined, 'Tukar Poin',
          const Color(0xFF7B1FA2), const Color(0xFFF3E5F5),
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Tukar Poin — Segera hadir!'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: const Color(0xFF333333),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color iconColor, Color bgColor, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                    letterSpacing: -0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 3. DAMPAK LINGKUNGAN CARDS — Animated + 3 Cards
  // ============================================================
  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F7A44)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDampakCards(NumberFormat numberFormat) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildDampakCard(
            icon: Icons.recycling_rounded,
            iconGradientColors: [const Color(0xFF0F7A44), const Color(0xFF22C55E)],
            label: 'Limbah Terserap',
            targetValue: _limbahTerserap,
            unit: 'kg',
            bgAccent: const Color(0xFFE8F5E9),
          ),
          const SizedBox(width: 12),
          _buildDampakCard(
            icon: Icons.cloud_off_rounded,
            iconGradientColors: [const Color(0xFF7B1FA2), const Color(0xFFAB47BC)],
            label: 'CO2 Dicegah',
            targetValue: (_co2Dicegah * 10).round(), // display as 10, 10.6 etc
            unit: 'ton',
            bgAccent: const Color(0xFFF3E5F5),
            isDecimal: true,
            decimalValue: _co2Dicegah,
          ),
          const SizedBox(width: 12),
          _buildDampakCard(
            icon: Icons.handshake_rounded,
            iconGradientColors: [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
            label: 'Transaksi Bulan Ini',
            targetValue: _totalTransaksi,
            unit: 'kali',
            bgAccent: const Color(0xFFE3F2FD),
          ),
        ],
      ),
    );
  }

  Widget _buildDampakCard({
    required IconData icon,
    required List<Color> iconGradientColors,
    required String label,
    required int targetValue,
    required String unit,
    required Color bgAccent,
    bool isDecimal = false,
    double? decimalValue,
  }) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bgAccent, width: 1.5),
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
          // Gradient icon container
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: iconGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          // Animated counting number
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: targetValue),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              String displayValue;
              if (isDecimal && decimalValue != null) {
                double ratio = value / targetValue;
                displayValue = (decimalValue * ratio).toStringAsFixed(1);
              } else {
                displayValue = value.toString();
              }
              return Text(
                '$displayValue $unit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. TUGAS PENJEMPUTAN HEADER — Badge Counter
  // ============================================================
  Widget _buildTugasHeader() {
    int badgeCount = _statusTugas == 'aktif' ? 1 : 0;
    bool isComplete = _statusTugas == 'selesai';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
            const Icon(Icons.local_shipping_rounded, size: 18, color: Color(0xFF0F7A44)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Tugas Penjemputan',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Animated badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isComplete
                    ? const Color(0xFF22C55E)
                    : badgeCount > 0
                        ? const Color(0xFFEF4444)
                        : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isComplete ? '✓' : '$badgeCount',
                style: TextStyle(
                  color: isComplete || badgeCount > 0 ? Colors.white : Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              color: Color(0xFF0F7A44),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 5. TASK CARDS — 3 States: kosong, aktif, selesai
  // ============================================================
  Widget _buildTugasContent() {
    if (_statusTugas == 'kosong') {
      return _buildEmptyState();
    } else if (_statusTugas == 'aktif') {
      return _buildActiveTask();
    } else if (_statusTugas == 'selesai') {
      return _buildCompletedTask();
    }
    return const SizedBox.shrink();
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Custom illustration: stacked icons
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
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0F7A44).withValues(alpha: 0.08),
                        Color(0xFF22C55E).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0F7A44).withValues(alpha: 0.08),
                  ),
                ),
                Icon(
                  Icons.inbox_outlined,
                  size: 32,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada tugas aktif.',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              fontSize: 16,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cari limbah di Marketplace untuk\nmemulai penjemputan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // CTA Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F7A44), Color(0xFF14A05A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF0F7A44).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Buka tab Marketplace untuk mencari limbah!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: const Color(0xFF333333),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Cari di Marketplace',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ACTIVE TASK with pulsing dot & left accent ---
  Widget _buildActiveTask() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetailPenjemputan()),
        ).then((_) => _refreshData());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF0F7A44).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(
                  width: 5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0F7A44), Color(0xFF22C55E)],
                    ),
                  ),
                ),
                // Card content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Name + Status with pulsing dot
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _namaPenyedia,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFDBA74),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Pulsing dot
                                  AnimatedBuilder(
                                    animation: _pulseAnimation!,
                                    builder: (context, child) {
                                      return Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.orange.shade600.withValues(
                                            alpha: _pulseAnimation!.value,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Menunggu',
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Waste info
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAF8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFF0F7A44)),
                              const SizedBox(width: 8),
                              Text(
                                '$_namaLimbah • $_beratLimbah',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Location
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 15, color: Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _lokasiPenyedia,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Button
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
                                  color: Color(0xFF0F7A44).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const DetailPenjemputan()),
                                  ).then((_) => _refreshData());
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  child: Center(
                                    child: Text(
                                      'Lihat Detail Penjemputan',
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- COMPLETED TASK with decorative elements ---
  Widget _buildCompletedTask() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF22C55E).withValues(alpha: 0.08),
            Color(0xFF0F7A44).withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Color(0xFF22C55E).withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative circles (confetti-like)
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF22C55E).withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 5,
              left: 30,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F7A44).withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: 15,
              right: 70,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF22C55E).withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 40,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F7A44).withValues(alpha: 0.07),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Success checkmark
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F7A44), Color(0xFF22C55E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF22C55E).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Semua tugas hari ini selesai!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A),
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Data telah diverifikasi dan masuk ke riwayat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F7A44).withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Completed badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF22C55E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, color: Color(0xFF0F7A44), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Terverifikasi',
                          style: TextStyle(
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
          ],
        ),
      ),
    );
  }
}